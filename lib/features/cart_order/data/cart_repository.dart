import '../../../core/errors/result.dart';
import '../../../core/network/api_client.dart';

final class CartSnapshot {
  const CartSnapshot({
    required this.quantities,
    required this.totalAmount,
  });

  final Map<String, int> quantities;
  final double totalAmount;
}

final class CartRepository {
  const CartRepository(this._client);

  final ApiClient _client;

  Future<Result<CartSnapshot>> getCart() {
    return _client.get<CartSnapshot>('/cart', parser: _parseCartResponse);
  }

  Future<Result<CartSnapshot>> addToCart({
    required String productId,
    required int quantity,
  }) {
    return _client.post<CartSnapshot>(
      '/cart/add',
      data: {'product': productId, 'quantity': quantity},
      parser: _parseCartResponse,
    );
  }

  Future<Result<CartSnapshot>> updateCart({
    required String productId,
    required int quantity,
  }) {
    return _client.put<CartSnapshot>(
      '/cart/update',
      data: {'product': productId, 'quantity': quantity},
      parser: _parseCartResponse,
    );
  }

  Future<Result<CartSnapshot>> clearCart() {
    return _client.delete<CartSnapshot>('/cart/clear', parser: _parseCartResponse);
  }

  static CartSnapshot _parseCartResponse(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      throw Exception('Invalid cart response');
    }

    if (raw['success'] == false) {
      throw Exception(raw['message']?.toString() ?? 'Cart request failed');
    }

    final data = raw['data'];
    if (data is! Map<String, dynamic>) {
      return const CartSnapshot(quantities: {}, totalAmount: 0);
    }

    final items = data['items'];
    final quantities = <String, int>{};

    if (items is List) {
      for (final item in items) {
        if (item is! Map<String, dynamic>) {
          continue;
        }

        final product = item['product'];
        String productId = '';
        if (product is Map<String, dynamic>) {
          productId = product['_id']?.toString() ?? '';
        } else if (product != null) {
          productId = product.toString();
        }

        final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
        if (productId.isEmpty || quantity <= 0) {
          continue;
        }

        quantities[productId] = quantity;
      }
    }

    return CartSnapshot(
      quantities: quantities,
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0,
    );
  }
}
