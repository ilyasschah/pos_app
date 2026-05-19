import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:pos_app/cart/payment_type_model.dart';
import 'package:pos_app/cart/payment_type_provider.dart';
import 'package:pos_app/refund/refund_service.dart';
import 'package:pos_app/stock/warehouse_provider.dart';

class RefundDialog extends ConsumerStatefulWidget {
  const RefundDialog({super.key});

  @override
  ConsumerState<RefundDialog> createState() => _RefundDialogState();
}

class _RefundDialogState extends ConsumerState<RefundDialog> {
  final _receiptCtrl = TextEditingController();
  final _focusNode   = FocusNode();

  FetchedDocument? _document;
  bool _loading    = false;
  bool _submitting = false;
  String? _error;
  int? _selectedPaymentTypeId;
  // productId → quantity the cashier wants to refund
  Map<int, double> _refundQty = {};
  final _fmt = NumberFormat('#,##0.00');

  @override
  void dispose() {
    _receiptCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _lookupReceipt() async {
    final number = _receiptCtrl.text.trim();
    if (number.isEmpty) return;

    setState(() { _loading = true; _error = null; _document = null; _refundQty = {}; });

    try {
      final service = ref.read(refundServiceProvider);
      final doc     = await service.fetchDocument(number);
      setState(() {
        _document = doc;
        _error    = doc == null ? 'Receipt "$number" not found.' : null;
        if (doc != null) {
          // default: refund full quantity of every item
          _refundQty = {for (final i in doc.items) i.productId: i.quantity};
        }
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  double get _totalRefund {
    if (_document == null) return 0.0;
    return _document!.items.fold(0.0, (sum, item) {
      final qty = _refundQty[item.productId] ?? 0.0;
      return sum + qty * item.price;
    });
  }

  Future<void> _submit() async {
    if (_document == null)             { _showSnack('Look up a receipt first.'); return; }
    if (_selectedPaymentTypeId == null) { _showSnack('Select a refund payment type.'); return; }

    final selectedItems = _document!.items
        .where((i) => (_refundQty[i.productId] ?? 0) > 0)
        .toList();
    if (selectedItems.isEmpty) {
      _showSnack('Select at least one item to refund.');
      return;
    }

    setState(() { _submitting = true; _error = null; });

    try {
      final warehouse = ref.read(allWarehousesProvider).value?.firstOrNull;
      final service   = ref.read(refundServiceProvider);

      final result = await service.submitRefund(RefundPayload(
        originalDocumentNumber: _document!.number,
        refundPaymentTypeId:    _selectedPaymentTypeId!,
        warehouseId:            warehouse?.id ?? 0,
        items: selectedItems
            .map((i) => {
                  'productId': i.productId,
                  'quantity':  _refundQty[i.productId] ?? i.quantity,
                })
            .toList(),
      ));

      if (!mounted) return;

      if (result.queued) {
        _showSnack('Offline – refund queued for sync.', success: true);
      } else {
        _showSnack('Refund ${result.refundNumber} processed.', success: true);
      }
      Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _submitting = false);
    }
  }

  void _showSnack(String msg, {bool success = false}) {
    if (!mounted) return;
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: success ? Colors.green.shade700 : cs.error,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final cs           = Theme.of(context).colorScheme;
    final paymentTypes = ref.watch(allPaymentTypesProvider).value ?? [];

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: SizedBox(
        width:  860,
        height: 560,
        child: Column(
          children: [
            // ── Title bar ──────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              color: cs.surfaceContainerHighest,
              child: Row(
                children: [
                  Icon(Icons.undo, color: cs.primary),
                  const Gap(10),
                  Text('Refund items',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Left: item list with qty steppers ──────────────────
                  SizedBox(
                    width: 360,
                    child: Column(
                      children: [
                        Expanded(
                          child: _document == null
                              ? Center(
                                  child: Text('Search a receipt to see its items',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: cs.onSurfaceVariant,
                                          fontSize: 13)),
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.all(10),
                                  separatorBuilder: (_, __) =>
                                      Divider(height: 1, color: cs.outlineVariant),
                                  itemCount: _document!.items.length,
                                  itemBuilder: (_, i) {
                                    final item = _document!.items[i];
                                    final qty  = _refundQty[item.productId] ?? 0.0;
                                    final lineTotal = qty * item.price;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(item.productName,
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w600,
                                                        color: cs.onSurface)),
                                                Text(
                                                  '${_fmt.format(item.price)} × max ${_fmt.format(item.quantity)}',
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      color: cs.onSurfaceVariant),
                                                ),
                                              ],
                                            ),
                                          ),
                                          _QtyStepper(
                                            value: qty,
                                            max:   item.quantity,
                                            onChanged: (v) =>
                                                setState(() => _refundQty[item.productId] = v),
                                          ),
                                          const Gap(6),
                                          SizedBox(
                                            width: 68,
                                            child: Text(
                                              _fmt.format(lineTotal),
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: qty > 0
                                                      ? cs.error
                                                      : cs.onSurfaceVariant),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                        // Total refund amount
                        Container(
                          color: cs.surfaceContainerHighest,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text('TOTAL REFUND AMOUNT',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: cs.onSurfaceVariant,
                                      letterSpacing: 0.8)),
                              const Gap(2),
                              Text(
                                _document == null
                                    ? '0.00'
                                    : '-${_fmt.format(_totalRefund)}',
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: cs.error),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  VerticalDivider(width: 1, color: cs.outlineVariant),

                  // ── Right: receipt search (fixed top) + payment types ──
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Receipt search — always visible at top
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest,
                            border: Border(
                                bottom: BorderSide(color: cs.outlineVariant)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Receipt number',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: cs.onSurfaceVariant,
                                      fontWeight: FontWeight.w600)),
                              const Gap(6),
                              KeyboardListener(
                                focusNode: FocusNode(),
                                onKeyEvent: (e) {
                                  if (e is KeyDownEvent &&
                                      e.logicalKey ==
                                          LogicalKeyboardKey.enter) {
                                    _lookupReceipt();
                                  }
                                },
                                child: TextField(
                                  controller: _receiptCtrl,
                                  focusNode:  _focusNode,
                                  autofocus:  true,
                                  textAlign:  TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: cs.onSurface),
                                  decoration: InputDecoration(
                                    hintText: 'e.g. 26-200-000001',
                                    isDense: true,
                                    filled: true,
                                    fillColor: cs.surface,
                                    border: const OutlineInputBorder(),
                                    suffixIcon: _loading
                                        ? const Padding(
                                            padding: EdgeInsets.all(10),
                                            child: SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(
                                                    strokeWidth: 2)),
                                          )
                                        : IconButton(
                                            icon: const Icon(Icons.search),
                                            onPressed: _lookupReceipt,
                                          ),
                                  ),
                                  onSubmitted: (_) => _lookupReceipt(),
                                ),
                              ),
                              if (_error != null) ...[
                                const Gap(6),
                                Text(
                                  _error!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: cs.error, fontSize: 11),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Payment type selector — scrollable
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Refund payment type',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: cs.onSurfaceVariant,
                                        fontWeight: FontWeight.w600)),
                                const Gap(10),
                                paymentTypes.isEmpty
                                    ? Text('Loading payment types…',
                                        style: TextStyle(
                                            color: cs.onSurfaceVariant,
                                            fontSize: 12))
                                    : Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: paymentTypes
                                            .where((pt) => pt.isEnabled)
                                            .map((pt) => _PaymentTypeButton(
                                                  paymentType: pt,
                                                  selected:
                                                      _selectedPaymentTypeId ==
                                                          pt.id,
                                                  onTap: () => setState(() =>
                                                      _selectedPaymentTypeId =
                                                          pt.id),
                                                ))
                                            .toList(),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Bottom buttons ─────────────────────────────────────────────
            Divider(height: 1, color: cs.outlineVariant),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Gap(10),
                  FilledButton.icon(
                    icon: _submitting
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.check, size: 16),
                    label: const Text('OK'),
                    onPressed: _submitting ? null : _submit,
                    style: FilledButton.styleFrom(
                        backgroundColor: Colors.green.shade700),
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

// ── Qty stepper ───────────────────────────────────────────────────────────────

class _QtyStepper extends StatelessWidget {
  final double value;
  final double max;
  final ValueChanged<double> onChanged;

  const _QtyStepper(
      {required this.value, required this.max, required this.onChanged});

  String _label(double v) =>
      v.truncateToDouble() == v ? v.toInt().toString() : v.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepBtn(
          icon:    Icons.remove,
          enabled: value > 0,
          onTap:   () => onChanged(value - 1),
          cs:      cs,
        ),
        Container(
          width: 34,
          alignment: Alignment.center,
          child: Text(_label(value),
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface)),
        ),
        _StepBtn(
          icon:    Icons.add,
          enabled: value < max,
          onTap:   () => onChanged(value + 1),
          cs:      cs,
        ),
      ],
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final ColorScheme cs;

  const _StepBtn(
      {required this.icon,
      required this.enabled,
      required this.onTap,
      required this.cs});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: enabled ? cs.primaryContainer : cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon,
            size: 16,
            color: enabled ? cs.onPrimaryContainer : cs.onSurfaceVariant),
      ),
    );
  }
}

// ── Payment type button ───────────────────────────────────────────────────────

class _PaymentTypeButton extends StatelessWidget {
  final PaymentType paymentType;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentTypeButton({
    required this.paymentType,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 90,
        height: 60,
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surfaceContainerHigh,
          border: Border.all(
            color: selected ? cs.primary : cs.outlineVariant,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                paymentType.name.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: selected ? cs.onPrimary : cs.onSurface,
                ),
              ),
            ),
            if (selected)
              Positioned(
                top: 4,
                right: 4,
                child:
                    Icon(Icons.check_circle, size: 14, color: cs.onPrimary),
              ),
          ],
        ),
      ),
    );
  }
}
