import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pos_app/auth/user_model.dart';
import 'package:pos_app/cart/checkout_models.dart';
import 'package:pos_app/company/company_model.dart';
import 'package:pos_app/printer/printer_selection_settings_model.dart';
import 'package:pos_app/reports/z_report_model.dart';
import 'package:printing/printing.dart';

class ReceiptPrinterService {
  // ── Shared helpers ────────────────────────────────────────────────────────

  static PdfPageFormat _pageFormat(int paperWidth) {
    if (paperWidth >= 72) return PdfPageFormat.roll80;
    if (paperWidth >= 50) return PdfPageFormat.roll57;
    return PdfPageFormat.roll80;
  }

  static double _edgeMargin(PrinterSelectionSettingsModel? s) =>
      (s?.margin != null && s!.margin > 0) ? s.margin.toDouble() : 12.0;

  static pw.Widget _row(
    String label,
    String value, {
    bool bold = false,
    double fontSize = 10,
  }) {
    final style = bold
        ? pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: fontSize)
        : pw.TextStyle(fontSize: fontSize);
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [pw.Text(label, style: style), pw.Text(value, style: style)],
      ),
    );
  }

  static String _fmtDateTime(DateTime dt) {
    final d =
        '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$d $h:$m';
  }

  static Future<void> _doPrint(
      pw.Document pdf, String name, int copies) async {
    final bytes = await pdf.save();
    for (var i = 0; i < copies; i++) {
      await Printing.layoutPdf(
        onLayout: (_) async => bytes,
        name: name,
      );
    }
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
    PrinterSelectionSettingsModel? settings,
    bool isGuestCheck = false,
  }) async {
    final pdf = pw.Document();
    final fmt = _pageFormat(settings?.paperWidth ?? 80);
    final margin = _edgeMargin(settings);
    final footerText =
        settings?.footer?.isNotEmpty == true ? settings!.footer : null;
    final showBarcode = settings?.printBarcode ?? true;
    final copies = settings?.numberOfCopies ?? 1;
    final companyHeader = (settings?.header?.isNotEmpty == true)
        ? settings!.header!
        : company.name;

    final itemCount =
        items.fold<double>(0, (sum, i) => sum + i.quantity);
    final itemCountStr = itemCount % 1 == 0
        ? itemCount.toInt().toString()
        : itemCount.toStringAsFixed(2);

    pdf.addPage(
      pw.Page(
        pageFormat: fmt,
        margin: pw.EdgeInsets.all(margin),
        build: (pw.Context ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            // ── Logo ───────────────────────────────────────────────────────
            if (logoBytes != null) ...[
              pw.Center(
                child: pw.Image(pw.MemoryImage(logoBytes),
                    width: 80, height: 60, fit: pw.BoxFit.contain),
              ),
              pw.SizedBox(height: 6),
            ],

            // ── Company header ─────────────────────────────────────────────
            pw.Center(
              child: pw.Text(
                companyHeader,
                style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold, fontSize: 16),
                textAlign: pw.TextAlign.center,
              ),
            ),
            if (company.taxNumber?.isNotEmpty == true)
              pw.Center(
                child: pw.Text(
                  'Tax No: ${company.taxNumber}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ),
            if (company.address?.isNotEmpty == true)
              pw.Center(
                child: pw.Text(
                  company.address!,
                  style: const pw.TextStyle(fontSize: 9),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            if (company.phoneNumber?.isNotEmpty == true)
              pw.Center(
                child: pw.Text(
                  'Tel: ${company.phoneNumber}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ),
            pw.SizedBox(height: 6),
            pw.Divider(borderStyle: pw.BorderStyle.dashed),
            pw.SizedBox(height: 4),

            // ── Guest check banner ─────────────────────────────────────────
            if (isGuestCheck) ...[
              pw.Center(
                child: pw.Text(
                  '*** GUEST CHECK ***',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 13),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 4),
            ],

            // ── Transaction info ───────────────────────────────────────────
            _row('Receipt:', orderNumber),
            _row('Date:', _fmtDateTime(printTime)),
            if (cashier != null) _row('Cashier:', cashier.displayName),
            pw.SizedBox(height: 4),
            pw.Divider(borderStyle: pw.BorderStyle.dashed),
            pw.SizedBox(height: 6),

            // ── Items (two-line format) ────────────────────────────────────
            ...items.map((item) {
              final qty = item.quantity % 1 == 0
                  ? item.quantity.toInt().toString()
                  : item.quantity.toStringAsFixed(2);
              final unitPrice =
                  item.price - item.discount - item.promotionalDiscount;
              final lineTotal = unitPrice * item.quantity;
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    item.productName,
                    style: pw.TextStyle(
                        fontSize: 11, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        '  $qty x ${unitPrice.toStringAsFixed(2)} $currencySymbol',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        '${lineTotal.toStringAsFixed(2)} $currencySymbol',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 3),
                ],
              );
            }),

            pw.Divider(borderStyle: pw.BorderStyle.dashed),
            pw.SizedBox(height: 4),

            // ── Totals ─────────────────────────────────────────────────────
            _row('Subtotal:',
                '${subtotal.toStringAsFixed(2)} $currencySymbol'),
            if (totalDiscount > 0)
              _row('Discount:',
                  '-${totalDiscount.toStringAsFixed(2)} $currencySymbol'),
            if (totalTax > 0)
              _row('Tax:',
                  '${totalTax.toStringAsFixed(2)} $currencySymbol'),
            pw.SizedBox(height: 4),
            pw.Divider(),
            pw.SizedBox(height: 4),
            _row(
              'GRAND TOTAL:',
              '${grandTotal.toStringAsFixed(2)} $currencySymbol',
              bold: true,
              fontSize: 13,
            ),
            pw.Divider(),
            pw.SizedBox(height: 6),

            // ── Payment breakdown (finalized only) ─────────────────────────
            if (!isGuestCheck && paymentTypeName != null)
              _row(
                '$paymentTypeName:',
                '${(amountPaid ?? grandTotal).toStringAsFixed(2)} $currencySymbol',
              ),
            _row('Items:', itemCountStr),
            pw.SizedBox(height: 10),
            pw.Divider(borderStyle: pw.BorderStyle.dashed),
            pw.SizedBox(height: 6),

            // ── Footer ─────────────────────────────────────────────────────
            pw.Center(
              child: pw.Text(
                footerText ??
                    (isGuestCheck ? '' : 'Thank you for your visit!'),
                style: const pw.TextStyle(fontSize: 9),
                textAlign: pw.TextAlign.center,
              ),
            ),

            // ── Barcode (finalized only) ───────────────────────────────────
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

    await _doPrint(
      pdf,
      isGuestCheck ? 'GuestCheck_$orderNumber' : 'Receipt_$orderNumber',
      copies,
    );
  }

  // ── Kitchen Ticket ────────────────────────────────────────────────────────

  Future<void> printKitchenTicket({
    required String orderNumber,
    String? tableInfo,
    String? serverName,
    required DateTime printTime,
    required List<CartItem> items,
    PrinterSelectionSettingsModel? settings,
  }) async {
    final pdf = pw.Document();
    final fmt = _pageFormat(settings?.paperWidth ?? 80);
    final margin = _edgeMargin(settings);
    final copies = settings?.numberOfCopies ?? 1;

    pdf.addPage(
      pw.Page(
        pageFormat: fmt,
        margin: pw.EdgeInsets.all(margin),
        build: (pw.Context ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            // Header
            pw.Center(
              child: pw.Text(
                'KITCHEN',
                style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold, fontSize: 22),
              ),
            ),
            pw.Divider(thickness: 2),
            pw.SizedBox(height: 4),
            _row('Order:', orderNumber, fontSize: 12),
            if (tableInfo?.isNotEmpty == true)
              _row('Table:', tableInfo!, fontSize: 12),
            if (serverName?.isNotEmpty == true)
              _row('Server:', serverName!, fontSize: 12),
            _row('Time:', _fmtDateTime(printTime), fontSize: 12),
            pw.SizedBox(height: 8),
            pw.Divider(thickness: 2),
            pw.SizedBox(height: 8),

            // Items — large font, no prices
            ...items.map((item) {
              final qty = item.quantity % 1 == 0
                  ? item.quantity.toInt().toString()
                  : item.quantity.toStringAsFixed(2);
              return pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(
                      width: 38,
                      child: pw.Text(
                        qty,
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 20),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        item.productName,
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 18),
                      ),
                    ),
                  ],
                ),
              );
            }),

            // Comments
            if (items.any((i) => i.comment?.isNotEmpty == true)) ...[
              pw.SizedBox(height: 4),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 4),
              ...items
                  .where((i) => i.comment?.isNotEmpty == true)
                  .map((i) => pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 2),
                        child: pw.Text(
                          '* ${i.productName}: ${i.comment}',
                          style: pw.TextStyle(
                              fontStyle: pw.FontStyle.italic, fontSize: 10),
                        ),
                      )),
            ],
          ],
        ),
      ),
    );

    await _doPrint(pdf, 'Kitchen_$orderNumber', copies);
  }

  // ── Z-Report ──────────────────────────────────────────────────────────────

  static pw.Widget _zRow(String label, String value, {bool bold = false}) {
    final style = bold
        ? pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)
        : const pw.TextStyle(fontSize: 10);
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [pw.Text(label, style: style), pw.Text(value, style: style)],
      ),
    );
  }

  Future<void> printZReport(
    ZReportModel report,
    String currencySymbol, {
    PrinterSelectionSettingsModel? settings,
  }) async {
    final pdf = pw.Document();
    final pageFormat = _pageFormat(settings?.paperWidth ?? 80);
    final edgeMargin = _edgeMargin(settings);
    final headerText =
        (settings?.header?.isNotEmpty == true) ? settings!.header! : null;
    final footerText =
        settings?.footer?.isNotEmpty == true ? settings!.footer : null;
    final showBarcode = settings?.printBarcode ?? true;
    final copies = settings?.numberOfCopies ?? 1;

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        margin: pw.EdgeInsets.all(edgeMargin),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              if (headerText != null)
                pw.Center(
                  child: pw.Text(headerText,
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 16)),
                ),
              pw.Center(
                child: pw.Text('Z-Report #${report.number}',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 14)),
              ),
              pw.Center(
                child: pw.Text(_fmtDateTime(report.dateCreated),
                    style: const pw.TextStyle(fontSize: 10)),
              ),
              pw.SizedBox(height: 8),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 6),
              pw.Center(
                child: pw.Text('SHIFT SUMMARY',
                    style: const pw.TextStyle(fontSize: 10)),
              ),
              pw.SizedBox(height: 6),
              _zRow('Documents',
                  '#${report.fromDocumentId} – #${report.toDocumentId}'),
              _zRow('Total Sales',
                  '${report.totalSales.toStringAsFixed(2)} $currencySymbol'),
              _zRow('Total Returns',
                  '${report.totalReturns.toStringAsFixed(2)} $currencySymbol'),
              _zRow('Discounts',
                  '${report.discountsGranted.toStringAsFixed(2)} $currencySymbol'),
              _zRow('Taxable Total',
                  '${report.taxableTotal.toStringAsFixed(2)} $currencySymbol'),
              _zRow('Total Tax',
                  '${report.totalTax.toStringAsFixed(2)} $currencySymbol'),
              pw.SizedBox(height: 4),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 6),
              pw.Center(
                child: pw.Text('TENDER TYPES',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 10)),
              ),
              pw.SizedBox(height: 6),
              if (report.paymentSummaries.isEmpty)
                pw.Center(
                  child: pw.Text('No payments recorded.',
                      style: const pw.TextStyle(fontSize: 10)),
                ),
              ...report.paymentSummaries.map((p) => _zRow(
                    p.paymentTypeName ?? 'Unknown',
                    '${p.totalAmount.toStringAsFixed(2)} $currencySymbol',
                  )),
              pw.SizedBox(height: 4),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 6),
              _zRow(
                'GRAND TOTAL',
                '${report.grandTotal.toStringAsFixed(2)} $currencySymbol',
                bold: true,
              ),
              pw.SizedBox(height: 16),
              if (footerText != null)
                pw.Center(
                  child: pw.Text(footerText,
                      style: const pw.TextStyle(fontSize: 10)),
                ),
              if (showBarcode) ...[
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.BarcodeWidget(
                    barcode: pw.Barcode.code128(),
                    data: 'Z${report.number}',
                    width: 120,
                    height: 40,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );

    await _doPrint(pdf, 'ZReport_${report.number}', copies);
  }
}
