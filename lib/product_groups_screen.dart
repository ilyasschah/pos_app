import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'api_client.dart';
import 'company_provider.dart';
import 'product_group_model.dart';
import 'product_group_provider.dart';

// --- HELPER: CLEAN ERROR PARSER ---
String _parseApiError(dynamic e) {
  if (e is DioException && e.response?.data != null) {
    final data = e.response!.data;
    if (data is Map) {
      if (data.containsKey('message')) return data['message'].toString();
      if (data.containsKey('title')) return data['title'].toString();
    }
    if (data is String && !data.contains('<html') && data.length < 150)
      return data;
  }
  return "A server error occurred. Please check your inputs.";
}

// --- MAIN SCREEN ---
class ProductGroupsScreen extends ConsumerWidget {
  const ProductGroupsScreen({super.key});

  Future<void> _attemptDeleteGroup(
      BuildContext context, WidgetRef ref, ProductGroup group) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()));

    try {
      final dio = createDio();
      List children = [];
      List products = [];

      try {
        final childRes = await dio.get('/ProductGroups/GetChildren',
            queryParameters: {
              'parentId': group.id,
              'companyId': group.companyId
            });
        children = childRes.data as List;
      } catch (_) {}

      try {
        final prodRes = await dio.get('/Products/GetByProductGroup',
            queryParameters: {
              'productGroupId': group.id,
              'companyId': group.companyId
            });
        products = prodRes.data as List;
      } catch (_) {}

      if (context.mounted) Navigator.pop(context);

      if (children.isNotEmpty || products.isNotEmpty) {
        String msg =
            "This group has products or sub-groups, it can't be deleted.";
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              title: const Row(children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange),
                SizedBox(width: 8),
                Text("Cannot Delete")
              ]),
              content: Text(msg, style: const TextStyle(fontSize: 16)),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Understood"))
              ],
            ),
          );
        }
        return;
      }

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
                  child: const Text("Delete",
                      style: TextStyle(color: Colors.white))),
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
      if (context.mounted) Navigator.pop(context);
      if (context.mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(_parseApiError(e)), backgroundColor: Colors.red));
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
                context: context, builder: (_) => const _GroupEditorDialog())
            .then((_) => ref.invalidate(allProductGroupsProvider)),
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

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 260,
              childAspectRatio: 0.85,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- TOP HALF: Updated to show Name inside the Box ---
                    Expanded(
                      flex: 3,
                      child: Container(
                        color: group.imageBytes == null
                            ? group.flutterColor.withOpacity(0.15)
                            : Colors.grey[200],
                        child: group.imageBytes != null
                            ? Image.memory(group.imageBytes!, fit: BoxFit.cover)
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                      group.parentGroupId == null
                                          ? Icons.folder
                                          : Icons.subdirectory_arrow_right,
                                      size: 45,
                                      color: group.flutterColor),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text(
                                      group.name,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            group.flutterColor.withOpacity(0.9),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    // BOTTOM HALF: Details & Actions
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(group.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: Colors.blueGrey[50],
                                      borderRadius: BorderRadius.circular(4)),
                                  child: Text("Rank: ${group.rank}",
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87)),
                                ),
                                if (group.parentGroupName != null) ...[
                                  const SizedBox(width: 4),
                                  Expanded(
                                      child: Text("• ${group.parentGroupName}",
                                          style: const TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis)),
                                ]
                              ],
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blueGrey, size: 20),
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => showDialog(
                                      context: context,
                                      builder: (_) => _GroupEditorDialog(
                                          existingGroup: group)).then((_) =>
                                      ref.invalidate(allProductGroupsProvider)),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent, size: 20),
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () =>
                                      _attemptDeleteGroup(context, ref, group),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
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
  final _rankCtrl = TextEditingController(text: '0');

  String _selectedHexColor = '#607D8B';
  int? _selectedParentId;
  String? _selectedImageBase64;

  bool _isLoading = false;
  String? _errorMessage;

  bool get _isEditing => widget.existingGroup != null;

  final List<Color> _colorPalette = [
    Colors.blueGrey,
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
  ];

  String _colorToHex(Color color) =>
      '#${color.value.toRadixString(16).substring(2).toUpperCase()}';

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameCtrl.text = widget.existingGroup!.name;
      _selectedHexColor = widget.existingGroup!.color;
      _rankCtrl.text = widget.existingGroup!.rank.toString();
      _selectedParentId = widget.existingGroup!.parentGroupId;
      _selectedImageBase64 = widget.existingGroup!.image;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _rankCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85);
    if (xFile != null) {
      final bytes = await xFile.readAsBytes();
      setState(() {
        _selectedImageBase64 = base64Encode(bytes);
      });
    }
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
        'color': _selectedHexColor,
        // CRITICAL FIX: If image is null, send an empty string ("") to clear it in the database
        'image': _selectedImageBase64 ?? "",
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
        width: 450,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                      labelText: "Folder Name *", border: OutlineInputBorder()),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: allGroupsAsync.when(
                          loading: () => const LinearProgressIndicator(),
                          error: (_, __) =>
                              const Text("Failed to load parents"),
                          data: (groups) {
                            final validParents = groups
                                .where((g) =>
                                    !_isEditing ||
                                    g.id != widget.existingGroup!.id)
                                .toList();
                            return DropdownButtonFormField<int?>(
                              value: _selectedParentId,
                              decoration: const InputDecoration(
                                  labelText: "Parent Folder",
                                  border: OutlineInputBorder()),
                              items: [
                                const DropdownMenuItem(
                                    value: null,
                                    child: Text("None (Root Folder)")),
                                ...validParents.map((g) => DropdownMenuItem(
                                    value: g.id, child: Text(g.name))),
                              ],
                              onChanged: (v) =>
                                  setState(() => _selectedParentId = v),
                            );
                          }),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _rankCtrl,
                        decoration: const InputDecoration(
                            labelText: "Rank", border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text("Group Image",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[400]!),
                      ),
                      child: _selectedImageBase64 != null &&
                              _selectedImageBase64!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                  base64Decode(_selectedImageBase64!),
                                  fit: BoxFit.cover),
                            )
                          : const Icon(Icons.image,
                              color: Colors.grey, size: 30),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.upload),
                      label: const Text("Choose Image"),
                      onPressed: _pickImage,
                    ),
                    if (_selectedImageBase64 != null &&
                        _selectedImageBase64!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () =>
                            setState(() => _selectedImageBase64 = null),
                        child: const Text("Remove",
                            style: TextStyle(color: Colors.red)),
                      ),
                    ]
                  ],
                ),
                const SizedBox(height: 20),
                const Text("Fallback Folder Color",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _colorPalette.map((color) {
                    final hex = _colorToHex(color);
                    final isSelected =
                        _selectedHexColor.toUpperCase() == hex.toUpperCase();

                    return InkWell(
                      onTap: () => setState(() => _selectedHexColor = hex),
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    width: 3)
                                : null,
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                    color: color.withOpacity(0.4),
                                    blurRadius: 8,
                                    spreadRadius: 2)
                            ]),
                        child: isSelected
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 20)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 20),
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
