import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../home/application/store_controller.dart';
import '../../../home/domain/store_models.dart';
import '../widgets/order_confirmed_sheet.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final _nameController = TextEditingController(text: 'Tanjila Hafiza Lata');
  final _addressController = TextEditingController(text: 'Dhaka, Bangladesh');
  final _phoneController = TextEditingController(text: '01810641003');

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storeState = ref.watch(storeControllerProvider);
    final catalog = ref.watch(storeCatalogProvider);

    final cartItems = storeState.cartQuantities.entries
        .where((e) => catalog.any((b) => b.id == e.key))
        .map((e) => catalog.firstWhere((b) => b.id == e.key))
        .toList();
    
    final subtotal = ref.read(storeControllerProvider.notifier).subtotal(cartItems);
    final deliveryFee = ref.read(storeControllerProvider.notifier).deliveryFee(cartItems);
    final total = subtotal + deliveryFee;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.chevron_left, color: Color(0xFF243041), size: 28),
        ),
        title: const Text(
          'Payment details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF243041),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8EBF0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Checkout',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF243041),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Complete your order details',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8E98A5),
                ),
              ),
              const SizedBox(height: 24),
              
              _buildInputLabel(Icons.person_outline, 'Name'),
              const SizedBox(height: 8),
              _buildTextField(_nameController),
              const SizedBox(height: 16),
              
              _buildInputLabel(Icons.location_on_outlined, 'Address'),
              const SizedBox(height: 8),
              _buildTextField(_addressController),
              const SizedBox(height: 16),
              
              _buildInputLabel(Icons.phone_in_talk_outlined, 'Phone number'),
              const SizedBox(height: 8),
              _buildTextField(_phoneController),
              const SizedBox(height: 24),
              
              // Order Summary
              Row(
                children: [
                  const Icon(Icons.receipt_long_outlined, size: 16, color: Color(0xFF5A91C4)),
                  const SizedBox(width: 8),
                  const Text(
                    'Order Summary',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF243041)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildSummaryRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              _buildSummaryRow('Delivery fee', '\$${deliveryFee.toStringAsFixed(2)}'),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(color: Color(0xFFE8EBF0), height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF243041)),
                  ),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF5A91C4)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Payment
              Row(
                children: [
                  const Icon(Icons.payment_outlined, size: 16, color: Color(0xFF5A91C4)),
                  const SizedBox(width: 8),
                  const Text(
                    'Payment',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF243041)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F8FC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'stripe',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF6772E5)),
                ),
              ),
              const SizedBox(height: 32),
              
              // Place Order Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _placeOrder(catalog, subtotal, deliveryFee, total),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5A91C4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.receipt_long, color: Colors.white, size: 20),
                  label: const Text(
                    'Place Order',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF5A91C4)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF243041)),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 13, color: Color(0xFF243041)),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF3F8FC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF8E98A5)),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF243041)),
        ),
      ],
    );
  }

  void _placeOrder(List<BookItem> catalog, double subtotal, double deliveryFee, double total) async {
    final storeState = ref.read(storeControllerProvider);
    if (storeState.cartQuantities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cart is empty')));
      return;
    }

    final input = CheckoutInput(
      name: _nameController.text,
      address: _addressController.text,
      city: 'Book City',
      phone: _phoneController.text,
      paymentMethod: PaymentMethod.stripe,
    );

    // Call storeController to clear cart and place order
    await ref.read(storeControllerProvider.notifier).placeOrder(
      catalog: catalog,
      input: input,
    );

    OrderConfirmedSheet.show(
      context,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      total: total,
      onBackToHome: () {
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
    );
  }
}
