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
    
    if (items.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(context),
        body: Center(
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Your cart is empty, go back'),
          ),
        ),
      );
    }

    final ctrl = ref.read(storeControllerProvider.notifier);
    final subtotal = ctrl.subtotal(books);
    final deliveryFee = ctrl.deliveryFee(items);
    final total = subtotal + deliveryFee;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildFormFields(),
              const SizedBox(height: 32),
              _buildOrderSummary(subtotal, deliveryFee, total),
              const SizedBox(height: 32),
              _buildPaymentMethodSection(),
              const SizedBox(height: 40),
              _buildPlaceOrderButton(context),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Payment details',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF243041),
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF243041)),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Checkout',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF243041),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Complete your order details',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF8E98A5),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel(icon: Icons.person_outline, text: 'Name'),
        const SizedBox(height: 8),
        _CheckoutField(controller: _nameController),
        const SizedBox(height: 16),
        const _FieldLabel(icon: Icons.location_on_outlined, text: 'Address'),
        const SizedBox(height: 8),
        _CheckoutField(controller: _addressController),
        const SizedBox(height: 16),
        const _FieldLabel(icon: Icons.phone_outlined, text: 'Phone number'),
        const SizedBox(height: 8),
        _CheckoutField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildOrderSummary(double subtotal, double deliveryFee, double total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel(icon: Icons.receipt_long_outlined, text: 'Order Summary'),
        const SizedBox(height: 12),
        _SummaryRow(label: 'Subtotal', value: formatPrice(subtotal)),
        const SizedBox(height: 8),
        _SummaryRow(label: 'Delivery Fee', value: formatPrice(deliveryFee)),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(color: Color(0xFFE8EBF0), height: 1),
        ),
        _SummaryRow(label: 'Total', value: formatPrice(total), highlight: true),
      ],
    );
  }

  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel(icon: Icons.account_balance_wallet_outlined, text: 'Payment'),
        const SizedBox(height: 12),
        _PaymentMethodTile(
          label: 'stripe',
          selected: _paymentMethod == PaymentMethod.stripe,
          onTap: () => setState(() => _paymentMethod = PaymentMethod.stripe),
        ),
      ],
    );
  }

  Widget _buildPlaceOrderButton(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _placeOrder(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5A91C4),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        icon: const Icon(Icons.shopping_cart_outlined, size: 20),
        label: const Text(
          'Place Order',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future<void> _placeOrder(BuildContext context) async {
    if (_nameController.text.trim().isEmpty || 
        _addressController.text.trim().isEmpty || 
        _phoneController.text.trim().isEmpty) {
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
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text('🎉', style: TextStyle(fontSize: 56)),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Order Confirmed',
              style: TextStyle(
                fontSize: 22,
                color: Color(0xFF4EA0F2),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Your order has been placed successfully!',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF8E98A5),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Status:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF243041),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7D0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Pending',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFD4A017),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF243041),
            ),
          ),
          const SizedBox(height: 16),
          _SummaryRow(label: 'Subtotal', value: formatPrice(receipt.subtotal)),
          const SizedBox(height: 8),
          _SummaryRow(label: 'Delivery Fee', value: formatPrice(receipt.deliveryFee)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFE8EBF0), height: 1),
          ),
          _SummaryRow(label: 'Total', value: formatPrice(receipt.total), highlight: true),
          const SizedBox(height: 24),
          const _FieldLabel(icon: Icons.account_balance_wallet_outlined, text: 'Payment'),
          const SizedBox(height: 12),
          _PaymentMethodTile(
            label: receipt.paymentMethod.label,
            selected: false,
            onTap: () {},
            readOnly: true,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5A91C4),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              icon: const Icon(Icons.home_outlined, size: 20),
              label: const Text(
                'Back to Home',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
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
        Icon(icon, size: 18, color: const Color(0xFF4EA0F2)),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF243041),
          ),
        ),
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
      height: 52,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF243041),
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF4F5F8),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF5A91C4)),
          ),
        ),
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.label,
    required this.selected,
    required this.onTap,
    this.readOnly = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: readOnly ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F5F8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? const Color(0xFF5A91C4) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            color: Color(0xFF675DF4),
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: highlight ? const Color(0xFF243041) : const Color(0xFF8E98A5),
            fontWeight: highlight ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: highlight ? const Color(0xFF4EA0F2) : const Color(0xFF243041),
            fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
