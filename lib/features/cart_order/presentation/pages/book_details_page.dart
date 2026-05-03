import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../home/application/store_controller.dart';
import '../../../home/domain/store_models.dart';

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.chevron_left, color: Color(0xFF243041), size: 28),
        ),
        title: Text(
          widget.book.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF243041),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Book Cover
                Container(
                  width: double.infinity,
                  height: 240,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE8EBF0)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      widget.book.coverImageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: widget.book.coverColor,
                        child: const Icon(Icons.book, color: Colors.white, size: 48),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Title and Rating
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.book.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF243041),
                        ),
                      ),
                    ),
                    const Icon(Icons.star, color: Color(0xFFFFC107), size: 18),
                    const SizedBox(width: 4),
                    Text(
                      widget.book.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8E98A5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Author
                Text(
                  widget.book.author,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8E98A5),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                // Location
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF5A91C4)),
                    const SizedBox(width: 4),
                    const Text(
                      '123 Library, Book City',
                      style: TextStyle(fontSize: 12, color: Color(0xFF8E98A5)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Category Chip
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F8FC),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.book.categoryName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF5A91C4),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Description
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF243041),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.book.description,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Color(0xFF8E98A5),
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {}, // Optional
                  child: const Text(
                    'Read more',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF5A91C4),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Price and Stepper
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\$${widget.book.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF5A91C4),
                          ),
                        ),
                        Text(
                          '\$${(widget.book.price + 2).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF8E98A5),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F8FC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (_quantity > 1) setState(() => _quantity--);
                            },
                            child: Container(
                              width: 32,
                              color: Colors.transparent,
                              child: const Center(
                                child: Icon(Icons.remove, size: 18, color: Color(0xFF243041)),
                              ),
                            ),
                          ),
                          Container(
                            width: 24,
                            alignment: Alignment.center,
                            child: Text(
                              '$_quantity',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF243041),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() => _quantity++);
                            },
                            child: Container(
                              width: 32,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFE8EBF0)),
                              ),
                              child: const Center(
                                child: Icon(Icons.add, size: 18, color: Color(0xFF243041)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Bottom Add to Cart Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _addToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5A91C4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
                  label: const Text(
                    'Add to Cart',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addToCart() {
    ref.read(storeControllerProvider.notifier).addToCart(widget.book, quantity: _quantity);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${widget.book.title} added to cart')));
    Navigator.of(context).pop();
  }
}
