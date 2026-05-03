import 'package:flutter/material.dart';

import '../../home/domain/store_models.dart';

enum OrderStatus {
  pending,
  processing,
  picked,
  delivered,
}

extension OrderStatusX on OrderStatus {
  String get label => switch (this) {
        OrderStatus.pending => 'Pending',
        OrderStatus.processing => 'Processing',
        OrderStatus.picked => 'Picked',
        OrderStatus.delivered => 'Delivered',
      };

  Color get backgroundColor => switch (this) {
        OrderStatus.pending => const Color(0xFFFFF7D0),
        OrderStatus.processing => const Color(0xFF9BD4B1),
        OrderStatus.picked => const Color(0xFFFFD5B6),
        OrderStatus.delivered => const Color(0xFFD6E9FA),
      };

  Color get textColor => switch (this) {
        OrderStatus.pending => const Color(0xFFD4A017),
        OrderStatus.processing => const Color(0xFF226E3A),
        OrderStatus.picked => const Color(0xFFD36F1E),
        OrderStatus.delivered => const Color(0xFF4EA0F2),
      };
}

final class OrderModel {
  const OrderModel({
    required this.orderNumber,
    required this.customerName,
    required this.address,
    required this.phone,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
  });

  final String orderNumber;
  final String customerName;
  final String address;
  final String phone;
  final List<BookItem> items;
  final double subtotal;
  final double deliveryFee;
  final PaymentMethod paymentMethod;
  final OrderStatus status;
  final DateTime createdAt;

  double get total => subtotal + deliveryFee;

  OrderModel copyWith({
    OrderStatus? status,
  }) {
    return OrderModel(
      orderNumber: orderNumber,
      customerName: customerName,
      address: address,
      phone: phone,
      items: items,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      paymentMethod: paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }

  factory OrderModel.fromReceipt(OrderReceipt receipt, {OrderStatus status = OrderStatus.pending}) {
    return OrderModel(
      orderNumber: receipt.orderNumber,
      customerName: receipt.customerName,
      address: receipt.address,
      phone: receipt.phone,
      items: receipt.items,
      subtotal: receipt.subtotal,
      deliveryFee: receipt.deliveryFee,
      paymentMethod: receipt.paymentMethod,
      status: status,
      createdAt: DateTime.now(),
    );
  }
}
