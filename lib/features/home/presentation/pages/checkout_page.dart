import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../auth/application/auth_controller.dart';
import '../../application/store_controller.dart';
import '../../domain/store_models.dart';
import '../widgets/store_widgets.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  PaymentMethod _paymentMethod = PaymentMethod.stripe;

  @override
  void initState() {
    super.initState();
    final auth = ref.read(authControllerProvider);
    _nameController = TextEditingController(text: auth.fullName);
    _addressController = TextEditingController(text: 'Dhaka, Bangladesh');
    _phoneController = TextEditingController(text: auth.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final books = ref.watch(storeCatalogProvider);
    final state = ref.watch(storeControllerProvider);
    final items = books.where((b) => state.quantityFor(b.id) > 0).toList();
    final ctrl = ref.read(storeControllerProvider.notifier);
    final subtotal = ctrl.subtotal(books);
    final deliveryFee = ctrl.deliveryFee(items);
    final total = subtotal + deliveryFee;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text('Payment details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFFF5F6F8),
      ),
      body: items.isEmpty
          ? Center(
              child: TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Your cart is empty, go back')),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                children: [
                  const Text('Checkout', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
                  const Text('Complete your order details', style: TextStyle(fontSize: 11, color: Color(0xFF8E98A5))),
                  const SizedBox(height: 10),
                  _FieldLabel(icon: Icons.person_outline, text: 'Name'),
                  const SizedBox(height: 4),
                  _CheckoutField(controller: _nameController),
                  const SizedBox(height: 8),
                  _FieldLabel(icon: Icons.location_on_outlined, text: 'Address'),
                  const SizedBox(height: 4),
                  _CheckoutField(controller: _addressController),
                  const SizedBox(height: 8),
                  _FieldLabel(icon: Icons.phone_outlined, text: 'Phone number'),
                  const SizedBox(height: 4),
                  _CheckoutField(controller: _phoneController, keyboardType: TextInputType.phone),
                  const SizedBox(height: 10),
                  const _FieldLabel(icon: Icons.description_outlined, text: 'Order Summary'),
                  const SizedBox(height: 6),
                  _SummaryRow(label: 'Subtotal', value: formatPrice(subtotal)),
                  _SummaryRow(label: 'Delivery Fee', value: formatPrice(deliveryFee)),
                  _SummaryRow(label: 'Total', value: formatPrice(total), highlight: true),
                  const SizedBox(height: 8),
                  const _FieldLabel(icon: Icons.payment_outlined, text: 'Payment'),
                  const SizedBox(height: 4),
                  _PaymentMethodTile(
                    label: 'stripe',
                    selected: _paymentMethod == PaymentMethod.stripe,
                    onTap: () => setState(() => _paymentMethod = PaymentMethod.stripe),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 42,
                    child: ElevatedButton.icon(
                      onPressed: () => _placeOrder(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5A91C4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      icon: const Icon(Icons.verified, color: Colors.white, size: 15),
                      label: const Text('Place Order', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _placeOrder(BuildContext context) async {
    if (_nameController.text.trim().isEmpty || _addressController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
      return;
    }

    final receipt = await ref.read(storeControllerProvider.notifier).placeOrder(
      catalog: ref.read(storeCatalogProvider),
      input: CheckoutInput(
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        city: '',
        phone: _phoneController.text.trim(),
        paymentMethod: _paymentMethod,
      ),
    );

    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(14))),
      builder: (context) => _OrderSuccessSheet(receipt: receipt),
    );
  }
}

class _OrderSuccessSheet extends StatelessWidget {
  const _OrderSuccessSheet({required this.receipt});

  final OrderReceipt receipt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: Text('🎉', style: TextStyle(fontSize: 28))),
          const Center(child: Text('Order Confirmed', style: TextStyle(fontSize: 26, color: Color(0xFF4D92D4), fontWeight: FontWeight.w500))),
          const SizedBox(height: 2),
          const Center(child: Text('Your order has been placed successfully!', style: TextStyle(fontSize: 11, color: Color(0xFF8D97A3)))),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text('Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFFF8E68E), borderRadius: BorderRadius.circular(12)),
                child: const Text('Pending', style: TextStyle(fontSize: 10, color: Color(0xFF7A6722))),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Order Summary', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          _SummaryRow(label: 'Subtotal', value: formatPrice(receipt.subtotal)),
          _SummaryRow(label: 'Delivery Fee', value: formatPrice(receipt.deliveryFee)),
          _SummaryRow(label: 'Total', value: formatPrice(receipt.total), highlight: true),
          const SizedBox(height: 6),
          const _FieldLabel(icon: Icons.payment_outlined, text: 'Payment'),
          const SizedBox(height: 2),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFFF3F4F7), borderRadius: BorderRadius.circular(4)),
            child: Text(receipt.paymentMethod.label, style: const TextStyle(color: Color(0xFF5856D6), fontSize: 30, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5A91C4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              icon: const Icon(Icons.home_outlined, color: Colors.white, size: 16),
              label: const Text('Back to Home', style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF6F7990)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _CheckoutField extends StatelessWidget {
  const _CheckoutField({required this.controller, this.keyboardType});

  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFEFF1F4),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xFF5A91C4)),
          ),
        ),
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF1F4),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: selected ? const Color(0xFF5A91C4) : Colors.transparent),
        ),
        child: Text(label, style: const TextStyle(fontSize: 30, color: Color(0xFF5856D6), fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.highlight = false});

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF555F6D)))),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: highlight ? const Color(0xFF4EA0F2) : const Color(0xFF555F6D),
              fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
