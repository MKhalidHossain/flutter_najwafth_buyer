import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/application/store_controller.dart';
import '../../home/domain/store_models.dart';
import '../domain/order_models.dart';

final orderControllerProvider = NotifierProvider<OrderController, List<OrderModel>>(OrderController.new);

class OrderController extends Notifier<List<OrderModel>> {
  @override
  List<OrderModel> build() {
    final catalog = ref.read(storeCatalogProvider);
    
    // Create some dummy orders for preview
    return [
      OrderModel(
        orderNumber: '#BK12345',
        customerName: 'Tanjila Hafsa Lata',
        address: 'Dhaka, Bangladesh',
        phone: '01810641003',
        items: [catalog[0], catalog[1]], // The Great Gatsby, The Road Ahead
        subtotal: 12.99 + 11.99,
        deliveryFee: 2.00,
        paymentMethod: PaymentMethod.stripe,
        status: OrderStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      OrderModel(
        orderNumber: '#BK12346',
        customerName: 'Tanjila Hafsa Lata',
        address: 'Dhaka, Bangladesh',
        phone: '01810641003',
        items: [catalog[0], catalog[0]], 
        subtotal: 12.99 * 2,
        deliveryFee: 2.00,
        paymentMethod: PaymentMethod.stripe,
        status: OrderStatus.picked,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      OrderModel(
        orderNumber: '#BK12347',
        customerName: 'Tanjila Hafsa Lata',
        address: 'Dhaka, Bangladesh',
        phone: '01810641003',
        items: [catalog[2], catalog[3]],
        subtotal: 9.99 + 10.49,
        deliveryFee: 2.00,
        paymentMethod: PaymentMethod.stripe,
        status: OrderStatus.processing,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      OrderModel(
        orderNumber: '#BK12348',
        customerName: 'Tanjila Hafsa Lata',
        address: 'Dhaka, Bangladesh',
        phone: '01810641003',
        items: [catalog[4], catalog[5]],
        subtotal: 15.50 + 13.25,
        deliveryFee: 2.00,
        paymentMethod: PaymentMethod.stripe,
        status: OrderStatus.delivered,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }

  void addOrder(OrderModel order) {
    state = [order, ...state];
  }
}
