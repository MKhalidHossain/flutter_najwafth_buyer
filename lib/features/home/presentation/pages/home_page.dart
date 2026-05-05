import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/application/auth_controller.dart';
import '../../../auth/presentation/auth_routes.dart';
import '../../../cart_order/presentation/pages/book_details_page.dart';
import '../../../cart_order/presentation/pages/checkout_page.dart';
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
    final books = ref.watch(storeCatalogProvider);
    final categories = ref.watch(storeCategoriesProvider);
    final storeState = ref.watch(storeControllerProvider);
    final featuredBooks = books.where((b) => b.isFeatured).toList();
    final popularBooks = books.where((b) => b.isPopular).toList();

    final pages = [
      HomeTab(
        featuredBooks: featuredBooks,
        categories: categories,
        popularBooks: popularBooks,
        onBookTap: _openBookDetails,
        onNotificationsTap: _openNotifications,
        onFeaturedTap: _openFeatured,
        onPopularTap: _openPopular,
      ),
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
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, height: 1.25),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, height: 1.25),
        iconSize: 28,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2_outlined), label: 'Order'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_checkout_outlined), activeIcon: Icon(Icons.shopping_cart_checkout_outlined), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  void _openFeatured() {
    final books = ref.read(storeCatalogProvider).where((b) => b.isFeatured).toList();
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
    final books = ref.read(storeCatalogProvider).where((b) => b.isPopular).toList();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BooksGridPage(title: 'Popular Books', books: books, onBookTap: _openBookDetails),
      ),
    );
  }

  void _openCategory(BookCategory category) {
    final books = ref.read(storeCatalogProvider).where((b) => b.categoryId == category.id).toList();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BooksGridPage(title: category.name, books: books, onBookTap: _openBookDetails),
      ),
    );
  }

  void _openBookDetails(BookItem book) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => BookDetailsPage(book: book)),
    );
  }

  void _openCheckout() {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const CheckoutPage()));
  }

  void _openNotifications() {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const NotificationsPage()));
  }

  Future<void> _signOut() async {
    await ref.read(authControllerProvider.notifier).logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(AuthRoutes.signIn, (route) => false);
  }
}
