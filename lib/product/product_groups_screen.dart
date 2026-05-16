import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/product/product_group_model.dart';
import 'package:pos_app/product/product_group_provider.dart';
import 'package:pos_app/product/product_group_service.dart';
import 'package:pos_app/utils/api_error_parser.dart';

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
      final service = ref.read(productGroupServiceProvider);
      List<dynamic> children = [];
      List<dynamic> products = [];

      try {
        children = await service.getChildren(group.id, group.companyId);
      } catch (_) {}

      try {
        products = await service.getProductsByGroup(group.id, group.companyId);
      } catch (_) {}

      if (context.mounted) Navigator.pop(context);

      if (children.isNotEmpty || products.isNotEmpty) {
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
              content: const Text(
                "This group has products or sub-groups, it can't be deleted.",
                style: TextStyle(fontSize: 16),
              ),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(ctx).colorScheme.error,
                    foregroundColor: Theme.of(ctx).colorScheme.onError,
                  ),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text("Delete")),
            ],
          ),
        );

        if (confirm == true && context.mounted) {
          await service.delete(group.id, group.companyId);
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
            content: Text(parseApiError(e)), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncGroups = ref.watch(allProductGroupsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Product Groups"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
                context: context, builder: (_) => const _GroupEditorDialog())
            .then((_) => ref.invalidate(allProductGroupsProvider)),
        icon: const Icon(Icons.add),
        label: const Text("New Group"),
        tooltip: "Create a new product group",
      ),
      body: asyncGroups.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error.withAlpha(128)),
              const SizedBox(height: 16),
              Text(
                "Error loading groups",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                parseApiError(e),
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ),
        ),
        data: (groups) {
          if (groups.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary.withAlpha(64)),
                  const SizedBox(height: 24),
                  Text(
                    "No product groups yet",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Create one to organize your products",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(128)),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => showDialog(
                            context: context,
                            builder: (_) => const _GroupEditorDialog())
                        .then((_) =>
                            ref.invalidate(allProductGroupsProvider)),
                    icon: const Icon(Icons.add),
                    label: const Text("Create Group"),
                  ),
                ],
              ),
            );
          }

          return LayoutBuilder(builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final isMobile = screenWidth < 600;
            final isTablet = screenWidth < 1200;

            int crossAxisCount;
            if (isMobile) {
              crossAxisCount = 1;
            } else if (isTablet) {
              crossAxisCount = 2;
            } else {
              crossAxisCount = 3;
            }

            return SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 12 : 20),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.95,
                  crossAxisSpacing: isMobile ? 8 : 16,
                  mainAxisSpacing: isMobile ? 8 : 16,
                ),
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final group = groups[index];
                  return _ProductGroupCard(
                    group: group,
                    onEdit: () => showDialog(
                            context: context,
                            builder: (_) =>
                                _GroupEditorDialog(existingGroup: group))
                        .then((_) =>
                            ref.invalidate(allProductGroupsProvider)),
                    onDelete: () => _attemptDeleteGroup(context, ref, group),
                  );
                },
              ),
            );
          });
        },
      ),
    );
  }
}

// --- PRODUCT GROUP CARD ---
class _ProductGroupCard extends StatefulWidget {
  final ProductGroup group;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductGroupCard({
    required this.group,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_ProductGroupCard> createState() => _ProductGroupCardState();
}

class _ProductGroupCardState extends State<_ProductGroupCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _setHovered(bool hovered) {
    setState(() => _isHovered = hovered);
    if (hovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final surfaceVariant = Theme.of(context).colorScheme.surfaceContainer;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: GestureDetector(
        onTap: widget.onEdit,
        child: ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: 1.02).animate(
            CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
          ),
          child: Card(
            elevation: _isHovered ? 8 : 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: _isHovered
                    ? Border.all(color: primary.withAlpha(100), width: 2)
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- IMAGE/ICON SECTION ---
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.group.imageBytes == null
                            ? widget.group.flutterColor.withValues(alpha: 0.12)
                            : surfaceVariant,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: widget.group.imageBytes != null
                          ? ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                              child: Image.memory(
                                widget.group.imageBytes!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  widget.group.parentGroupId == null
                                      ? Icons.folder
                                      : Icons.subdirectory_arrow_right,
                                  size: 56,
                                  color: widget.group.flutterColor,
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    widget.group.name,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: widget.group.flutterColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  // --- INFO & ACTIONS SECTION ---
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Group name
                          Text(
                            widget.group.name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),

                          // Rank badge and parent
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: primary.withAlpha(30),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: primary.withAlpha(60)),
                                ),
                                child: Text(
                                  "Rank: ${widget.group.rank}",
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                              if (widget.group.parentGroupName != null) ...[
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "• ${widget.group.parentGroupName}",
                                    style: Theme.of(context).textTheme.labelSmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withAlpha(128),
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ]
                            ],
                          ),

                          const Spacer(),

                          // --- ACTION BUTTONS ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Edit button
                              Tooltip(
                                message: "Edit group",
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: widget.onEdit,
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.edit,
                                        color: primary,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              // Delete button
                              Tooltip(
                                message: "Delete group",
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: widget.onDelete,
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.delete,
                                        color: Theme.of(context).colorScheme.error,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- ADD/EDIT DIALOG ---
class _GroupEditorDialog extends ConsumerStatefulWidget {
  final ProductGroup? existingGroup;
  const _GroupEditorDialog({this.existingGroup});

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
      '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

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
      final service = ref.read(productGroupServiceProvider);
      final Map<String, dynamic> payload = {
        'name': _nameCtrl.text.trim(),
        'parentGroupId': _selectedParentId,
        'color': _selectedHexColor,
        'image': _selectedImageBase64 ?? "",
        'rank': int.tryParse(_rankCtrl.text.trim()) ?? 0,
      };

      if (_isEditing) {
        payload['id'] = widget.existingGroup!.id;
        await service.update(company.id, payload);
      } else {
        await service.add(company.id, payload);
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _errorMessage = parseApiError(e);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final allGroupsAsync = ref.watch(allProductGroupsProvider);
    final primary = Theme.of(context).colorScheme.primary;
    final surface = Theme.of(context).colorScheme.surface;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 500,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- HEADER ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isEditing ? Icons.edit : Icons.add,
                    color: primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEditing ? "Edit Product Group" : "New Product Group",
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isEditing
                              ? "Update group details"
                              : "Create a new product group",
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withAlpha(128),
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // --- FORM CONTENT ---
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- GROUP NAME ---
                      Text(
                        "Group Name",
                        style: Theme.of(context).textTheme.labelLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(
                          hintText: "e.g., Beverages, Desserts",
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? "Required" : null,
                      ),
                      const SizedBox(height: 24),

                      // --- PARENT GROUP ---
                      Text(
                        "Parent Folder",
                        style: Theme.of(context).textTheme.labelLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      allGroupsAsync.when(
                        loading: () => const LinearProgressIndicator(),
                        error: (_, __) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            "Failed to load parent groups",
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                              color:
                                  Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                        data: (groups) {
                          final validParents = groups
                              .where((g) =>
                                  !_isEditing ||
                                  g.id != widget.existingGroup!.id)
                              .toList();
                          return DropdownButtonFormField<int?>(
                            initialValue: _selectedParentId,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text("None (Root Folder)"),
                              ),
                              ...validParents.map((g) => DropdownMenuItem(
                                    value: g.id,
                                    child: Text(g.name),
                                  )),
                            ],
                            onChanged: (v) =>
                                setState(() => _selectedParentId = v),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // --- RANK ---
                      Text(
                        "Display Order (Rank)",
                        style: Theme.of(context).textTheme.labelLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _rankCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "0",
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // --- IMAGE SECTION ---
                      Text(
                        "Folder Image",
                        style: Theme.of(context).textTheme.labelLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: primary.withAlpha(60),
                                width: 2,
                              ),
                            ),
                            child: _selectedImageBase64 != null &&
                                    _selectedImageBase64!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.memory(
                                      base64Decode(_selectedImageBase64!),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(
                                    Icons.image,
                                    color: primary.withAlpha(100),
                                    size: 40,
                                  ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _pickImage,
                                  icon: const Icon(Icons.upload),
                                  label: const Text("Choose Image"),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                                if (_selectedImageBase64 != null &&
                                    _selectedImageBase64!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  TextButton.icon(
                                    onPressed: () => setState(
                                        () => _selectedImageBase64 = null),
                                    icon: const Icon(Icons.close),
                                    label: const Text("Remove"),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Theme.of(context)
                                          .colorScheme
                                          .error,
                                    ),
                                  ),
                                ]
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 24),

                      // --- COLOR PALETTE ---
                      Text(
                        "Fallback Folder Color",
                        style: Theme.of(context).textTheme.labelLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _colorPalette.map((color) {
                          final hex = _colorToHex(color);
                          final isSelected = _selectedHexColor.toUpperCase() ==
                              hex.toUpperCase();

                          return InkWell(
                            onTap: () =>
                                setState(() => _selectedHexColor = hex),
                            borderRadius: BorderRadius.circular(24),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 120),
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(color: primary, width: 3)
                                    : Border.all(
                                        color: primary.withAlpha(40),
                                        width: 1,
                                      ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: color.withAlpha(100),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        )
                                      ]
                                    : null,
                              ),
                              child: isSelected
                                  ? Icon(
                                      Icons.check,
                                      size: 24,
                                      color: color.computeLuminance() > 0.4
                                          ? const Color(0xFF1A1A1A)
                                          : const Color(0xFFFAFAFA),
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // --- ERROR MESSAGE ---
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.error.withAlpha(20),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .error
                                  .withAlpha(60),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline,
                                  color: Theme.of(context).colorScheme.error,
                                  size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // --- ACTIONS ---
            Container(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _submit,
                    icon: _isLoading
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : Icon(_isEditing ? Icons.save : Icons.add),
                    label: Text(_isEditing ? "Update" : "Create"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
