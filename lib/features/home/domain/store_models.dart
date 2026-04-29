import 'package:flutter/material.dart';

enum AppLanguage { english, french }

enum PaymentMethod { paypal, stripe }

extension AppLanguageX on AppLanguage {
  String get label => switch (this) {
    AppLanguage.english => 'English',
    AppLanguage.french => 'France',
  };

  String get flag => switch (this) {
    AppLanguage.english => '🇬🇧',
    AppLanguage.french => '🇫🇷',
  };
}

extension PaymentMethodX on PaymentMethod {
  String get label => switch (this) {
    PaymentMethod.paypal => 'Paypal',
    PaymentMethod.stripe => 'stripe',
  };
}

final class BookCategory {
  const BookCategory({
    required this.id,
    required this.name,
    required this.color,
    this.previewImageAsset,
  });

  final String id;
  final String name;
  final Color color;
  final String? previewImageAsset;
}

final class BookItem {
  const BookItem({
    required this.id,
    required this.title,
    required this.author,
    required this.coverImageAsset,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    required this.coverColor,
    required this.coverAccent,
    this.isFeatured = false,
    this.isPopular = false,
  });

  final String id;
  final String title;
  final String author;
  final String coverImageAsset;
  final double price;
  final double rating;
  final int reviewCount;
  final String description;
  final String categoryId;
  final String categoryName;
  final Color coverColor;
  final Color coverAccent;
  final bool isFeatured;
  final bool isPopular;
}

final class CheckoutInput {
  const CheckoutInput({
    required this.name,
    required this.address,
    required this.city,
    required this.phone,
    required this.paymentMethod,
  });

  final String name;
  final String address;
  final String city;
  final String phone;
  final PaymentMethod paymentMethod;
}

final class OrderReceipt {
  const OrderReceipt({
    required this.orderNumber,
    required this.customerName,
    required this.address,
    required this.phone,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.paymentMethod,
  });

  final String orderNumber;
  final String customerName;
  final String address;
  final String phone;
  final List<BookItem> items;
  final double subtotal;
  final double deliveryFee;
  final PaymentMethod paymentMethod;

  double get total => subtotal + deliveryFee;
}
