// lib/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/app_settings/app_settings_model.dart';
import 'package:pos_app/app_settings/app_settings_provider.dart';

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

  const _SettingSwitch({
    required this.settingKey,
    required this.label,
    this.subtitle,
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
      onChanged: (v) =>
          ref.read(appSettingsProvider.notifier).setBool(settingKey, v),
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
            const _SettingTextField(
              settingKey: SettingKeys.currencySymbol,
              label: 'Currency Symbol',
              hint: 'e.g.  \$  €  £',
            ),
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
            const _SettingTextField(
              settingKey: SettingKeys.timezone,
              label: 'Timezone',
              hint: 'e.g. UTC, Europe/Paris',
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
    return _TabScrollView(
      cards: [
        _SettingsCard(
          title: 'PRINTER',
          children: [
            const _SettingTextField(
              settingKey: SettingKeys.printerName,
              label: 'Printer Name',
              hint: 'Leave empty to use default printer',
            ),
            const _SettingDropdown(
              settingKey: SettingKeys.paperSize,
              label: 'Paper Size',
              options: ['80mm', '58mm', 'A4', 'A5', 'Letter'],
            ),
            const _SettingTextField(
              settingKey: SettingKeys.printCopies,
              label: 'Number of Copies',
              hint: '1',
              keyboardType: TextInputType.number,
            ),
            const _SettingSwitch(
              settingKey: SettingKeys.autoprint,
              label: 'Auto-print Receipt After Sale',
            ),
          ],
        ),
      ],
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
                        Icon(Icons.check_circle,
                            color: Colors.greenAccent, size: 18),
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
                  theme.colorScheme.secondaryContainer
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
