import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/auth/auth_provider.dart';
import 'package:pos_app/cart/payment_provider.dart';
import 'package:pos_app/reports/z_report_model.dart';
import 'package:pos_app/reports/z_report_provider.dart';
import 'package:pos_app/currency/currencies_provider.dart';

class EndOfDayScreen extends ConsumerStatefulWidget {
  const EndOfDayScreen({super.key});

  @override
  ConsumerState<EndOfDayScreen> createState() => _EndOfDayScreenState();
}

class _EndOfDayScreenState extends ConsumerState<EndOfDayScreen> {
  bool _isGenerating = false;

  Future<void> _closeRegister() async {
    final companyId = ref.read(selectedCompanyProvider)?.id;
    final currentUser = ref.read(currentUserProvider);

    if (companyId == null || currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Error: Missing company or user context."),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final dio = createDio();
      final response = await dio.post(
        '/ZReports/Generate',
        queryParameters: {
          'companyId': companyId,
          'userId': currentUser.id,
        },
      );

      final newReport = ZReportModel.fromJson(response.data);

      // Refresh both tabs!
      ref.invalidate(unreportedPaymentsProvider);
      ref.invalidate(allZReportsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Register Closed Successfully!"),
              backgroundColor: Colors.green),
        );
        _showReceiptDialog(newReport);
      }
    } on DioException catch (e) {
      if (mounted) {
        final errorMsg = e.response?.data?['message'] ??
            e.response?.data?.toString() ??
            "Failed to close shift.";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(errorMsg),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  void _showReceiptDialog(ZReportModel report) {
    final sym = ref.read(currencySymbolProvider);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Center(
            child: Text("Z-Report #${report.number}",
                style: const TextStyle(fontWeight: FontWeight.bold))),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text("SHIFT SUMMARY",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, letterSpacing: 2)),
                const Divider(thickness: 2),
                _receiptRow(
                    "Date/Time",
                    report.dateCreated
                        .toIso8601String()
                        .split('.')[0]
                        .replaceFirst('T', ' ')),
                _receiptRow("Documents",
                    "#${report.fromDocumentId} to #${report.toDocumentId}"),
                const Divider(),
                _receiptRow(
                    "Total Sales", "${report.totalSales.toStringAsFixed(2)} $sym"),
                _receiptRow("Total Returns",
                    "${report.totalReturns.toStringAsFixed(2)} $sym"),
                _receiptRow("Discounts",
                    "${report.discountsGranted.toStringAsFixed(2)} $sym"),
                _receiptRow("Taxable Total",
                    "${report.taxableTotal.toStringAsFixed(2)} $sym"),
                _receiptRow(
                    "Total Tax", "${report.totalTax.toStringAsFixed(2)} $sym"),
                const Divider(thickness: 2),
                const SizedBox(height: 8),
                const Text("TENDER TYPES",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (report.paymentSummaries.isEmpty)
                  const Text("No payments recorded.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontStyle: FontStyle.italic)),
                ...report.paymentSummaries.map((p) => _receiptRow(
                    p.paymentTypeName ?? "Unknown",
                    "${p.totalAmount.toStringAsFixed(2)} $sym")),
                const Divider(thickness: 2),
                _receiptRow(
                    "GRAND TOTAL", "${report.grandTotal.toStringAsFixed(2)} $sym",
                    isBold: true),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("Close")),
          ElevatedButton.icon(
            icon: const Icon(Icons.print),
            label: const Text("Print Receipt"),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Widget _receiptRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  fontSize: isBold ? 16 : 14)),
          Text(value,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  fontSize: isBold ? 16 : 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("End of Day"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Current Shift (Open)"),
              Tab(text: "History (Z-Reports)"),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _isGenerating
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white))
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.lock_clock),
                      label: const Text("Close Register"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          foregroundColor: Colors.white),
                      onPressed: _closeRegister,
                    ),
            )
          ],
        ),
        body: TabBarView(
          children: [
            _CurrentShiftTab(),
            _ZReportHistoryTab(onViewReceipt: _showReceiptDialog),
          ],
        ),
      ),
    );
  }
}

// --- TAB 1: CURRENT SHIFT PREVIEW ---
class _CurrentShiftTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUnreported = ref.watch(unreportedPaymentsProvider);

    return asyncUnreported.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
          child: Text("Error: $e", style: const TextStyle(color: Colors.red))),
      data: (payments) {
        if (payments.isEmpty) {
          return const Center(
            child: Text("No open transactions. The register is balanced.",
                style: TextStyle(fontSize: 18, color: Colors.grey)),
          );
        }

        final Map<String, double> totalsByType = {};
        double grandTotal = 0;

        for (var p in payments) {
          final typeName = p.paymentTypeName ?? "Unknown";
          totalsByType[typeName] = (totalsByType[typeName] ?? 0) + p.amount;
          grandTotal += p.amount;
        }

        return Row(
          children: [
            // LEFT PANEL: Preview
            Expanded(
              flex: 1,
              child: Container(
                color: const Color(0xFF2B3344),
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ...totalsByType.entries.map((e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(e.key,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16)),
                              Text(e.value.toStringAsFixed(2),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )),
                    const SizedBox(height: 8),
                    const Divider(color: Colors.grey, thickness: 1),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("TOTAL:",
                            style: TextStyle(
                                color: Colors.pinkAccent,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        Text(grandTotal.toStringAsFixed(2),
                            style: const TextStyle(
                                color: Colors.pinkAccent,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            // RIGHT PANEL: Details
            Expanded(
              flex: 1,
              child: Container(
                color: const Color(0xFF222835),
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Open transactions",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w300)),
                    const SizedBox(height: 24),
                    Text(
                        ref
                                .watch(currentUserProvider)
                                ?.displayName
                                .toUpperCase() ??
                            "UNKNOWN USER",
                        style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            letterSpacing: 1.5)),
                    const SizedBox(height: 16),
                    ...totalsByType.entries.map((e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(e.key,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 16)),
                              Text(e.value.toStringAsFixed(2),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16)),
                            ],
                          ),
                        )),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.grey),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("TOTAL:",
                            style: TextStyle(
                                color: Colors.pinkAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        Text(grandTotal.toStringAsFixed(2),
                            style: const TextStyle(
                                color: Colors.pinkAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// --- TAB 2: Z-REPORT HISTORY ---
class _ZReportHistoryTab extends ConsumerWidget {
  final Function(ZReportModel) onViewReceipt;

  const _ZReportHistoryTab({required this.onViewReceipt});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sym = ref.watch(currencySymbolProvider);
    final asyncReports = ref.watch(allZReportsProvider);

    return asyncReports.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
          child: Text("Error: $e", style: const TextStyle(color: Colors.red))),
      data: (reports) {
        if (reports.isEmpty) {
          return const Center(child: Text("No Z-Reports generated yet."));
        }
        return ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.indigo.shade100,
                  child: Text("#${report.number}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.indigo)),
                ),
                title: Text(
                    "Z-Report generated on ${report.dateCreated.toIso8601String().split('T').first}"),
                subtitle: Text(
                    "Documents: #${report.fromDocumentId} - #${report.toDocumentId} | Grand Total: ${report.grandTotal.toStringAsFixed(2)} $sym"),
                trailing: IconButton(
                  icon: const Icon(Icons.receipt_long, color: Colors.teal),
                  onPressed: () => onViewReceipt(report),
                  tooltip: "View Receipt",
                ),
              ),
            );
          },
        );
      },
    );
  }
}
