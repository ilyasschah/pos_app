import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'api_client.dart';
import 'company_provider.dart';
import 'payment_type_model.dart';
import 'payment_type_provider.dart';

// --- SCREEN ---
class PaymentTypesScreen extends ConsumerWidget {
  const PaymentTypesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTypes = ref.watch(allPaymentTypesProvider);
    final company = ref.watch(selectedCompanyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Types"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh",
            onPressed: () => ref.invalidate(allPaymentTypesProvider),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "New Payment Type",
            onPressed: company == null
                ? null
                : () async {
                    await showDialog(
                      context: context,
                      builder: (_) =>
                          _PaymentTypeFormDialog(companyId: company.id),
                    );
                    ref.invalidate(allPaymentTypesProvider);
                  },
          ),
        ],
      ),
      body: asyncTypes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error loading payment types: $e")),
        data: (types) {
          if (company == null) {
            return const Center(child: Text("No company selected."));
          }
          final int companyId = company.id;

          if (types.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("No payment types found.",
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text("Add First Payment Type"),
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (_) =>
                            _PaymentTypeFormDialog(companyId: companyId),
                      );
                      ref.invalidate(allPaymentTypesProvider);
                    },
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.blueGrey[50]),
                columns: const [
                  DataColumn(label: Text("Name")),
                  DataColumn(label: Text("Code")),
                  DataColumn(label: Text("Position"), numeric: true),
                  DataColumn(label: Text("Enabled")),
                  DataColumn(label: Text("Quick Pay")),
                  DataColumn(label: Text("Customer Req.")),
                  DataColumn(label: Text("Change")),
                  DataColumn(label: Text("Mark Paid")),
                  DataColumn(label: Text("Cash Drawer")),
                  DataColumn(label: Text("Fiscal")),
                  DataColumn(label: Text("Slip")),
                  DataColumn(label: Text("Shortcut")),
                  DataColumn(label: Text("Actions")),
                ],
                rows: types.map((t) {
                  return DataRow(cells: [
                    DataCell(Text(t.name)),
                    DataCell(Text(t.code ?? '-')),
                    DataCell(Text(t.ordinal.toString())),
                    DataCell(_BoolIcon(value: t.isEnabled)),
                    DataCell(_BoolIcon(value: t.isQuickPayment)),
                    DataCell(_BoolIcon(value: t.isCustomerRequired)),
                    DataCell(_BoolIcon(value: t.isChangeAllowed)),
                    DataCell(_BoolIcon(value: t.markAsPaid)),
                    DataCell(_BoolIcon(value: t.openCashDrawer)),
                    DataCell(_BoolIcon(value: t.isFiscal)),
                    DataCell(_BoolIcon(value: t.isSlipRequired)),
                    DataCell(Text(t.shortcutKey ?? '-')),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors.blueGrey, size: 18),
                            tooltip: "Edit",
                            onPressed: () async {
                              await showDialog(
                                context: context,
                                builder: (_) => _PaymentTypeFormDialog(
                                  companyId: companyId,
                                  paymentType: t,
                                ),
                              );
                              ref.invalidate(allPaymentTypesProvider);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red, size: 18),
                            tooltip: "Delete",
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("Delete"),
                                  content:
                                      Text("Delete payment type '${t.name}'?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(false),
                                      child: const Text("Cancel"),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red),
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(true),
                                      child: const Text("Delete",
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true && context.mounted) {
                                await _delete(context, ref, t.id, companyId);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _delete(
      BuildContext context, WidgetRef ref, int id, int companyId) async {
    try {
      final dio = createDio();
      // DELETE sends id as raw integer body, companyId as query param
      await dio.delete(
        '/PaymentTypes/Delete',
        queryParameters: {'companyId': companyId, 'id': id},
      );
      ref.invalidate(allPaymentTypesProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Payment type deleted"),
            backgroundColor: Colors.green),
      );
    } on DioException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.response?.data?.toString() ?? "Delete failed"),
        backgroundColor: Colors.red,
      ));
    }
  }
}

// --- BOOL ICON WIDGET ---
class _BoolIcon extends StatelessWidget {
  final bool value;
  const _BoolIcon({required this.value});

  @override
  Widget build(BuildContext context) {
    return Icon(
      value ? Icons.check : null,
      color: Colors.green,
      size: 18,
    );
  }
}

// --- ADD / EDIT FORM DIALOG ---
class _PaymentTypeFormDialog extends ConsumerStatefulWidget {
  final int companyId;
  final PaymentType? paymentType;

  const _PaymentTypeFormDialog({
    required this.companyId,
    this.paymentType,
  });

  @override
  ConsumerState<_PaymentTypeFormDialog> createState() =>
      _PaymentTypeFormDialogState();
}

class _PaymentTypeFormDialogState
    extends ConsumerState<_PaymentTypeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _codeCtrl;
  late final TextEditingController _ordinalCtrl;
  late final TextEditingController _shortcutCtrl;

  late bool _isEnabled;
  late bool _isQuickPayment;
  late bool _isCustomerRequired;
  late bool _isChangeAllowed;
  late bool _markAsPaid;
  late bool _openCashDrawer;
  late bool _isFiscal;
  late bool _isSlipRequired;

  bool get _isEditing => widget.paymentType != null;

  @override
  void initState() {
    super.initState();
    final p = widget.paymentType;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _codeCtrl = TextEditingController(text: p?.code ?? '');
    _ordinalCtrl = TextEditingController(text: p?.ordinal.toString() ?? '0');
    _shortcutCtrl = TextEditingController(text: p?.shortcutKey ?? '');
    _isEnabled = p?.isEnabled ?? true;
    _isQuickPayment = p?.isQuickPayment ?? false;
    _isCustomerRequired = p?.isCustomerRequired ?? false;
    _isChangeAllowed = p?.isChangeAllowed ?? false;
    _markAsPaid = p?.markAsPaid ?? false;
    _openCashDrawer = p?.openCashDrawer ?? false;
    _isFiscal = p?.isFiscal ?? false;
    _isSlipRequired = p?.isSlipRequired ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _ordinalCtrl.dispose();
    _shortcutCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final payload = <String, dynamic>{
      'name': _nameCtrl.text.trim(),
      'code': _codeCtrl.text.trim(),
      'ordinal': int.tryParse(_ordinalCtrl.text.trim()) ?? 0,
      'shortcutKey': _shortcutCtrl.text.trim(),
      'isEnabled': _isEnabled,
      'isQuickPayment': _isQuickPayment,
      'isCustomerRequired': _isCustomerRequired,
      'isChangeAllowed': _isChangeAllowed,
      'markAsPaid': _markAsPaid,
      'openCashDrawer': _openCashDrawer,
      'isFiscal': _isFiscal,
      'isSlipRequired': _isSlipRequired,
    };

    try {
      final dio = createDio();
      if (_isEditing) {
        payload['id'] = widget.paymentType!.id;
        await dio.patch(
          '/PaymentTypes/Update',
          queryParameters: {'companyId': widget.companyId},
          data: payload,
        );
      } else {
        await dio.post(
          '/PaymentTypes/Add',
          queryParameters: {'companyId': widget.companyId},
          data: payload,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop();
    } on DioException catch (e) {
      setState(() {
        _errorMessage = e.response?.data?.toString() ?? "Operation failed.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? "Edit Payment Type" : "New Payment Type"),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name & Code
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(labelText: "Name *"),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? "Required" : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _codeCtrl,
                        decoration: const InputDecoration(labelText: "Code"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Ordinal & Shortcut
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _ordinalCtrl,
                        decoration:
                            const InputDecoration(labelText: "Position"),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _shortcutCtrl,
                        decoration:
                            const InputDecoration(labelText: "Shortcut Key"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Toggle switches in a grid
                _switchRow("Enabled", _isEnabled,
                    (v) => setState(() => _isEnabled = v)),
                _switchRow("Quick Payment", _isQuickPayment,
                    (v) => setState(() => _isQuickPayment = v)),
                _switchRow("Customer Required", _isCustomerRequired,
                    (v) => setState(() => _isCustomerRequired = v)),
                _switchRow("Change Allowed", _isChangeAllowed,
                    (v) => setState(() => _isChangeAllowed = v)),
                _switchRow("Mark As Paid", _markAsPaid,
                    (v) => setState(() => _markAsPaid = v)),
                _switchRow("Open Cash Drawer", _openCashDrawer,
                    (v) => setState(() => _openCashDrawer = v)),
                _switchRow(
                    "Fiscal", _isFiscal, (v) => setState(() => _isFiscal = v)),
                _switchRow("Slip Required", _isSlipRequired,
                    (v) => setState(() => _isSlipRequired = v)),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(_errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 13)),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel")),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          )
        else
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: Text(_isEditing ? "Update" : "Save"),
            onPressed: _submit,
          ),
      ],
    );
  }

  Widget _switchRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.green,
          ),
        ],
      ),
    );
  }
}
