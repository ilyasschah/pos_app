import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'api_client.dart';
import 'auth_provider.dart';
import 'company_provider.dart';
import 'user_model.dart';

class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUsers = ref.watch(allUsersProvider);
    final company = ref.watch(selectedCompanyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Users"),
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
      body: asyncUsers.when(
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
                    onPressed: company == null
                        ? null
                        : () async {
                            await showDialog(
                              context: context,
                              builder: (_) =>
                                  _AddUserDialog(companyId: companyId),
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
                  backgroundColor:
                      user.accessLevel == 0 ? Colors.blue : Colors.orange,
                  child: Text(
                    user.displayName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(user.displayName),
                subtitle: Text(
                  "${user.accessLevel == 0 ? 'Admin' : 'Cashier'}"
                  "${user.email != null ? ' · ${user.email}' : ''}",
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Edit button
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueGrey),
                      tooltip: "Edit User",
                      onPressed: company == null
                          ? null
                          : () async {
                              await showDialog(
                                context: context,
                                builder: (_) => _EditUserDialog(
                                  user: user,
                                  companyId: companyId,
                                ),
                              );
                              ref.invalidate(allUsersProvider);
                            },
                    ),
                    // Delete button
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: "Delete User",
                      onPressed: company == null
                          ? null
                          : () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("Delete User"),
                                  content: Text(
                                      "Are you sure you want to delete ${user.displayName}?"),
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
                              if (confirm == true) {
                                await _deleteUser(
                                    context, ref, user.id, companyId);
                              }
                            },
                    ),
                    // Enable/Disable toggle
                    _EnableToggle(user: user, companyId: companyId),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _deleteUser(
      BuildContext context, WidgetRef ref, int userId, int companyId) async {
    try {
      final dio = createDio();
      await dio.delete(
        '/Users/Delete',
        queryParameters: {'id': userId, 'companyId': companyId},
      );
      ref.invalidate(allUsersProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("User deleted"), backgroundColor: Colors.green),
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

// --- ENABLE / DISABLE TOGGLE ---
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
      // PATCH — only send isEnabled, null fields won't overwrite
      await dio.patch(
        '/Users/UpdateUser',
        queryParameters: {'companyId': widget.companyId},
        data: {
          'id': widget.user.id,
          'isEnabled': !widget.user.isEnabled,
        },
      );
      ref.invalidate(allUsersProvider);
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.response?.data?.toString() ?? "Update failed"),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2));
    }
    return Switch(
      value: widget.user.isEnabled,
      onChanged: (_) => _toggle(),
      activeThumbColor: Colors.green,
    );
  }
}

// --- ADD USER DIALOG ---
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
            e.response?.data?.toString() ?? "Failed to create user.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameCtrl,
                      decoration:
                          const InputDecoration(labelText: "Last Name *"),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? "Required" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _usernameCtrl,
                decoration: const InputDecoration(labelText: "Username *"),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordCtrl,
                decoration: const InputDecoration(labelText: "Password *"),
                obscureText: true,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: [0, 1].contains(_accessLevel) ? _accessLevel : 1,
                decoration: const InputDecoration(labelText: "Access Level"),
                items: const [
                  DropdownMenuItem(value: 0, child: Text("Admin")),
                  DropdownMenuItem(value: 1, child: Text("Cashier")),
                ],
                onChanged: (v) => setState(() => _accessLevel = v ?? 1),
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
            label: const Text("Save"),
            onPressed: _submit,
          ),
      ],
    );
  }
}

// --- EDIT USER DIALOG ---
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
    // Pre-fill with current user data
    _firstNameCtrl = TextEditingController(text: widget.user.firstName ?? '');
    _lastNameCtrl = TextEditingController(text: widget.user.lastName ?? '');
    _usernameCtrl = TextEditingController(text: widget.user.username);
    _emailCtrl = TextEditingController(text: widget.user.email ?? '');
    _accessLevel = widget.user.accessLevel;
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
      // PATCH — send only non-empty fields so null won't overwrite existing data
      final Map<String, dynamic> payload = {
        'id': widget.user.id,
        'accessLevel': _accessLevel,
      };

      if (_firstNameCtrl.text.trim().isNotEmpty) {
        payload['firstName'] = _firstNameCtrl.text.trim();
      }
      if (_lastNameCtrl.text.trim().isNotEmpty) {
        payload['lastName'] = _lastNameCtrl.text.trim();
      }
      if (_usernameCtrl.text.trim().isNotEmpty) {
        payload['username'] = _usernameCtrl.text.trim();
      }
      if (_emailCtrl.text.trim().isNotEmpty) {
        payload['email'] = _emailCtrl.text.trim();
      }

      await dio.patch(
        '/Users/UpdateUser',
        queryParameters: {'companyId': widget.companyId},
        data: payload,
      );

      if (!mounted) return;
      Navigator.of(context).pop();
    } on DioException catch (e) {
      setState(() {
        _errorMessage =
            e.response?.data?.toString() ?? "Failed to update user.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                          const InputDecoration(labelText: "First Name"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameCtrl,
                      decoration: const InputDecoration(labelText: "Last Name"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _usernameCtrl,
                decoration: const InputDecoration(labelText: "Username"),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: [0, 1].contains(_accessLevel) ? _accessLevel : 0,
                decoration: const InputDecoration(labelText: "Access Level"),
                items: const [
                  DropdownMenuItem(value: 0, child: Text("Admin")),
                  DropdownMenuItem(value: 1, child: Text("Cashier")),
                ],
                onChanged: (v) => setState(() => _accessLevel = v ?? 1),
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
            label: const Text("Update"),
            onPressed: _submit,
          ),
      ],
    );
  }
}
