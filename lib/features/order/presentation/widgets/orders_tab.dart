import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/order_controller.dart';
import '../../domain/order_models.dart';
import '../pages/order_details_page.dart';
import 'order_card.dart';

class OrdersTab extends ConsumerStatefulWidget {
  const OrdersTab({super.key, required this.onCheckoutTap});

  final VoidCallback onCheckoutTap;

  @override
  ConsumerState<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends ConsumerState<OrdersTab> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(orderControllerProvider);

    final orders = ordersAsync.asData?.value ?? const <OrderModel>[];
    final filteredOrders = _selectedFilter == 'All'
        ? orders
        : orders
              .where(
                (o) =>
                    o.status.label.toLowerCase() ==
                    _selectedFilter.toLowerCase(),
              )
              .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF243041),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Chips Row
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip('All', orders.length),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Pending',
                  orders.where((o) => o.status == OrderStatus.pending).length,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Processing',
                  orders
                      .where((o) => o.status == OrderStatus.processing)
                      .length,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Picked',
                  orders.where((o) => o.status == OrderStatus.picked).length,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Delivered',
                  orders.where((o) => o.status == OrderStatus.delivered).length,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Order List
          Expanded(
            child: ordersAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFF5A91C4)),
              ),
              error: (error, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Failed to load orders',
                      style: TextStyle(color: Color(0xFF8E98A5), fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () =>
                          ref.read(orderControllerProvider.notifier).refresh(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (_) => filteredOrders.isEmpty
                  ? const Center(
                      child: Text(
                        'No orders found',
                        style: TextStyle(
                          color: Color(0xFF8E98A5),
                          fontSize: 14,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () =>
                          ref.read(orderControllerProvider.notifier).refresh(),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = filteredOrders[index];
                          return OrderCard(
                            order: order,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      OrderDetailsPage(order: order),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    String displayLabel = label;
    if (label == 'Pending' || label == 'Picked') {
      if (count > 0) {
        displayLabel = '$label ($count)';
      }
    }

    final isSelected = _selectedFilter == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5A91C4) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF5A91C4), width: 1),
        ),
        child: Text(
          displayLabel,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF5A91C4),
          ),
        ),
      ),
    );
  }
}
