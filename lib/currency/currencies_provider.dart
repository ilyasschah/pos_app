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

/// Reads the stored currency code/symbol from app settings and converts it to
/// a display symbol using the Currency model's symbol getter.
/// Stored value may be a code (USD, EUR, MAD) or a legacy literal ($, €).
final currencySymbolProvider = Provider<String>((ref) {
  final stored =
      ref.watch(appSettingsProvider)[SettingKeys.currencySymbol] ?? '\$';
  final temp = Currency(id: 0, name: stored, code: stored);
  return temp.symbol;
});
