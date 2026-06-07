import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/database/app_database.dart';
import 'package:pos_app/database/database_provider.dart';
import 'package:pos_app/app_settings/app_settings_model.dart';
import 'package:pos_app/app_settings/service_type_model.dart';
import 'package:pos_app/app_settings/service_status_model.dart';
import 'package:pos_app/app_settings/booking_settings_model.dart';
import 'package:pos_app/sync/sync_provider.dart';

/// Streamed from Drift instead of fetched per build. The previous FutureProvider
/// hit `/ApplicationProperties/GetAll` and silently swallowed errors — but
/// Riverpod 3's automatic retry timer kept re-scheduling the failed fetch in
/// the background. With multiple offline-failing FutureProviders, two retry
/// timers could race and trip the "Only one task can be scheduled at a time"
/// assertion in ProviderScope.
///
/// Drift streams don't fail and don't retry, so the storm dies. The SyncManager
/// keeps the rows fresh via `pullAppProperties` whenever network returns.
final rawAppPropertiesProvider =
    StreamProvider.autoDispose<List<AppProperty>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final companyId = ref.watch(selectedCompanyProvider)?.id;
  if (companyId == null) return Stream.value(const []);

  final query = db.select(db.appPropertiesTable)
    ..where((t) => t.companyId.equals(companyId));

  return query.watch().map((rows) => rows.map(AppProperty.fromDrift).toList());
});

class AppSettingsNotifier extends Notifier<Map<String, String>> {
  // Optimistic writes survive build() re-runs triggered by rawAppPropertiesProvider
  // reloads, preventing theme/setting flashes when any setting is saved.
  final Map<String, String> _pendingOverrides = {};

  @override
  Map<String, String> build() {
    final map = Map<String, String>.from(kSettingDefaults);

    // In Riverpod 3.x, setting `state` inside a fireImmediately listener during
    // build() violates the "one task at a time" scheduler rule. Use ref.watch so
    // Riverpod re-runs build() whenever the async source resolves, instead.
    final rawProps = ref.watch(rawAppPropertiesProvider);
    rawProps.whenData((props) {
      for (final p in props) {
        map[p.name] = p.value;
      }
    });

    // Re-apply any optimistic writes so the theme/settings don't flash back to
    // defaults while rawAppPropertiesProvider is reloading after a save.
    map.addAll(_pendingOverrides);

    return map;
  }

  String get(String key) => state[key] ?? kSettingDefaults[key] ?? '';

  bool getBool(String key) => get(key).toLowerCase() == 'true';

  bool get serviceTypeEnabled =>
      getBool(SettingKeys.featureServiceTypeEnabled);

  String get serviceTypePack =>
      get(SettingKeys.appServiceTypePack).isNotEmpty
          ? get(SettingKeys.appServiceTypePack)
          : 'Restaurant';

  bool get serviceStatusEnabled =>
      getBool(SettingKeys.featureServiceStatusEnabled);

  String get serviceStatusPack =>
      get(SettingKeys.appServiceStatusPack).isNotEmpty
          ? get(SettingKeys.appServiceStatusPack)
          : 'Restaurant';

  List<CustomServiceType> get customServiceTypes =>
      CustomServiceType.listFromJson(get(SettingKeys.customServiceTypes));

  List<CustomServiceStatus> get customServiceStatuses =>
      CustomServiceStatus.listFromJson(get(SettingKeys.customServiceStatuses));

  BookingSettingsModel get bookingSettings =>
      BookingSettingsModel.fromJsonStr(get(SettingKeys.bookingSettings));

  Future<void> setBookingSettings(BookingSettingsModel value) =>
      set(SettingKeys.bookingSettings, value.toJsonStr());

  Future<void> set(String key, String value) async {
    _pendingOverrides[key] = value;
    state = {...state, key: value};

    final company = ref.read(selectedCompanyProvider);
    if (company == null) return;

    final dio = createDio();
    final db = ref.read(appDatabaseProvider);
    final props = ref.read(rawAppPropertiesProvider).value ?? [];
    final existing = _findProp(props, key);

    // Optimistic Drift write — for EXISTING settings, where we have a stable
    // server id to upsert against. The Drift stream re-emits immediately so
    // anything else watching rawAppPropertiesProvider (theme, menu options
    // that toggle on settings) reacts without waiting for the API round-trip
    // + pullAppProperties.
    //
    // Stamp `lastModified` with `now.toUtc()` so the next pullAppProperties
    // sees local > server and respects the user's just-made change (the
    // existing per-key timestamp guard in SyncManager._pullAppProperties).
    if (existing != null) {
      await db.into(db.appPropertiesTable).insertOnConflictUpdate(
            AppPropertiesTableCompanion(
              id: Value(existing.id),
              companyId: Value(company.id),
              name: Value(key),
              value: Value(value),
              lastModified: Value(DateTime.now().toUtc()),
            ),
          );
    }

    try {
      if (existing != null) {
        await dio.patch(
          '/ApplicationProperties/Update',
          queryParameters: {'companyId': company.id},
          data: {'id': existing.id, 'newValue': value},
        );
      } else {
        await dio.post(
          '/ApplicationProperties/Add',
          queryParameters: {'companyId': company.id},
          data: {'name': key, 'value': value},
        );
        // New settings have no stable id yet — pull so the row lands in
        // Drift with the server-assigned id. Best-effort: a failure here
        // just means the UI reflects state until the next manual sync.
        try {
          await ref.read(syncManagerProvider).pullAppProperties(company.id);
        } catch (_) {/* deferred to next sync */}
      }
    } on DioException {
      _pendingOverrides.remove(key);
      final prev = existing?.value ?? kSettingDefaults[key] ?? '';
      state = {...state, key: prev};

      // Revert the optimistic Drift write so the cache stays consistent
      // with the server's actual rejection. New-setting failures have no
      // Drift row to revert (we never wrote one).
      if (existing != null) {
        await db.into(db.appPropertiesTable).insertOnConflictUpdate(
              AppPropertiesTableCompanion(
                id: Value(existing.id),
                companyId: Value(company.id),
                name: Value(key),
                value: Value(existing.value),
                lastModified: Value(DateTime.now().toUtc()),
              ),
            );
      }
      // Swallow — state and Drift are already reverted above. Callers in
      // the settings UI don't handle exceptions, so rethrowing would surface
      // as an unhandled crash. The sync manager will retry when online.
    }
  }

  Future<void> setBool(String key, bool value) =>
      set(key, value ? 'true' : 'false');

  AppProperty? _findProp(List<AppProperty> props, String key) {
    try {
      return props.firstWhere((p) => p.name == key);
    } catch (_) {
      return null;
    }
  }
}

final appSettingsProvider =
    NotifierProvider<AppSettingsNotifier, Map<String, String>>(
      () => AppSettingsNotifier(),
    );
