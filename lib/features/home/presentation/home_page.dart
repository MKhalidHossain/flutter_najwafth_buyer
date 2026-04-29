import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../../auth/presentation/auth_routes.dart';
import '../application/store_controller.dart';
import '../domain/store_models.dart';
import 'widgets/store_widgets.dart';

const _homeBannerAssets = <String>[
  'assets/images/books/home_banner_01.png',
  'assets/images/books/home_banner_02.png',
  'assets/images/books/home_banner_03.png',
  'assets/images/books/home_banner_04.png',
  'assets/images/books/home_banner_05.png',
];

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeState = ref.watch(storeControllerProvider);

    if (storeState.selectedLanguage == null) {
      return const _LanguageSelectionPage();
    }

    return const _StoreShell();
  }
}

class _LanguageSelectionPage extends ConsumerStatefulWidget {
  const _LanguageSelectionPage();

  @override
  ConsumerState<_LanguageSelectionPage> createState() =>
      _LanguageSelectionPageState();
}

class _LanguageSelectionPageState
    extends ConsumerState<_LanguageSelectionPage> {
  AppLanguage _selectedLanguage = AppLanguage.english;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return StorePageScaffold(
      title: 'Language chan...',
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose Language',
              style: TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            ...AppLanguage.values.map(
              (language) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _LanguageOptionTile(
                  language: language,
                  selected: _selectedLanguage == language,
                  onTap: () => setState(() => _selectedLanguage = language),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveLanguage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6E93BD),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveLanguage() async {
    setState(() => _isSaving = true);
    await ref.read(storeControllerProvider.notifier).setLanguage(
      _selectedLanguage,
    );
    if (mounted) {
      setState(() => _isSaving = false);
    }
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
    final featuredBooks = books.where((book) => book.isFeatured).toList();
    final popularBooks = books.where((book) => book.isPopular).toList();

    final screens = [
      _HomeTab(
        featuredBooks: featuredBooks,
        popularBooks: popularBooks,
        categories: categories,
        onBookTap: _openBookDetails,
        onFeaturedTap: () => _openBookCollection(
          title: 'Featured Bookstores',
          books: featuredBooks,
        ),
        onPopularTap: () => _openBookCollection(
          title: 'Popular Books',
          books: popularBooks,
        ),
        onCategoryTap: _openCategoryCollection,
        onCartTap: _openCheckout,
        onMenuTap: _showQuickMenu,
        cartCount: storeState.totalItems,
      ),
      _CategoriesTab(
        categories: categories,
        books: books,
        cartCount: storeState.totalItems,
        onCategoryTap: _openCategoryCollection,
        onBookTap: _openBookDetails,
        onCartTap: _openCheckout,
      ),
      _PopularBooksTab(
        books: popularBooks,
        cartCount: storeState.totalItems,
        onBookTap: _openBookDetails,
        onCartTap: _openCheckout,
      ),
      _ProfileTab(
        cartCount: storeState.totalItems,
        onCartTap: _openCheckout,
        onSignOutTap: _signOut,
        onChangeLanguageTap: _showLanguagePicker,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        height: 68,
        indicatorColor: const Color(0xFFEDF4FC),
        backgroundColor: Colors.white,
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Categories',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            label: 'Popular',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _openBookCollection({
    required String title,
    required List<BookItem> books,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _BookCollectionPage(
          title: title,
          books: books,
          onBookTap: _openBookDetails,
          onCartTap: _openCheckout,
        ),
      ),
    );
  }

  void _openCategoryCollection(BookCategory category) {
    final books = ref
        .read(storeCatalogProvider)
        .where((book) => book.categoryId == category.id)
        .toList();

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _BookCollectionPage(
          title: category.name,
          books: books,
          onBookTap: _openBookDetails,
          onCartTap: _openCheckout,
        ),
      ),
    );
  }

  void _openBookDetails(BookItem book) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _BookDetailsPage(
          book: book,
          onCheckoutTap: _openCheckout,
        ),
      ),
    );
  }

  void _openCheckout() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const _CheckoutPage()),
    );
  }

  Future<void> _signOut() async {
    await ref.read(authControllerProvider.notifier).logout();
    if (!mounted) {
      return;
    }

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AuthRoutes.signIn, (route) => false);
  }

  Future<void> _showQuickMenu() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7DCE5),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.language, color: Color(0xFF6E93BD)),
                  title: const Text('Change language'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showLanguagePicker();
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFDA5A5A),
                  ),
                  title: const Text('Sign out'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _signOut();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showLanguagePicker() async {
    final current = ref.read(storeControllerProvider).selectedLanguage;
    AppLanguage selected = current ?? AppLanguage.english;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('Choose language'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: AppLanguage.values
                    .map(
                      (language) => RadioListTile<AppLanguage>(
                        value: language,
                        groupValue: selected,
                        activeColor: const Color(0xFF6E93BD),
                        title: Text('${language.flag}  ${language.label}'),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selected = value);
                          }
                        },
                      ),
                    )
                    .toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    await ref
                        .read(storeControllerProvider.notifier)
                        .setLanguage(selected);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _HomeTab extends ConsumerWidget {
  const _HomeTab({
    required this.featuredBooks,
    required this.popularBooks,
    required this.categories,
    required this.onBookTap,
    required this.onFeaturedTap,
    required this.onPopularTap,
    required this.onCategoryTap,
    required this.onCartTap,
    required this.onMenuTap,
    required this.cartCount,
  });

  final List<BookItem> featuredBooks;
  final List<BookItem> popularBooks;
  final List<BookCategory> categories;
  final ValueChanged<BookItem> onBookTap;
  final VoidCallback onFeaturedTap;
  final VoidCallback onPopularTap;
  final ValueChanged<BookCategory> onCategoryTap;
  final VoidCallback onCartTap;
  final VoidCallback onMenuTap;
  final int cartCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return StorePageScaffold(
      title: 'Home',
      leading: IconButton(
        onPressed: onMenuTap,
        icon: const Icon(Icons.menu, color: Color(0xFF364152)),
      ),
      actions: [
        CartBadgeButton(count: cartCount, onTap: onCartTap),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
        children: [
          Text(
            'Moblie book shopping',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(0xFF28303F),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Welcome ${authState.fullName}',
            style: const TextStyle(
              color: Color(0xFF9AA4B2),
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 14),
          const StoreSearchField(hintText: 'Search here...'),
          const SizedBox(height: 14),
          SizedBox(
            height: 122,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _homeBannerAssets.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) => ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  _homeBannerAssets[index],
                  width: 230,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 230,
                    color: const Color(0xFFE9EEF5),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      color: Color(0xFF7B8798),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          SectionTitleRow(
            title: 'Featured Bookstores',
            actionLabel: 'See all',
            onActionTap: onFeaturedTap,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 214,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) => BookCard(
                book: featuredBooks[index],
                onTap: () => onBookTap(featuredBooks[index]),
              ),
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemCount: featuredBooks.length,
            ),
          ),
          const SizedBox(height: 22),
          const SectionTitleRow(title: 'Categories'),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.92,
            ),
            itemBuilder: (context, index) => CategoryChipCard(
              category: categories[index],
              onTap: () => onCategoryTap(categories[index]),
            ),
          ),
          const SizedBox(height: 22),
          SectionTitleRow(
            title: 'Popular Books',
            actionLabel: 'See all',
            onActionTap: onPopularTap,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 216,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: popularBooks.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, index) => BookCard(
                book: popularBooks[index],
                onTap: () => onBookTap(popularBooks[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoriesTab extends StatefulWidget {
  const _CategoriesTab({
    required this.categories,
    required this.books,
    required this.cartCount,
    required this.onCategoryTap,
    required this.onBookTap,
    required this.onCartTap,
  });

  final List<BookCategory> categories;
  final List<BookItem> books;
  final int cartCount;
  final ValueChanged<BookCategory> onCategoryTap;
  final ValueChanged<BookItem> onBookTap;
  final VoidCallback onCartTap;

  @override
  State<_CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends State<_CategoriesTab> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final visibleBooks = widget.books.where((book) {
      if (_query.isEmpty) {
        return true;
      }

      final text = '${book.title} ${book.author} ${book.categoryName}'
          .toLowerCase();
      return text.contains(_query.toLowerCase());
    }).toList();

    return StorePageScaffold(
      title: 'Categories',
      actions: [
        CartBadgeButton(count: widget.cartCount, onTap: widget.onCartTap),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
        children: [
          StoreSearchField(
            hintText: 'Search books...',
            onChanged: (value) => setState(() => _query = value.trim()),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: widget.categories
                .map(
                  (category) => ActionChip(
                    backgroundColor: const Color(0xFFF4F5F8),
                    side: const BorderSide(color: Color(0xFFE4E8EF)),
                    label: Text(category.name),
                    onPressed: () => widget.onCategoryTap(category),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visibleBooks.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.7,
            ),
            itemBuilder: (context, index) => BookGridTile(
              book: visibleBooks[index],
              onTap: () => widget.onBookTap(visibleBooks[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _PopularBooksTab extends StatelessWidget {
  const _PopularBooksTab({
    required this.books,
    required this.cartCount,
    required this.onBookTap,
    required this.onCartTap,
  });

  final List<BookItem> books;
  final int cartCount;
  final ValueChanged<BookItem> onBookTap;
  final VoidCallback onCartTap;

  @override
  Widget build(BuildContext context) {
    return StorePageScaffold(
      title: 'Popular Books',
      actions: [
        CartBadgeButton(count: cartCount, onTap: onCartTap),
      ],
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
        itemCount: books.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (context, index) => BookGridTile(
          book: books[index],
          onTap: () => onBookTap(books[index]),
        ),
      ),
    );
  }
}

class _ProfileTab extends ConsumerWidget {
  const _ProfileTab({
    required this.cartCount,
    required this.onCartTap,
    required this.onSignOutTap,
    required this.onChangeLanguageTap,
  });

  final int cartCount;
  final VoidCallback onCartTap;
  final VoidCallback onSignOutTap;
  final VoidCallback onChangeLanguageTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final language = ref.watch(storeControllerProvider).selectedLanguage;

    return StorePageScaffold(
      title: 'Profile',
      actions: [
        CartBadgeButton(count: cartCount, onTap: onCartTap),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authState.fullName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF28303F),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  authState.email,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF758195),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  authState.phone,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF758195),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ListTile(
            tileColor: const Color(0xFFF7F9FC),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            leading: const Icon(Icons.language, color: Color(0xFF6E93BD)),
            title: const Text('Language'),
            subtitle: Text(language?.label ?? 'Not set'),
            trailing: const Icon(Icons.chevron_right),
            onTap: onChangeLanguageTap,
          ),
          const SizedBox(height: 12),
          ListTile(
            tileColor: const Color(0xFFF7F9FC),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            leading: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF6E93BD)),
            title: const Text('Open checkout'),
            trailing: const Icon(Icons.chevron_right),
            onTap: onCartTap,
          ),
          const SizedBox(height: 12),
          ListTile(
            tileColor: const Color(0xFFFFF4F4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            leading: const Icon(Icons.logout_rounded, color: Color(0xFFDA5A5A)),
            title: const Text('Sign out'),
            onTap: onSignOutTap,
          ),
        ],
      ),
    );
  }
}

class _BookCollectionPage extends StatelessWidget {
  const _BookCollectionPage({
    required this.title,
    required this.books,
    required this.onBookTap,
    required this.onCartTap,
  });

  final String title;
  final List<BookItem> books;
  final ValueChanged<BookItem> onBookTap;
  final VoidCallback onCartTap;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final cartCount = ref.watch(storeControllerProvider).totalItems;

        return StorePageScaffold(
          title: title,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.chevron_left, color: Color(0xFF364152)),
          ),
          actions: [
            CartBadgeButton(count: cartCount, onTap: onCartTap),
          ],
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
            itemCount: books.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, index) => BookGridTile(
              book: books[index],
              onTap: () => onBookTap(books[index]),
            ),
          ),
        );
      },
    );
  }
}

class _BookDetailsPage extends ConsumerStatefulWidget {
  const _BookDetailsPage({
    required this.book,
    required this.onCheckoutTap,
  });

  final BookItem book;
  final VoidCallback onCheckoutTap;

  @override
  ConsumerState<_BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends ConsumerState<_BookDetailsPage> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final cartCount = ref.watch(storeControllerProvider).totalItems;

    return StorePageScaffold(
      title: 'Book Details',
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.chevron_left, color: Color(0xFF364152)),
      ),
      actions: [
        CartBadgeButton(count: cartCount, onTap: widget.onCheckoutTap),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
        children: [
          BookCover(
            title: widget.book.title,
            imageAsset: widget.book.coverImageAsset,
            color: widget.book.coverColor,
            accentColor: widget.book.coverAccent,
            height: 260,
            radius: 18,
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.book.title,
                  style: const TextStyle(
                    color: Color(0xFF243041),
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(Icons.star, color: Color(0xFFF0B533), size: 18),
              const SizedBox(width: 4),
              Text(
                widget.book.rating.toStringAsFixed(1),
                style: const TextStyle(
                  color: Color(0xFF758195),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            widget.book.author,
            style: const TextStyle(
              color: Color(0xFF9AA4B2),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ...List.generate(
                5,
                (index) => Icon(
                  index < widget.book.rating.round()
                      ? Icons.star
                      : Icons.star_border,
                  size: 14,
                  color: const Color(0xFFF1BA3C),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.book.reviewCount} reviews',
                style: const TextStyle(
                  color: Color(0xFF758195),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Description',
            style: TextStyle(
              color: Color(0xFF243041),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.book.description,
            style: const TextStyle(
              color: Color(0xFF758195),
              fontSize: 12,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                formatPrice(widget.book.price),
                style: const TextStyle(
                  color: Color(0xFF4B91F1),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              QuantitySelector(
                quantity: _quantity,
                onChanged: (value) {
                  setState(() => _quantity = value.clamp(1, 99).toInt());
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 46,
            child: ElevatedButton.icon(
              onPressed: _addToCart,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4B91F1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.shopping_bag_outlined, size: 18),
              label: const Text('Add to Cart'),
            ),
          ),
        ],
      ),
    );
  }

  void _addToCart() {
    ref.read(storeControllerProvider.notifier).addToCart(
      widget.book,
      quantity: _quantity,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.book.title} added to cart')),
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
  late final TextEditingController _cityController;
  late final TextEditingController _phoneController;
  PaymentMethod _paymentMethod = PaymentMethod.stripe;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final authState = ref.read(authControllerProvider);
    _nameController = TextEditingController(text: authState.fullName);
    _addressController = TextEditingController(text: 'Dhaka');
    _cityController = TextEditingController(text: 'Dhanmondi');
    _phoneController = TextEditingController(text: authState.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final books = ref.watch(storeCatalogProvider);
    final storeState = ref.watch(storeControllerProvider);
    final items = books
        .where((book) => storeState.quantityFor(book.id) > 0)
        .toList();
    final controller = ref.read(storeControllerProvider.notifier);
    final subtotal = controller.subtotal(books);
    final deliveryFee = controller.deliveryFee(items);
    final total = subtotal + deliveryFee;

    return StorePageScaffold(
      title: 'Payment details',
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.chevron_left, color: Color(0xFF364152)),
      ),
      child: items.isEmpty
          ? _EmptyCheckoutView(onContinueTap: () => Navigator.of(context).pop())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                children: [
                  const Text(
                    'Checkout',
                    style: TextStyle(
                      color: Color(0xFF243041),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'complete your order details',
                    style: TextStyle(
                      color: Color(0xFF96A1B0),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _CheckoutField(
                    controller: _nameController,
                    hintText: 'Name',
                    validator: _requiredField,
                  ),
                  const SizedBox(height: 10),
                  _CheckoutField(
                    controller: _cityController,
                    hintText: 'City',
                    validator: _requiredField,
                  ),
                  const SizedBox(height: 10),
                  _CheckoutField(
                    controller: _addressController,
                    hintText: 'Address',
                    validator: _requiredField,
                  ),
                  const SizedBox(height: 10),
                  _CheckoutField(
                    controller: _phoneController,
                    hintText: 'Phone number',
                    keyboardType: TextInputType.phone,
                    validator: _requiredField,
                  ),
                  const SizedBox(height: 16),
                  ...items.map(
                    (book) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _CheckoutItemRow(book: book),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _SummaryRow(label: 'Order Summary', value: ''),
                  const SizedBox(height: 8),
                  _SummaryRow(
                    label: 'Subtotal',
                    value: formatPrice(subtotal),
                  ),
                  const SizedBox(height: 6),
                  _SummaryRow(
                    label: 'Delivery fee',
                    value: formatPrice(deliveryFee),
                  ),
                  const SizedBox(height: 6),
                  _SummaryRow(
                    label: 'Total',
                    value: formatPrice(total),
                    emphasize: true,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Payment',
                    style: TextStyle(
                      color: Color(0xFF243041),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _PaymentOptionTile(
                    label: 'Paypal',
                    selected: _paymentMethod == PaymentMethod.paypal,
                    onTap: () => setState(
                      () => _paymentMethod = PaymentMethod.paypal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _PaymentOptionTile(
                    label: 'stripe',
                    selected: _paymentMethod == PaymentMethod.stripe,
                    onTap: () => setState(
                      () => _paymentMethod = PaymentMethod.stripe,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: _submitting ? null : _placeOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6E93BD),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: _submitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.lock_outline, size: 18),
                      label: Text(_submitting ? 'Processing...' : 'Place Order'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String? _requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _submitting = true);
    final receipt = await ref.read(storeControllerProvider.notifier).placeOrder(
      catalog: ref.read(storeCatalogProvider),
      input: CheckoutInput(
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        phone: _phoneController.text.trim(),
        paymentMethod: _paymentMethod,
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() => _submitting = false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => _OrderConfirmedPage(receipt: receipt),
      ),
    );
  }
}

class _OrderConfirmedPage extends StatelessWidget {
  const _OrderConfirmedPage({required this.receipt});

  final OrderReceipt receipt;

  @override
  Widget build(BuildContext context) {
    return StorePageScaffold(
      title: 'Payment details',
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.chevron_left, color: Color(0xFF364152)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
        child: Column(
          children: [
            const Spacer(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 24, 18, 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEAF5FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.celebration_outlined,
                      color: Color(0xFF4B91F1),
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Order Confirmed',
                    style: TextStyle(
                      color: Color(0xFF243041),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your order has been placed successfully',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF8B97A8),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _SummaryRow(label: 'Order Number', value: receipt.orderNumber),
                  const SizedBox(height: 6),
                  _SummaryRow(
                    label: 'Delivery fee',
                    value: formatPrice(receipt.deliveryFee),
                  ),
                  const SizedBox(height: 6),
                  _SummaryRow(
                    label: 'Total',
                    value: formatPrice(receipt.total),
                    emphasize: true,
                  ),
                  const SizedBox(height: 6),
                  _SummaryRow(
                    label: 'Payment',
                    value: receipt.paymentMethod.label,
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6E93BD),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.home_outlined, size: 18),
                label: const Text('Back to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOptionTile extends StatelessWidget {
  const _LanguageOptionTile({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  final AppLanguage language;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFDCE1E8)),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Text(language.flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                language.label,
                style: const TextStyle(
                  color: Color(0xFF253041),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected
                  ? const Color(0xFF6E93BD)
                  : const Color(0xFF8D97A7),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutField extends StatelessWidget {
  const _CheckoutField({
    required this.controller,
    required this.hintText,
    required this.validator,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hintText;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: const Color(0xFFF4F5F8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF6E93BD)),
        ),
      ),
    );
  }
}

class _CheckoutItemRow extends ConsumerWidget {
  const _CheckoutItemRow({required this.book});

  final BookItem book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quantity = ref.watch(storeControllerProvider).quantityFor(book.id);

    return Row(
      children: [
        Expanded(
          child: Text(
            book.title,
            style: const TextStyle(
              color: Color(0xFF243041),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        QuantitySelector(
          quantity: quantity,
          onChanged: (value) {
            ref.read(storeControllerProvider.notifier).setQuantity(book, value);
          },
        ),
        const SizedBox(width: 10),
        Text(
          formatPrice(book.price * quantity),
          style: const TextStyle(
            color: Color(0xFF4B91F1),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PaymentOptionTile extends StatelessWidget {
  const _PaymentOptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEFF5FD) : const Color(0xFFF7F8FB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? const Color(0xFF6E93BD) : const Color(0xFFE4E8EF),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: selected
                      ? const Color(0xFF2A5B8A)
                      : const Color(0xFF475467),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? const Color(0xFF6E93BD) : const Color(0xFF98A2B3),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: emphasize ? const Color(0xFF243041) : const Color(0xFF7A8699),
      fontSize: emphasize ? 13 : 12,
      fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
    );

    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        if (value.isNotEmpty) Text(value, style: style),
      ],
    );
  }
}

class _EmptyCheckoutView extends StatelessWidget {
  const _EmptyCheckoutView({required this.onContinueTap});

  final VoidCallback onContinueTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 48,
              color: Color(0xFF9AA4B2),
            ),
            const SizedBox(height: 14),
            const Text(
              'Your cart is empty',
              style: TextStyle(
                color: Color(0xFF243041),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add a few books before continuing to checkout.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF8B97A8),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onContinueTap,
              child: const Text('Continue shopping'),
            ),
          ],
        ),
      ),
    );
  }
}
