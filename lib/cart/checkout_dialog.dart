import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/cart/cart_provider.dart';
import 'package:pos_app/cart/payment_type_provider.dart';
import 'package:pos_app/auth/auth_provider.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/floor_plan/floor_plan_screen.dart';
import 'package:pos_app/currency/currencies_provider.dart';

class CheckoutDialog extends ConsumerStatefulWidget {
  const CheckoutDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends ConsumerState<CheckoutDialog> {
  int? selectedPaymentTypeId;
  bool isProcessing = false;

  void _processPayment() async {
    if (selectedPaymentTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method.')),
      );
      return;
    }

    setState(() => isProcessing = true);

    final cartNotifier = ref.read(cartProvider.notifier);
    final grandTotal = ref.read(cartTotalProvider);
    final user = ref.read(currentUserProvider);
    final company = ref.read(selectedCompanyProvider);
    final apiClient = ApiClient();

    if (company == null || user == null) {
      setState(() => isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing company or user context.')),
      );
      return;
    }

    try {
      final success = await cartNotifier.checkoutOrder(
        apiClient: apiClient,
        companyId: company.id,
        userId: user.id,
        paymentTypeId: selectedPaymentTypeId!,
        amountPaid: grandTotal,
        documentTypeId: 4,
      );

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Payment Successful! Table is now free.')),
        );
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const FloorPlanScreen()),
            (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final grandTotal = ref.watch(cartTotalProvider);
    final paymentTypesAsync = ref.watch(allPaymentTypesProvider);
    final sym = ref.watch(currencySymbolProvider);

    return AlertDialog(
      title: const Text('Checkout'),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Total Due: $sym${grandTotal.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            paymentTypesAsync.when(
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error loading payment types: $e',
                    style: const TextStyle(color: Colors.red)),
                data: (paymentTypes) {
                  if (paymentTypes.isEmpty) {
                    return const Text("No payment types available.",
                        style: TextStyle(color: Colors.red));
                  }
                  return DropdownButtonFormField<int>(
                    isExpanded: true,
                    initialValue: selectedPaymentTypeId,
                    hint: const Text('Select Payment Method'),
                    items: paymentTypes.map((pt) {
                      return DropdownMenuItem<int>(
                        value: pt.id,
                        child: Text(pt.name),
                      );
                    }).toList(),
                    onChanged: (val) =>
                        setState(() => selectedPaymentTypeId = val),
                  );
                }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isProcessing ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isProcessing ? null : _processPayment,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: isProcessing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white))
              : const Text('Confirm Payment'),
        ),
      ],
    );
  }
}
