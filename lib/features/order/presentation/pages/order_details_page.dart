import 'package:flutter/material.dart';
import '../../domain/order_models.dart';
import '../widgets/review_bottom_sheet.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({super.key, required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Color(0xFF243041), size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Order Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF243041),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDeliveryAndContact(),
            const SizedBox(height: 16),
            _buildOrderSummary(),
            const SizedBox(height: 16),
            _buildItemsList(),
            const SizedBox(height: 16),
            _buildTimeline(),
            const SizedBox(height: 32),
          ],
        ),
      ),
      floatingActionButton: order.status == OrderStatus.delivered
          ? FloatingActionButton.extended(
              onPressed: () => ReviewBottomSheet.show(context),
              backgroundColor: const Color(0xFF5A91C4),
              icon: const Icon(Icons.rate_review, color: Colors.white),
              label: const Text('Leave a Review', style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }

  Widget _buildDeliveryAndContact() {
    final dateStr = '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EBF0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF5A91C4)),
                    const SizedBox(width: 6),
                    const Text(
                      'Delivery Address',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF243041)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  order.address,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF8E98A5), height: 1.5),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 60, color: const Color(0xFFE8EBF0), margin: const EdgeInsets.symmetric(horizontal: 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.phone_in_talk_outlined, size: 16, color: Color(0xFF5A91C4)),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'Contact Information',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF243041)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildInfoRow('Order Date:', dateStr),
                const SizedBox(height: 4),
                _buildInfoRow('Phone:', order.phone),
                const SizedBox(height: 4),
                _buildInfoRow('Order ID:', order.orderNumber),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF8E98A5)),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF243041)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EBF0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_outlined, size: 20, color: Color(0xFF5A91C4)),
              const SizedBox(width: 8),
              const Text(
                'Order Summary',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF243041)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Subtotal', '\$${order.subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildSummaryRow('Delivery Fee', '\$${order.deliveryFee.toStringAsFixed(2)}'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFE8EBF0), height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF243041)),
              ),
              Text(
                '\$${order.total.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF5A91C4)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF8E98A5)),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF243041)),
        ),
      ],
    );
  }

  Widget _buildItemsList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EBF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shopping_cart_outlined, size: 20, color: Color(0xFF5A91C4)),
              const SizedBox(width: 8),
              Text(
                'Items (${order.items.length})',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF243041)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...order.items.map((item) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE8EBF0)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE8EBF0)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          item.coverImageAsset,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: item.coverColor,
                            child: const Icon(Icons.book, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF243041)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF8E98A5), fontWeight: FontWeight.w400),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF5A91C4)),
                              const SizedBox(width: 4),
                              const Expanded(
                                child: Text(
                                  '123 Library, Book City',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 10, color: Color(0xFF8E98A5)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  color: item.coverColor,
                                  image: DecorationImage(
                                    image: AssetImage(item.coverImageAsset),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$ ${item.price.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF5A91C4)),
                                  ),
                                  const Text(
                                    '1 items',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF5A91C4)),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.chevron_right, size: 18, color: Color(0xFF5A91C4)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    int currentStep = 0;
    if (order.status == OrderStatus.processing) currentStep = 1;
    if (order.status == OrderStatus.picked) currentStep = 2;
    if (order.status == OrderStatus.delivered) currentStep = 3;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EBF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_shipping_outlined, size: 20, color: Color(0xFF5A91C4)),
              const SizedBox(width: 8),
              const Text(
                'Order Status',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF243041)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildTimelineItem('Pending', 'Order received by store', isActive: currentStep >= 0, isLast: false),
          _buildTimelineItem('Processing', 'Store is preparing your order', isActive: currentStep >= 1, isLast: false),
          _buildTimelineItem('Picked', 'Delivery partner picked up order', isActive: currentStep >= 2, isLast: false),
          _buildTimelineItem('Delivered', 'Order delivered successfully', isActive: currentStep >= 3, isLast: true),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String subtitle, {required bool isActive, required bool isLast}) {
    final color = isActive ? const Color(0xFF5A91C4) : const Color(0xFFD4D9E2);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? color : Colors.white,
                border: Border.all(color: color, width: 2),
              ),
              child: isActive
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: color,
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isActive ? color : const Color(0xFF243041)),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: isActive ? color.withOpacity(0.8) : const Color(0xFF8E98A5)),
              ),
              if (!isLast) const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}
