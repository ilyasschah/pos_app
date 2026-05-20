import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pos_app/auth/user_model.dart';
import 'package:pos_app/cart/checkout_models.dart';
import 'package:pos_app/company/company_model.dart';
import 'package:pos_app/printer/printer_selection_model.dart';
import 'package:pos_app/printer/printer_selection_settings_model.dart';
import 'package:pos_app/reports/z_report_model.dart';
import 'package:printing/printing.dart';

class ReceiptPrinterService {
  // ── Settings helpers ──────────────────────────────────────────────────────

  static PdfPageFormat _paperFmt(String? size) =>
      size == '58mm' ? PdfPageFormat.roll57 : PdfPageFormat.roll80;

  static pw.EdgeInsets _margins(Map<String, String> s, String role) {
    double mm(String key) =>
        (double.tryParse(s['$role.$key'] ?? '') ?? 3) * PdfPageFormat.mm;
    return pw.EdgeInsets.only(
      top: mm('MarginTop'),
      bottom: mm('MarginBottom'),
      left: mm('MarginLeft'),
      right: mm('MarginRight'),
    );
  }

  static int _copies(Map<String, String> s, String role) {
    final v = int.tryParse(s['$role.Copies'] ?? '1') ?? 1;
    return v < 1 ? 1 : v;
  }

  static double _fontScale(Map<String, String> s, String role) =>
      (double.tryParse(s['$role.FontSize'] ?? '100') ?? 100) / 100;

  static Future<pw.Font> _font(Map<String, String> s, String role) async {
    switch (s['$role.FontFamily'] ?? '(None)') {
      case 'Courier':
      case 'Monospace':
        return pw.Font.courier();
      case 'Times New Roman':
      case 'Times':
        return pw.Font.times();
      default:
        return await PdfGoogleFonts.notoSansRegular();
    }
  }

  static Future<pw.Font> _fontBold(Map<String, String> s, String role) async {
    switch (s['$role.FontFamily'] ?? '(None)') {
      case 'Courier':
      case 'Monospace':
        return pw.Font.courierBold();
      case 'Times New Roman':
      case 'Times':
        return pw.Font.timesBold();
      default:
        return await PdfGoogleFonts.notoSansBold();
    }
  }

  static bool _flag(Map<String, String> s, String key) =>
      (s[key] ?? 'false').toLowerCase() == 'true';

  // ── Print dispatcher ──────────────────────────────────────────────────────

  static Future<void> _dispatch(
    pw.Document pdf,
    String name,
    int copies,
    String? printerName,
  ) async {
    final bytes = await pdf.save();
    Printer? target;
    if (printerName != null && printerName.isNotEmpty) {
      try {
        final printers = await Printing.listPrinters();
        target = printers.where((p) => p.name == printerName).firstOrNull;
      } catch (_) {}
    }
    for (var i = 0; i < copies; i++) {
      if (target != null) {
        await Printing.directPrintPdf(
          printer: target,
          onLayout: (_) async => bytes,
          name: name,
        );
      } else {
        await Printing.layoutPdf(onLayout: (_) async => bytes, name: name);
      }
    }
  }

  // ── Shared row builder ────────────────────────────────────────────────────

  static pw.Widget _row(
    String label,
    String value, {
    bool bold = false,
    double fontSize = 10,
    double fontScale = 1.0,
    pw.Font? font,
    pw.Font? boldFont,
    bool rtl = false,
  }) {
    final size = fontSize * fontScale;
    final activeFont = bold ? (boldFont ?? font) : font;
    final style = pw.TextStyle(
      font: activeFont,
      fontWeight: bold ? pw.FontWeight.bold : null,
      fontSize: size,
    );
    final dir = rtl ? pw.TextDirection.rtl : pw.TextDirection.ltr;
    final labelW = pw.Text(label, style: style, textDirection: dir);
    final valueW = pw.Text(value, style: style, textDirection: dir);
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: rtl ? [valueW, labelW] : [labelW, valueW],
      ),
    );
  }

  static String _fmtDateTime(DateTime dt) {
    final d =
        '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    return '$d ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  // ── Receipt / Guest Check ─────────────────────────────────────────────────

  Future<void> printCartReceipt({
    required Company company,
    required User? cashier,
    required String orderNumber,
    required DateTime printTime,
    required List<CartItem> items,
    required double subtotal,
    required double totalDiscount,
    required double totalTax,
    required double grandTotal,
    required String currencySymbol,
    String? paymentTypeName,
    double? amountPaid,
    Uint8List? logoBytes,
    Map<String, String> roleSettings = const {},
    bool isGuestCheck = false,
  }) async {
    const role = 'Receipt';
    final fmt = _paperFmt(roleSettings['$role.PaperSize']);
    final margins = _margins(roleSettings, role);
    final copies = _copies(roleSettings, role);
    final fontScale = _fontScale(roleSettings, role);
    final font = await _font(roleSettings, role);
    final boldFont = await _fontBold(roleSettings, role);
    final rtl = _flag(roleSettings, '$role.RightToLeft');
    final logoFull = _flag(roleSettings, '$role.LogoFullWidth');
    final showBarcode = _flag(roleSettings, '$role.PrintBarcode');
    final printerName = roleSettings['$role.PrinterName'];

    final headerText = (roleSettings['$role.Header'] ?? '').isNotEmpty
        ? roleSettings['$role.Header']!
        : company.name;
    final footerRaw = roleSettings['$role.Footer'] ?? '';
    final footerText = footerRaw.isNotEmpty
        ? footerRaw
        : (isGuestCheck ? '' : 'Thank you for your visit!');

    pw.TextStyle ts(double size, {bool bold = false}) => pw.TextStyle(
      font: bold ? boldFont : font,
      fontWeight: bold ? pw.FontWeight.bold : null,
      fontSize: size * fontScale,
    );

    final dir = rtl ? pw.TextDirection.rtl : pw.TextDirection.ltr;

    pw.Widget center(String text, {double size = 10, bool bold = false}) =>
        pw.Center(
          child: pw.Text(
            text,
            style: ts(size, bold: bold),
            textAlign: pw.TextAlign.center,
            textDirection: dir,
          ),
        );

    final itemCount = items.fold<double>(0, (s, i) => s + i.quantity);
    final itemCountStr = itemCount % 1 == 0
        ? itemCount.toInt().toString()
        : itemCount.toStringAsFixed(2);

    pw.Widget rowW(
      String l,
      String v, {
      bool bold = false,
      double fontSize = 10,
    }) => _row(
      l,
      v,
      bold: bold,
      fontSize: fontSize,
      fontScale: fontScale,
      font: font,
      boldFont: boldFont,
      rtl: rtl,
    );

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: fmt,
        margin: margins,
        build: (_) => pw.Column(
          crossAxisAlignment: rtl
              ? pw.CrossAxisAlignment.end
              : pw.CrossAxisAlignment.start,
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            // ── Logo ───────────────────────────────────────────────────────
            if (logoBytes != null) ...[
              pw.Center(
                child: pw.Image(
                  pw.MemoryImage(logoBytes),
                  width: logoFull ? double.infinity : 80,
                  height: logoFull ? 80 : 60,
                  fit: pw.BoxFit.contain,
                ),
              ),
              pw.SizedBox(height: 6),
            ],

            // ── Header ─────────────────────────────────────────────────────
            center(headerText, size: 16, bold: true),
            if (company.taxNumber?.isNotEmpty == true)
              center('Tax No: ${company.taxNumber}', size: 9),
            if (company.address?.isNotEmpty == true)
              center(company.address!, size: 9),
            if (company.phoneNumber?.isNotEmpty == true)
              center('Tel: ${company.phoneNumber}', size: 9),
            pw.SizedBox(height: 6),
            pw.Divider(borderStyle: pw.BorderStyle.dashed),
            pw.SizedBox(height: 4),

            // ── Guest check banner ─────────────────────────────────────────
            if (isGuestCheck) ...[
              center('*** GUEST CHECK ***', size: 13, bold: true),
              pw.SizedBox(height: 4),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 4),
            ],

            // ── Transaction info ───────────────────────────────────────────
            rowW('Receipt:', orderNumber),
            rowW('Date:', _fmtDateTime(printTime)),
            if (cashier != null) rowW('Cashier:', cashier.displayName),
            pw.SizedBox(height: 4),
            pw.Divider(borderStyle: pw.BorderStyle.dashed),
            pw.SizedBox(height: 6),

            // ── Items ──────────────────────────────────────────────────────
            ...items.map((item) {
              final qty = item.quantity % 1 == 0
                  ? item.quantity.toInt().toString()
                  : item.quantity.toStringAsFixed(2);
              final unitPrice =
                  item.price - item.discount - item.promotionalDiscount;
              final lineTotal = unitPrice * item.quantity;
              final nameW = pw.Text(
                item.productName,
                style: ts(11, bold: true),
                textDirection: dir,
              );
              final qtyPriceW = pw.Text(
                '${rtl ? '' : '  '}$qty x ${unitPrice.toStringAsFixed(2)} $currencySymbol',
                style: ts(10),
                textDirection: dir,
              );
              final lineTotalW = pw.Text(
                '${lineTotal.toStringAsFixed(2)} $currencySymbol',
                style: ts(10),
                textDirection: dir,
              );
              return pw.Column(
                crossAxisAlignment: rtl
                    ? pw.CrossAxisAlignment.end
                    : pw.CrossAxisAlignment.start,
                children: [
                  nameW,
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: rtl
                        ? [lineTotalW, qtyPriceW]
                        : [qtyPriceW, lineTotalW],
                  ),
                  pw.SizedBox(height: 3),
                ],
              );
            }),

            pw.Divider(borderStyle: pw.BorderStyle.dashed),
            pw.SizedBox(height: 4),

            // ── Totals ─────────────────────────────────────────────────────
            rowW('Subtotal:', '${subtotal.toStringAsFixed(2)} $currencySymbol'),
            if (totalDiscount > 0)
              rowW(
                'Discount:',
                '-${totalDiscount.toStringAsFixed(2)} $currencySymbol',
              ),
            if (totalTax > 0)
              rowW('Tax:', '${totalTax.toStringAsFixed(2)} $currencySymbol'),
            pw.SizedBox(height: 4),
            pw.Divider(),
            pw.SizedBox(height: 4),
            rowW(
              'GRAND TOTAL:',
              '${grandTotal.toStringAsFixed(2)} $currencySymbol',
              bold: true,
              fontSize: 13,
            ),
            pw.Divider(),
            pw.SizedBox(height: 6),

            // ── Payment ────────────────────────────────────────────────────
            if (!isGuestCheck && paymentTypeName != null)
              rowW(
                '$paymentTypeName:',
                '${(amountPaid ?? grandTotal).toStringAsFixed(2)} $currencySymbol',
              ),
            rowW('Items:', itemCountStr),
            pw.SizedBox(height: 10),
            pw.Divider(borderStyle: pw.BorderStyle.dashed),
            pw.SizedBox(height: 6),

            // ── Footer ─────────────────────────────────────────────────────
            if (footerText.isNotEmpty) center(footerText, size: 9),

            // ── Barcode ────────────────────────────────────────────────────
            if (showBarcode && !isGuestCheck) ...[
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.BarcodeWidget(
                  barcode: pw.Barcode.code128(),
                  data: orderNumber,
                  width: 120,
                  height: 35,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    await _dispatch(
      pdf,
      isGuestCheck ? 'GuestCheck_$orderNumber' : 'Receipt_$orderNumber',
      copies,
      printerName,
    );
  }

  // ── Kitchen Ticket ────────────────────────────────────────────────────────

  Future<void> printKitchenTicket({
    required String orderNumber,
    required String cashierName,
    required String serviceType,
    int roundNumber = 1,
    required DateTime printTime,
    required List<CartItem> items,
    List<List<String>> itemComments = const [],
    required PrinterSelectionModel printerSelection,
    required PrinterSelectionSettingsModel settings,
  }) async {
    final fmt =
        settings.paperWidth == 58 ? PdfPageFormat.roll57 : PdfPageFormat.roll80;
    final margins = pw.EdgeInsets.only(
      top: settings.topMargin * PdfPageFormat.mm,
      bottom: settings.bottomMargin * PdfPageFormat.mm,
      left: settings.leftMargin * PdfPageFormat.mm,
      right: settings.rightMargin * PdfPageFormat.mm,
    );
    final copies = settings.numberOfCopies < 1 ? 1 : settings.numberOfCopies;
    final fontScale = settings.fontSizePercent / 100;
    final printerName = printerSelection.printerName;

    pw.Font font;
    pw.Font boldFont;
    switch (settings.fontName) {
      case 'Courier':
      case 'Monospace':
        font = pw.Font.courier();
        boldFont = pw.Font.courierBold();
      case 'Times New Roman':
      case 'Times':
        font = pw.Font.times();
        boldFont = pw.Font.timesBold();
      default:
        font = await PdfGoogleFonts.notoSansRegular();
        boldFont = await PdfGoogleFonts.notoSansBold();
    }

    pw.TextStyle ts(
      double size, {
      bool bold = false,
      bool italic = false,
    }) => pw.TextStyle(
      font: bold ? boldFont : font,
      fontWeight: bold ? pw.FontWeight.bold : null,
      fontStyle: italic ? pw.FontStyle.italic : null,
      fontSize: size * fontScale,
    );

    // Show just the counter portion (e.g. "005") large at the top.
    final ticketNum = orderNumber.contains('#')
        ? orderNumber.split('#').last.trim()
        : orderNumber;

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: fmt,
        margin: margins,
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            // ── Big order number ──────────────────────────────────────
            pw.Center(child: pw.Text(ticketNum, style: ts(40, bold: true))),
            pw.SizedBox(height: 4),
            pw.Divider(borderStyle: pw.BorderStyle.dashed),
            pw.SizedBox(height: 4),

            // ── Meta info ─────────────────────────────────────────────
            pw.Text('User: $cashierName', style: ts(10)),
            pw.Text(
              'Order: $orderNumber   Round: $roundNumber',
              style: ts(10),
            ),
            pw.Text('Time: ${_fmtDateTime(printTime)}', style: ts(10)),
            pw.SizedBox(height: 6),

            // ── Service type ──────────────────────────────────────────
            pw.Center(child: pw.Text(serviceType, style: ts(13, bold: true))),
            pw.SizedBox(height: 6),
            pw.Divider(borderStyle: pw.BorderStyle.dashed),
            pw.SizedBox(height: 8),

            // ── Items ─────────────────────────────────────────────────
            ...List.generate(items.length, (i) {
              final item = items[i];
              final qty = item.quantity % 1 == 0
                  ? item.quantity.toInt().toString()
                  : item.quantity.toStringAsFixed(2);

              // Gather all comment lines for this item:
              // 1. CartItem.comment split by newline (supports multi-line selections)
              // 2. Extra structured comments from the caller's itemComments list
              final commentLines = <String>[
                if (item.comment?.isNotEmpty == true)
                  ...item.comment!
                      .split('\n')
                      .where((l) => l.trim().isNotEmpty),
                if (i < itemComments.length) ...itemComments[i],
              ];

              return pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 10),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '$qty x ${item.productName}',
                      style: ts(16, bold: true),
                    ),
                    ...commentLines.map(
                      (c) => pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 12, top: 2),
                        child: pw.Text(c, style: ts(10, italic: true)),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );

    await _dispatch(pdf, 'Kitchen_$orderNumber', copies, printerName);
  }

  // ── Z-Report ──────────────────────────────────────────────────────────────

  Future<void> printZReport(
    ZReportModel report,
    String currencySymbol, {
    required Map<String, String> roleSettings,
  }) async {
    final font = await PdfGoogleFonts.notoSansRegular();
    final boldFont = await PdfGoogleFonts.notoSansBold();
    final pdf = pw.Document();

    // Standard 80mm thermal receipt format
    final format = PdfPageFormat.roll80;

    pw.TextStyle ts(double size, {bool bold = false}) => pw.TextStyle(
          font: bold ? boldFont : font,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: size,
        );

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(10),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text('Z-REPORT',
                  textAlign: pw.TextAlign.center, style: ts(16, bold: true)),
              pw.SizedBox(height: 8),
              pw.Text('Report #${report.number}',
                  textAlign: pw.TextAlign.center, style: ts(12)),
              pw.Text(
                'Date: ${report.dateCreated.toIso8601String().split('T').first}'
                '  Time: ${report.dateCreated.toIso8601String().split('T').last.split('.').first}',
                textAlign: pw.TextAlign.center,
                style: ts(10),
              ),
              pw.SizedBox(height: 8),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 8),

              pw.Text('SHIFT SUMMARY',
                  textAlign: pw.TextAlign.center, style: ts(12, bold: true)),
              pw.SizedBox(height: 8),
              _buildReceiptRow('Documents:',
                  '#${report.fromDocumentId} to #${report.toDocumentId}',
                  font: font, boldFont: boldFont),
              _buildReceiptRow('Cash in:',
                  '${report.totalCashIn.toStringAsFixed(2)} $currencySymbol',
                  font: font, boldFont: boldFont),
              _buildReceiptRow('Cash out:',
                  '-${report.totalCashOut.toStringAsFixed(2)} $currencySymbol',
                  font: font, boldFont: boldFont),
              pw.SizedBox(height: 4),
              _buildReceiptRow('Total Sales:',
                  '${report.totalSales.toStringAsFixed(2)} $currencySymbol',
                  font: font, boldFont: boldFont),
              _buildReceiptRow('Total Returns:',
                  '${report.totalReturns.toStringAsFixed(2)} $currencySymbol',
                  font: font, boldFont: boldFont),
              _buildReceiptRow('Discounts:',
                  '${report.discountsGranted.toStringAsFixed(2)} $currencySymbol',
                  font: font, boldFont: boldFont),
              _buildReceiptRow('Taxable Total:',
                  '${report.taxableTotal.toStringAsFixed(2)} $currencySymbol',
                  font: font, boldFont: boldFont),
              _buildReceiptRow('Total Tax:',
                  '${report.totalTax.toStringAsFixed(2)} $currencySymbol',
                  font: font, boldFont: boldFont),

              pw.SizedBox(height: 8),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 8),

              pw.Text('TENDER TYPES',
                  textAlign: pw.TextAlign.center, style: ts(12, bold: true)),
              pw.SizedBox(height: 8),
              if (report.paymentSummaries.isEmpty)
                pw.Text('No payments recorded.',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                        font: font,
                        fontStyle: pw.FontStyle.italic,
                        fontSize: 10))
              else
                ...report.paymentSummaries.map(
                  (p) => _buildReceiptRow(
                    p.paymentTypeName ?? 'Unknown',
                    '${p.totalAmount.toStringAsFixed(2)} $currencySymbol',
                    font: font,
                    boldFont: boldFont,
                  ),
                ),

              pw.SizedBox(height: 8),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 8),

              _buildReceiptRow(
                'GRAND TOTAL:',
                '${report.grandTotal.toStringAsFixed(2)} $currencySymbol',
                isBold: true,
                size: 14,
                font: font,
                boldFont: boldFont,
              ),

              pw.SizedBox(height: 24),
              pw.Text('*** END OF REPORT ***',
                  textAlign: pw.TextAlign.center, style: ts(10)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Z_Report_${report.number}',
    );
  }

  pw.Widget _buildReceiptRow(
    String label,
    String value, {
    bool isBold = false,
    double size = 10,
    required pw.Font font,
    required pw.Font boldFont,
  }) {
    final style = pw.TextStyle(
      font: isBold ? boldFont : font,
      fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
      fontSize: size,
    );
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: style),
          pw.Text(value, style: style),
        ],
      ),
    );
  }
}
