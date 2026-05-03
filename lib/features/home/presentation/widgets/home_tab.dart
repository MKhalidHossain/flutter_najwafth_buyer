import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../auth/application/auth_controller.dart';
import '../../application/store_controller.dart';
import '../../domain/store_models.dart';
import 'book_card_mini.dart';
import 'home_search_bar.dart';
import 'section_title.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({
    super.key,
    required this.featuredBooks,
    required this.categories,
    required this.popularBooks,
    required this.onBookTap,
    required this.onFeaturedTap,
    required this.onPopularTap,
    required this.onCartTap,
  });

  final List<BookItem> featuredBooks;
  final List<BookCategory> categories;
  final List<BookItem> popularBooks;
  final ValueChanged<BookItem> onBookTap;
  final VoidCallback onFeaturedTap;
  final VoidCallback onPopularTap;
  final VoidCallback onCartTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final storeState = ref.watch(storeControllerProvider);
    final cartItemCount = storeState.totalItems;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFFDCE3EC),
                child: Icon(Icons.person, color: Color(0xFF6A7788), size: 32),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(authState.fullName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const Text('Hi, Good Morning!', style: TextStyle(fontSize: 12, color: Color(0xFF9CA6B3))),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onCartTap,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    // color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.notifications_none_outlined,
                        color: Colors.black,
                        size: 30,
                      ),
                      if (cartItemCount > 0)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF3B30),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Center(
                              child: Text(
                                '$cartItemCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const HomeSearchBar(),
          const SizedBox(height: 14),
          SectionTitle(title: 'Featured Bookstores', actionText: 'See all', onActionTap: onFeaturedTap),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: featuredBooks.length.clamp(0, 6).toInt(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: .75,
            ),
            itemBuilder: (context, index) => BookCardMini(book: featuredBooks[index], onTap: () => onBookTap(featuredBooks[index])),
          ),
          const SizedBox(height: 14),
          SectionTitle(title: 'Categories', actionText: 'See all', onActionTap: onFeaturedTap),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              final itemWidth = (screenWidth * 0.2).clamp(68.0, 86.0).toDouble();
              final thumbSize = (itemWidth * 0.82).clamp(54.0, 68.0).toDouble();
              final horizontalGap = (screenWidth * 0.018).clamp(6.0, 10.0).toDouble();
              final listHeight = (thumbSize + 28).toDouble();

              return SizedBox(
                height: listHeight,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, _) => SizedBox(width: horizontalGap),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final previewPath = category.previewImageAsset;

                    return SizedBox(
                      width: itemWidth,
                      child: Column(
                        children: [
                          Container(
                            width: thumbSize,
                            height: thumbSize,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE8ECF1)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(7),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(7),
                                child: previewPath == null || previewPath.isEmpty
                                    ? const Icon(Icons.menu_book_outlined, color: Color(0xFF9CA6B3))
                                    : Image.asset(
                                        previewPath,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.menu_book_outlined, color: Color(0xFF9CA6B3)),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(category.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10)),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          SectionTitle(title: 'Popular Books', actionText: 'See all', onActionTap: onPopularTap),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              final itemWidth = (screenWidth * 0.38).clamp(120.0, 170.0).toDouble();
              final listHeight = (itemWidth * 1.55).clamp(185.0, 280.0).toDouble();

              if (popularBooks.isEmpty) {
                return SizedBox(
                  height: listHeight,
                  child: const Center(
                    child: Text(
                      'No popular books available',
                      style: TextStyle(color: Color(0xFF9CA6B3), fontSize: 13),
                    ),
                  ),
                );
              }

              return SizedBox(
                height: listHeight,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: popularBooks.length,
                  separatorBuilder: (_, _) => SizedBox(width: (screenWidth * 0.025).clamp(8.0, 14.0).toDouble()),
                  itemBuilder: (context, i) => SizedBox(
                    width: itemWidth,
                    child: BookCardMini(book: popularBooks[i], onTap: () => onBookTap(popularBooks[i])),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
