import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../order/application/order_controller.dart';
import '../../../order/domain/order_models.dart';
import '../../../order/presentation/pages/order_details_page.dart';
import '../../../order/presentation/widgets/order_card.dart';


class OrderHistoryPage extends ConsumerStatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  ConsumerState<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends ConsumerState<OrderHistoryPage> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(orderControllerProvider);

    final filteredOrders = orders.where((order) {
      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Completed') return order.status == OrderStatus.delivered;
      if (_selectedFilter == 'Picked') return order.status == OrderStatus.picked;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left, color: Color(0xFF243041), size: 28),
        ),
        title: const Text(
          'Order History',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF243041),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildFilterChip('All'),
                const SizedBox(width: 12),
                _buildFilterChip('Completed', count: 3),
                const SizedBox(width: 12),
                _buildFilterChip('Picked', count: 3),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: filteredOrders.isEmpty
                ? const Center(child: Text('No orders found'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return OrderCard(
                        order: order,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrderDetailsPage(order: order),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {int? count}) {
    final isSelected = _selectedFilter == label;
    final displayLabel = count != null ? '$label ($count)' : label;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5A91C4) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF5A91C4) : const Color(0xFFE8EBF0),
            width: 1,
          ),
        ),
        child: Text(
          displayLabel,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF5A91C4),
          ),
        ),
      ),
    );
  }
}
