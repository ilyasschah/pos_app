import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'api_client.dart';
import 'auth_provider.dart';
import 'company_provider.dart';
import 'user_model.dart';
import 'security_key_model.dart';
import 'security_key_provider.dart';

class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final company = ref.watch(selectedCompanyProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Users & Security"),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.people), text: "Users"),
              Tab(icon: Icon(Icons.security), text: "Security Rules"),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add),
              tooltip: "Add User",
              onPressed: company == null
                  ? null
                  : () async {
                      await showDialog(
                        context: context,
                        builder: (_) => _AddUserDialog(companyId: company.id),
                      );
                      ref.invalidate(allUsersProvider);
                    },
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            _UsersListTab(),
            _SecurityKeysTab(),
          ],
        ),
      ),
    );
  }
}

class _SecurityKeysTab extends ConsumerWidget {
  const _SecurityKeysTab();

  // Helper to categorize the keys exactly like Aronium
  String _getCategory(String key) {
    if (key == 'Management.Stock.QuickInventory' ||
        key == 'Management.Stock.ShowCostPrices') return 'Stock';
    if (key.startsWith('Management.') && key != 'Management')
      return 'Management';
    if (key == 'Management' ||
        key == 'Settings' ||
        key == 'BusinessDay.Close' ||
        key == 'UserProfile' ||
        key == 'FloorPlans.Design') return 'General';
    return 'Sales';
  }

  // Helper to make the database keys look pretty in the UI
  String _getFriendlyName(String key) {
    final names = {
      // General
      'Management': 'Management',
      'Settings': 'Settings',
      'BusinessDay.Close': 'End of day',
      'UserProfile': 'User profile',
      'FloorPlans.Design': 'Design floor plans',
      // Sales
      'Order.All': 'View all open orders',
      'Order.Void': 'Void order',
      'Order.Item.Void': 'Void item',
      'Order.Estimate': 'Create estimate',
      'Order.Estimate.Clear': 'Clear estimate',
      'Order.Transfer': 'Transfer order',
      'Payment.Discount': 'Apply discount',
      'Invoices.Delete': 'Delete document',
      'Refund': 'Refund',
      'Payment.TaxOverride': 'Override taxes',
      'SalesHistory': 'View sales history',
      'SalesHistory.Receipt': 'Reprint receipt',
      'CreditPayments': 'Credit payments',
      'StartingCash': 'Starting cash',
      'CashDrawer.Open': 'Open cash drawer',
      'Stock.Control.NegativeQuantity': 'Zero stock quantity sale',
      // Management
      'Management.Dashboard': 'Dashboard',
      'Management.Documents': 'Documents',
      'Management.Products': 'Products',
      'Management.Stock': 'Stock',
      'Management.Reporting': 'Reporting',
      'Management.Customers': 'Customers & suppliers',
      'Management.Promotions': 'Promotions',
      'Management.Security': 'Users & security',
      'Management.PaymentTypes': 'Payment types',
      'Management.Countries': 'Countries',
      'Management.TaxRates': 'Tax rates',
      'Management.Company': 'My company',
      // Stock
      'Management.Stock.QuickInventory': 'Quick inventory',
      'Management.Stock.ShowCostPrices': 'View cost prices',
    };
    return names[key] ?? key;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncKeys = ref.watch(allSecurityKeysProvider);
    final company = ref.watch(selectedCompanyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return asyncKeys.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("Error loading security rules: $e")),
      data: (keys) {
        if (company == null)
          return const Center(child: Text("No company selected."));
        if (keys.isEmpty)
          return const Center(child: Text("No security rules found."));

        // Group the keys into our categories
        final groupedKeys = {
          'General': <SecurityKeyModel>[],
          'Sales': <SecurityKeyModel>[],
          'Management': <SecurityKeyModel>[],
          'Stock': <SecurityKeyModel>[],
        };

        for (var k in keys) {
          groupedKeys[_getCategory(k.name)]?.add(k);
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children:
              groupedKeys.entries.where((e) => e.value.isNotEmpty).map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Header (Adaptive Blue)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.blue.shade800 : Colors.blue.shade600,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
                const SizedBox(height: 8),
                // Items built in a 2-column wrap layout
                Wrap(
                  children: entry.value.map((keyItem) {
                    return FractionallySizedBox(
                      widthFactor: 0.5, // Makes it exactly 2 columns wide
                      child: Padding(
                        padding:
                            const EdgeInsets.only(right: 16.0, bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _getFriendlyName(keyItem.name),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            _SecurityLevelDropdown(
                              securityKey: keyItem,
                              companyId: company.id,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24), // Spacing between groups
              ],
            );
          }).toList(),
        );
      },
    );
  }
}

class _SecurityLevelDropdown extends ConsumerStatefulWidget {
  final SecurityKeyModel securityKey;
  final int companyId;

  const _SecurityLevelDropdown(
      {required this.securityKey, required this.companyId});

  @override
  ConsumerState<_SecurityLevelDropdown> createState() =>
      _SecurityLevelDropdownState();
}

class _SecurityLevelDropdownState
    extends ConsumerState<_SecurityLevelDropdown> {
  bool _isLoading = false;

  Future<void> _updateLevel(int newLevel) async {
    setState(() => _isLoading = true);
    try {
      final dio = createDio();
      await dio.patch(
        '/SecurityKeys/Update',
        queryParameters: {'companyId': widget.companyId},
        data: {
          'name': widget.securityKey.name,
          'level': newLevel,
        },
      );
      ref.invalidate(allSecurityKeysProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("${widget.securityKey.name} updated."),
            backgroundColor: Colors.green),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      final errorMsg = e.response?.data?['message'] ?? "Update failed";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: Padding(
          padding: EdgeInsets.all(4.0),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return DropdownButton<int>(
      value: widget.securityKey.level,
      underline: const SizedBox(),
      focusColor: Colors.transparent,
      items: const [
        DropdownMenuItem(value: 0, child: Text("Cashier")),
        DropdownMenuItem(value: 1, child: Text("Admin")),
      ],
      onChanged: (val) {
        if (val != null && val != widget.securityKey.level) {
          _updateLevel(val);
        }
      },
    );
  }
}

class _UsersListTab extends ConsumerWidget {
  const _UsersListTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUsers = ref.watch(allUsersProvider);
    final company = ref.watch(selectedCompanyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return asyncUsers.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("Error loading users: $e")),
      data: (users) {
        if (company == null) {
          return const Center(child: Text("No company selected."));
        }
        final int companyId = company.id;
        if (users.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("No users found.",
                    style: TextStyle(color: Colors.grey, fontSize: 16)),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.person_add),
                  label: const Text("Add First User"),
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder: (_) => _AddUserDialog(companyId: companyId),
                    );
                    ref.invalidate(allUsersProvider);
                  },
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, i) {
            final user = users[i];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: user.accessLevel == 0
                    ? (isDark ? Colors.blue.shade700 : Colors.blue)
                    : (isDark ? Colors.orange.shade700 : Colors.orange),
                child: Text(
                  user.displayName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(user.displayName),
              subtitle: Text(
                "${user.accessLevel == 0 ? 'Admin' : 'Cashier'}"
                "${user.email != null && user.email!.isNotEmpty ? ' · ${user.email}' : ''}",
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit,
                        color:
                            isDark ? Colors.blueAccent : Colors.blue.shade700),
                    tooltip: "Edit User",
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (_) =>
                            _EditUserDialog(user: user, companyId: companyId),
                      );
                      ref.invalidate(allUsersProvider);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete,
                        color: isDark ? Colors.redAccent : Colors.red),
                    tooltip: "Delete User",
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Delete User"),
                          content: Text(
                              "Are you sure you want to delete ${user.displayName}?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      isDark ? Colors.redAccent : Colors.red),
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text("Delete",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        try {
                          final dio = createDio();
                          await dio.delete(
                            '/Users/Delete',
                            queryParameters: {
                              'id': user.id,
                              'companyId': companyId
                            },
                          );
                          ref.invalidate(allUsersProvider);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("User deleted successfully."),
                                backgroundColor: Colors.green),
                          );
                        } on DioException catch (e) {
                          if (!context.mounted) return;
                          final errorMsg =
                              e.response?.data?['message'] ?? "Delete failed";
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(errorMsg),
                                backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
                  ),
                  _EnableToggle(user: user, companyId: companyId),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _EnableToggle extends ConsumerStatefulWidget {
  final User user;
  final int companyId;
  const _EnableToggle({required this.user, required this.companyId});
  @override
  ConsumerState<_EnableToggle> createState() => _EnableToggleState();
}

class _EnableToggleState extends ConsumerState<_EnableToggle> {
  bool _loading = false;
  Future<void> _toggle() async {
    setState(() => _loading = true);
    try {
      final dio = createDio();
      await dio.patch(
        '/Users/UpdateUser',
        queryParameters: {'companyId': widget.companyId},
        data: {'id': widget.user.id, 'isEnabled': !widget.user.isEnabled},
      );
      ref.invalidate(allUsersProvider);
    } on DioException catch (e) {
      if (!mounted) return;
      final errorMsg = e.response?.data?['message'] ?? "Update failed";
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading)
      return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2));
    return Switch(
        value: widget.user.isEnabled,
        onChanged: (_) => _toggle(),
        activeThumbColor: Colors.green);
  }
}

class _AddUserDialog extends ConsumerStatefulWidget {
  final int companyId;
  const _AddUserDialog({required this.companyId});
  @override
  ConsumerState<_AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends ConsumerState<_AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  int _accessLevel = 1;
  bool _isLoading = false;
  final _passwordCtrl = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
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
        '/Users/Add',
        queryParameters: {'companyId': widget.companyId},
        data: {
          'firstName': _firstNameCtrl.text.trim(),
          'lastName': _lastNameCtrl.text.trim(),
          'username': _usernameCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'accessLevel': _accessLevel,
          'isEnabled': true,
          'password': _passwordCtrl.text.trim(),
        },
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } on DioException catch (e) {
      setState(() {
        _errorMessage =
            e.response?.data?['message'] ?? "Failed to create user.";
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "An unexpected error occurred.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: const Text("Add New User"),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                      child: TextFormField(
                          controller: _firstNameCtrl,
                          decoration:
                              const InputDecoration(labelText: "First Name *"),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? "Required"
                              : null)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: TextFormField(
                          controller: _lastNameCtrl,
                          decoration:
                              const InputDecoration(labelText: "Last Name *"),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? "Required"
                              : null)),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                  controller: _usernameCtrl,
                  decoration: const InputDecoration(labelText: "Username *"),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? "Required" : null),
              const SizedBox(height: 12),
              TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(labelText: "Email"),
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              TextFormField(
                  controller: _passwordCtrl,
                  decoration: const InputDecoration(labelText: "Password *"),
                  obscureText: true,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? "Required" : null),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: _accessLevel,
                decoration: const InputDecoration(labelText: "Access Level"),
                items: const [
                  DropdownMenuItem(value: 0, child: Text("Admin")),
                  DropdownMenuItem(value: 1, child: Text("Cashier"))
                ],
                onChanged: (v) => setState(() => _accessLevel = v ?? 1),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(_errorMessage!,
                    style: TextStyle(
                        color: isDark ? Colors.redAccent : Colors.red,
                        fontSize: 13))
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
              padding: EdgeInsets.all(8.0), child: CircularProgressIndicator())
        else
          ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text("Save"),
              onPressed: _submit),
      ],
    );
  }
}

class _EditUserDialog extends ConsumerStatefulWidget {
  final User user;
  final int companyId;
  const _EditUserDialog({required this.user, required this.companyId});
  @override
  ConsumerState<_EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends ConsumerState<_EditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _emailCtrl;
  late int _accessLevel;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController(text: widget.user.firstName ?? '');
    _lastNameCtrl = TextEditingController(text: widget.user.lastName ?? '');
    _usernameCtrl = TextEditingController(text: widget.user.username);
    _emailCtrl = TextEditingController(text: widget.user.email ?? '');
    _accessLevel =
        (widget.user.accessLevel == 0 || widget.user.accessLevel == 1)
            ? widget.user.accessLevel
            : 1;
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
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
      await dio.patch(
        '/Users/UpdateUser',
        queryParameters: {'companyId': widget.companyId},
        data: {
          'id': widget.user.id,
          'accessLevel': _accessLevel,
          'firstName': _firstNameCtrl.text.trim(),
          'lastName': _lastNameCtrl.text.trim(),
          'username': _usernameCtrl.text.trim(),
          'email': _emailCtrl.text.trim()
        },
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } on DioException catch (e) {
      setState(() {
        _errorMessage =
            e.response?.data?['message'] ?? "Failed to update user.";
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "An unexpected error occurred.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: Text("Edit ${widget.user.displayName}"),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                      child: TextFormField(
                          controller: _firstNameCtrl,
                          decoration:
                              const InputDecoration(labelText: "First Name"))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: TextFormField(
                          controller: _lastNameCtrl,
                          decoration:
                              const InputDecoration(labelText: "Last Name"))),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                  controller: _usernameCtrl,
                  decoration: const InputDecoration(labelText: "Username"),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? "Required" : null),
              const SizedBox(height: 12),
              TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(labelText: "Email"),
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: _accessLevel,
                decoration: const InputDecoration(labelText: "Access Level"),
                items: const [
                  DropdownMenuItem(value: 0, child: Text("Admin")),
                  DropdownMenuItem(value: 1, child: Text("Cashier"))
                ],
                onChanged: (v) => setState(() => _accessLevel = v ?? 1),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(_errorMessage!,
                    style: TextStyle(
                        color: isDark ? Colors.redAccent : Colors.red,
                        fontSize: 13))
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
              padding: EdgeInsets.all(8.0), child: CircularProgressIndicator())
        else
          ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text("Update"),
              onPressed: _submit),
      ],
    );
  }
}
