import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/store_controller.dart';
import '../../domain/store_models.dart';
import '../widgets/store_widgets.dart';

class BookDetailsPage extends ConsumerStatefulWidget {
  const BookDetailsPage({super.key, required this.book});

  final BookItem book;

  @override
  ConsumerState<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends ConsumerState<BookDetailsPage> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF5F6F8),
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.chevron_left, color: Color(0xFF20242B), size: 24),
        ),
        title: Text(
          widget.book.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF22252D),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F8FB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD9E2EE)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BookCover(
                  title: widget.book.title,
                  imageAsset: widget.book.coverImageAsset,
                  color: widget.book.coverColor,
                  accentColor: widget.book.coverAccent,
                  height: 268,
                  radius: 12,
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.book.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF22252D),
                        ),
                      ),
                    ),
                    const Icon(Icons.star, color: Color(0xFFFFC52E), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      widget.book.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4F5B68),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  widget.book.author,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8E98A6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                const Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF59A4EF)),
                    SizedBox(width: 4),
                    Text(
                      '123 Library, Book City',
                      style: TextStyle(fontSize: 11.5, color: Color(0xFF8A95A4)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBFDFFF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.book.categoryName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF2E82D8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D2533),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.book.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.35,
                    color: Color(0xFF5F6C7B),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Read more',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2E90FA),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatPrice(widget.book.price),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2E90FA),
                          ),
                        ),
                        Text(
                          formatPrice(widget.book.price + 2),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF808B98),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    _FigmaQuantityControl(
                      quantity: _quantity,
                      onChanged: (value) => setState(() => _quantity = value.clamp(1, 99).toInt()),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _addToCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5E92C2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
                    label: const Text(
                      'Add to Cart',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addToCart() {
    ref.read(storeControllerProvider.notifier).addToCart(widget.book, quantity: _quantity);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${widget.book.title} added to cart')));
  }
}

class _FigmaQuantityControl extends StatelessWidget {
  const _FigmaQuantityControl({
    required this.quantity,
    required this.onChanged,
  });

  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFD7E7F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyButton(icon: Icons.remove, onTap: () => onChanged(quantity - 1)),
          const SizedBox(width: 10),
          SizedBox(
            width: 16,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                color: Color(0xFF243041),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          _QtyButton(icon: Icons.add, onTap: () => onChanged(quantity + 1)),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFFF7FAFD),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF253447)),
      ),
    );
  }
}
