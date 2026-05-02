import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../auth/application/auth_controller.dart';
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
  });

  final List<BookItem> featuredBooks;
  final List<BookCategory> categories;
  final List<BookItem> popularBooks;
  final ValueChanged<BookItem> onBookTap;
  final VoidCallback onFeaturedTap;
  final VoidCallback onPopularTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
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
                onTap: () {
                  // TODO: Navigate to notifications
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDCE3EC),
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.notifications_none_outlined,
                        color: Color(0xFF6A7788),
                        size: 26,
                      ),
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
                          child: const Center(
                            child: Text(
                              '3',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
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
              childAspectRatio: .63,
            ),
            itemBuilder: (context, index) => BookCardMini(book: featuredBooks[index], onTap: () => onBookTap(featuredBooks[index])),
          ),
          const SizedBox(height: 14),
          SectionTitle(title: 'Categories', actionText: 'See all', onActionTap: onFeaturedTap),
          const SizedBox(height: 10),
          SizedBox(
            height: 88,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = categories[index];
                return SizedBox(
                  width: 74,
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE8ECF1)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(7),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child: Image.asset(category.previewImageAsset ?? '', fit: BoxFit.cover),
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
          ),
          const SizedBox(height: 8),
          SectionTitle(title: 'Popular Books', actionText: 'See all', onActionTap: onPopularTap),
          const SizedBox(height: 10),
          SizedBox(
            height: 190,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: popularBooks.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, i) => SizedBox(
                width: 130,
                child: BookCardMini(book: popularBooks[i], onTap: () => onBookTap(popularBooks[i])),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
