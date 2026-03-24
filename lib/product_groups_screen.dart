import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'api_client.dart';
import 'company_provider.dart';
import 'product_group_model.dart';

// --- PROVIDER ---
final allProductGroupsProvider =
    FutureProvider.autoDispose<List<ProductGroup>>((ref) async {
  final company = ref.watch(selectedCompanyProvider);
  if (company == null) return [];

  final dio = createDio();
  final response = await dio
      .get('/ProductGroups/GetAll', queryParameters: {'companyId': company.id});

  return (response.data as List).map((j) => ProductGroup.fromJson(j)).toList();
});

// --- HELPER: CLEAN ERROR PARSER ---
// This prevents the "Big Red Screen" by extracting only the clean, readable message from the C# backend
String _parseApiError(dynamic e) {
  if (e is DioException) {
    if (e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map) {
        if (data.containsKey('message')) return data['message'].toString();
        if (data.containsKey('Message')) return data['Message'].toString();
        if (data.containsKey('title')) return data['title'].toString();
        if (data.containsKey('detail')) return data['detail'].toString();
      }
      if (data is String) {
        // If it's a massive HTML error page, hide it and show a simple message
        if (data.contains('<html') || data.length > 150) {
          return "A server error occurred. Please check your inputs.";
        }
        return data; // Otherwise, return the safe, short string
      }
    }
    return e.message ?? "Network error occurred.";
  }
  return e.toString();
}

// --- MAIN SCREEN ---
class ProductGroupsScreen extends ConsumerWidget {
  const ProductGroupsScreen({super.key});

  Future<void> _attemptDeleteGroup(
      BuildContext context, WidgetRef ref, ProductGroup group) async {
    // 1. Show a quick loading spinner
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final dio = createDio();

      List children = [];
      List products = [];

      // 2. Safely check for children (If endpoint fails, it won't crash)
      try {
        final childRes = await dio.get('/ProductGroups/GetChildren',
            queryParameters: {
              'parentId': group.id,
              'companyId': group.companyId
            });
        children = childRes.data as List;
      } catch (_) {}

      // 3. Safely check for products (If endpoint fails, it won't crash)
      try {
        final prodRes = await dio.get('/Products/GetByProductGroup',
            queryParameters: {
              'productGroupId': group.id,
              'companyId': group.companyId
            });
        products = prodRes.data as List;
      } catch (_) {}

      // Close the loading spinner
      if (context.mounted) Navigator.pop(context);

      // 4. Exact Custom Messages based on your rules
      if (children.isNotEmpty || products.isNotEmpty) {
        String msg = "";

        if (children.isNotEmpty && products.isNotEmpty) {
          msg =
              "This group has a child group and products, it can't be deleted.";
        } else if (children.isNotEmpty) {
          msg = "This group has a child group, it can't be deleted.";
        } else if (products.isNotEmpty) {
          msg = "This group has products, it can't be deleted.";
        }

        if (context.mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              title: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange),
                  SizedBox(width: 8),
                  Text("Cannot Delete"),
                ],
              ),
              content: Text(msg, style: const TextStyle(fontSize: 16)),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Understood")),
              ],
            ),
          );
        }
        return; // Stop the delete process!
      }

      // 5. If it's completely empty, ask for final confirmation
      if (context.mounted) {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Delete Product Group"),
            content: Text("Are you sure you want to delete '${group.name}'?"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text("Cancel")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(ctx, true),
                child:
                    const Text("Delete", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );

        if (confirm == true && context.mounted) {
          await dio.delete('/ProductGroups/Delete',
              queryParameters: {'id': group.id, 'companyId': group.companyId});
          ref.invalidate(allProductGroupsProvider);
          if (context.mounted)
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Group deleted successfully"),
                backgroundColor: Colors.green));
        }
      }
    } catch (e) {
      if (context.mounted)
        Navigator.pop(context); // Ensure loading spinner is closed on error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(_parseApiError(e)), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncGroups = ref.watch(allProductGroupsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        title: const Text("Product Groups"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.create_new_folder),
        label: const Text("New Group"),
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const _GroupEditorDialog(),
        ).then((_) => ref.invalidate(allProductGroupsProvider)),
      ),
      body: asyncGroups.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text("Error: ${_parseApiError(e)}",
                style: const TextStyle(color: Colors.red))),
        data: (groups) {
          if (groups.isEmpty) {
            return const Center(
                child: Text("No product groups found. Create one!",
                    style: TextStyle(color: Colors.grey, fontSize: 16)));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: groups.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final group = groups[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: group.flutterColor.withOpacity(0.2),
                    child: Icon(
                        group.parentGroupId == null
                            ? Icons.folder
                            : Icons.subdirectory_arrow_right,
                        color: group.flutterColor),
                  ),
                  title: Text(group.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                              color: Colors.blueGrey[100],
                              borderRadius: BorderRadius.circular(12)),
                          child: Text("Rank: ${group.rank}",
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87)),
                        ),
                        if (group.parentGroupName != null) ...[
                          const SizedBox(width: 8),
                          Text("Parent: ${group.parentGroupName}",
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 13)),
                        ]
                      ],
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueGrey),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) =>
                              _GroupEditorDialog(existingGroup: group),
                        ).then((_) => ref.invalidate(allProductGroupsProvider)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () =>
                            _attemptDeleteGroup(context, ref, group),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// --- ADD/EDIT DIALOG ---
class _GroupEditorDialog extends ConsumerStatefulWidget {
  final ProductGroup? existingGroup;
  const _GroupEditorDialog({super.key, this.existingGroup});

  @override
  ConsumerState<_GroupEditorDialog> createState() => _GroupEditorDialogState();
}

class _GroupEditorDialogState extends ConsumerState<_GroupEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _colorCtrl = TextEditingController(text: '#000000');
  final _rankCtrl = TextEditingController(text: '0');
  int? _selectedParentId;

  bool _isLoading = false;
  String? _errorMessage;

  bool get _isEditing => widget.existingGroup != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameCtrl.text = widget.existingGroup!.name;
      _colorCtrl.text = widget.existingGroup!.color;
      _rankCtrl.text = widget.existingGroup!.rank.toString();
      _selectedParentId = widget.existingGroup!.parentGroupId;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _colorCtrl.dispose();
    _rankCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final company = ref.read(selectedCompanyProvider);
    if (company == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dio = createDio();
      final payload = {
        'name': _nameCtrl.text.trim(),
        'parentGroupId': _selectedParentId,
        'color': _colorCtrl.text.trim(),
        'rank': int.tryParse(_rankCtrl.text.trim()) ?? 0,
      };

      if (_isEditing) {
        payload['id'] = widget.existingGroup!.id;
        await dio.patch('/ProductGroups/Update',
            queryParameters: {'companyId': company.id}, data: payload);
      } else {
        await dio.post('/ProductGroups/Add',
            queryParameters: {'companyId': company.id}, data: payload);
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _errorMessage = _parseApiError(e);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final allGroupsAsync = ref.watch(allProductGroupsProvider);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(_isEditing ? "Edit Group" : "New Product Group",
          style: const TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                    labelText: "Name *", border: OutlineInputBorder()),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              allGroupsAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const Text("Failed to load parents"),
                  data: (groups) {
                    final validParents = groups
                        .where((g) =>
                            !_isEditing || g.id != widget.existingGroup!.id)
                        .toList();

                    return DropdownButtonFormField<int?>(
                      value: _selectedParentId,
                      decoration: const InputDecoration(
                          labelText: "Parent Group (Optional)",
                          border: OutlineInputBorder()),
                      items: [
                        const DropdownMenuItem(
                            value: null, child: Text("None (Root Folder)")),
                        ...validParents.map((g) =>
                            DropdownMenuItem(value: g.id, child: Text(g.name))),
                      ],
                      onChanged: (v) => setState(() => _selectedParentId = v),
                    );
                  }),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _colorCtrl,
                      decoration: const InputDecoration(
                          labelText: "Color Hex (e.g. #FF0000)",
                          border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _rankCtrl,
                      decoration: const InputDecoration(
                          labelText: "Display Rank",
                          border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.red.shade300)),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(_errorMessage!,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 13))),
                    ],
                  ),
                )
              ]
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel")),
        if (_isLoading)
          const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)))
        else
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo, foregroundColor: Colors.white),
            onPressed: _submit,
            child: Text(_isEditing ? "Update" : "Create"),
          ),
      ],
    );
  }
}
