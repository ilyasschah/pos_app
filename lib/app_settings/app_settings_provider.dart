import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/app_settings/app_settings_model.dart';

final rawAppPropertiesProvider = FutureProvider.autoDispose<List<AppProperty>>((
  ref,
) async {
  final company = ref.watch(selectedCompanyProvider);
  if (company == null) return [];

  try {
    final dio = createDio();
    final response = await dio.get(
      '/ApplicationProperties/GetAll',
      queryParameters: {'companyId': company.id},
    );
    return (response.data as List).map((j) => AppProperty.fromJson(j)).toList();
  } catch (_) {
    return [];
  }
});

class AppSettingsNotifier extends Notifier<Map<String, String>> {
  @override
  Map<String, String> build() {
    final map = Map<String, String>.from(kSettingDefaults);

    ref.listen<AsyncValue<List<AppProperty>>>(rawAppPropertiesProvider, (
      _,
      next,
    ) {
      next.whenData((props) {
        for (final p in props) {
          map[p.name] = p.value;
        }
        state = Map<String, String>.from(map);
      });
    }, fireImmediately: true);

    return map;
  }

  String get(String key) => state[key] ?? kSettingDefaults[key] ?? '';

  bool getBool(String key) => get(key).toLowerCase() == 'true';

  List<String> get activeOrderTypes {
    try {
      final raw = state[SettingKeys.appActiveOrderTypes] ??
          kSettingDefaults[SettingKeys.appActiveOrderTypes] ??
          '';
      if (raw.isEmpty) return ['Dine-In', 'Takeaway'];
      return (jsonDecode(raw) as List).cast<String>();
    } catch (_) {
      return ['Dine-In', 'Takeaway'];
    }
  }

  List<Map<String, dynamic>> get serviceStatuses {
    try {
      final raw = state[SettingKeys.appServiceStatuses] ??
          kSettingDefaults[SettingKeys.appServiceStatuses] ??
          '';
      if (raw.isEmpty) return [];
      return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  Future<void> set(String key, String value) async {
    state = {...state, key: value};

    final company = ref.read(selectedCompanyProvider);
    if (company == null) return;

    final dio = createDio();
    final props = ref.read(rawAppPropertiesProvider).value ?? [];
    final existing = _findProp(props, key);

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
      }
      ref.invalidate(rawAppPropertiesProvider);
    } on DioException {
      final prev = existing?.value ?? kSettingDefaults[key] ?? '';
      state = {...state, key: prev};
      rethrow;
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
