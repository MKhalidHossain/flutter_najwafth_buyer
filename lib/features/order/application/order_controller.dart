import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/order_models.dart';

final orderControllerProvider = NotifierProvider<OrderController, List<OrderModel>>(OrderController.new);

class OrderController extends Notifier<List<OrderModel>> {
  @override
  List<OrderModel> build() => const [];

  void addOrder(OrderModel order) {
    state = [order, ...state];
  }
}
