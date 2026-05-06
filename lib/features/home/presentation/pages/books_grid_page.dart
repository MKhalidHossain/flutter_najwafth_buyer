import 'package:flutter/material.dart';

import '../../domain/store_models.dart';
import '../widgets/book_card_mini.dart';

class BooksGridPage extends StatelessWidget {
  const BooksGridPage({
    super.key,
    required this.title,
    required this.books,
    required this.onBookTap,
  });

  final String title;
  final List<BookItem> books;
  final ValueChanged<BookItem> onBookTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFFF5F6F8),
      ),
      body: books.isEmpty
          ? const Center(
              child: Text(
                'No books found in this category',
                style: TextStyle(color: Color(0xFF8E98A5), fontSize: 14),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              itemCount: books.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: .75,
              ),
              itemBuilder: (context, index) => BookCardMini(
                book: books[index],
                onTap: () => onBookTap(books[index]),
              ),
            ),
    );
  }
}
