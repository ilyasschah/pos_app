import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/app_settings/app_settings_model.dart';
import 'package:pos_app/app_settings/app_settings_provider.dart';
import 'package:pos_app/auth/auth_provider.dart';
import 'package:pos_app/cart/cart_provider.dart';
import 'package:pos_app/cart/checkout_models.dart';
import 'package:pos_app/cart/payment_type_model.dart';
import 'package:pos_app/cart/payment_type_provider.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/currency/currencies_provider.dart';
import 'package:pos_app/customer/customer_model.dart';
import 'package:pos_app/customer/customer_provider.dart';
import 'package:pos_app/document/document_type_constants.dart';
import 'package:pos_app/navigation/main_layout.dart';
import 'package:pos_app/printer/receipt_printer_service.dart';

// ---------------------------------------------------------------------------
// Main Dialog
// ---------------------------------------------------------------------------
class PaymentCheckoutDialog extends ConsumerStatefulWidget {
  const PaymentCheckoutDialog({super.key});

  @override
  ConsumerState<PaymentCheckoutDialog> createState() =>
      _PaymentCheckoutDialogState();
}

class _PaymentCheckoutDialogState
    extends ConsumerState<PaymentCheckoutDialog> {
  // ── Numpad state: ValueNotifier so ONLY the Paid/Change rows rebuild ──
  final _paidNotifier = ValueNotifier<String>('');

  int? _selectedPaymentTypeId;
  bool _isProcessing = false;

  // Snapshot captured once at open — never re-read during numpad input
  late final double _grandTotal;
  late final double _subtotal;
  late final double _taxTotal;
  late final double _totalDiscount;
  late final List<CartItem> _cartItems;
  late final String _sym;

  @override
  void initState() {
    super.initState();
    final notifier = ref.read(cartProvider.notifier);
    _grandTotal  = ref.read(cartTotalProvider);
    _subtotal    = notifier.subtotal;
    _taxTotal    = notifier.taxTotal;
    _totalDiscount = notifier.discountTotal
        + notifier.manualCartDiscountAmount
        + notifier.customerDiscountAmount
        + notifier.promotionalDiscountTotal;
    _cartItems   = List.unmodifiable(ref.read(cartProvider).items);
    _sym         = ref.read(currencySymbolProvider);
    _paidNotifier.value = '0';
  }

  @override
  void dispose() {
    _paidNotifier.dispose();
    super.dispose();
  }

  // ── Numpad logic ──────────────────────────────────────────────────────────
  void _onKey(String key) {
    final cur = _paidNotifier.value;
    String next;
    switch (key) {
      case '⌫':
        next = cur.length > 1 ? cur.substring(0, cur.length - 1) : '0';
        break;
      case 'C':
        next = '0';
        break;
      case '.':
        next = cur.contains('.') ? cur : '$cur.';
        break;
      case '00':
        next = cur == '0' ? '0' : '${cur}00';
        break;
      default: // digit
        next = cur == '0' ? key : '$cur$key';
    }
    // Cap at 2 decimal places
    final parts = next.split('.');
    if (parts.length > 1 && parts[1].length > 2) return;
    _paidNotifier.value = next;
  }

  double get _paid => double.tryParse(_paidNotifier.value) ?? 0;

  // ── Checkout ──────────────────────────────────────────────────────────────
  Future<void> _complete(BuildContext ctx) async {
    if (_selectedPaymentTypeId == null) return;
    setState(() => _isProcessing = true);

    final user    = ref.read(currentUserProvider);
    final company = ref.read(selectedCompanyProvider);
    if (company == null || user == null) {
      setState(() => _isProcessing = false);
      return;
    }

    // Capture everything before checkout clears the cart
    final wasBooking = ref.read(cartProvider).bookingId != null;
    final wasTable   = ref.read(cartProvider).floorPlanTableId != null;
    final orderNum   = ref.read(cartProvider).orderNumber;
    final payTypes   = ref.read(allPaymentTypesProvider).asData?.value ?? [];
    final selectedPayType = payTypes
        .where((p) => p.id == _selectedPaymentTypeId)
        .firstOrNull;
    final payName = selectedPayType?.name;

    // Rule 1: block checkout if the payment type requires a real customer.
    // The default walk-in customer has code "C000" — that is not sufficient.
    if (selectedPayType?.isCustomerRequired == true) {
      final customer = ref.read(cartProvider).selectedCustomer;
      if (customer == null || customer.code == 'C000') {
        setState(() => _isProcessing = false);
        if (mounted) {
          await showDialog<void>(
            context: ctx,
            builder: (c) => AlertDialog(
              icon: const Icon(Icons.block, color: Colors.red, size: 36),
              title: const Text('Transaction Blocked'),
              content: const Text(
                'Credit payment requires a selected customer.\n\n'
                'Please choose a customer before completing this transaction.',
              ),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.pop(c),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        return;
      }
    }
    Uint8List? logoBytes;
    final logoB64 = company.logo;
    if (logoB64 != null && logoB64.isNotEmpty) {
      try { logoBytes = base64Decode(logoB64); } catch (_) {}
    }
    final appSettings = ref.read(appSettingsProvider);

    try {
      // Cap at grandTotal: tendered amount is UI-only for change display.
      // _paid.clamp preserves the partial-payment path for future Credit/Tab.
      final amountToSave = _paid.clamp(0.0, _grandTotal);

      final success = await ref.read(cartProvider.notifier).checkoutOrder(
        apiClient:      ApiClient(),
        companyId:      company.id,
        userId:         user.id,
        paymentTypeId:  _selectedPaymentTypeId!,
        amountPaid:     amountToSave,
        documentTypeId: DocumentTypes.sales,
      );

      if (!success || !mounted) return;

      // ── Close dialog immediately — cashier can start next order ──
      Navigator.pop(ctx);

      // ── Fire-and-forget: print + navigate in background ──────────
      ReceiptPrinterService().printCartReceipt(
        company:         company,
        cashier:         user,
        orderNumber:     orderNum ?? 'WALK-IN',
        printTime:       DateTime.now(),
        items:           _cartItems,
        subtotal:        _subtotal,
        totalDiscount:   _totalDiscount,
        totalTax:        _taxTotal,
        grandTotal:      _grandTotal,
        currencySymbol:  _sym,
        paymentTypeName: payName,
        amountPaid:      _paid,
        logoBytes:       logoBytes,
        roleSettings:    appSettings,
      ).catchError((_) {}); // swallow print errors silently

      await syncLatestOrderNumber(ref, company.id);

      final bookingEnabled   = appSettings[SettingKeys.featureBookingEnabled]?.toLowerCase() == 'true';
      final floorPlanEnabled = appSettings[SettingKeys.featureFloorPlanEnabled]?.toLowerCase() == 'true';
      final int nextIndex;
      if (wasBooking && bookingEnabled)       nextIndex = 2;
      else if (wasTable && floorPlanEnabled)  nextIndex = 3;
      else if (bookingEnabled)                nextIndex = 2;
      else if (floorPlanEnabled)              nextIndex = 3;
      else                                    nextIndex = 0;

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          ctx,
          MaterialPageRoute(builder: (_) => MainLayout(initialIndex: nextIndex)),
          (r) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(ctx)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  // ── Customer picker (reused from menu_screen pattern) ─────────────────────
  void _clearCustomer() {
    final companyId = ref.read(selectedCompanyProvider)?.id;
    final customers = ref.read(allCustomersProvider).asData?.value ?? [];
    final defaultCustomer = customers.firstWhere(
      (c) => c.code == 'C000',
      orElse: () => customers.first,
    );
    ref.read(currentCustomerProvider.notifier).setCustomer(defaultCustomer);
    if (companyId != null) {
      ref.read(cartProvider.notifier).setCustomer(companyId, defaultCustomer);
    }
  }

  void _pickCustomer(BuildContext ctx, List<Customer> customers) {
    showDialog(
      context: ctx,
      builder: (c) => AlertDialog(
        title: const Text('Select Customer'),
        content: SizedBox(
          width: 360,
          height: 360,
          child: Material(
            color: Colors.transparent,
            child: ListView.separated(
              itemCount: customers.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (c2, i) {
                final cu = customers[i];
                final isSelected =
                    ref.read(cartProvider).selectedCustomer?.id == cu.id;
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(cu.name),
                  subtitle: Text(cu.phoneNumber ?? cu.email ?? ''),
                  selected: isSelected,
                  onTap: () {
                    final companyId = ref.read(selectedCompanyProvider)?.id;
                    ref.read(currentCustomerProvider.notifier).setCustomer(cu);
                    if (companyId != null) {
                      ref.read(cartProvider.notifier).setCustomer(companyId, cu);
                    }
                    Navigator.pop(c);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final payTypesAsync = ref.watch(allPaymentTypesProvider);
    final customer = ref.watch(cartProvider).selectedCustomer;
    final allCustomersAsync = ref.watch(allCustomersProvider);

    // Auto-select first payment type once loaded
    payTypesAsync.whenData((types) {
      if (_selectedPaymentTypeId == null && types.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _selectedPaymentTypeId = types.first.id);
        });
      }
    });

    final selectedPayType = payTypesAsync.asData?.value
        .where((p) => p.id == _selectedPaymentTypeId)
        .firstOrNull;
    final markAsPaid = selectedPayType?.markAsPaid ?? true;

    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 24,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── LEFT: Order Summary ────────────────────────────────────────
            _OrderSummaryColumn(
              items: _cartItems,
              subtotal: _subtotal,
              taxTotal: _taxTotal,
              discountTotal: _totalDiscount,
              grandTotal: _grandTotal,
              sym: _sym,
            ),
            VerticalDivider(width: 1, color: theme.colorScheme.outlineVariant),

            // ── CENTER: Payment Methods ────────────────────────────────────
            _PaymentMethodsColumn(
              payTypesAsync: payTypesAsync,
              selectedId: _selectedPaymentTypeId,
              onSelect: (id) => setState(() => _selectedPaymentTypeId = id),
            ),
            VerticalDivider(width: 1, color: theme.colorScheme.outlineVariant),

            // ── RIGHT: Numpad & Totals ─────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Customer button bar
                  _CustomerBar(
                    customer: customer,
                    allCustomersAsync: allCustomersAsync,
                    onPick: _pickCustomer,
                    onCancel: () => Navigator.pop(context),
                  ),
                  const Divider(height: 1),

                  // Totals display
                  _TotalsDisplay(
                    grandTotal: _grandTotal,
                    sym: _sym,
                    paidNotifier: _paidNotifier,
                    markAsPaid: markAsPaid,
                  ),
                  const Divider(height: 1),

                  // Rich customer card — only for real (non-walk-in) customers
                  if (customer != null && customer.code != 'C000')
                    _CustomerDetailCard(
                      customer: customer,
                      onRemove: _clearCustomer,
                    ),

                  _Numpad(
                    onKey: _onKey,
                    onComplete: _selectedPaymentTypeId != null && !_isProcessing
                        ? () => _complete(context)
                        : null,
                    isProcessing: _isProcessing,
                    paidNotifier: _paidNotifier,
                    grandTotal: _grandTotal,
                    markAsPaid: markAsPaid,
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

// ---------------------------------------------------------------------------
// Left column: order summary
// ---------------------------------------------------------------------------
class _OrderSummaryColumn extends StatelessWidget {
  final List<CartItem> items;
  final double subtotal, taxTotal, discountTotal, grandTotal;
  final String sym;

  const _OrderSummaryColumn({
    required this.items,
    required this.subtotal,
    required this.taxTotal,
    required this.discountTotal,
    required this.grandTotal,
    required this.sym,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            color: theme.colorScheme.surfaceContainer,
            child: Text(
              'Order Summary',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          // Items list
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: items.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: theme.colorScheme.outlineVariant),
                itemBuilder: (_, i) {
                  final item = items[i];
                  final lineTotal =
                      (item.price - item.discount - item.promotionalDiscount) *
                      item.quantity;
                  return ListTile(
                    dense: true,
                    title: Text(
                      item.productName,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w500),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${item.quantity % 1 == 0 ? item.quantity.toInt() : item.quantity} × $sym ${item.price.toStringAsFixed(2)}',
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: Text(
                      '$sym ${lineTotal.toStringAsFixed(2)}',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),
          ),
          // Summary footer
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              border: Border(
                top: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
            ),
            child: Column(
              children: [
                _SummaryRow('Subtotal', subtotal, sym, theme),
                if (discountTotal > 0)
                  _SummaryRow('Discounts', -discountTotal, sym, theme,
                      color: Colors.green),
                if (taxTotal > 0)
                  _SummaryRow('Taxes', taxTotal, sym, theme),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    Text(
                      '$sym ${grandTotal.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _SummaryRow(String label, double amount, String sym, ThemeData theme,
    {Color? color}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        Text(
          '$sym ${amount.abs().toStringAsFixed(2)}',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: color ?? theme.colorScheme.onSurface),
        ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// Center column: payment methods
// ---------------------------------------------------------------------------
class _PaymentMethodsColumn extends StatelessWidget {
  final AsyncValue<List<PaymentType>> payTypesAsync;
  final int? selectedId;
  final void Function(int) onSelect;

  const _PaymentMethodsColumn({
    required this.payTypesAsync,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 210,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            color: theme.colorScheme.surfaceContainer,
            child: Text(
              'Payment Method',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: payTypesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('Error', style: TextStyle(color: theme.colorScheme.error)),
              ),
              data: (types) => Material(
                color: Colors.transparent,
                child: ListView(
                  padding: const EdgeInsets.all(8),
                  children: [
                    ...types.where((t) => t.isEnabled).map((t) {
                      final isSelected = selectedId == t.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: _PaymentTypeButton(
                          type: t,
                          isSelected: isSelected,
                          onTap: () => onSelect(t.id),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () =>
                          debugPrint('Split payments: to be implemented'),
                      icon: const Icon(Icons.call_split, size: 18),
                      label: const Text('Split Payments'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
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

class _PaymentTypeButton extends StatelessWidget {
  final PaymentType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentTypeButton({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: isSelected
          ? theme.colorScheme.primary
          : theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Row(
            children: [
              Icon(
                _iconForPayment(type.name),
                size: 20,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  type.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForPayment(String name) {
    final n = name.toLowerCase();
    if (n.contains('cash') || n.contains('espèce') || n.contains('espece'))
      return Icons.payments_rounded;
    if (n.contains('credit') || n.contains('card') || n.contains('carte'))
      return Icons.credit_card;
    if (n.contains('debit')) return Icons.credit_card_outlined;
    if (n.contains('check') || n.contains('chèque')) return Icons.receipt_long;
    if (n.contains('voucher')) return Icons.confirmation_number;
    if (n.contains('gift')) return Icons.card_giftcard;
    return Icons.payment;
  }
}

// ---------------------------------------------------------------------------
// Customer bar (top of right column)
// ---------------------------------------------------------------------------
class _CustomerBar extends StatelessWidget {
  final Customer? customer;
  final AsyncValue allCustomersAsync;
  final void Function(BuildContext, List<Customer>) onPick;
  final VoidCallback onCancel;

  const _CustomerBar({
    required this.customer,
    required this.allCustomersAsync,
    required this.onPick,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainer,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          allCustomersAsync.when(
            loading: () => const SizedBox(
              width: 18, height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (all) {
              final customers =
                  (all as List<dynamic>).whereType<Customer>()
                      .where((c) => c.isCustomer)
                      .toList();
              return TextButton.icon(
                onPressed: () => onPick(context, customers),
                icon: const Icon(Icons.person_outline, size: 18),
                label: Text(
                  customer?.name ?? 'Walk-in',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              );
            },
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: onCancel,
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Cancel'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Totals display (Total / Paid / Change)
// Only Paid and Change rows listen to _paidNotifier — Total never rebuilds
// ---------------------------------------------------------------------------
class _TotalsDisplay extends StatelessWidget {
  final double grandTotal;
  final String sym;
  final ValueNotifier<String> paidNotifier;
  final bool markAsPaid;

  const _TotalsDisplay({
    required this.grandTotal,
    required this.sym,
    required this.paidNotifier,
    required this.markAsPaid,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          // Total — static, never rebuilds
          _TotalRow(
            label: 'Total',
            value: '$sym ${grandTotal.toStringAsFixed(2)}',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          // Paid, Change/Remaining — only these rebuild on numpad input
          ValueListenableBuilder<String>(
            valueListenable: paidNotifier,
            builder: (_, raw, __) {
              final paid      = double.tryParse(raw) ?? 0;
              final change    = (paid - grandTotal).clamp(0.0, double.infinity);
              final remaining = paid < grandTotal ? grandTotal - paid : 0.0;
              return Column(
                children: [
                  _TotalRow(
                    label: 'Paid',
                    value: '$sym ${paid.toStringAsFixed(2)}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    trailing: Icon(Icons.edit,
                        size: 16,
                        color: theme.colorScheme.onSurface.withAlpha(120)),
                  ),
                  const SizedBox(height: 12),
                  // Show "Remaining" for credit/tab types; show "Change" for cash
                  if (!markAsPaid && remaining > 0) ...[
                    _TotalRow(
                      label: 'Remaining',
                      value: '$sym ${remaining.toStringAsFixed(2)}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ] else ...[
                    _TotalRow(
                      label: 'Change',
                      value: '$sym ${change.toStringAsFixed(2)}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: change > 0
                            ? Colors.green
                            : theme.colorScheme.onSurface.withAlpha(100),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? style;
  final Widget? trailing;

  const _TotalRow({
    required this.label,
    required this.value,
    this.style,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: theme.textTheme.titleMedium
                ?.copyWith(color: theme.colorScheme.onSurface.withAlpha(160))),
        Row(children: [
          if (trailing != null) ...[trailing!, const SizedBox(width: 6)],
          Text(value, style: style ?? theme.textTheme.headlineSmall),
        ]),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Numpad — fully fluid Expanded layout.
// Returns Expanded so it fills all remaining vertical space in the right
// column. No hardcoded pixel sizes anywhere; Flutter sizes buttons to fit.
//
// Grid layout:
//   Row 1: 7  8  9  ⌫
//   Row 2: 4  5  6  C
//   Row 3+4 left (flex 3):  1 2 3 / 00 0 .
//   Row 3+4 right (flex 1): Complete (spans both rows)
// ---------------------------------------------------------------------------
class _Numpad extends StatelessWidget {
  final void Function(String) onKey;
  final VoidCallback? onComplete;
  final bool isProcessing;
  final ValueNotifier<String> paidNotifier;
  final double grandTotal;
  final bool markAsPaid;

  const _Numpad({
    required this.onKey,
    required this.onComplete,
    required this.isProcessing,
    required this.paidNotifier,
    required this.grandTotal,
    required this.markAsPaid,
  });

  static const double _gap = 8;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget numKey(String key) => Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () => onKey(key),
        borderRadius: BorderRadius.circular(10),
        child: Center(
          child: Text(
            key,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );

    Widget actionKey(String key) => Material(
      color: theme.colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () => onKey(key),
        borderRadius: BorderRadius.circular(10),
        child: Center(
          child: key == '⌫'
              ? Icon(Icons.backspace_outlined,
                  size: 26, color: theme.colorScheme.onErrorContainer)
              : Text(
                  key,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
        ),
      ),
    );

    Widget expandedRow(List<Widget> children) => Row(
      children: [
        for (int i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: _gap),
          Expanded(child: children[i]),
        ],
      ],
    );

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Column(
          children: [
            // Row 1: 7  8  9  ⌫
            Expanded(child: expandedRow([
              numKey('7'), numKey('8'), numKey('9'), actionKey('⌫'),
            ])),
            const SizedBox(height: _gap),
            // Row 2: 4  5  6  C
            Expanded(child: expandedRow([
              numKey('4'), numKey('5'), numKey('6'), actionKey('C'),
            ])),
            const SizedBox(height: _gap),
            // Rows 3+4: number grid left, Complete button right (spans both)
            Expanded(
              flex: 2,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left: 3 cols × 2 rows
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        Expanded(child: expandedRow([
                          numKey('1'), numKey('2'), numKey('3'),
                        ])),
                        const SizedBox(height: _gap),
                        Expanded(child: expandedRow([
                          numKey('00'), numKey('0'), numKey('.'),
                        ])),
                      ],
                    ),
                  ),
                  const SizedBox(width: _gap),
                  // Right: Complete spans full height of both rows
                  Expanded(
                    child: ValueListenableBuilder<String>(
                      valueListenable: paidNotifier,
                      builder: (_, raw, __) {
                        final paid   = double.tryParse(raw) ?? 0;
                        // Credit/tab types (markAsPaid == false) can complete
                        // even when paid amount is less than the grand total.
                        final canPay = (paid >= grandTotal || !markAsPaid) &&
                            onComplete != null;
                        return _CompleteButton(
                          canPay: canPay,
                          isProcessing: isProcessing,
                          onTap: canPay ? onComplete : null,
                        );
                      },
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

class _CompleteButton extends StatelessWidget {
  final bool canPay;
  final bool isProcessing;
  final VoidCallback? onTap;

  const _CompleteButton({
    required this.canPay,
    required this.isProcessing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: canPay ? Colors.green : theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: isProcessing
              ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 36,
                      color: canPay
                          ? Colors.white
                          : theme.colorScheme.onSurface.withAlpha(80),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Complete\nTransaction',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: canPay
                            ? Colors.white
                            : theme.colorScheme.onSurface.withAlpha(80),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── Rich customer detail card ─────────────────────────────────────────────────

class _CustomerDetailCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback onRemove;

  const _CustomerDetailCard({required this.customer, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final addressParts = <String>[
      if (customer.streetName != null && customer.streetName!.isNotEmpty)
        customer.streetName!,
      if (customer.city != null && customer.city!.isNotEmpty) customer.city!,
    ];
    final address = addressParts.isNotEmpty ? addressParts.join(', ') : null;

    return Container(
      margin: const EdgeInsets.fromLTRB(8, 6, 8, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        border: const Border(
            left: BorderSide(color: Colors.blue, width: 4)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const Icon(Icons.person, color: Colors.blue, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(customer.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13)),
                if (address != null)
                  Text('Address: $address',
                      style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurface.withValues(alpha: 0.65))),
                if (customer.taxNumber != null &&
                    customer.taxNumber!.isNotEmpty)
                  Text('Tax No.: ${customer.taxNumber}',
                      style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurface.withValues(alpha: 0.65))),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, size: 18, color: cs.error),
            onPressed: onRemove,
            tooltip: 'Remove customer',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
