import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/stock/warehouse_model.dart';
import 'package:pos_app/stock/warehouse_provider.dart';

// --- SCREEN ---
class WarehousesScreen extends ConsumerWidget {
  const WarehousesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncWarehouses = ref.watch(allWarehousesProvider);
    final company = ref.watch(selectedCompanyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Warehouses"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh",
            onPressed: () => ref.invalidate(allWarehousesProvider),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Add Warehouse",
            onPressed: company == null
                ? null
                : () async {
                    await showDialog(
                      context: context,
                      builder: (_) =>
                          _WarehouseFormDialog(companyId: company.id),
                    );
                    ref.invalidate(allWarehousesProvider);
                  },
          ),
        ],
      ),
      body: asyncWarehouses.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error loading warehouses: $e")),
        data: (warehouses) {
          if (company == null) {
            return const Center(child: Text("No company selected."));
          }
          final int companyId = company.id;

          if (warehouses.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("No warehouses found.",
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text("Add First Warehouse"),
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (_) =>
                            _WarehouseFormDialog(companyId: companyId),
                      );
                      ref.invalidate(allWarehousesProvider);
                    },
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: warehouses.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, i) {
              final w = warehouses[i];
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.indigo,
                  child: Icon(Icons.warehouse, color: Colors.white),
                ),
                title: Text(w.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("ID: ${w.id}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Edit
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueGrey),
                      tooltip: "Edit",
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (_) => _WarehouseFormDialog(
                            companyId: companyId,
                            warehouse: w,
                          ),
                        );
                        ref.invalidate(allWarehousesProvider);
                      },
                    ),
                    // Delete
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: "Delete",
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text("Delete Warehouse"),
                            content: Text(
                                "Are you sure you want to delete '${w.name}'?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text("Delete",
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true && context.mounted) {
                          await _delete(context, ref, w.id, companyId);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
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
        '/Warehouses/Delete',
        queryParameters: {'id': id, 'companyId': companyId},
      );
      ref.invalidate(allWarehousesProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Warehouse deleted"), backgroundColor: Colors.green),
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

// --- ADD / EDIT DIALOG ---
class _WarehouseFormDialog extends ConsumerStatefulWidget {
  final int companyId;
  final Warehouse? warehouse;

  const _WarehouseFormDialog({
    required this.companyId,
    this.warehouse,
  });

  @override
  ConsumerState<_WarehouseFormDialog> createState() =>
      _WarehouseFormDialogState();
}

class _WarehouseFormDialogState extends ConsumerState<_WarehouseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  bool _isLoading = false;
  String? _errorMessage;

  bool get _isEditing => widget.warehouse != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.warehouse?.name ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dio = createDio();
      if (_isEditing) {
        await dio.patch(
          '/Warehouses/Update',
          queryParameters: {'companyId': widget.companyId},
          data: {
            'id': widget.warehouse!.id,
            'name': _nameCtrl.text.trim(),
          },
        );
      } else {
        await dio.post(
          '/Warehouses/Add',
          queryParameters: {'companyId': widget.companyId},
          data: {'name': _nameCtrl.text.trim()},
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
      title: Text(_isEditing ? "Edit Warehouse" : "New Warehouse"),
      content: SizedBox(
        width: 320,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration:
                    const InputDecoration(labelText: "Warehouse Name *"),
                autofocus: true,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Required" : null,
              ),
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
}
