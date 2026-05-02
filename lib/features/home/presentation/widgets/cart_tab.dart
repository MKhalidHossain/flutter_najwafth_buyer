import 'package:flutter/material.dart';

class CartTab extends StatelessWidget {
  const CartTab({super.key, required this.onCheckoutTap, required this.cartCount});

  final VoidCallback onCheckoutTap;
  final int cartCount;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: TextButton(
          onPressed: onCheckoutTap,
          child: Text(cartCount > 0 ? 'Go to checkout ($cartCount)' : 'Cart is empty'),
        ),
      ),
    );
  }
}
