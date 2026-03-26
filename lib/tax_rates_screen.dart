import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'api_client.dart';
import 'company_provider.dart';
import 'tax_model.dart';
import 'tax_provider.dart';

// --- SCREEN ---
class TaxRatesScreen extends ConsumerWidget {
  const TaxRatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTaxes = ref.watch(allTaxesProvider);
    final company = ref.watch(selectedCompanyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tax Rates"),
        actions: [
          // Refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh",
            onPressed: () => ref.invalidate(allTaxesProvider),
          ),
          // Switch Taxes
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: "Switch Taxes",
            onPressed: company == null || asyncTaxes.value == null
                ? null
                : () async {
                    await showDialog(
                      context: context,
                      builder: (_) => _SwitchTaxesDialog(
                        taxes: asyncTaxes.value!,
                        companyId: company.id,
                      ),
                    );
                    ref.invalidate(allTaxesProvider);
                  },
          ),
          // Add
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "New Tax Rate",
            onPressed: company == null
                ? null
                : () async {
                    await showDialog(
                      context: context,
                      builder: (_) => _TaxFormDialog(companyId: company.id),
                    );
                    ref.invalidate(allTaxesProvider);
                  },
          ),
        ],
      ),
      body: asyncTaxes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error loading taxes: $e")),
        data: (taxes) {
          if (company == null) {
            return const Center(child: Text("No company selected."));
          }
          final int companyId = company.id;

          if (taxes.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("No tax rates found.",
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text("Add First Tax Rate"),
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (_) => _TaxFormDialog(companyId: companyId),
                      );
                      ref.invalidate(allTaxesProvider);
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
                  DataColumn(label: Text("Rate"), numeric: true),
                  DataColumn(label: Text("Code")),
                  DataColumn(label: Text("Fixed")),
                  DataColumn(label: Text("Tax on Total")),
                  DataColumn(label: Text("Enabled")),
                  DataColumn(label: Text("Actions")),
                ],
                rows: taxes.map((t) {
                  return DataRow(cells: [
                    DataCell(Text(t.name)),
                    DataCell(Text(
                        "${t.isFixed ? '' : ''}${t.rate.toStringAsFixed(t.rate % 1 == 0 ? 0 : 2)}${t.isFixed ? '' : '%'}")),
                    DataCell(Text(t.code ?? '-')),
                    DataCell(_BoolIcon(value: t.isFixed)),
                    DataCell(_BoolIcon(value: t.isTaxOnTotal)),
                    DataCell(_BoolIcon(value: t.isEnabled)),
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
                                builder: (_) => _TaxFormDialog(
                                  companyId: companyId,
                                  tax: t,
                                ),
                              );
                              ref.invalidate(allTaxesProvider);
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
                                  title: const Text("Delete Tax"),
                                  content: Text("Delete tax rate '${t.name}'?"),
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
      await dio.delete(
        '/Taxes/DeleteTax',
        queryParameters: {'id': id, 'companyId': companyId},
      );
      ref.invalidate(allTaxesProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Tax rate deleted"), backgroundColor: Colors.green),
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

// --- BOOL ICON ---
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

// --- ADD / EDIT TAX DIALOG ---
class _TaxFormDialog extends ConsumerStatefulWidget {
  final int companyId;
  final Tax? tax;

  const _TaxFormDialog({required this.companyId, this.tax});

  @override
  ConsumerState<_TaxFormDialog> createState() => _TaxFormDialogState();
}

class _TaxFormDialogState extends ConsumerState<_TaxFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _rateCtrl;
  late final TextEditingController _codeCtrl;
  late bool _isFixed;
  late bool _isTaxOnTotal;
  late bool _isEnabled;

  bool get _isEditing => widget.tax != null;

  @override
  void initState() {
    super.initState();
    final t = widget.tax;
    _nameCtrl = TextEditingController(text: t?.name ?? '');
    _rateCtrl = TextEditingController(
        text: t != null
            ? t.rate % 1 == 0
                ? t.rate.toInt().toString()
                : t.rate.toString()
            : '');
    _codeCtrl = TextEditingController(text: t?.code ?? '');
    _isFixed = t?.isFixed ?? false;
    _isTaxOnTotal = t?.isTaxOnTotal ?? true;
    _isEnabled = t?.isEnabled ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _rateCtrl.dispose();
    _codeCtrl.dispose();
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
      'rate': double.tryParse(_rateCtrl.text.trim()) ?? 0,
      'code': _codeCtrl.text.trim(),
      'isFixed': _isFixed,
      'isTaxOnTotal': _isTaxOnTotal,
      'isEnabled': _isEnabled,
    };

    try {
      final dio = createDio();
      if (_isEditing) {
        payload['id'] = widget.tax!.id;
        await dio.patch(
          '/Taxes/UpdateTax',
          queryParameters: {'companyId': widget.companyId},
          data: payload,
        );
      } else {
        await dio.post(
          '/Taxes/AddTax',
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
      title: Text(_isEditing ? "Edit Tax Rate" : "New Tax Rate"),
      content: SizedBox(
        width: 380,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              TextFormField(
                controller: _rateCtrl,
                decoration: const InputDecoration(
                    labelText: "Rate *", hintText: "e.g. 20 for 20%"),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return "Required";
                  if (double.tryParse(v.trim()) == null) {
                    return "Enter a valid number";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _switchRow("Fixed Amount", _isFixed,
                  (v) => setState(() => _isFixed = v)),
              _switchRow("Tax on Total", _isTaxOnTotal,
                  (v) => setState(() => _isTaxOnTotal = v)),
              _switchRow(
                  "Enabled", _isEnabled, (v) => setState(() => _isEnabled = v)),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(_errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 13)),
              ],
            ],
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
          Switch(value: value, onChanged: onChanged, activeColor: Colors.green),
        ],
      ),
    );
  }
}

// --- SWITCH TAXES DIALOG ---
class _SwitchTaxesDialog extends ConsumerStatefulWidget {
  final List<Tax> taxes;
  final int companyId;

  const _SwitchTaxesDialog({
    required this.taxes,
    required this.companyId,
  });

  @override
  ConsumerState<_SwitchTaxesDialog> createState() => _SwitchTaxesDialogState();
}

class _SwitchTaxesDialogState extends ConsumerState<_SwitchTaxesDialog> {
  int? _oldTaxId;
  int? _newTaxId;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  Future<void> _replace() async {
    if (_oldTaxId == null || _newTaxId == null) {
      setState(() => _errorMessage = "Please select both taxes.");
      return;
    }
    if (_oldTaxId == _newTaxId) {
      setState(() => _errorMessage = "Old and new tax must be different.");
      return;
    }

    // Get the old tax object to extract its rate
    final oldTax = widget.taxes.firstWhere((t) => t.id == _oldTaxId);
    // Get the new tax object to keep all its other fields intact
    final newTax = widget.taxes.firstWhere((t) => t.id == _newTaxId);

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final dio = createDio();
      // PATCH the new tax — keep all its fields, only swap the rate
      await dio.patch(
        '/Taxes/UpdateTax',
        queryParameters: {'companyId': widget.companyId},
        data: {
          'id': newTax.id,
          'name': newTax.name,
          'code': newTax.code,
          'rate': oldTax.rate, // <-- old tax rate applied to new tax
          'isFixed': newTax.isFixed,
          'isTaxOnTotal': newTax.isTaxOnTotal,
          'isEnabled': newTax.isEnabled,
        },
      );
      setState(() => _successMessage =
          "Rate ${oldTax.rate}${oldTax.isFixed ? '' : '%'} from '${oldTax.name}' "
              "applied to '${newTax.name}' successfully.");
    } on DioException catch (e) {
      setState(() {
        _errorMessage = e.response?.data?.toString() ?? "Switch failed.";
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Switch Taxes"),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Use this form to replace taxes for all products. "
                      "Select old tax you wish to replace with new tax and click Replace.",
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Old Tax Dropdown
            DropdownButtonFormField<int>(
              value: _oldTaxId,
              decoration: const InputDecoration(
                labelText: "Old Tax",
                border: OutlineInputBorder(),
              ),
              items: widget.taxes
                  .map((t) => DropdownMenuItem(
                        value: t.id,
                        child: Text(
                            "${t.name} (${t.rate.toStringAsFixed(t.rate % 1 == 0 ? 0 : 2)}${t.isFixed ? '' : '%'})"),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _oldTaxId = v),
            ),
            const SizedBox(height: 16),

            // New Tax Dropdown
            DropdownButtonFormField<int>(
              value: _newTaxId,
              decoration: const InputDecoration(
                labelText: "New Tax",
                border: OutlineInputBorder(),
              ),
              items: widget.taxes
                  .map((t) => DropdownMenuItem(
                        value: t.id,
                        child: Text(
                            "${t.name} (${t.rate.toStringAsFixed(t.rate % 1 == 0 ? 0 : 2)}${t.isFixed ? '' : '%'})"),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _newTaxId = v),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(_errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 13)),
            ],
            if (_successMessage != null) ...[
              const SizedBox(height: 12),
              Text(_successMessage!,
                  style: const TextStyle(color: Colors.green, fontSize: 13)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close")),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          )
        else
          ElevatedButton.icon(
            icon: const Icon(Icons.swap_horiz),
            label: const Text("Replace"),
            onPressed: _replace,
          ),
      ],
    );
  }
}
