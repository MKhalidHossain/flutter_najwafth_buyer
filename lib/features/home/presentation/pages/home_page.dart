import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../cart_order/presentation/pages/book_details_page.dart';
import '../../../cart_order/presentation/pages/checkout_page.dart';
import '../../../../core/errors/result.dart';
import '../../application/book_provider.dart';
import '../../application/store_controller.dart';
import '../../domain/store_models.dart';
import '../../../cart_order/presentation/widgets/cart_tab.dart';
import '../widgets/home_tab.dart';
import '../../../order/presentation/widgets/orders_tab.dart';
import '../../../profile/presentation/widgets/profile_tab.dart';
import '../../../profile/presentation/pages/notifications_page.dart';
import 'books_grid_page.dart';
import 'featured_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _StoreShell();
  }
}

class _StoreShell extends ConsumerStatefulWidget {
  const _StoreShell();

  @override
  ConsumerState<_StoreShell> createState() => _StoreShellState();
}

class _StoreShellState extends ConsumerState<_StoreShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(booksAsyncProvider);
    final categories = ref.watch(storeCategoriesProvider);

    final homeTab = booksAsync.when(
      loading: () => const _BooksLoadingView(),
      error: (error, _) => _BooksErrorView(
        message: error.toString(),
        onRetry: () => ref.invalidate(booksAsyncProvider),
      ),
      data: (books) => HomeTab(
        featuredBooks: books.take(6).toList(),
        categories: categories,
        popularBooks: books,
        onBookTap: _openBookDetails,
        onCategoryTap: _openCategory,
        onNotificationsTap: _openNotifications,
        onFeaturedTap: _openFeatured,
        onPopularTap: _openPopular,
      ),
    );

    final pages = [
      homeTab,
      OrdersTab(onCheckoutTap: _openCheckout),
      CartTab(
        onCheckoutTap: _openCheckout,
        onHomeTap: () => setState(() => _currentIndex = 0),
      ),
      const ProfileTab(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        backgroundColor: const Color(0xFFF7F7F8),
        elevation: 0,
        selectedItemColor: const Color(0xFF4A9AF0),
        unselectedItemColor: const Color(0xFF6F6F72),
        selectedFontSize: 13,
        unselectedFontSize: 13,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          height: 1.25,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          height: 1.25,
        ),
        iconSize: 28,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2_outlined),
            label: 'Order',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_checkout_outlined),
            activeIcon: Icon(Icons.shopping_cart_checkout_outlined),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _openFeatured() {
    final books = ref.read(storeCatalogProvider);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FeaturedPage(
          categories: ref.read(storeCategoriesProvider),
          popularBooks: books,
          onBookTap: _openBookDetails,
          onCategoryTap: _openCategory,
        ),
      ),
    );
  }

  void _openPopular() {
    final books = ref.read(storeCatalogProvider);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BooksGridPage(
          title: 'Popular Books',
          books: books,
          onBookTap: _openBookDetails,
        ),
      ),
    );
  }

  Future<void> _openCategory(BookCategory category) async {
    final all = ref.read(storeCatalogProvider);
    final result = await ref
        .read(bookRepositoryProvider)
        .getBooks(categoryId: category.id, limit: 100);
    final filtered = switch (result) {
      Success(data: final data) => data.books,
      ResultFailure() => all.where((b) => b.categoryId == category.id).toList(),
    };

    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BooksGridPage(
          title: category.name,
          books: filtered,
          onBookTap: _openBookDetails,
        ),
      ),
    );
  }

  void _openBookDetails(BookItem book) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => BookDetailsPage(book: book)),
    );
  }

  void _openCheckout() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const CheckoutPage()));
  }

  void _openNotifications() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const NotificationsPage()));
  }
}

class _BooksLoadingView extends StatelessWidget {
  const _BooksLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF5F6F8),
      body: Center(child: CircularProgressIndicator(color: Color(0xFF5A91C4))),
    );
  }
}

class _BooksErrorView extends StatelessWidget {
  const _BooksErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 56,
                color: Color(0xFF9CA6B3),
              ),
              const SizedBox(height: 16),
              const Text(
                'Could not load books',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF243041),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFF8E98A5)),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A91C4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text(
                  'Retry',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
