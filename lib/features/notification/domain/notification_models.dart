final class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.orderId,
    this.productId,
    this.productTitle,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final order = json['order'];
    final product = json['product'];

    String? orderId;
    if (order is Map<String, dynamic>) {
      orderId = order['orderId']?.toString();
    }

    String? productId;
    String? productTitle;
    if (product is Map<String, dynamic>) {
      productId = product['_id']?.toString();
      productTitle = product['title']?.toString();
    }

    final createdAtRaw = json['createdAt']?.toString();
    final createdAt = createdAtRaw == null
        ? DateTime.now()
        : DateTime.tryParse(createdAtRaw) ?? DateTime.now();

    return AppNotification(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Notification',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? 'general',
      isRead: json['isRead'] as bool? ?? false,
      createdAt: createdAt,
      orderId: orderId,
      productId: productId,
      productTitle: productTitle,
    );
  }

  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final String? orderId;
  final String? productId;
  final String? productTitle;

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      type: type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      orderId: orderId,
      productId: productId,
      productTitle: productTitle,
    );
  }
}

final class NotificationsPageData {
  const NotificationsPageData({required this.items, required this.unreadCount});

  final List<AppNotification> items;
  final int unreadCount;
}
