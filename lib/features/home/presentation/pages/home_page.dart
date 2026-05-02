import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/application/auth_controller.dart';
import '../../../auth/presentation/auth_routes.dart';
import '../../application/store_controller.dart';
import '../../domain/store_models.dart';
import 'book_details_page.dart';
import 'featured_page.dart';
import '../widgets/store_widgets.dart';

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
      _HomeTab(
        featuredBooks: featuredBooks,
        categories: categories,
        popularBooks: popularBooks,
        onBookTap: _openBookDetails,
        onFeaturedTap: _openFeatured,
        onPopularTap: _openPopular,
      ),
      _OrdersTab(onCheckoutTap: _openCheckout),
      _CartTab(onCheckoutTap: _openCheckout, cartCount: storeState.totalItems),
      _ProfileTab(
        onSignOutTap: _signOut,
        selectedLanguage: storeState.selectedLanguage,
      ),
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
        builder: (_) => _BooksGridPage(title: 'Popular Books', books: books, onBookTap: _openBookDetails),
      ),
    );
  }

  void _openCategory(BookCategory category) {
    final books = ref.read(storeCatalogProvider).where((b) => b.categoryId == category.id).toList();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _BooksGridPage(title: category.name, books: books, onBookTap: _openBookDetails),
      ),
    );
  }

  void _openBookDetails(BookItem book) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => BookDetailsPage(book: book)),
    );
  }

  void _openCheckout() {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const _CheckoutPage()));
  }

  Future<void> _signOut() async {
    await ref.read(authControllerProvider.notifier).logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(AuthRoutes.signIn, (route) => false);
  }
}

class _HomeTab extends ConsumerWidget {
  const _HomeTab({
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
                    Text(authState.fullName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const Text('Hi, Good Morning!', style: TextStyle(fontSize: 10, color: Color(0xFF9CA6B3))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _SearchBar(),
          const SizedBox(height: 14),
          _SectionTitle(title: 'Featured Bookstores', actionText: 'See all', onActionTap: onFeaturedTap),
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
            itemBuilder: (context, index) => _BookCardMini(book: featuredBooks[index], onTap: () => onBookTap(featuredBooks[index])),
          ),
          const SizedBox(height: 14),
          _SectionTitle(title: 'Categories', actionText: 'See all', onActionTap: onFeaturedTap),
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
          _SectionTitle(title: 'Popular Books', actionText: 'See all', onActionTap: onPopularTap),
          const SizedBox(height: 10),
          SizedBox(
            height: 190,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: popularBooks.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, i) => SizedBox(
                width: 130,
                child: _BookCardMini(book: popularBooks[i], onTap: () => onBookTap(popularBooks[i])),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BooksGridPage extends StatelessWidget {
  const _BooksGridPage({
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
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFFF5F6F8),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        itemCount: books.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: .63,
        ),
        itemBuilder: (context, index) => _BookCardMini(book: books[index], onTap: () => onBookTap(books[index])),
      ),
    );
  }
}

class _CheckoutPage extends ConsumerStatefulWidget {
  const _CheckoutPage();

  @override
  ConsumerState<_CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<_CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  PaymentMethod _paymentMethod = PaymentMethod.stripe;

  @override
  void initState() {
    super.initState();
    final auth = ref.read(authControllerProvider);
    _nameController = TextEditingController(text: auth.fullName);
    _addressController = TextEditingController(text: 'Dhaka, Bangladesh');
    _phoneController = TextEditingController(text: auth.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final books = ref.watch(storeCatalogProvider);
    final state = ref.watch(storeControllerProvider);
    final items = books.where((b) => state.quantityFor(b.id) > 0).toList();
    final ctrl = ref.read(storeControllerProvider.notifier);
    final subtotal = ctrl.subtotal(books);
    final deliveryFee = ctrl.deliveryFee(items);
    final total = subtotal + deliveryFee;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text('Payment details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFFF5F6F8),
      ),
      body: items.isEmpty
          ? Center(
              child: TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Your cart is empty, go back')),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                children: [
                  const Text('Checkout', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
                  const Text('Complete your order details', style: TextStyle(fontSize: 11, color: Color(0xFF8E98A5))),
                  const SizedBox(height: 10),
                  _FieldLabel(icon: Icons.person_outline, text: 'Name'),
                  const SizedBox(height: 4),
                  _CheckoutField(controller: _nameController),
                  const SizedBox(height: 8),
                  _FieldLabel(icon: Icons.location_on_outlined, text: 'Address'),
                  const SizedBox(height: 4),
                  _CheckoutField(controller: _addressController),
                  const SizedBox(height: 8),
                  _FieldLabel(icon: Icons.phone_outlined, text: 'Phone number'),
                  const SizedBox(height: 4),
                  _CheckoutField(controller: _phoneController, keyboardType: TextInputType.phone),
                  const SizedBox(height: 10),
                  const _FieldLabel(icon: Icons.description_outlined, text: 'Order Summary'),
                  const SizedBox(height: 6),
                  _SummaryRow(label: 'Subtotal', value: formatPrice(subtotal)),
                  _SummaryRow(label: 'Delivery Fee', value: formatPrice(deliveryFee)),
                  _SummaryRow(label: 'Total', value: formatPrice(total), highlight: true),
                  const SizedBox(height: 8),
                  const _FieldLabel(icon: Icons.payment_outlined, text: 'Payment'),
                  const SizedBox(height: 4),
                  _PaymentMethodTile(
                    label: 'stripe',
                    selected: _paymentMethod == PaymentMethod.stripe,
                    onTap: () => setState(() => _paymentMethod = PaymentMethod.stripe),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 42,
                    child: ElevatedButton.icon(
                      onPressed: () => _placeOrder(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5A91C4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      icon: const Icon(Icons.verified, color: Colors.white, size: 15),
                      label: const Text('Place Order', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _placeOrder(BuildContext context) async {
    if (_nameController.text.trim().isEmpty || _addressController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
      return;
    }

    final receipt = await ref.read(storeControllerProvider.notifier).placeOrder(
      catalog: ref.read(storeCatalogProvider),
      input: CheckoutInput(
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        city: '',
        phone: _phoneController.text.trim(),
        paymentMethod: _paymentMethod,
      ),
    );

    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(14))),
      builder: (context) => _OrderSuccessSheet(receipt: receipt),
    );
  }
}

class _OrderSuccessSheet extends StatelessWidget {
  const _OrderSuccessSheet({required this.receipt});

  final OrderReceipt receipt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: Text('🎉', style: TextStyle(fontSize: 28))),
          const Center(child: Text('Order Confirmed', style: TextStyle(fontSize: 26, color: Color(0xFF4D92D4), fontWeight: FontWeight.w500))),
          const SizedBox(height: 2),
          const Center(child: Text('Your order has been placed successfully!', style: TextStyle(fontSize: 11, color: Color(0xFF8D97A3)))),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text('Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFFF8E68E), borderRadius: BorderRadius.circular(12)),
                child: const Text('Pending', style: TextStyle(fontSize: 10, color: Color(0xFF7A6722))),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Order Summary', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          _SummaryRow(label: 'Subtotal', value: formatPrice(receipt.subtotal)),
          _SummaryRow(label: 'Delivery Fee', value: formatPrice(receipt.deliveryFee)),
          _SummaryRow(label: 'Total', value: formatPrice(receipt.total), highlight: true),
          const SizedBox(height: 6),
          const _FieldLabel(icon: Icons.payment_outlined, text: 'Payment'),
          const SizedBox(height: 2),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFFF3F4F7), borderRadius: BorderRadius.circular(4)),
            child: Text(receipt.paymentMethod.label, style: const TextStyle(color: Color(0xFF5856D6), fontSize: 30, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5A91C4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              icon: const Icon(Icons.home_outlined, color: Colors.white, size: 16),
              label: const Text('Back to Home', style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrdersTab extends StatelessWidget {
  const _OrdersTab({required this.onCheckoutTap});

  final VoidCallback onCheckoutTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ElevatedButton(onPressed: onCheckoutTap, child: const Text('Open Payment details')),
      ),
    );
  }
}

class _CartTab extends StatelessWidget {
  const _CartTab({required this.onCheckoutTap, required this.cartCount});

  final VoidCallback onCheckoutTap;
  final int cartCount;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: TextButton(
          onPressed: onCheckoutTap,
          child: Text(cartCount > 0 ? 'Go to checkout ($cartCount)' : 'Cart is empty'),
        ),
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({required this.onSignOutTap, required this.selectedLanguage});

  final VoidCallback onSignOutTap;
  final AppLanguage? selectedLanguage;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Language: ${selectedLanguage?.label ?? 'English'}', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onSignOutTap, child: const Text('Sign Out')),
          ],
        ),
      ),
    );
  }
}

class _BookCardMini extends ConsumerWidget {
  const _BookCardMini({required this.book, required this.onTap});

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
            Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600)),
            Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFFFC83A), size: 10),
                const SizedBox(width: 2),
                Text(book.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 10, color: Color(0xFF6E7784))),
              ],
            ),
            Text(book.author, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 8, color: Color(0xFFAFB7C1))),
            Row(
              children: [
                Text(formatPrice(book.price), style: const TextStyle(fontSize: 16, color: Color(0xFF3694F4), fontWeight: FontWeight.w600)),
                const Spacer(),
                GestureDetector(
                  onTap: () => ref.read(storeControllerProvider.notifier).addToCart(book),
                  child: const CircleAvatar(
                    radius: 10,
                    backgroundColor: Color(0xFF5A91C4),
                    child: Icon(Icons.add, color: Colors.white, size: 14),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.actionText, this.onActionTap});

  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w500))),
        if (actionText != null)
          GestureDetector(
            onTap: onActionTap,
            child: Text(actionText!, style: const TextStyle(fontSize: 14, color: Color(0xFF4F8FC5))),
          ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search books, authors, stores...',
          hintStyle: const TextStyle(fontSize: 10, color: Color(0xFFA6AFBA)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xFFDDE2E9)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xFFDDE2E9)),
          ),
          suffixIcon: Container(
            width: 34,
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(color: const Color(0xFF5A91C4), borderRadius: BorderRadius.circular(3)),
            child: const Icon(Icons.search, color: Colors.white, size: 16),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF6F7990)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _CheckoutField extends StatelessWidget {
  const _CheckoutField({required this.controller, this.keyboardType});

  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFEFF1F4),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xFF5A91C4)),
          ),
        ),
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF1F4),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: selected ? const Color(0xFF5A91C4) : Colors.transparent),
        ),
        child: Text(label, style: const TextStyle(fontSize: 30, color: Color(0xFF5856D6), fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.highlight = false});

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF555F6D)))),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: highlight ? const Color(0xFF4EA0F2) : const Color(0xFF555F6D),
              fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
