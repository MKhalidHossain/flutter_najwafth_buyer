import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/store_controller.dart';
import '../../domain/store_models.dart';
import 'store_widgets.dart';

class BookCardMini extends ConsumerWidget {
  const BookCardMini({super.key, required this.book, required this.onTap});

  final BookItem book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE9EDF2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: BookCover(
                title: book.title,
                imageAsset: book.coverImageAsset,
                color: book.coverColor,
                accentColor: book.coverAccent,
                height: double.infinity,
                radius: 6,
              ),
            ),
            const SizedBox(height: 4),
            Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFFFC83A), size: 18),
                const SizedBox(width: 2),
                Text(book.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 14, color: Color(0xFF6E7784))),
              ],
            ),
            Text(book.author, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Color(0xFFAFB7C1))),
            Row(
              children: [
                Text(formatPrice(book.price), style: const TextStyle(fontSize: 16, color: Color(0xFF3694F4), fontWeight: FontWeight.w600)),
                const Spacer(),
                GestureDetector(
                  onTap: () => ref.read(storeControllerProvider.notifier).addToCart(book),
                  child: const CircleAvatar(
                    radius: 14,
                    backgroundColor: Color(0xFF5A91C4),
                    child: Icon(Icons.add, color: Colors.white, size: 24),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
