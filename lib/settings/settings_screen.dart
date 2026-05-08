// lib/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:pos_app/printer/printer_selection_model.dart';
import 'package:pos_app/printer/printer_selection_settings_model.dart';
import 'package:pos_app/printer/printer_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ENTRY POINT
// ─────────────────────────────────────────────────────────────────────────────
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = [
    (icon: Icons.tune, label: 'General'),
    (icon: Icons.receipt_long, label: 'Order & Payment'),
    (icon: Icons.inventory_2, label: 'Products'),
    (icon: Icons.description, label: 'Documents'),
    (icon: Icons.monitor_weight, label: 'Weighing Scale'),
    (icon: Icons.display_settings, label: 'Customer Display'),
    (icon: Icons.email, label: 'Email'),
    (icon: Icons.print, label: 'Print'),
    (icon: Icons.currency_exchange, label: 'Dual Currency'),
    (icon: Icons.storage, label: 'Database'),
    (icon: Icons.vpn_key, label: 'License'),
    (icon: Icons.info_outline, label: 'About'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save settings: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(rawAppPropertiesProvider).isLoading;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: theme.colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.disabledColor,
              indicatorColor: theme.colorScheme.primary,
              indicatorWeight: 3,
              tabs: _tabs
                  .map(
                    (t) => Tab(
                      child: Row(
                        children: [
                          Icon(t.icon, size: 16),
                          const SizedBox(width: 6),
                          Text(t.label, style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
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
      body: TabBarView(
        controller: _tabController,
        children: const [
          _GeneralTab(),
          _OrderPaymentTab(),
          _ProductsTab(),
          _DocumentsTab(),
          _WeighingScaleTab(),
          _CustomerDisplayTab(),
          _EmailTab(),
          _PrintTab(),
          _DualCurrencyTab(),
          _DatabaseTab(),
          _LicenseTab(),
          _AboutTab(),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
  final int maxLines;

  const _SettingTextField({
    required this.settingKey,
    required this.label,
    this.hint,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.label} saved'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save ${widget.label}'),
            backgroundColor: Colors.red,
          ),
        );
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
              maxLines: widget.maxLines,
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
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
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
            (s) => Container(
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
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
            _SettingTextField(
              settingKey: SettingKeys.tablesButtonLabel,
              label: 'Tables Button Label',
              hint: 'e.g. Tables, Rooms, Resources',
            ),
          ],
        ),
        const _BookingSettingsCard(),
        const _WorkflowCard(),
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
            _SettingDropdown(
              settingKey: SettingKeys.themeMode,
              label: 'Theme Mode',
              options: ['dark', 'light'],
            ),
            _SettingTextField(
              settingKey: SettingKeys.themeAccentColor,
              label: 'Accent Color',
              hint: 'e.g. #FF5733',
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
    return _TabScrollView(
      cards: [
        _SettingsCard(
          title: 'ORDER',
          children: [
            const _SettingTextField(
              settingKey: SettingKeys.orderPrefix,
              label: 'Order Number Prefix',
              hint: 'e.g. ORD',
            ),
            const _SettingSwitch(
              settingKey: SettingKeys.allowNegativeStock,
              label: 'Allow Sale When Stock is Zero / Negative',
            ),
            const _SettingSwitch(
              settingKey: SettingKeys.allowPriceChange,
              label: 'Allow Cashier to Change Product Price',
            ),
            const _SettingDropdown(
              settingKey: SettingKeys.roundingMode,
              label: 'Rounding Decimal Places',
              options: ['0', '1', '2', '3', '4'],
            ),
          ],
        ),
        _SettingsCard(
          title: 'PAYMENT',
          children: [
            const _SettingTextField(
              settingKey: SettingKeys.defaultPaymentType,
              label: 'Default Payment Type Name',
              hint: 'e.g. Cash',
            ),
            const _SettingTextField(
              settingKey: SettingKeys.receiptFooter,
              label: 'Receipt Footer Message',
              hint: 'e.g. Thank you for your purchase!',
              maxLines: 3,
            ),
          ],
        ),
      ],
    );
  }
}

// ── Products ──────────────────────────────────────────────────────────────────
class _ProductsTab extends ConsumerWidget {
  const _ProductsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _TabScrollView(
      cards: [
        _SettingsCard(
          title: 'DISPLAY',
          children: [
            const _SettingSwitch(
              settingKey: SettingKeys.showProductImages,
              label: 'Show Product Images in POS Grid',
            ),
          ],
        ),
        _SettingsCard(
          title: 'DEFAULTS',
          children: [
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
    return _TabScrollView(
      cards: [
        _SettingsCard(
          title: 'SCALE CONNECTION',
          children: [
            const _SettingSwitch(
              settingKey: SettingKeys.scaleEnabled,
              label: 'Weighing Scale Enabled',
              subtitle:
                  'Connect a serial weighing scale to automatically read weights',
            ),
            const _SettingDropdown(
              settingKey: SettingKeys.scalePort,
              label: 'Serial Port',
              options: [
                'COM1',
                'COM2',
                'COM3',
                'COM4',
                '/dev/ttyS0',
                '/dev/ttyS1',
              ],
            ),
            const _SettingDropdown(
              settingKey: SettingKeys.scaleBaudRate,
              label: 'Baud Rate',
              options: ['1200', '2400', '4800', '9600', '19200', '38400'],
            ),
          ],
        ),
      ],
    );
  }
}

// ── Customer Display ──────────────────────────────────────────────────────────
class _CustomerDisplayTab extends ConsumerWidget {
  const _CustomerDisplayTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _TabScrollView(
      cards: [
        _SettingsCard(
          title: 'CUSTOMER DISPLAY',
          children: [
            const _SettingSwitch(
              settingKey: SettingKeys.customerDisplayEnabled,
              label: 'Customer Display Enabled',
              subtitle:
                  'Show order total on a secondary customer-facing screen',
            ),
            const _SettingDropdown(
              settingKey: SettingKeys.customerDisplayPort,
              label: 'Display Port',
              options: [
                'COM1',
                'COM2',
                'COM3',
                'COM4',
                '/dev/ttyS0',
                '/dev/ttyS1',
                'Network',
              ],
            ),
            const _SettingTextField(
              settingKey: SettingKeys.customerDisplayWelcomeMessage,
              label: 'Welcome Message',
              hint: 'e.g. Welcome!',
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
class _PrintTab extends ConsumerWidget {
  const _PrintTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final company = ref.watch(selectedCompanyProvider);
    final selectionsAsync = ref.watch(allPrinterSelectionsProvider);
    final cs = Theme.of(context).colorScheme;

    return selectionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: cs.error),
              const SizedBox(height: 12),
              Text(
                '$e',
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.error),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                onPressed: () => ref.invalidate(allPrinterSelectionsProvider),
              ),
            ],
          ),
        ),
      ),
      data: (selections) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Company context banner — helps diagnose ID mismatches
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.business_outlined,
                    size: 16,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    company != null
                        ? 'Company: ${company.name} (ID ${company.id})'
                        : 'No company selected',
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                  const Spacer(),
                  Text(
                    '${selections.length} slot${selections.length == 1 ? '' : 's'}',
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (selections.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(
                      Icons.print_disabled_outlined,
                      size: 48,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No printer slots found for Company ID ${company?.id}.\nUse "+ Add Printer Slot" to create one.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ...selections.map(
              (sel) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PrinterSlotCard(
                  selection: sel,
                  onChanged: () => ref.invalidate(allPrinterSelectionsProvider),
                ),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Printer Slot'),
              onPressed: () => _showAddSlotDialog(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSlotDialog(BuildContext context, WidgetRef ref) {
    final keyCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Printer Slot'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: keyCtrl,
              decoration: const InputDecoration(
                labelText: 'Slot Key',
                hintText: 'receipt_printer, kitchen_printer, laddition_printer',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Printer Name (optional)',
                hintText: 'e.g. EPSON TM-T88VI',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (keyCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              await _addSlot(
                context,
                ref,
                keyCtrl.text.trim(),
                nameCtrl.text.trim().isEmpty ? null : nameCtrl.text.trim(),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addSlot(
    BuildContext context,
    WidgetRef ref,
    String key,
    String? printerName,
  ) async {
    final company = ref.read(selectedCompanyProvider);
    if (company == null) return;
    try {
      final dio = createDio();
      await dio.post(
        '/PosPrinterSelections/Add',
        queryParameters: {'companyId': company.id},
        data: {'key': key, 'printerName': printerName, 'isEnabled': false},
      );
      ref.invalidate(allPrinterSelectionsProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add slot: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// ── Printer Slot Card ─────────────────────────────────────────────────────────
class _PrinterSlotCard extends ConsumerStatefulWidget {
  final PrinterSelectionModel selection;
  final VoidCallback onChanged;

  const _PrinterSlotCard({required this.selection, required this.onChanged});

  @override
  ConsumerState<_PrinterSlotCard> createState() => _PrinterSlotCardState();
}

class _PrinterSlotCardState extends ConsumerState<_PrinterSlotCard> {
  late TextEditingController _nameCtrl;
  late bool _isEnabled;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.selection.printerName ?? '');
    _isEnabled = widget.selection.isEnabled;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveSelection() async {
    final company = ref.read(selectedCompanyProvider);
    if (company == null) return;
    setState(() => _isSaving = true);
    try {
      final dio = createDio();
      await dio.put(
        '/PosPrinterSelections/Update/${widget.selection.id}',
        queryParameters: {
          'key': widget.selection.key,
          'printerName': _nameCtrl.text.trim().isEmpty
              ? null
              : _nameCtrl.text.trim(),
          'isEnabled': _isEnabled,
        },
      );
      widget.onChanged();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Printer slot saved.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Save failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _openLayoutSheet() async {
    final company = ref.read(selectedCompanyProvider);
    if (company == null) return;
    PrinterSelectionSettingsModel? settings;
    try {
      final dio = createDio();
      final res = await dio.get(
        '/PosPrinterSelectionSettings/GetBySelectionId/${widget.selection.id}',
        queryParameters: {'companyId': company.id},
      );
      final list = res.data as List?;
      if (list != null && list.isNotEmpty) {
        settings = PrinterSelectionSettingsModel.fromJson(list.first);
      }
    } catch (_) {}
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _LayoutSettingsSheet(
        selectionId: widget.selection.id,
        settings: settings,
        onSaved: widget.onChanged,
      ),
    );
  }

  static String _slotLabel(String key) => switch (key) {
    'receipt_printer' => 'Receipt Printer',
    'kitchen_printer' => 'Kitchen Printer',
    'laddition_printer' => "L'Addition Printer",
    _ => key,
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.print_outlined, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  _slotLabel(widget.selection.key),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: ShapeDecoration(
                    color: cs.surfaceContainerHighest,
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    widget.selection.key,
                    style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                  ),
                ),
                const Spacer(),
                Switch(
                  value: _isEnabled,
                  onChanged: (v) {
                    setState(() => _isEnabled = v);
                    _saveSelection();
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: 'Printer Name',
                hintText: 'Leave empty to use default printer',
                border: const OutlineInputBorder(),
                suffixIcon: _isSaving
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.save_outlined),
                        onPressed: _saveSelection,
                        tooltip: 'Save',
                      ),
              ),
              onSubmitted: (_) => _saveSelection(),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.tune, size: 16),
                label: const Text('Edit Layout'),
                onPressed: _openLayoutSheet,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Layout Settings Bottom Sheet ──────────────────────────────────────────────
class _LayoutSettingsSheet extends ConsumerStatefulWidget {
  final int selectionId;
  final PrinterSelectionSettingsModel? settings;
  final VoidCallback onSaved;

  const _LayoutSettingsSheet({
    required this.selectionId,
    this.settings,
    required this.onSaved,
  });

  @override
  ConsumerState<_LayoutSettingsSheet> createState() =>
      _LayoutSettingsSheetState();
}

class _LayoutSettingsSheetState extends ConsumerState<_LayoutSettingsSheet> {
  late TextEditingController _headerCtrl;
  late TextEditingController _footerCtrl;
  late TextEditingController _copiesCtrl;
  late int _paperWidth;
  late bool _printBarcode;
  late bool _cutPaper;
  late bool _openCashDrawer;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.settings;
    _headerCtrl = TextEditingController(text: s?.header ?? '');
    _footerCtrl = TextEditingController(text: s?.footer ?? '');
    _copiesCtrl = TextEditingController(
      text: (s?.numberOfCopies ?? 1).toString(),
    );
    _paperWidth = s?.paperWidth ?? 80;
    _printBarcode = s?.printBarcode ?? true;
    _cutPaper = s?.cutPaper ?? true;
    _openCashDrawer = s?.openCashDrawer ?? true;
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _footerCtrl.dispose();
    _copiesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final company = ref.read(selectedCompanyProvider);
    if (company == null) return;
    setState(() => _isSaving = true);
    final copies = int.tryParse(_copiesCtrl.text) ?? 1;
    final header = _headerCtrl.text.trim().isEmpty
        ? null
        : _headerCtrl.text.trim();
    final footer = _footerCtrl.text.trim().isEmpty
        ? null
        : _footerCtrl.text.trim();

    try {
      final dio = createDio();
      final s = widget.settings;

      if (s == null) {
        await dio.post(
          '/PosPrinterSelectionSettings/Add',
          queryParameters: {'companyId': company.id},
          data: {
            'posPrinterSelectionId': widget.selectionId,
            'paperWidth': _paperWidth,
            'header': header,
            'footer': footer,
            'cutPaper': _cutPaper,
            'openCashDrawer': _openCashDrawer,
            'printBarcode': _printBarcode,
            'numberOfCopies': copies,
          },
        );
      } else {
        final updated = PrinterSelectionSettingsModel(
          id: s.id,
          posPrinterSelectionId: s.posPrinterSelectionId,
          paperWidth: _paperWidth,
          header: header,
          footer: footer,
          feedLines: s.feedLines,
          cutPaper: _cutPaper,
          printBitmap: s.printBitmap,
          openCashDrawer: _openCashDrawer,
          cashDrawerCommand: s.cashDrawerCommand,
          headerAlignment: s.headerAlignment,
          footerAlignment: s.footerAlignment,
          isFormattingEnabled: s.isFormattingEnabled,
          printerType: s.printerType,
          numberOfCopies: copies,
          codePage: s.codePage,
          characterSet: s.characterSet,
          margin: s.margin,
          leftMargin: s.leftMargin,
          topMargin: s.topMargin,
          rightMargin: s.rightMargin,
          bottomMargin: s.bottomMargin,
          printBarcode: _printBarcode,
          fontName: s.fontName,
          fontSizePercent: s.fontSizePercent,
          printLogoFullWidth: s.printLogoFullWidth,
        );
        await dio.put(
          '/PosPrinterSelectionSettings/Update/${s.id}',
          queryParameters: updated.toQueryParams(),
        );
      }

      widget.onSaved();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Layout settings saved.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Save failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (ctx, scrollCtrl) => ListView(
        controller: scrollCtrl,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'Layout Settings',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<int>(
            initialValue: _paperWidth == 58 ? 58 : 80,
            decoration: const InputDecoration(
              labelText: 'Paper Width',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 80, child: Text('80 mm')),
              DropdownMenuItem(value: 58, child: Text('58 mm')),
            ],
            onChanged: (v) => setState(() => _paperWidth = v ?? 80),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _headerCtrl,
            decoration: const InputDecoration(
              labelText: 'Header Text',
              hintText: 'e.g. MY RESTAURANT',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _footerCtrl,
            decoration: const InputDecoration(
              labelText: 'Footer Text',
              hintText: 'e.g. Thank you for your visit!',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _copiesCtrl,
            decoration: const InputDecoration(
              labelText: 'Number of Copies',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            value: _printBarcode,
            onChanged: (v) => setState(() => _printBarcode = v),
            title: const Text('Print Barcode'),
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            value: _cutPaper,
            onChanged: (v) => setState(() => _cutPaper = v),
            title: const Text('Cut Paper After Print'),
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            value: _openCashDrawer,
            onChanged: (v) => setState(() => _openCashDrawer = v),
            title: const Text('Open Cash Drawer'),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isSaving ? null : _save,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save Layout'),
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
class _DatabaseTab extends ConsumerWidget {
  const _DatabaseTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _TabScrollView(
      cards: [
        _SettingsCard(
          title: 'BACKUP',
          children: [
            const _SettingSwitch(
              settingKey: SettingKeys.dbAutoBackup,
              label: 'Automatic Backup Enabled',
            ),
            const _SettingTextField(
              settingKey: SettingKeys.dbBackupPath,
              label: 'Backup Destination Path',
              hint: 'e.g. C:\\Backups\\POS  or  /home/user/backups',
            ),
            const _SettingTextField(
              settingKey: SettingKeys.dbBackupVersion,
              label: 'Backup Schema Version',
              hint: 'e.g. v2',
            ),
          ],
        ),
      ],
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
class _AboutTab extends ConsumerWidget {
  const _AboutTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
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
                const Text(
                  'POS System',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
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
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SettingsCard(
            title: 'SYSTEM INFO',
            children: [
              _InfoRow(
                label: 'Currency Symbol',
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
                label: 'Tax Included by Default',
                value: (settings[SettingKeys.taxIncludedByDefault] == 'true')
                    ? 'Yes'
                    : 'No',
              ),
              _InfoRow(
                label: 'Dual Currency',
                value: (settings[SettingKeys.dualCurrencyEnabled] == 'true')
                    ? 'Enabled'
                    : 'Disabled',
              ),
              _InfoRow(
                label: 'Backup',
                value: (settings[SettingKeys.dbAutoBackup] == 'true')
                    ? 'Automatic'
                    : 'Manual',
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
  late final List<String> _tzIds;

  @override
  void initState() {
    super.initState();
    tz_data.initializeTimeZones();
    _tzIds = tz.timeZoneDatabase.locations.keys.toList()..sort();
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
