import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/currency/currency_model.dart';
import 'package:pos_app/app_settings/app_settings_model.dart';
import 'package:pos_app/app_settings/app_settings_provider.dart';

final currenciesProvider = FutureProvider<List<Currency>>((ref) async {
  try {
    final dio = createDio();
    final response = await dio.get('/Currencies/GetAll');
    return (response.data as List).map((j) => Currency.fromJson(j)).toList();
  } catch (_) {
    return [];
  }
});

final currencySymbolProvider = Provider<String>((ref) {
  return ref.watch(appSettingsProvider)[SettingKeys.currencySymbol] ?? '\$';
});
