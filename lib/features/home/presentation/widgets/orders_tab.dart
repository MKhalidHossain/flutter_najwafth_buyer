import 'package:flutter/material.dart';

class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key, required this.onCheckoutTap});

  final VoidCallback onCheckoutTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ElevatedButton(onPressed: onCheckoutTap, child: const Text('Open Payment details')),
      ),
    );
  }
}
