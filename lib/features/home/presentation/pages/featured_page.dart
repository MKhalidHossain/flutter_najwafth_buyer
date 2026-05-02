import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/store_controller.dart';
import '../../domain/store_models.dart';
import '../widgets/store_widgets.dart';

class FeaturedPage extends StatelessWidget {
  const FeaturedPage({
    super.key,
    required this.categories,
    required this.popularBooks,
    required this.onBookTap,
    required this.onCategoryTap,
  });

  final List<BookCategory> categories;
  final List<BookItem> popularBooks;
  final ValueChanged<BookItem> onBookTap;
  final ValueChanged<BookCategory> onCategoryTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF5F6F8),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.chevron_left, color: Color(0xFF1F2933), size: 20),
        ),
        titleSpacing: 0,
        title: const Text(
          'Featured Bookstores',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
        children: [
          const _FeaturedSearchBar(),
          const SizedBox(height: 14),
          const Text(
            'Categories',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length.clamp(0, 6).toInt(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.88,
            ),
            itemBuilder: (context, index) {
              final category = categories[index];
              return GestureDetector(
                onTap: () => onCategoryTap(category),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE7EBF0)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(7),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              category.previewImageAsset ?? '',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              Expanded(
                child: Text(
                  'Popular Books',
                  style: TextStyle(
                    fontSize: 29,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              Text(
                'See all',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4F8FC5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 268,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: popularBooks.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) => SizedBox(
                width: 210,
                child: _FeaturedBookCard(
                  book: popularBooks[index],
                  onTap: () => onBookTap(popularBooks[index]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedSearchBar extends StatelessWidget {
  const _FeaturedSearchBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search books, authors, stores...',
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFA6AFBA)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFDDE2E9)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFDDE2E9)),
          ),
          suffixIcon: Container(
            width: 56,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: const Color(0xFF5A91C4),
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(Icons.search, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}

class _FeaturedBookCard extends ConsumerWidget {
  const _FeaturedBookCard({required this.book, required this.onTap});

  final BookItem book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
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
                radius: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              book.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
            Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFFFC83A), size: 13),
                const SizedBox(width: 4),
                Text(
                  book.rating.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 13, color: Color(0xFF6E7784)),
                ),
              ],
            ),
            Text(
              book.author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Color(0xFFAFB7C1)),
            ),
            Row(
              children: [
                Text(
                  formatPrice(book.price),
                  style: const TextStyle(
                    fontSize: 19,
                    color: Color(0xFF3694F4),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => ref.read(storeControllerProvider.notifier).addToCart(book),
                  child: const CircleAvatar(
                    radius: 13,
                    backgroundColor: Color(0xFF5A91C4),
                    child: Icon(Icons.add, color: Colors.white, size: 16),
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
