import 'package:pos_app/app_settings/app_settings_model.dart';

/// Data extracted from a weighing-scale barcode.
class ParsedScaleData {
  final String productCode;
  final double parsedValue;

  /// true  → parsedValue is a price; quantity = parsedValue / product.price
  /// false → parsedValue is a weight/quantity; use it directly
  final bool isPrice;

  const ParsedScaleData({
    required this.productCode,
    required this.parsedValue,
    required this.isPrice,
  });
}

/// Attempts to decode [barcode] as a scale-printed barcode.
///
/// Format assumed:
///   [prefix][codeLength digits][5 value digits][1 check digit]
///
/// Example (prefix "21", codeLength 5, decimalPlaces 3):
///   "21" + "12345" + "01234" + "5"  →  code "12345", value 1.234
///
/// Returns null when:
/// • [Scale.Barcode.Enabled] is not 'true'
/// • The barcode does not start with the configured prefix
/// • The barcode body is shorter than codeLength + 6 characters
/// • The 5-digit value segment is not numeric
ParsedScaleData? parseScaleBarcode(
  String barcode,
  Map<String, String> settings,
) {
  if (settings[SettingKeys.scaleBarcodeEnabled]?.toLowerCase() != 'true') {
    return null;
  }

  final prefix = settings[SettingKeys.scaleBarcodePrefix] ?? '';
  if (prefix.isNotEmpty && !barcode.startsWith(prefix)) return null;

  final body = barcode.substring(prefix.length);

  final codeLen =
      (int.tryParse(settings[SettingKeys.scaleBarcodeCodeLength] ?? '5') ?? 5)
          .clamp(1, 20);
  final decPlaces =
      (int.tryParse(
                settings[SettingKeys.scaleBarcodeDecimalPlaces] ?? '3',
              ) ??
              3)
          .clamp(0, 5);
  final trimZeros =
      settings[SettingKeys.scaleBarcodeTrimZeros]?.toLowerCase() != 'false';
  final isPrice =
      settings[SettingKeys.scaleBarcodePrintsPrice]?.toLowerCase() == 'true';

  // Need at least: codeLen product digits + 5 value digits + 1 check digit
  if (body.length < codeLen + 6) return null;

  // Extract and optionally trim the product code
  String productCode = body.substring(0, codeLen);
  if (trimZeros) productCode = productCode.replaceAll(RegExp(r'^0+'), '');
  if (productCode.isEmpty) return null;

  // Extract the 5-digit value (the trailing character is the check digit)
  final valueStr = body.substring(codeLen, codeLen + 5);
  final rawValue = int.tryParse(valueStr);
  if (rawValue == null) return null;

  final parsedValue = rawValue / _pow10(decPlaces);

  return ParsedScaleData(
    productCode: productCode,
    parsedValue: parsedValue,
    isPrice: isPrice,
  );
}

int _pow10(int exp) {
  var r = 1;
  for (var i = 0; i < exp; i++) {
    r *= 10;
  }
  return r;
}
