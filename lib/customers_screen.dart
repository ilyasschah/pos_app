import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'api_client.dart';
import 'company_provider.dart';
import 'customer_provider.dart';
import 'customer_model.dart';

class CustomersScreen extends ConsumerWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCustomers = ref.watch(allCustomersProvider);
    final company = ref.watch(selectedCompanyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Customers"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: "Add Customer",
            onPressed: company == null
                ? null
                : () async {
                    await showDialog(
                      context: context,
                      builder: (_) =>
                          _AddCustomerDialog(companyId: company.id),
                    );
                    ref.invalidate(allCustomersProvider);
                  },
          ),
        ],
      ),
      body: asyncCustomers.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error loading customers: $e")),
        data: (customers) {
          if (customers.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("No customers found.",
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.person_add),
                    label: const Text("Add First Customer"),
                    onPressed: company == null
                        ? null
                        : () async {
                            await showDialog(
                              context: context,
                              builder: (_) =>
                                  _AddCustomerDialog(companyId: company.id),
                            );
                            ref.invalidate(allCustomersProvider);
                          },
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: customers.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, i) {
              final c = customers[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Text(
                    c.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(c.name),
                subtitle: Text([
                  if (c.phoneNumber != null) c.phoneNumber!,
                  if (c.email != null) c.email!,
                ].join(' · ')),
              );
            },
          );
        },
      ),
    );
  }
}

// --- ADD CUSTOMER DIALOG ---
class _AddCustomerDialog extends ConsumerStatefulWidget {
  final int companyId;
  const _AddCustomerDialog({required this.companyId});

  @override
  ConsumerState<_AddCustomerDialog> createState() =>
      _AddCustomerDialogState();
}

class _AddCustomerDialogState extends ConsumerState<_AddCustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
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
      await dio.post(
        '/Customer/AddCustomercommand',
        queryParameters: {'companyId': widget.companyId},
        data: {
          'name': _nameCtrl.text.trim(),
          'phoneNumber': _phoneCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'address': _addressCtrl.text.trim(),
          'isEnabled': true,
          'isCustomer': true,
          'isSupplier': false,
        },
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } on DioException catch (e) {
      setState(() {
        _errorMessage =
            e.response?.data?.toString() ?? "Failed to add customer.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add New Customer"),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: "Name *"),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                decoration:
                    const InputDecoration(labelText: "Phone Number"),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(labelText: "Address"),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(_errorMessage!,
                    style:
                        const TextStyle(color: Colors.red, fontSize: 13)),
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
            label: const Text("Save"),
            onPressed: _submit,
          ),
      ],
    );
  }
}