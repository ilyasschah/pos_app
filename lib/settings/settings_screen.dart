// lib/settings_screen.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:pos_app/database/database_provider.dart';
import 'package:pos_app/database/backup_service.dart';
import 'package:pos_app/utils/customer_display_service.dart';
import 'package:pos_app/customer_display/customer_display_web_server.dart';
import 'package:pos_app/customer_display/customer_display_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:pos_app/app_settings/app_settings_model.dart';
import 'package:pos_app/app_settings/app_settings_provider.dart';
import 'package:pos_app/app_settings/service_type_model.dart';
import 'package:pos_app/app_settings/service_status_model.dart';
import 'package:pos_app/app_settings/booking_settings_model.dart';
import 'package:pos_app/auth/auth_provider.dart';
import 'package:pos_app/auth/login_screen.dart';
import 'package:pos_app/cart/cart_provider.dart';
import 'package:pos_app/currency/currencies_provider.dart';
import 'package:pos_app/floor_plan/floor_plan_table_provider.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/currency/country_model.dart';
import 'package:dio/dio.dart';
import 'package:pos_app/settings/printer_settings_screen.dart';
import 'package:pos_app/kitchen/kitchen_push_service.dart';
import 'package:pos_app/utils/snackbar_helper.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ENTRY POINT
// ─────────────────────────────────────────────────────────────────────────────
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _selectedIndex = 0;

  static const _tabs = [
    (icon: Icons.tune,              label: 'General'),
    (icon: Icons.receipt_long,      label: 'Order & Payment'),
    (icon: Icons.inventory_2,       label: 'Products'),
    (icon: Icons.description,       label: 'Documents'),
    (icon: Icons.monitor_weight,    label: 'Weighing Scale'),
    (icon: Icons.display_settings,  label: 'Customer Display'),
    (icon: Icons.kitchen,           label: 'Kitchen Display'),
    (icon: Icons.email,             label: 'Email'),
    (icon: Icons.print,             label: 'Print'),
    (icon: Icons.currency_exchange, label: 'Dual Currency'),
    (icon: Icons.storage,           label: 'Database'),
    (icon: Icons.vpn_key,           label: 'License'),
    (icon: Icons.info_outline,      label: 'About'),
    (icon: Icons.public,            label: 'Countries'),
  ];

  static const _tabViews = [
    _GeneralTab(),
    _OrderPaymentTab(),
    _ProductsTab(),
    _DocumentsTab(),
    _WeighingScaleTab(),
    _CustomerDisplayTab(),
    _KitchenDisplayTab(),
    _EmailTab(),
    _PrintTab(),
    _DualCurrencyTab(),
    _DatabaseTab(),
    _LicenseTab(),
    _AboutTab(),
    _CountriesTab(),
  ];

  Future<void> _saveAndRestart() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      ref.read(cartProvider.notifier).clearCart();
      ref.read(floorPlanTableProvider.notifier).state = null;
      ref.invalidate(currentUserProvider);

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        showAppSnackbar(context, ref, 'Failed to save settings: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(rawAppPropertiesProvider).isLoading;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
        actions: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          TextButton.icon(
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save & Restart'),
            onPressed: _saveAndRestart,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          // ── Left sidebar ────────────────────────────────────────────────
          Material(
            color: cs.surfaceContainerLow,
            child: SizedBox(
              width: 210,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _tabs.length,
                itemBuilder: (context, i) {
                  final tab = _tabs[i];
                  final active = i == _selectedIndex;
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      tab.icon,
                      size: 18,
                      color: active ? cs.primary : cs.onSurfaceVariant,
                    ),
                    title: Text(
                      tab.label,
                      style: TextStyle(
                        fontSize: 13,
                        color: active ? cs.primary : cs.onSurface,
                        fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    selected: active,
                    selectedTileColor: cs.primaryContainer.withValues(alpha: 0.35),
                    onTap: () => setState(() => _selectedIndex = i),
                  );
                },
              ),
            ),
          ),
          VerticalDivider(width: 1, color: cs.outlineVariant),
          // ── Content ─────────────────────────────────────────────────────
          Expanded(child: _tabViews[_selectedIndex]),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shadowColor: theme.shadowColor.withValues(alpha: 0.08),
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.1)),
          ...children,
        ],
      ),
    );
  }
}

// A text field row that saves on focus-loss / submit
class _SettingTextField extends ConsumerStatefulWidget {
  final String settingKey;
  final String label;
  final String? hint;
  final bool obscure;
  final TextInputType keyboardType;

  const _SettingTextField({
    required this.settingKey,
    required this.label,
    this.hint,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  ConsumerState<_SettingTextField> createState() => _SettingTextFieldState();
}

class _SettingTextFieldState extends ConsumerState<_SettingTextField> {
  late final TextEditingController _ctrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final value = ref.read(appSettingsProvider.notifier).get(widget.settingKey);
    _ctrl = TextEditingController(text: value);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final notifier = ref.read(appSettingsProvider.notifier);
    if (_ctrl.text == notifier.get(widget.settingKey)) return;
    setState(() => _saving = true);
    try {
      await notifier.set(widget.settingKey, _ctrl.text.trim());
      if (mounted) {
        showAppSnackbar(context, ref, '${widget.label} saved');
      }
    } catch (_) {
      if (mounted) {
        showAppSnackbar(context, ref, 'Failed to save ${widget.label}', isError: true);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _ctrl,
              obscureText: widget.obscure,
              keyboardType: widget.keyboardType,
              maxLines: 1,
              decoration: InputDecoration(
                labelText: widget.label,
                hintText: widget.hint,
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                isDense: true,
              ),
              onSubmitted: (_) => _save(),
              onEditingComplete: _save,
            ),
          ),
          const SizedBox(width: 8),
          _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : IconButton(
                  icon: Icon(
                    Icons.check_circle_outline,
                    color: theme.colorScheme.primary,
                  ),
                  tooltip: 'Save',
                  onPressed: _save,
                ),
        ],
      ),
    );
  }
}

// A toggle (switch) row that saves immediately on change
class _SettingSwitch extends ConsumerWidget {
  final String settingKey;
  final String label;
  final String? subtitle;
  final void Function(WidgetRef, bool)? onChanged;

  const _SettingSwitch({
    required this.settingKey,
    required this.label,
    this.subtitle,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final value =
        ref.watch(appSettingsProvider)[settingKey]?.toLowerCase() == 'true';

    return SwitchListTile(
      title: Text(label),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      value: value,
      activeThumbColor: theme.colorScheme.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      onChanged: (v) {
        ref.read(appSettingsProvider.notifier).setBool(settingKey, v);
        onChanged?.call(ref, v);
      },
    );
  }
}

// A dropdown row
class _SettingDropdown extends ConsumerWidget {
  final String settingKey;
  final String label;
  final List<String> options;

  const _SettingDropdown({
    required this.settingKey,
    required this.label,
    required this.options,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final current =
        ref.watch(appSettingsProvider)[settingKey] ??
        kSettingDefaults[settingKey] ??
        options.first;

    final safeValue = options.contains(current) ? current : options.first;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: safeValue,
              decoration: InputDecoration(
                labelText: label,
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                isDense: true,
              ),
              dropdownColor: theme.colorScheme.surfaceContainerHighest,
              items: options
                  .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  ref.read(appSettingsProvider.notifier).set(settingKey, v);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Custom service-type editor ────────────────────────────────────────────────

class _CustomServiceTypesEditor extends ConsumerStatefulWidget {
  const _CustomServiceTypesEditor();

  @override
  ConsumerState<_CustomServiceTypesEditor> createState() =>
      _CustomServiceTypesEditorState();
}

class _CustomServiceTypesEditorState
    extends ConsumerState<_CustomServiceTypesEditor> {
  static const _palette = [
    Color(0xFF3F51B5),
    Color(0xFFFF5722),
    Color(0xFF4CAF50),
    Color(0xFF9C27B0),
    Color(0xFF009688),
    Color(0xFF795548),
  ];

  List<CustomServiceType> get _types =>
      ref.read(appSettingsProvider.notifier).customServiceTypes;

  Future<void> _save(List<CustomServiceType> updated) async {
    await ref
        .read(appSettingsProvider.notifier)
        .set(
          SettingKeys.customServiceTypes,
          CustomServiceType.listToJson(updated),
        );
    ref.read(cartProvider.notifier).clearCart();
  }

  Future<void> _showTypeDialog({CustomServiceType? existing}) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final prefixCtrl = TextEditingController(text: existing?.prefix ?? '');
    final result = await showDialog<List<String>>(
      context: context,
      builder: (_) => _TypeFormDialog(
        nameCtrl: nameCtrl,
        prefixCtrl: prefixCtrl,
        isEdit: existing != null,
      ),
    );
    if (result == null || !mounted) return;
    final name = result[0];
    final prefix = result[1];
    final updated = List<CustomServiceType>.from(_types);
    if (existing == null) {
      final nextId = updated.isEmpty
          ? 0
          : updated.map((t) => t.id).reduce((a, b) => a > b ? a : b) + 1;
      updated.add(CustomServiceType(id: nextId, name: name, prefix: prefix));
    } else {
      final i = updated.indexWhere((t) => t.id == existing.id);
      if (i >= 0) updated[i] = existing.copyWith(name: name, prefix: prefix);
    }
    await _save(updated);
  }

  Future<void> _delete(CustomServiceType target) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Service Type'),
        content: Text('Remove "${target.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _save(_types.where((t) => t.id != target.id).toList());
  }

  @override
  Widget build(BuildContext context) {
    // Watch so the list rebuilds when the setting is persisted.
    ref.watch(appSettingsProvider);
    final types = _types;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Service Types', style: theme.textTheme.labelLarge),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _showTypeDialog(),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ...types.asMap().entries.map((entry) {
            final idx = entry.key;
            final t = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Material(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                dense: true,
                leading: CircleAvatar(
                  backgroundColor: _palette[idx % _palette.length],
                  radius: 14,
                  child: Text(
                    '${t.id}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(t.name),
                subtitle: Text(
                  'Prefix: ${t.prefix}',
                  style: theme.textTheme.bodySmall,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      onPressed: () => _showTypeDialog(existing: t),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      color: theme.colorScheme.error,
                      onPressed: () => _delete(t),
                    ),
                  ],
                ),
              ),
            ),
          );
          }),
        ],
      ),
    );
  }
}

class _TypeFormDialog extends StatefulWidget {
  final TextEditingController nameCtrl;
  final TextEditingController prefixCtrl;
  final bool isEdit;

  const _TypeFormDialog({
    required this.nameCtrl,
    required this.prefixCtrl,
    required this.isEdit,
  });

  @override
  State<_TypeFormDialog> createState() => _TypeFormDialogState();
}

class _TypeFormDialogState extends State<_TypeFormDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEdit ? 'Edit Service Type' : 'Add Service Type'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: widget.nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'e.g. Uber Eats',
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: widget.prefixCtrl,
            decoration: const InputDecoration(
              labelText: 'Order Number Prefix',
              hintText: 'e.g. UBER',
            ),
            onChanged: (v) {
              final upper = v.toUpperCase();
              if (v != upper) {
                widget.prefixCtrl.value = widget.prefixCtrl.value.copyWith(
                  text: upper,
                  selection: TextSelection.collapsed(offset: upper.length),
                );
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = widget.nameCtrl.text.trim();
            final prefix = widget.prefixCtrl.text.trim().toUpperCase();
            if (name.isNotEmpty && prefix.isNotEmpty) {
              Navigator.pop(context, [name, prefix]);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// ── Custom service-status editor ──────────────────────────────────────────────

class _CustomServiceStatusesEditor extends ConsumerStatefulWidget {
  const _CustomServiceStatusesEditor();

  @override
  ConsumerState<_CustomServiceStatusesEditor> createState() =>
      _CustomServiceStatusesEditorState();
}

class _CustomServiceStatusesEditorState
    extends ConsumerState<_CustomServiceStatusesEditor> {
  List<CustomServiceStatus> get _statuses =>
      ref.read(appSettingsProvider.notifier).customServiceStatuses;

  Future<void> _save(List<CustomServiceStatus> updated) async {
    await ref
        .read(appSettingsProvider.notifier)
        .set(
          SettingKeys.customServiceStatuses,
          CustomServiceStatus.listToJson(updated),
        );
    ref.read(cartProvider.notifier).clearCart();
  }

  Future<void> _showStatusDialog({CustomServiceStatus? existing}) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    int pickedColor = existing?.colorValue ?? 0xFF2196F3;
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _StatusFormDialog(
        nameCtrl: nameCtrl,
        initialColor: pickedColor,
        isEdit: existing != null,
      ),
    );
    if (result == null || !mounted) return;
    final name = result['name'] as String;
    final colorValue = result['colorValue'] as int;
    final updated = List<CustomServiceStatus>.from(_statuses);
    if (existing == null) {
      final nextId = updated.isEmpty
          ? 1
          : updated.map((s) => s.id).reduce((a, b) => a > b ? a : b) + 1;
      updated.add(
        CustomServiceStatus(id: nextId, name: name, colorValue: colorValue),
      );
    } else {
      final i = updated.indexWhere((s) => s.id == existing.id);
      if (i >= 0)
        updated[i] = existing.copyWith(name: name, colorValue: colorValue);
    }
    await _save(updated);
  }

  Future<void> _delete(CustomServiceStatus target) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Service Status'),
        content: Text('Remove "${target.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _save(_statuses.where((s) => s.id != target.id).toList());
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(appSettingsProvider);
    final statuses = _statuses;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Service Statuses', style: theme.textTheme.labelLarge),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _showStatusDialog(),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ...statuses.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Material(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    backgroundColor: s.color,
                    radius: 14,
                    child: Text(
                      '${s.id}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(s.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        onPressed: () => _showStatusDialog(existing: s),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        color: theme.colorScheme.error,
                        onPressed: () => _delete(s),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusFormDialog extends StatefulWidget {
  final TextEditingController nameCtrl;
  final int initialColor;
  final bool isEdit;

  const _StatusFormDialog({
    required this.nameCtrl,
    required this.initialColor,
    required this.isEdit,
  });

  @override
  State<_StatusFormDialog> createState() => _StatusFormDialogState();
}

class _StatusFormDialogState extends State<_StatusFormDialog> {
  static const _presets = [
    Color(0xFF2196F3), // Blue
    Color(0xFFFF9800), // Orange
    Color(0xFF4CAF50), // Green
    Color(0xFFF44336), // Red
    Color(0xFF9C27B0), // Purple
    Color(0xFF009688), // Teal
    Color(0xFFFFC107), // Amber
    Color(0xFFE91E63), // Pink
    Color(0xFF3F51B5), // Indigo
    Color(0xFFFF5722), // Deep Orange
    Color(0xFF795548), // Brown
    Color(0xFF9E9E9E), // Grey
  ];

  late int _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEdit ? 'Edit Service Status' : 'Add Service Status'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: widget.nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'e.g. Waiting',
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          const Text('Color', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _presets.map((c) {
              final isSelected = c.toARGB32() == _selected;
              return GestureDetector(
                onTap: () => setState(() => _selected = c.toARGB32()),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(
                            color: Theme.of(context).colorScheme.onSurface,
                            width: 3,
                          )
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = widget.nameCtrl.text.trim();
            if (name.isNotEmpty) {
              Navigator.pop(context, {'name': name, 'colorValue': _selected});
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// ── Booking settings card ─────────────────────────────────────────────────────

class _BookingSettingsCard extends ConsumerStatefulWidget {
  const _BookingSettingsCard();

  @override
  ConsumerState<_BookingSettingsCard> createState() =>
      _BookingSettingsCardState();
}

class _BookingSettingsCardState extends ConsumerState<_BookingSettingsCard> {
  static const _snappingOptions = [5, 10, 15, 30, 60];
  static const _durationOptions = [15, 30, 45, 60, 90, 120, 180, 240];

  BookingSettingsModel get _current =>
      ref.read(appSettingsProvider.notifier).bookingSettings;

  Future<void> _save(BookingSettingsModel updated) =>
      ref.read(appSettingsProvider.notifier).setBookingSettings(updated);

  @override
  Widget build(BuildContext context) {
    ref.watch(appSettingsProvider);
    final s = _current;
    final theme = Theme.of(context);

    return _SettingsCard(
      title: 'BOOKING',
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Resource Mode ──────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Resource Mode',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'What a booking slot is assigned to',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: s.resourceMode,
                    underline: const SizedBox.shrink(),
                    borderRadius: BorderRadius.circular(8),
                    items: const [
                      DropdownMenuItem(
                        value: 'table',
                        child: Row(
                          children: [
                            Icon(Icons.table_restaurant, size: 16),
                            SizedBox(width: 6),
                            Text('Table'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'room',
                        child: Row(
                          children: [
                            Icon(Icons.meeting_room, size: 16),
                            SizedBox(width: 6),
                            Text('Room'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'staff',
                        child: Row(
                          children: [
                            Icon(Icons.person, size: 16),
                            SizedBox(width: 6),
                            Text('Staff'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) _save(s.copyWith(resourceMode: v));
                    },
                  ),
                ],
              ),
              const Divider(height: 28),

              // ── Default Duration ───────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Default Duration',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Pre-filled slot length when adding a booking',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<int>(
                    value: _durationOptions.contains(s.defaultDurationMinutes)
                        ? s.defaultDurationMinutes
                        : _durationOptions.last,
                    underline: const SizedBox.shrink(),
                    borderRadius: BorderRadius.circular(8),
                    items: _durationOptions
                        .map(
                          (m) => DropdownMenuItem(
                            value: m,
                            child: Text(_formatDuration(m)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null)
                        _save(s.copyWith(defaultDurationMinutes: v));
                    },
                  ),
                ],
              ),
              const Divider(height: 28),

              // ── Time Snapping ──────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Time Snapping',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Grid interval when picking start/end times',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<int>(
                    value: _snappingOptions.contains(s.timeSnappingMinutes)
                        ? s.timeSnappingMinutes
                        : 15,
                    underline: const SizedBox.shrink(),
                    borderRadius: BorderRadius.circular(8),
                    items: _snappingOptions
                        .map(
                          (m) =>
                              DropdownMenuItem(value: m, child: Text('$m min')),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) _save(s.copyWith(timeSnappingMinutes: v));
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _formatDuration(int minutes) {
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }
}

class _WorkflowCard extends ConsumerWidget {
  const _WorkflowCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final typeEnabled =
        settings[SettingKeys.featureServiceTypeEnabled]?.toLowerCase() ==
        'true';
    final statusEnabled =
        settings[SettingKeys.featureServiceStatusEnabled]?.toLowerCase() ==
        'true';

    return _SettingsCard(
      title: 'WORKFLOW',
      children: [
        const _SettingSwitch(
          settingKey: SettingKeys.featureServiceTypeEnabled,
          label: 'Service Type Selector',
          subtitle:
              'Show order type buttons (e.g. Dine-In, Takeaway) on the POS',
        ),
        Opacity(
          opacity: typeEnabled ? 1.0 : 0.4,
          child: IgnorePointer(
            ignoring: !typeEnabled,
            child: const _CustomServiceTypesEditor(),
          ),
        ),
        const _SettingSwitch(
          settingKey: SettingKeys.featureServiceStatusEnabled,
          label: 'Service Status Selector',
          subtitle: 'Show service status badge on table/booking cards',
        ),
        Opacity(
          opacity: statusEnabled ? 1.0 : 0.4,
          child: IgnorePointer(
            ignoring: !statusEnabled,
            child: const _CustomServiceStatusesEditor(),
          ),
        ),
      ],
    );
  }
}

// Currency picker — loads from /Currencies/GetAll and saves code to settings
class _CurrencyDropdown extends ConsumerWidget {
  const _CurrencyDropdown();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currenciesAsync = ref.watch(currenciesProvider);
    final storedValue =
        ref.watch(appSettingsProvider)[SettingKeys.currencySymbol] ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: currenciesAsync.when(
        loading: () => const Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Loading currencies…'),
          ],
        ),
        error: (_, __) => const Text(
          'Could not load currencies',
          style: TextStyle(color: Colors.red),
        ),
        data: (currencies) {
          if (currencies.isEmpty) return const SizedBox.shrink();

          final keys = currencies.map((c) => c.code ?? c.name).toList();
          final safeValue = keys.contains(storedValue)
              ? storedValue
              : keys.first;

          return DropdownButtonFormField<String>(
            initialValue: safeValue,
            decoration: InputDecoration(
              labelText: 'Currency',
              filled: true,
              fillColor: theme.colorScheme.surface,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              isDense: true,
            ),
            dropdownColor: theme.colorScheme.surfaceContainerHighest,
            items: currencies.map((c) {
              final key = c.code ?? c.name;
              final label = c.code != null ? '${c.name} (${c.code})' : c.name;
              return DropdownMenuItem<String>(value: key, child: Text(label));
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                ref
                    .read(appSettingsProvider.notifier)
                    .set(SettingKeys.currencySymbol, val);
              }
            },
          );
        },
      ),
    );
  }
}

// ─── Numeric stepper (± integer, saves to appSettingsProvider) ───────────────

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _StepBtn({required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(9),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? theme.colorScheme.primary : theme.disabledColor,
        ),
      ),
    );
  }
}

class _NumericStepper extends ConsumerWidget {
  final String settingKey;
  final int min;
  final int max;

  const _NumericStepper({
    required this.settingKey,
    required this.min,
    required this.max,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final raw =
        ref.watch(appSettingsProvider)[settingKey] ??
        kSettingDefaults[settingKey] ??
        '$min';
    final value = (int.tryParse(raw) ?? min).clamp(min, max);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepBtn(
            icon: Icons.remove,
            enabled: value > min,
            onTap: () => ref
                .read(appSettingsProvider.notifier)
                .set(settingKey, '${value - 1}'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              '$value',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          _StepBtn(
            icon: Icons.add,
            enabled: value < max,
            onTap: () => ref
                .read(appSettingsProvider.notifier)
                .set(settingKey, '${value + 1}'),
          ),
        ],
      ),
    );
  }
}

class _StepperRow extends StatelessWidget {
  final String label;
  final String settingKey;
  final int min;
  final int max;
  final String? suffix;

  const _StepperRow({
    required this.label,
    required this.settingKey,
    required this.min,
    required this.max,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          _NumericStepper(settingKey: settingKey, min: min, max: max),
          if (suffix != null) ...[
            const SizedBox(width: 8),
            Text(suffix!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB IMPLEMENTATIONS
// ─────────────────────────────────────────────────────────────────────────────

class _TabScrollView extends StatelessWidget {
  final List<Widget> cards;
  const _TabScrollView({required this.cards});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: cards,
      ),
    );
  }
}

// ── Accent Color Picker ───────────────────────────────────────────────────────

class _AccentColorPicker extends ConsumerWidget {
  const _AccentColorPicker();

  static const _colors = [
    ('Blue',        Color(0xFF2196F3)),
    ('Sky',         Color(0xFF03A9F4)),
    ('Indigo',      Color(0xFF3F51B5)),
    ('Green',       Color(0xFF4CAF50)),
    ('Teal',        Color(0xFF009688)),
    ('Emerald',     Color(0xFF10B981)),
    ('Pink',        Color(0xFFE91E63)),
    ('Rose',        Color(0xFFF43F5E)),
    ('Purple',      Color(0xFF9C27B0)),
    ('Violet',      Color(0xFF7C3AED)),
    ('Orange',      Color(0xFFFF9800)),
    ('Red',         Color(0xFFF44336)),
    ('Amber',       Color(0xFFFFC107)),
    ('Deep Orange', Color(0xFFFF5722)),
  ];

  static String _toHex(Color c) =>
      '#${c.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

  static Color? _fromHex(String? hex) {
    if (hex == null) return null;
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final current = _fromHex(settings[SettingKeys.themeAccentColor]);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Accent Color',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _colors.map<Widget>((entry) {
              final (name, color) = entry;
              final isSelected = current != null &&
                  color.toARGB32() == current.toARGB32();
              return GestureDetector(
                onTap: () => ref
                    .read(appSettingsProvider.notifier)
                    .set(SettingKeys.themeAccentColor, _toHex(color)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: theme.colorScheme.onSurface,
                                width: 3,
                              )
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Theme Mode Picker ─────────────────────────────────────────────────────────

class _ThemeOpt {
  final String key;
  final String label;
  final IconData icon;
  final Color previewBg;
  final Color previewAccent;
  const _ThemeOpt(this.key, this.label, this.icon, this.previewBg, this.previewAccent);
}

class _ThemeModePicker extends ConsumerWidget {
  const _ThemeModePicker();

  static final _options = <_ThemeOpt>[
    _ThemeOpt('light',         'Light',         PhosphorIconsRegular.sun,             const Color(0xFFF5F7FA), const Color(0xFF2196F3)),
    _ThemeOpt('dark',          'Dark',           PhosphorIconsRegular.moon,            const Color(0xFF1E2530), const Color(0xFF90CAF9)),
    _ThemeOpt('dimmed',        'Dimmed',         PhosphorIconsRegular.moonStars,       const Color(0xFF15202B), const Color(0xFF64B5F6)),
    _ThemeOpt('night',         'Night',          PhosphorIconsRegular.eye,             const Color(0xFF000000), const Color(0xFF82B1FF)),
    _ThemeOpt('gray',          'Gray',           PhosphorIconsRegular.circleHalf,      const Color(0xFF1E1E1E), const Color(0xFFBDBDBD)),
    _ThemeOpt('high_contrast', 'High Contrast',  PhosphorIconsRegular.circleHalfTilt,  const Color(0xFF000000), const Color(0xFFFFFFFF)),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final current  = settings[SettingKeys.themeMode] ?? 'dark';
    final opt      = _options.firstWhere((o) => o.key == current, orElse: () => _options[1]);
    final theme    = Theme.of(context);
    final cs       = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Theme Mode', style: TextStyle(fontSize: 14, color: cs.onSurface)),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _show(context, ref, current),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: cs.outline.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Icon(opt.icon, size: 17, color: cs.primary),
                  const SizedBox(width: 10),
                  Text(opt.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const Spacer(),
                  _MiniPreview(bg: opt.previewBg, accent: opt.previewAccent),
                  const SizedBox(width: 10),
                  Icon(PhosphorIconsRegular.caretDown, size: 14, color: cs.onSurfaceVariant),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _show(BuildContext context, WidgetRef ref, String current) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _ThemePickerDialog(
        options: _options,
        current: current,
        onSelect: (key) {
          ref.read(appSettingsProvider.notifier).set(SettingKeys.themeMode, key);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _MiniPreview extends StatelessWidget {
  final Color bg;
  final Color accent;
  const _MiniPreview({required this.bg, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 26,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: bg == const Color(0xFFF5F7FA)
                  ? const Color(0xFFE0E0E0)
                  : Colors.black.withValues(alpha: 0.35),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 2,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          height: 2,
                          width: 12,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemePickerDialog extends StatelessWidget {
  final List<_ThemeOpt> options;
  final String current;
  final void Function(String) onSelect;

  const _ThemePickerDialog({
    required this.options,
    required this.current,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 300,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF16202E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.55),
              blurRadius: 48,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
              child: Row(
                children: [
                  Icon(PhosphorIconsRegular.palette, size: 14, color: Colors.white38),
                  const SizedBox(width: 7),
                  const Text(
                    'CHOOSE THEME',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.9,
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.06)),
            const SizedBox(height: 4),
            ...options.asMap().entries.map((e) {
              final idx = e.key;
              final opt = e.value;
              final selected = opt.key == current;
              return _OptionTile(opt: opt, selected: selected, onTap: () => onSelect(opt.key))
                  .animate(delay: Duration(milliseconds: 35 * idx))
                  .fadeIn(duration: 220.ms)
                  .slideY(begin: 0.12, end: 0, duration: 220.ms, curve: Curves.easeOut);
            }),
            const SizedBox(height: 4),
          ],
        ),
      )
          .animate()
          .scale(
            begin: const Offset(0.93, 0.93),
            end: const Offset(1, 1),
            duration: 200.ms,
            curve: Curves.easeOut,
          )
          .fadeIn(duration: 180.ms),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final _ThemeOpt opt;
  final bool selected;
  final VoidCallback onTap;
  const _OptionTile({required this.opt, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      child: Material(
        color: selected ? Colors.white.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9),
          highlightColor: Colors.white.withValues(alpha: 0.05),
          splashColor: Colors.white.withValues(alpha: 0.07),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  opt.icon,
                  size: 17,
                  color: selected ? Colors.white : Colors.white54,
                ),
                const SizedBox(width: 12),
                Text(
                  opt.label,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.white70,
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                const Spacer(),
                _MiniPreview(bg: opt.previewBg, accent: opt.previewAccent),
                const SizedBox(width: 10),
                SizedBox(
                  width: 16,
                  child: selected
                      ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── General ──────────────────────────────────────────────────────────────────
class _GeneralTab extends ConsumerWidget {
  const _GeneralTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _TabScrollView(
      cards: [
        _SettingsCard(
          title: 'REGIONAL',
          children: [
            const _CurrencyDropdown(),
            const _SettingDropdown(
              settingKey: SettingKeys.language,
              label: 'Language',
              options: ['en', 'fr', 'ar', 'es', 'de', 'it', 'pt'],
            ),
            const _SettingDropdown(
              settingKey: SettingKeys.dateFormat,
              label: 'Date Format',
              options: ['dd-MM-yyyy', 'MM/dd/yyyy', 'yyyy-MM-dd', 'dd/MM/yyyy'],
            ),
            const _TimezoneCard(),
            const _SettingDropdown(
              settingKey: SettingKeys.industryMode,
              label: 'Industry Mode',
              options: ['FB', 'Service'],
            ),
          ],
        ),
        _SettingsCard(
          title: 'TAX',
          children: [
            const _SettingSwitch(
              settingKey: SettingKeys.taxIncludedByDefault,
              label: 'Tax Included in Price by Default',
              subtitle:
                  'All new products will default to tax-inclusive pricing',
            ),
          ],
        ),
        _SettingsCard(
          title: 'APPEARANCE',
          children: const [
            _ThemeModePicker(),
            _AccentColorPicker(),
          ],
        ),
        _SettingsCard(
          title: 'APPLICATION STYLE',
          children: const [
            _SettingDropdown(
              settingKey: SettingKeys.writingDirection,
              label: 'Writing Direction',
              options: ['LTR', 'RTL'],
            ),
            _SettingDropdown(
              settingKey: SettingKeys.posLayout,
              label: 'POS Layout',
              options: ['Visual', 'Standard'],
            ),
            _SettingSwitch(
              settingKey: SettingKeys.enableVirtualKeyboard,
              label: 'Enable Virtual Keyboard',
            ),
          ],
        ),
        _SettingsCard(
          title: 'MESSAGES (NOTIFICATIONS)',
          children: const [
            _StepperRow(
              label: 'Message Duration (seconds)',
              settingKey: SettingKeys.messageDuration,
              min: 1,
              max: 10,
            ),
            _SettingDropdown(
              settingKey: SettingKeys.messagePosition,
              label: 'Message Position',
              options: ['Top', 'Bottom'],
            ),
          ],
        ),
        _SettingsCard(
          title: 'BUSINESS DAY',
          children: const [
            _SettingSwitch(
              settingKey: SettingKeys.showCashInOnStart,
              label: 'Show cash in on application start',
            ),
            _SettingSwitch(
              settingKey: SettingKeys.selectBusinessDayOnStart,
              label: 'Select business day on application start',
            ),
          ],
        ),
        _SettingsCard(
          title: 'POS BUTTON BAR',
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Text(
                'Select which action buttons appear on the main POS screen.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
              ),
            ),
            const _SettingSwitch(
              settingKey: SettingKeys.showSearchBtn,
              label: 'Search',
            ),
            const _SettingSwitch(
              settingKey: SettingKeys.showTransferBtn,
              label: 'Transfer',
            ),
            const _SettingSwitch(
              settingKey: SettingKeys.showCustomerBtn,
              label: 'Customer',
            ),
            const _SettingSwitch(
              settingKey: SettingKeys.showDiscountBtn,
              label: 'Discount',
            ),
            const _SettingSwitch(
              settingKey: SettingKeys.showCommentBtn,
              label: 'Comment',
            ),
            const _SettingSwitch(
              settingKey: SettingKeys.showNewSaleBtn,
              label: 'New Sale',
            ),
            const _SettingSwitch(
              settingKey: SettingKeys.showRefundBtn,
              label: 'Refund',
            ),
            const _SettingSwitch(
              settingKey: SettingKeys.showOrderNameBtn,
              label: 'Order Name',
            ),
            const _SettingSwitch(
              settingKey: SettingKeys.showCashDrawerBtn,
              label: 'Cash Drawer',
            ),
            const _SettingSwitch(
              settingKey: SettingKeys.showWarehouseBtn,
              label: 'Warehouse Switcher',
            ),
            const _SettingSwitch(
              settingKey: SettingKeys.showBookingBtn,
              label: 'Bookings',
            ),
            const _SettingSwitch(
              settingKey: SettingKeys.showTablesBtn,
              label: 'Tables / Floor Plan',
            ),
            const _SettingSwitch(
              settingKey: SettingKeys.showKitchenBtn,
              label: 'Send to Kitchen',
            ),
            const _SettingSwitch(
              settingKey: SettingKeys.showTaxBtn,
              label: 'Tax',
            ),
          ],
        ),
        _SettingsCard(
          title: 'API',
          children: [
            const _SettingTextField(
              settingKey: SettingKeys.apiBaseUrl,
              label: 'API Base URL',
              hint: 'http://192.168.1.1:5002/api',
              keyboardType: TextInputType.url,
            ),
          ],
        ),
      ],
    );
  }
}

// ── Order & Payment ───────────────────────────────────────────────────────────
class _OrderPaymentTab extends ConsumerWidget {
  const _OrderPaymentTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final typeEnabled =
        settings[SettingKeys.featureServiceTypeEnabled]?.toLowerCase() == 'true';
    final statusEnabled =
        settings[SettingKeys.featureServiceStatusEnabled]?.toLowerCase() == 'true';

    return _TabScrollView(
      cards: [
        _SettingsCard(
          title: 'FEATURES',
          children: [
            _SettingSwitch(
              settingKey: SettingKeys.featureFloorPlanEnabled,
              label: 'Enable Floor Plan / Tables',
              subtitle:
                  'Show the Tables button in the POS and allow floor plan navigation',
              onChanged: (ref, enabled) {
                if (!enabled) {
                  ref
                      .read(appSettingsProvider.notifier)
                      .setBool(SettingKeys.featureBookingEnabled, false);
                }
              },
            ),
            _SettingSwitch(
              settingKey: SettingKeys.featureBookingEnabled,
              label: 'Enable Bookings / Calendar',
              subtitle: 'Requires Floor Plan / Tables to be enabled',
              onChanged: (ref, enabled) {
                if (enabled) {
                  ref
                      .read(appSettingsProvider.notifier)
                      .setBool(SettingKeys.featureFloorPlanEnabled, true);
                }
              },
            ),
            const _SettingTextField(
              settingKey: SettingKeys.tablesButtonLabel,
              label: 'Tables Button Label',
              hint: 'e.g. Tables, Rooms, Resources',
            ),
          ],
        ),
        const _BookingSettingsCard(),
        _SettingsCard(
          title: 'BASIC OPERATIONS',
          children: const [
            _SettingSwitch(
              settingKey: SettingKeys.enableSounds,
              label: 'Sounds',
            ),
          ],
        ),
        _SettingsCard(
          title: 'ITEMS',
          children: const [
            _SettingDropdown(
              settingKey: SettingKeys.defaultSearch,
              label: 'Default search',
              options: ['Name', 'Code', 'Barcode', 'All fields'],
            ),
            _SettingSwitch(
              settingKey: SettingKeys.showSearchOptions,
              label: 'Show search options',
            ),
            _SettingDropdown(
              settingKey: SettingKeys.defaultDiscountType,
              label: 'Default discount type',
              options: ['Percentage', 'Fixed'],
            ),
            _SettingSwitch(
              settingKey: SettingKeys.separateRowForEachItem,
              label: 'Separate row for each item',
            ),
            _SettingSwitch(
              settingKey: SettingKeys.preventSaleBelowCostPrice,
              label: 'Prevent sale below cost price',
            ),
            _SettingSwitch(
              settingKey: SettingKeys.preventNegativeInventory,
              label: 'Prevent negative inventory',
            ),
          ],
        ),
        _SettingsCard(
          title: 'USERS',
          children: const [
            _SettingSwitch(
              settingKey: SettingKeys.singleUser,
              label: 'Single user',
            ),
          ],
        ),
        _SettingsCard(
          title: 'PAYMENT',
          children: [
            const _SettingSwitch(
              settingKey: SettingKeys.displayReceiptPrintDialog,
              label: 'Display receipt print dialog',
            ),
            _StepperRow(
              label: 'Default due date (days)',
              settingKey: SettingKeys.defaultDueDateDays,
              min: 0,
              max: 90,
            ),
            const _SettingSwitch(
              settingKey: SettingKeys.mergeItemsOnReceipt,
              label: 'Merge items on receipt',
            ),
            const _SettingSwitch(
              settingKey: SettingKeys.singleItemDiscountAllowed,
              label: 'Single item discount allowed',
            ),
            const _SettingSwitch(
              settingKey: SettingKeys.shortcutKeysPaymentConfirmation,
              label: 'Shortcut keys payment confirmation',
            ),
          ],
        ),
        _SettingsCard(
          title: 'VOID ITEMS',
          children: const [
            _SettingSwitch(
              settingKey: SettingKeys.requireReasonOnVoid,
              label: 'Require reason on void',
            ),
            _SettingSwitch(
              settingKey: SettingKeys.trackUnconfirmedVoidedItems,
              label: 'Track unconfirmed voided items',
            ),
          ],
        ),
        _SettingsCard(
          title: 'ORDER NAME',
          children: const [
            _SettingSwitch(
              settingKey: SettingKeys.enableCustomOrderName,
              label: 'Enable custom order name',
            ),
            _SettingSwitch(
              settingKey: SettingKeys.orderNameRequired,
              label: 'Order name required',
            ),
            _SettingSwitch(
              settingKey: SettingKeys.requestOrderNameAutomatically,
              label: 'Request order name automatically',
            ),
          ],
        ),
        _SettingsCard(
          title: 'SERVICE TYPE',
          children: [
            const _SettingSwitch(
              settingKey: SettingKeys.requestServiceTypeAutomatically,
              label: 'Request service type automatically',
            ),
            const _SettingDropdown(
              settingKey: SettingKeys.defaultServiceType,
              label: 'Default service type',
              options: ['Dine-in', 'Takeaway', 'Delivery'],
            ),
            const _SettingSwitch(
              settingKey: SettingKeys.printLargeOrderNumberInReceipt,
              label: 'Print large order number in receipt',
            ),
            const _SettingSwitch(
              settingKey: SettingKeys.featureServiceTypeEnabled,
              label: 'Service Type Selector',
              subtitle:
                  'Show order type buttons (e.g. Dine-In, Takeaway) on the POS',
            ),
            Opacity(
              opacity: typeEnabled ? 1.0 : 0.4,
              child: IgnorePointer(
                ignoring: !typeEnabled,
                child: const _CustomServiceTypesEditor(),
              ),
            ),
            const _SettingSwitch(
              settingKey: SettingKeys.featureServiceStatusEnabled,
              label: 'Service Status Selector',
              subtitle: 'Show service status badge on table/booking cards',
            ),
            Opacity(
              opacity: statusEnabled ? 1.0 : 0.4,
              child: IgnorePointer(
                ignoring: !statusEnabled,
                child: const _CustomServiceStatusesEditor(),
              ),
            ),
          ],
        ),
        _SettingsCard(
          title: 'ADVANCED SETTINGS',
          children: [
            const _SettingSwitch(
              settingKey: SettingKeys.resetOrderNumberOnDayClose,
              label: 'Reset order number on day close',
            ),
            const _SettingSwitch(
              settingKey: SettingKeys.showItemsOnPaymentForm,
              label: 'Show items on payment form',
            ),
            _StepperRow(
              label: 'Number of payment type rows',
              settingKey: SettingKeys.numberOfPaymentTypeRows,
              min: 0,
              max: 10,
            ),
            const _SettingSwitch(
              settingKey: SettingKeys.showAllOccupiedTablesInFloorPlan,
              label: 'Show all occupied tables in floor plan',
            ),
          ],
        ),
      ],
    );
  }
}

// ── Products ──────────────────────────────────────────────────────────────────

// Placeholder checkbox swatch — replaced once the Tax Provider is wired up.
class _MockCheckbox extends StatelessWidget {
  final String label;
  const _MockCheckbox({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

class _ProductsTab extends ConsumerWidget {
  const _ProductsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final theme = Theme.of(context);
    final autoUpdateCost =
        settings[SettingKeys.autoUpdateCostPrice]?.toLowerCase() == 'true';

    return _TabScrollView(
      cards: [
        _SettingsCard(
          title: 'GENERAL',
          children: const [
            _SettingSwitch(
              settingKey: SettingKeys.displayAndPrintTaxIncluded,
              label: 'Display and print items with tax included',
            ),
            _SettingDropdown(
              settingKey: SettingKeys.discountApplyRule,
              label: 'Discount apply rule',
              options: ['Before tax', 'After tax'],
            ),
            _SettingDropdown(
              settingKey: SettingKeys.productSorting,
              label: 'Sorting',
              options: ['Name', 'Code', 'Barcode'],
            ),
            _SettingSwitch(
              settingKey: SettingKeys.allowNegativePrice,
              label: 'Allow negative price',
            ),
            _SettingSwitch(
              settingKey: SettingKeys.showProductImages,
              label: 'Show Product Images in POS Grid',
            ),
          ],
        ),
        _SettingsCard(
          title: 'PRODUCT DEFAULTS',
          children: [
            // TODO: Wire up to Tax Provider to generate checkboxes dynamically
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Default tax rate',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Wrap(
                    spacing: 20,
                    runSpacing: 8,
                    children: [
                      _MockCheckbox(label: 'Standard (10%)'),
                      _MockCheckbox(label: 'Reduced (5%)'),
                      _MockCheckbox(label: 'Zero (0%)'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tax rates will be loaded from the backend',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, indent: 20, endIndent: 20),
            const _SettingTextField(
              settingKey: SettingKeys.defaultMeasurementUnit,
              label: 'Default Measurement Unit',
              hint: 'e.g. pcs, kg, L',
            ),
            const _SettingDropdown(
              settingKey: SettingKeys.barcodeFormat,
              label: 'Default Barcode Format',
              options: ['EAN-13', 'EAN-8', 'UPC-A', 'Code128', 'QR'],
            ),
            const _SettingSwitch(
              settingKey: SettingKeys.costPriceBasedMarkup,
              label: 'Cost price based markup',
            ),
            const _SettingSwitch(
              settingKey: SettingKeys.autoUpdateCostPrice,
              label: 'Automatically update cost price on purchase',
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Opacity(
                opacity: autoUpdateCost ? 1.0 : 0.4,
                child: IgnorePointer(
                  ignoring: !autoUpdateCost,
                  child: const _SettingSwitch(
                    settingKey: SettingKeys.updateSalePriceOnMarkup,
                    label: 'Update sale price based on markup',
                  ),
                ),
              ),
            ),
          ],
        ),
        _SettingsCard(
          title: 'MOVING AVERAGE PRICE',
          children: const [
            _SettingSwitch(
              settingKey: SettingKeys.enableMovingAveragePrice,
              label: 'Enable moving average price',
            ),
          ],
        ),
        _SettingsCard(
          title: 'MENU GRID',
          children: const [
            _SettingDropdown(
              settingKey: SettingKeys.menuGridCols,
              label: 'Columns',
              options: ['4', '5'],
            ),
            _SettingDropdown(
              settingKey: SettingKeys.menuGridRows,
              label: 'Rows',
              options: ['3', '4', '5'],
            ),
          ],
        ),
      ],
    );
  }
}

// ── Documents ─────────────────────────────────────────────────────────────────
class _DocumentsTab extends ConsumerWidget {
  const _DocumentsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _TabScrollView(
      cards: [
        _SettingsCard(
          title: 'NUMBERING',
          children: [
            const _SettingTextField(
              settingKey: SettingKeys.invoicePrefix,
              label: 'Invoice Number Prefix',
              hint: 'e.g. INV',
            ),
            const _SettingSwitch(
              settingKey: SettingKeys.autoGenerateNumber,
              label: 'Auto-generate Document Numbers',
            ),
          ],
        ),
        _SettingsCard(
          title: 'DEFAULTS',
          children: [
            const _SettingTextField(
              settingKey: SettingKeys.defaultDocumentType,
              label: 'Default Document Type',
              hint: 'e.g. Sales',
            ),
          ],
        ),
      ],
    );
  }
}

// ── Weighing Scale ────────────────────────────────────────────────────────────
class _WeighingScaleTab extends ConsumerWidget {
  const _WeighingScaleTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final barcodeOn =
        settings[SettingKeys.scaleBarcodeEnabled]?.toLowerCase() == 'true';

    return _TabScrollView(
      cards: [
        _SettingsCard(
          title: 'BARCODE PARSING',
          children: [
            const _SettingSwitch(
              settingKey: SettingKeys.scaleBarcodeEnabled,
              label: 'Enable weighing scales barcode',
              subtitle:
                  'Parse weight/price from barcodes printed by a weighing scale',
            ),
            Opacity(
              opacity: barcodeOn ? 1.0 : 0.4,
              child: IgnorePointer(
                ignoring: !barcodeOn,
                child: Column(
                  children: [
                    const _SettingTextField(
                      settingKey: SettingKeys.scaleBarcodePrefix,
                      label: 'First two digits / prefix',
                      hint: 'e.g. 21',
                    ),
                    const _StepperRow(
                      label: 'Number of digits for product code',
                      settingKey: SettingKeys.scaleBarcodeCodeLength,
                      min: 1,
                      max: 10,
                    ),
                    const _StepperRow(
                      label: 'Number of decimal places',
                      settingKey: SettingKeys.scaleBarcodeDecimalPlaces,
                      min: 0,
                      max: 5,
                    ),
                    const _SettingSwitch(
                      settingKey: SettingKeys.scaleBarcodeTrimZeros,
                      label: 'Remove zeros from product code (trim zeros)',
                      subtitle:
                          'Strip leading zeros before looking up the product',
                    ),
                    const _SettingSwitch(
                      settingKey: SettingKeys.scaleBarcodePrintsPrice,
                      label: 'Scale prints price instead of quantity',
                      subtitle:
                          'When on, the encoded value is a price and quantity is calculated as price ÷ unit price',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Customer Display ──────────────────────────────────────────────────────────
class _CustomerDisplayTab extends ConsumerStatefulWidget {
  const _CustomerDisplayTab();

  @override
  ConsumerState<_CustomerDisplayTab> createState() =>
      _CustomerDisplayTabState();
}

class _CustomerDisplayTabState extends ConsumerState<_CustomerDisplayTab> {
  bool _showPortSettings = false;
  bool _webRunning = false;
  String _webUrl = '';

  @override
  void initState() {
    super.initState();
    // Re-start the server if it was already enabled (e.g. after settings tab reopen)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final on = ref.read(appSettingsProvider)[
              SettingKeys.customerDisplayWebEnabled]
          ?.toLowerCase() ==
          'true';
      if (on && mounted) _startWeb();
    });
  }

  // ── Serial display helpers ──────────────────────────────────────────────────

  void _restorePortDefaults() {
    final n = ref.read(appSettingsProvider.notifier);
    n.set(SettingKeys.customerDisplayBaudRate, '9600');
    n.set(SettingKeys.customerDisplayDataBits, '8');
    n.set(SettingKeys.customerDisplayParity, 'None');
    n.set(SettingKeys.customerDisplayStopBits, '1');
    n.set(SettingKeys.customerDisplayFlowControl, 'None');
  }

  Future<void> _testDisplay() async {
    final settings = ref.read(appSettingsProvider);
    await CustomerDisplayService.showWelcome(settings: settings);
    if (mounted) showAppSnackbar(context, ref, 'Test message sent.');
  }

  // ── Web server helpers ──────────────────────────────────────────────────────

  Future<void> _startWeb() async {
    await CustomerDisplayWebServer.instance.start();
    // Pre-load the Lottie animation so /lottie.json can be served to browsers.
    try {
      final data = await rootBundle.load(
          'assets/animations/success_animation.json');
      CustomerDisplayWebServer.instance.setLottieJson(
          utf8.decode(data.buffer.asUint8List()));
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _webRunning = true;
      _webUrl = CustomerDisplayWebServer.instance.url;
    });
  }

  Future<void> _stopWeb() async {
    await CustomerDisplayWebServer.instance.stop();
    if (!mounted) return;
    setState(() { _webRunning = false; _webUrl = ''; });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = ref.watch(appSettingsProvider)[
            SettingKeys.customerDisplayEnabled]
        ?.toLowerCase() ==
        'true';

    // _webRunning is local state, but the server is a singleton that outlives
    // this widget.  Derive from actual server state so the URL/QR section is
    // always visible when the server is running, even if _webRunning is stale.
    final serverRunning = _webRunning || CustomerDisplayWebServer.instance.isRunning;
    final displayUrl    = (_webUrl.isNotEmpty
        ? _webUrl
        : CustomerDisplayWebServer.instance.url);

    return _TabScrollView(
      cards: [
        _SettingsCard(
          title: 'CUSTOMER DISPLAY',
          children: [
            // Enabled
            const _SettingSwitch(
              settingKey: SettingKeys.customerDisplayEnabled,
              label: 'Enabled',
              subtitle: 'Show order total on a serial VFD / LCD pole display',
            ),
            Opacity(
              opacity: enabled ? 1.0 : 0.4,
              child: IgnorePointer(
                ignoring: !enabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // COM port row + toggle link
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: _SettingDropdown(
                              settingKey: SettingKeys.customerDisplayPort,
                              label: 'COM port',
                              options: const [
                                'COM1', 'COM2', 'COM3', 'COM4', 'COM5',
                                'COM6', 'COM7', 'COM8', 'COM9', 'COM10',
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          TextButton(
                            onPressed: () => setState(
                                () => _showPortSettings = !_showPortSettings),
                            child: Text(
                              _showPortSettings
                                  ? 'Hide port settings'
                                  : 'Show port settings',
                              style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Expandable port settings
                    if (_showPortSettings)
                      Container(
                        margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            const _SettingDropdown(
                              settingKey:
                                  SettingKeys.customerDisplayBaudRate,
                              label: 'Bits per second',
                              options: [
                                '1200', '2400', '4800', '9600',
                                '19200', '38400', '57600', '115200',
                              ],
                            ),
                            const _SettingDropdown(
                              settingKey:
                                  SettingKeys.customerDisplayDataBits,
                              label: 'Data bits',
                              options: ['5', '6', '7', '8'],
                            ),
                            const _SettingDropdown(
                              settingKey: SettingKeys.customerDisplayParity,
                              label: 'Parity',
                              options: [
                                'None', 'Even', 'Odd', 'Mark', 'Space',
                              ],
                            ),
                            const _SettingDropdown(
                              settingKey:
                                  SettingKeys.customerDisplayStopBits,
                              label: 'Stop bits',
                              options: ['1', '1.5', '2'],
                            ),
                            const _SettingDropdown(
                              settingKey:
                                  SettingKeys.customerDisplayFlowControl,
                              label: 'Flow control',
                              options: ['None', 'RTS/CTS', 'XON/XOFF'],
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                  onPressed: _restorePortDefaults,
                                  child: Text(
                                    'Restore defaults',
                                    style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontSize: 12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Number of characters
                    const _StepperRow(
                      label: 'Number of characters',
                      settingKey: SettingKeys.customerDisplayNumChars,
                      min: 1,
                      max: 40,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Welcome message card
        _SettingsCard(
          title: 'WELCOME MESSAGE',
          children: [
            const _SettingTextField(
              settingKey: SettingKeys.customerDisplayWelcomeMessage,
              label: 'Top line',
              hint: 'WELCOME!',
            ),
            const _SettingTextField(
              settingKey: SettingKeys.customerDisplayWelcomeBottom,
              label: 'Bottom line',
              hint: '',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: OutlinedButton(
                onPressed: enabled ? _testDisplay : null,
                child: const Text('Test display'),
              ),
            ),
          ],
        ),

        // ── Open on this device (always available, no web server needed) ───
        _SettingsCard(
          title: 'OPEN ON THIS DEVICE',
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
              child: Text(
                'Opens the customer display as a full-screen Flutter view on this machine. '
                'Ideal for a second monitor — drag the window over and press F11.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: FilledButton.icon(
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text('Open customer display'),
                onPressed: () async {
                  // Auto-start the WS server if it isn't running yet —
                  // the native screen connects to ws://localhost:8181/ws
                  // regardless of whether the web-display toggle is on.
                  if (!CustomerDisplayWebServer.instance.isRunning) {
                    await _startWeb();
                  }
                  // Push a fresh idle broadcast so _lastState has company
                  // name + logo before the native screen connects and reads it.
                  final settings = ref.read(appSettingsProvider);
                  final company  = ref.read(selectedCompanyProvider);
                  CustomerDisplayWebServer.instance.broadcast({
                    'type':        'idle',
                    'company':     {
                      'name': company?.name ?? '',
                      'logo': company?.logo,
                    },
                    'welcomeText':
                        settings[SettingKeys.customerDisplayWelcomeMessage] ??
                        'WELCOME!',
                  });
                  if (!mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (_) => const CustomerDisplayScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        // ── Web / Screen Display ────────────────────────────────────────────
        _SettingsCard(
          title: 'SCREEN DISPLAY (WEB)',
          children: [
            _SettingSwitch(
              settingKey: SettingKeys.customerDisplayWebEnabled,
              label: 'Enable live web customer display',
              subtitle:
                  'Host an interactive order screen accessible from any browser on your network',
              onChanged: (_, on) => on ? _startWeb() : _stopWeb(),
            ),
            if (serverRunning) ...[
              // ── Same-machine (second monitor) shortcut ──────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Row(
                  children: [
                    Icon(Icons.monitor, size: 18,
                        color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Same machine / second monitor',
                              style: theme.textTheme.labelMedium),
                          SelectableText(
                            'http://localhost:${CustomerDisplayWebServer.port}',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.open_in_browser),
                      tooltip: 'Open in browser (drag to second monitor)',
                      onPressed: () => launchUrl(
                        Uri.parse(
                            'http://localhost:${CustomerDisplayWebServer.port}'),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(indent: 20, endIndent: 20, height: 20),
              // ── LAN / other device URL ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Row(
                  children: [
                    Icon(Icons.wifi, size: 18,
                        color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Other device on same network',
                              style: theme.textTheme.labelMedium),
                          SelectableText(
                            displayUrl,
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 18),
                      tooltip: 'Copy LAN URL',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: displayUrl));
                        showAppSnackbar(context, ref, 'URL copied');
                      },
                    ),
                  ],
                ),
              ),
              // QR code
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: displayUrl,
                        version: QrVersions.auto,
                        size: 180,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Scan the QR code to open the customer display on any internet-connected device.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// ── Kitchen Display ───────────────────────────────────────────────────────────
class _KitchenDisplayTab extends ConsumerStatefulWidget {
  const _KitchenDisplayTab();

  @override
  ConsumerState<_KitchenDisplayTab> createState() => _KitchenDisplayTabState();
}

class _KitchenDisplayTabState extends ConsumerState<_KitchenDisplayTab> {
  final _ipController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<String> _parseIps(String? raw) =>
      (raw ?? '').split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

  void _addIp() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final ip = _ipController.text.trim();
    final existing = _parseIps(ref.read(appSettingsProvider)[SettingKeys.kitchenDisplayIps]);
    if (existing.contains(ip)) return;
    final updated = [...existing, ip].join(',');
    ref.read(appSettingsProvider.notifier).set(SettingKeys.kitchenDisplayIps, updated);
    _ipController.clear();
  }

  void _removeIp(String ip) {
    final existing = _parseIps(ref.read(appSettingsProvider)[SettingKeys.kitchenDisplayIps]);
    final updated = existing.where((e) => e != ip).join(',');
    ref.read(appSettingsProvider.notifier).set(SettingKeys.kitchenDisplayIps, updated);
  }

  void _testIp(String ip) {
    KitchenPushService.notify([ip]);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ping sent to $ip — check the KDS screen for a refresh.'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final ips = _parseIps(ref.watch(appSettingsProvider)[SettingKeys.kitchenDisplayIps]);

    return _TabScrollView(
      cards: [
        _SettingsCard(
          title: 'KITCHEN DISPLAY TABLETS',
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Each Kitchen Display tablet runs an HTTP server on port ${KitchenPushService.kdsPort}. '
                'The POS app will ping every IP below after any order change so the KDS refreshes instantly.',
                style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
            const Divider(height: 1),
            // ── existing IPs ──
            if (ips.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Text(
                  'No kitchen displays configured.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
            ...ips.map((ip) => ListTile(
                  leading: Icon(Icons.tablet_android, color: cs.primary),
                  title: Text(ip, style: theme.textTheme.bodyMedium),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.wifi_tethering, color: cs.secondary, size: 20),
                        tooltip: 'Test ping',
                        onPressed: () => _testIp(ip),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: cs.error, size: 20),
                        tooltip: 'Remove',
                        onPressed: () => _removeIp(ip),
                      ),
                    ],
                  ),
                )),
            const Divider(height: 1),
            // ── add new IP ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Form(
                key: _formKey,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _ipController,
                        decoration: InputDecoration(
                          labelText: 'KDS IP address',
                          hintText: '192.168.1.100',
                          border: const OutlineInputBorder(),
                          isDense: true,
                          prefixIcon: const Icon(Icons.lan_outlined, size: 18),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Enter an IP address';
                          final parts = v.trim().split('.');
                          if (parts.length != 4) return 'Invalid IP (e.g. 192.168.1.100)';
                          if (parts.any((p) => int.tryParse(p) == null)) return 'Invalid IP';
                          return null;
                        },
                        onFieldSubmitted: (_) => _addIp(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _addIp,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Email ─────────────────────────────────────────────────────────────────────
class _EmailTab extends ConsumerWidget {
  const _EmailTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _TabScrollView(
      cards: [
        _SettingsCard(
          title: 'SMTP SERVER',
          children: [
            const _SettingTextField(
              settingKey: SettingKeys.emailSmtpHost,
              label: 'SMTP Host',
              hint: 'smtp.gmail.com',
              keyboardType: TextInputType.url,
            ),
            const _SettingTextField(
              settingKey: SettingKeys.emailSmtpPort,
              label: 'SMTP Port',
              hint: '587',
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        _SettingsCard(
          title: 'SENDER',
          children: [
            const _SettingTextField(
              settingKey: SettingKeys.emailFromAddress,
              label: 'From Email Address',
              hint: 'pos@yourbusiness.com',
              keyboardType: TextInputType.emailAddress,
            ),
            const _SettingTextField(
              settingKey: SettingKeys.emailFromName,
              label: 'From Name',
              hint: 'POS System',
            ),
            const _SettingTextField(
              settingKey: SettingKeys.emailUserEmail,
              label: 'Account / User Email',
              hint: 'your@email.com',
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
      ],
    );
  }
}

// ── Print ─────────────────────────────────────────────────────────────────────
class _PrintTab extends StatelessWidget {
  const _PrintTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 520),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(18),
                border: isDark
                    ? Border.all(
                        color: theme.dividerColor.withValues(alpha: 0.2),
                      )
                    : null,
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: theme.shadowColor.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Column(
                children: [
                  // Icon header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(32, 36, 32, 0),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(
                            Icons.print_outlined,
                            size: 32,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Printer & Receipt Settings',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Configure your printer hardware, customize receipt '
                          'layout and branding, localize text labels, and '
                          'set up invoice templates.',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.hintColor,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                  // Feature bullets
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        _FeatureBullet(
                          icon: Icons.settings_input_component_outlined,
                          label: 'Hardware & Layout',
                          subtitle:
                              'Printer type, paper size, margins, cash drawer',
                          theme: theme,
                        ),
                        _FeatureBullet(
                          icon: Icons.receipt_long_outlined,
                          label: 'Customize Receipt',
                          subtitle:
                              'Logo, branding, toggles, customer details',
                          theme: theme,
                        ),
                        _FeatureBullet(
                          icon: Icons.translate_rounded,
                          label: 'Localize Text',
                          subtitle: 'Override label text on printed receipts',
                          theme: theme,
                        ),
                        _FeatureBullet(
                          icon: Icons.article_outlined,
                          label: 'Print Templates',
                          subtitle:
                              'Invoice title, A5, columns, header & footer',
                          theme: theme,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Divider(
                    height: 1,
                    color: theme.dividerColor.withValues(alpha: 0.15),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PrinterSettingsScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.tune_rounded, size: 18),
                        label: const Text(
                          'Open Printer & Receipt Settings',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
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

class _FeatureBullet extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final ThemeData theme;
  const _FeatureBullet({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: theme.hintColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dual Currency ─────────────────────────────────────────────────────────────
class _DualCurrencyTab extends ConsumerWidget {
  const _DualCurrencyTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _TabScrollView(
      cards: [
        _SettingsCard(
          title: 'DUAL CURRENCY',
          children: [
            const _SettingSwitch(
              settingKey: SettingKeys.dualCurrencyEnabled,
              label: 'Dual Currency Enabled',
              subtitle:
                  'Display prices and totals in a second currency simultaneously',
            ),
            const _SettingTextField(
              settingKey: SettingKeys.dualCurrencySymbol,
              label: 'Secondary Currency Symbol',
              hint: 'e.g. €',
            ),
            const _SettingTextField(
              settingKey: SettingKeys.dualCurrencyRate,
              label: 'Exchange Rate',
              hint: 'e.g. 1.08  (1 primary = X secondary)',
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Database ──────────────────────────────────────────────────────────────────
class _DatabaseTab extends ConsumerStatefulWidget {
  const _DatabaseTab();

  @override
  ConsumerState<_DatabaseTab> createState() => _DatabaseTabState();
}

class _DatabaseTabState extends ConsumerState<_DatabaseTab> {
  bool _isBackingUp = false;

  Future<void> _doBackup() async {
    // If no backup location is configured yet, ask the user to pick one first.
    var backupDir =
        ref.read(appSettingsProvider)[SettingKeys.dbBackupPath] ?? '';
    if (backupDir.trim().isEmpty) {
      final picked = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select Backup Folder',
      );
      if (picked == null || !mounted) return;
      await ref.read(appSettingsProvider.notifier).set(
            SettingKeys.dbBackupPath, picked,
          );
      backupDir = picked;
    }

    setState(() => _isBackingUp = true);
    try {
      final settings = ref.read(appSettingsProvider);
      final companyName = ref.read(selectedCompanyProvider)?.name ?? 'POS';

      final destPath = await BackupService.backupNow(
        backupDir: backupDir,
        companyName: companyName,
      );

      // Prune old backups if enabled
      if (settings[SettingKeys.dbBackupAutoDelete]?.toLowerCase() == 'true') {
        final days =
            int.tryParse(settings[SettingKeys.dbBackupRetentionDays] ?? '10') ??
            10;
        final resolvedDir = p.dirname(destPath);
        await BackupService.pruneOldBackups(
          backupDir: resolvedDir,
          retentionDays: days,
        );
      }

      if (mounted) {
        showAppSnackbar(context, ref, 'Backup saved: ${p.basename(destPath)}');
      }
    } catch (e) {
      if (mounted) {
        showAppSnackbar(context, ref, 'Backup failed: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isBackingUp = false);
    }
  }

  /// Picks a folder if none is configured, saves it, then opens it in Explorer.
  Future<void> _openLocation() async {
    var dir = ref.read(appSettingsProvider)[SettingKeys.dbBackupPath] ?? '';
    if (dir.trim().isEmpty) {
      final picked = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select Backup Folder',
      );
      if (picked == null || !mounted) return;
      await ref.read(appSettingsProvider.notifier).set(
            SettingKeys.dbBackupPath, picked,
          );
      dir = picked;
    }
    BackupService.openDirectory(dir);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = ref.watch(appSettingsProvider);
    final autoEnabled =
        settings[SettingKeys.dbAutoBackup]?.toLowerCase() == 'true';
    final autoDelete =
        settings[SettingKeys.dbBackupAutoDelete]?.toLowerCase() == 'true';

    return _TabScrollView(
      cards: [
        // ── Backup now ────────────────────────────────────────────────────────
        _SettingsCard(
          title: 'DATABASE',
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
              child: FilledButton.icon(
                onPressed: _isBackingUp ? null : _doBackup,
                icon: _isBackingUp
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.backup_outlined),
                label: Text(_isBackingUp ? 'Backing up…' : 'Backup database'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 20, 14),
              child: TextButton.icon(
                onPressed: _openLocation,
                icon: Icon(
                  Icons.folder_open_outlined,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                label: Text(
                  'Open database location',
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  alignment: Alignment.centerLeft,
                ),
              ),
            ),
          ],
        ),

        // ── Automatic backups ─────────────────────────────────────────────────
        _SettingsCard(
          title: 'AUTOMATIC BACKUPS',
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
              child: Text(
                'Automatically create backup copies of your data to protect against loss or corruption',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const _SettingSwitch(
              settingKey: SettingKeys.dbAutoBackup,
              label: 'Enable automatic backups',
            ),
            Opacity(
              opacity: autoEnabled ? 1.0 : 0.4,
              child: IgnorePointer(
                ignoring: !autoEnabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SettingSwitch(
                      settingKey: SettingKeys.dbBackupOnStart,
                      label: 'Backup database on application start',
                    ),
                    const _SettingSwitch(
                      settingKey: SettingKeys.dbBackupOnClose,
                      label: 'Backup database on application close',
                    ),
                    const _StepperRow(
                      label: 'Back up automatically every',
                      settingKey: SettingKeys.dbBackupIntervalHours,
                      min: 0,
                      max: 168,
                      suffix: 'hours',
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                      child: Text(
                        'Set to 0 to turn off scheduled backups',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const _BackupLocationField(),
                    const _SettingSwitch(
                      settingKey: SettingKeys.dbBackupAutoDelete,
                      label: 'Delete old backups automatically',
                    ),
                    Opacity(
                      opacity: autoDelete ? 1.0 : 0.4,
                      child: IgnorePointer(
                        ignoring: !autoDelete,
                        child: const _StepperRow(
                          label: 'Delete backups older than',
                          settingKey: SettingKeys.dbBackupRetentionDays,
                          min: 1,
                          max: 365,
                          suffix: 'days',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Backup location text field with a "…" browse button.
/// Saves to [SettingKeys.dbBackupPath] on focus-loss/submit/browse.
class _BackupLocationField extends ConsumerStatefulWidget {
  const _BackupLocationField();

  @override
  ConsumerState<_BackupLocationField> createState() =>
      _BackupLocationFieldState();
}

class _BackupLocationFieldState extends ConsumerState<_BackupLocationField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: ref.read(appSettingsProvider.notifier).get(SettingKeys.dbBackupPath),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final notifier = ref.read(appSettingsProvider.notifier);
    if (_ctrl.text.trim() == notifier.get(SettingKeys.dbBackupPath)) return;
    await notifier.set(SettingKeys.dbBackupPath, _ctrl.text.trim());
  }

  Future<void> _browse() async {
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select Backup Folder',
    );
    if (result != null) {
      _ctrl.text = result;
      await ref
          .read(appSettingsProvider.notifier)
          .set(SettingKeys.dbBackupPath, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _ctrl,
              decoration: InputDecoration(
                labelText: 'Backup location',
                hintText: Platform.isWindows
                    ? r'e.g. D:\database\Backup'
                    : 'e.g. /home/user/backups',
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                isDense: true,
              ),
              onEditingComplete: _save,
              onSubmitted: (_) => _save(),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: _browse,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(44, 44),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text('…'),
          ),
        ],
      ),
    );
  }
}

// ── License ───────────────────────────────────────────────────────────────────
class _LicenseTab extends ConsumerWidget {
  const _LicenseTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _TabScrollView(
      cards: [
        _SettingsCard(
          title: 'LICENSE',
          children: [
            const _SettingTextField(
              settingKey: SettingKeys.licenseEmail,
              label: 'License Email',
              hint: 'your@email.com',
              keyboardType: TextInputType.emailAddress,
            ),
            const _SettingTextField(
              settingKey: SettingKeys.licenseKey,
              label: 'License Key',
              hint: 'XXXX-XXXX-XXXX-XXXX',
              obscure: false,
            ),
          ],
        ),
        _SettingsCard(
          title: 'STATUS',
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.greenAccent),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.greenAccent,
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Valid License',
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── About ─────────────────────────────────────────────────────────────────────
// ── About tab helpers ─────────────────────────────────────────────────────────

class _AboutStats {
  final int productCount;
  final int customerCount;
  final int userCount;
  final DateTime? lastSync;
  final int dbSizeBytes;

  const _AboutStats({
    required this.productCount,
    required this.customerCount,
    required this.userCount,
    required this.lastSync,
    required this.dbSizeBytes,
  });

  String get dbSizeFormatted {
    if (dbSizeBytes < 1024) return '$dbSizeBytes B';
    if (dbSizeBytes < 1024 * 1024) {
      return '${(dbSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(dbSizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}

final _aboutStatsProvider =
    FutureProvider.autoDispose<_AboutStats>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final companyId = ref.watch(selectedCompanyProvider)?.id ?? 0;

  final products = await (db.select(db.productsTable)
        ..where((t) => t.companyId.equals(companyId)))
      .get();
  final customers = await (db.select(db.customersTable)
        ..where((t) => t.companyId.equals(companyId)))
      .get();
  final users = await (db.select(db.usersTable)
        ..where((t) => t.companyId.equals(companyId)))
      .get();

  // Most recent lastSyncedAt across all entities
  final syncRows = await db.select(db.syncMetaTable).get();
  final lastSync = syncRows
      .map((r) => r.lastSyncedAt)
      .whereType<DateTime>()
      .fold<DateTime?>(
        null,
        (best, t) => best == null || t.isAfter(best) ? t : best,
      );

  int dbSizeBytes = 0;
  try {
    final path = await BackupService.dbFilePath();
    dbSizeBytes = File(path).lengthSync();
  } catch (_) {}

  return _AboutStats(
    productCount: products.length,
    customerCount: customers.length,
    userCount: users.length,
    lastSync: lastSync,
    dbSizeBytes: dbSizeBytes,
  );
});

String _fmtAboutDt(DateTime dt) {
  final l = dt.toLocal();
  final now = DateTime.now();
  final isToday =
      l.year == now.year && l.month == now.month && l.day == now.day;
  final datePart = isToday
      ? 'Today'
      : '${l.day.toString().padLeft(2, '0')}/'
            '${l.month.toString().padLeft(2, '0')}/'
            '${l.year}';
  final timePart =
      '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  return '$datePart at $timePart';
}

// ─────────────────────────────────────────────────────────────────────────────

class _AboutTab extends ConsumerWidget {
  const _AboutTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final company  = ref.watch(selectedCompanyProvider);
    final statsAsync = ref.watch(_aboutStatsProvider);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // ── Hero header ───────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.point_of_sale, size: 64, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  company?.name ?? 'POS System',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'API: ${settings[SettingKeys.apiBaseUrl] ?? '–'}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Company ───────────────────────────────────────────────────────
          _SettingsCard(
            title: 'COMPANY',
            children: [
              _InfoRow(label: 'Name',   value: company?.name       ?? '–'),
              _InfoRow(label: 'Tax No', value: company?.taxNumber  ?? '–'),
              _InfoRow(label: 'Phone',  value: company?.phoneNumber ?? '–'),
              _InfoRow(label: 'Address',value: company?.address    ?? '–'),
            ],
          ),

          // ── Database ──────────────────────────────────────────────────────
          statsAsync.when(
            loading: () => _SettingsCard(
              title: 'DATABASE',
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            ),
            error: (e, _) => _SettingsCard(
              title: 'DATABASE',
              children: [
                _InfoRow(label: 'Error', value: e.toString()),
              ],
            ),
            data: (s) => _SettingsCard(
              title: 'DATABASE',
              children: [
                _InfoRow(label: 'Products',  value: '${s.productCount}'),
                _InfoRow(label: 'Customers', value: '${s.customerCount}'),
                _InfoRow(label: 'Users',     value: '${s.userCount}'),
                _InfoRow(label: 'DB Size',   value: s.dbSizeFormatted),
                _InfoRow(
                  label: 'Last Sync',
                  value: s.lastSync != null ? _fmtAboutDt(s.lastSync!) : 'Never',
                ),
              ],
            ),
          ),

          // ── System ────────────────────────────────────────────────────────
          _SettingsCard(
            title: 'SYSTEM INFO',
            children: [
              _InfoRow(
                label: 'Currency',
                value: settings[SettingKeys.currencySymbol] ?? '–',
              ),
              _InfoRow(
                label: 'Language',
                value: settings[SettingKeys.language] ?? '–',
              ),
              _InfoRow(
                label: 'Date Format',
                value: settings[SettingKeys.dateFormat] ?? '–',
              ),
              _InfoRow(
                label: 'Industry Mode',
                value: settings[SettingKeys.industryMode] ?? '–',
              ),
              _InfoRow(
                label: 'Dual Currency',
                value: settings[SettingKeys.dualCurrencyEnabled] == 'true'
                    ? 'Enabled'
                    : 'Disabled',
              ),
              _InfoRow(
                label: 'Auto Backup',
                value: settings[SettingKeys.dbAutoBackup] == 'true'
                    ? 'On'
                    : 'Off',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Theme.of(context).hintColor, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ── Timezone Card ─────────────────────────────────────────────────────────────

String _tzOffsetLabel(String name) {
  try {
    final loc = tz.getLocation(name);
    final offsetMs = loc.currentTimeZone.offset.inMilliseconds;
    final sign = offsetMs >= 0 ? '+' : '-';
    final abs = offsetMs.abs();
    final h = (abs ~/ 3600000).toString().padLeft(2, '0');
    final m = ((abs % 3600000) ~/ 60000).toString().padLeft(2, '0');
    return '$name (UTC$sign$h:$m)';
  } catch (_) {
    return name;
  }
}

class _TimezoneCard extends ConsumerStatefulWidget {
  const _TimezoneCard();

  @override
  ConsumerState<_TimezoneCard> createState() => _TimezoneCardState();
}

class _TimezoneCardState extends ConsumerState<_TimezoneCard> {
  bool _detecting = false;
  List<String> _tzIds = [];

  @override
  void initState() {
    super.initState();
    _tzIds = [];
    // Defer heavy timezone DB init so it doesn't block the route transition
    Future.microtask(() {
      tz_data.initializeTimeZones();
      final ids = tz.timeZoneDatabase.locations.keys.toList()..sort();
      if (mounted) setState(() => _tzIds = ids);
    });
  }

  Future<void> _applyAutoTimezone() async {
    setState(() => _detecting = true);
    try {
      final detected = await FlutterTimezone.getLocalTimezone();
      await ref
          .read(appSettingsProvider.notifier)
          .set(SettingKeys.timezone, detected.identifier);
    } catch (_) {
      // Detection failed — keep the existing value.
    } finally {
      if (mounted) setState(() => _detecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final isAuto = (settings[SettingKeys.timezoneMode] ?? 'Auto') == 'Auto';
    final currentTz = settings[SettingKeys.timezone] ?? 'UTC';
    final safeId = _tzIds.contains(currentTz) ? currentTz : 'UTC';
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 8, 0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Timezone',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isAuto
                          ? 'Auto-detected: ${_tzOffsetLabel(currentTz)}'
                          : 'Set timezone manually',
                      style: TextStyle(fontSize: 12, color: theme.hintColor),
                    ),
                  ],
                ),
              ),
              if (_detecting)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Switch(
                  value: isAuto,
                  onChanged: (val) async {
                    await ref
                        .read(appSettingsProvider.notifier)
                        .set(SettingKeys.timezoneMode, val ? 'Auto' : 'Manual');
                    if (val) await _applyAutoTimezone();
                  },
                ),
              const SizedBox(width: 4),
              Text(
                'Auto',
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
        if (!isAuto) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: DropdownButtonFormField<String>(
              initialValue: safeId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'IANA Timezone',
                labelStyle: TextStyle(fontSize: 13, color: theme.hintColor),
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                isDense: true,
              ),
              dropdownColor: theme.colorScheme.surfaceContainerHighest,
              items: _tzIds
                  .map(
                    (id) => DropdownMenuItem(
                      value: id,
                      child: Text(
                        _tzOffsetLabel(id),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  ref
                      .read(appSettingsProvider.notifier)
                      .set(SettingKeys.timezone, val);
                }
              },
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COUNTRIES TAB
// ─────────────────────────────────────────────────────────────────────────────
class _CountriesTab extends ConsumerStatefulWidget {
  const _CountriesTab();

  @override
  ConsumerState<_CountriesTab> createState() => _CountriesTabState();
}

class _CountriesTabState extends ConsumerState<_CountriesTab> {
  List<Country> _countries = [];
  bool _loading = false;
  Country? _selected;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final company = ref.read(selectedCompanyProvider);
    if (company == null) return;
    setState(() => _loading = true);
    try {
      final dio = createDio();
      final res = await dio.get(
        '/Country/GetAllCountries',
        queryParameters: {'companyId': company.id},
      );
      final list = (res.data as List).map((e) => Country.fromJson(e)).toList();
      if (mounted) setState(() { _countries = list; _selected = null; });
    } catch (_) {
      if (mounted) setState(() => _countries = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(Country c) async {
    final company = ref.read(selectedCompanyProvider);
    if (company == null) return;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: cs.error),
            const SizedBox(width: 8),
            const Text("Delete Country"),
          ],
        ),
        content: Text("Delete '${c.name}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      final dio = createDio();
      await dio.delete(
        '/Country/Delete',
        queryParameters: {'id': c.id, 'companyId': company.id},
      );
      _load();
    } on DioException catch (e) {
      if (!mounted) return;
      final data = e.response?.data;
      final msg = (data is Map ? data['message'] : null) ?? data?.toString() ?? "Delete failed";
      showAppSnackbar(context, ref, msg, isError: true);
    }
  }

  Future<void> _openForm({Country? country}) async {
    final company = ref.read(selectedCompanyProvider);
    if (company == null) return;
    await showDialog(
      context: context,
      builder: (_) => _CountryFormDialog(companyId: company.id, country: country),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final company = ref.watch(selectedCompanyProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (company == null) {
      return Center(
        child: Text("No company selected.", style: TextStyle(color: cs.onSurfaceVariant)),
      );
    }

    return Column(
      children: [
        Container(
          color: cs.surfaceContainerLow,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: "Refresh",
                onPressed: _load,
              ),
              const SizedBox(width: 4),
              FilledButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text("New Country"),
                onPressed: () => _openForm(),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _loading
              ? Center(child: CircularProgressIndicator(color: cs.primary))
              : _countries.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.public, size: 64,
                              color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
                          const SizedBox(height: 16),
                          Text("No countries yet.",
                              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 16)),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text("Add Country"),
                            onPressed: () => _openForm(),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: LayoutBuilder(
                        builder: (context, constraints) => SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minWidth: constraints.maxWidth),
                            child: DataTable(
                              headingRowColor:
                                  WidgetStateProperty.all(cs.surfaceContainerHighest),
                              dataRowMaxHeight: 52,
                              dataRowMinHeight: 52,
                              columnSpacing: 32,
                              showCheckboxColumn: false,
                              columns: [
                                DataColumn(
                                  label: Text("Name",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: cs.onSurfaceVariant)),
                                ),
                                DataColumn(
                                  label: Text("Code",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: cs.onSurfaceVariant)),
                                ),
                                DataColumn(
                                  label: Text("Actions",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: cs.onSurfaceVariant)),
                                ),
                              ],
                              rows: _countries.map((c) {
                                final isSelected = _selected?.id == c.id;
                                return DataRow(
                                  selected: isSelected,
                                  onSelectChanged: (_) => setState(
                                      () => _selected = isSelected ? null : c),
                                  cells: [
                                    DataCell(Text(c.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500))),
                                    DataCell(Text(c.code ?? '–')),
                                    DataCell(Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit,
                                              color: cs.primary, size: 20),
                                          tooltip: "Edit",
                                          onPressed: () => _openForm(country: c),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete_outline,
                                              color: cs.error, size: 20),
                                          tooltip: "Delete",
                                          onPressed: () => _delete(c),
                                        ),
                                      ],
                                    )),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
        ),
      ],
    );
  }
}

class _CountryFormDialog extends ConsumerStatefulWidget {
  final int companyId;
  final Country? country;

  const _CountryFormDialog({required this.companyId, this.country});

  @override
  ConsumerState<_CountryFormDialog> createState() => _CountryFormDialogState();
}

class _CountryFormDialogState extends ConsumerState<_CountryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _codeCtrl;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.country?.name ?? '');
    _codeCtrl = TextEditingController(text: widget.country?.code ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _saving = true; _error = null; });
    try {
      final dio = createDio();
      final body = {
        'name': _nameCtrl.text.trim(),
        'code': _codeCtrl.text.trim().isEmpty ? null : _codeCtrl.text.trim(),
      };
      if (widget.country == null) {
        await dio.post(
          '/Country/Add',
          data: body,
          queryParameters: {'companyId': widget.companyId},
        );
      } else {
        await dio.put(
          '/Country/Update',
          data: body,
          queryParameters: {
            'id': widget.country!.id,
            'companyId': widget.companyId,
          },
        );
      }
      if (mounted) Navigator.of(context).pop();
    } on DioException catch (e) {
      setState(() => _error = e.response?.data?.toString() ?? "Save failed");
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isEdit = widget.country != null;

    return AlertDialog(
      backgroundColor: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(isEdit ? "Edit Country" : "New Country"),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_error != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_error!, style: TextStyle(color: cs.onErrorContainer)),
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: "Name *",
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? "Name is required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeCtrl,
                decoration: const InputDecoration(
                  labelText: "Code (e.g. US)",
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                maxLength: 10,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEdit ? "Save" : "Add"),
        ),
      ],
    );
  }
}
