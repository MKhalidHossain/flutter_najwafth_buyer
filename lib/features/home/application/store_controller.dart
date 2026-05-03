import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/key_value_storage.dart';
import '../../../core/storage/storage_providers.dart';
import '../domain/store_models.dart';
import '../../order/application/order_controller.dart';
import '../../order/domain/order_models.dart';

final storeCatalogProvider = Provider<List<BookItem>>((ref) {
  return const [
    BookItem(
      id: 'book-1',
      title: 'The Great Gatsby',
      author: 'F. Scott Fitzgerald',
      coverImageAsset: 'assets/images/books/book_cover_01.png',
      price: 12.99,
      rating: 4.8,
      reviewCount: 120,
      description:
          'A lush portrait of wealth, longing, and reinvention set against the Jazz Age in America.',
      categoryId: 'classic',
      categoryName: 'Classic',
      coverColor: Color(0xFF8A5A3B),
      coverAccent: Color(0xFFE6C261),
      isFeatured: true,
      isPopular: true,
    ),
    BookItem(
      id: 'book-2',
      title: 'The Road Ahead',
      author: 'Bill Gates',
      coverImageAsset: 'assets/images/books/book_cover_02.png',
      price: 11.99,
      rating: 4.6,
      reviewCount: 86,
      description:
          'A reflective fiction title about second chances, old secrets, and a library that remembers everything.',
      categoryId: 'fiction',
      categoryName: 'Fiction',
      coverColor: Color(0xFF3E4C63),
      coverAccent: Color(0xFFF1C27D),
      isFeatured: true,
      isPopular: true,
    ),
    BookItem(
      id: 'book-3',
      title: 'Who Moved My Cheese',
      author: 'Spencer Johnson',
      coverImageAsset: 'assets/images/books/book_cover_03.png',
      price: 9.99,
      rating: 4.4,
      reviewCount: 64,
      description:
          'A warm contemporary romance told through city walks, handwritten notes, and difficult timing.',
      categoryId: 'romance',
      categoryName: 'Romance',
      coverColor: Color(0xFFC46E5E),
      coverAccent: Color(0xFFFFD3C6),
      isFeatured: true,
      isPopular: true,
    ),
    BookItem(
      id: 'book-4',
      title: 'The Silent Patient',
      author: 'Alex Michaelides',
      coverImageAsset: 'assets/images/books/book_cover_04.png',
      price: 10.49,
      rating: 4.2,
      reviewCount: 52,
      description:
          'A compact horror thriller where every midnight phone call reveals another piece of the truth.',
      categoryId: 'horror',
      categoryName: 'Horror',
      coverColor: Color(0xFF25272E),
      coverAccent: Color(0xFFE39B2D),
      isFeatured: true,
      isPopular: true,
    ),
    BookItem(
      id: 'book-5',
      title: 'To Kill a Mockingbird',
      author: 'Harper Lee',
      coverImageAsset: 'assets/images/books/book_cover_05.png',
      price: 15.50,
      rating: 4.9,
      reviewCount: 149,
      description:
          'A high-altitude adventure memoir about endurance, friendship, and the cost of ambition.',
      categoryId: 'adventure',
      categoryName: 'Adventure',
      coverColor: Color(0xFF2B5B67),
      coverAccent: Color(0xFFAAD9D7),
      isFeatured: true,
      isPopular: true,
    ),
    BookItem(
      id: 'book-6',
      title: 'Sapiens',
      author: 'Yuval Noah Harari',
      coverImageAsset: 'assets/images/books/book_cover_06.png',
      price: 13.25,
      rating: 4.7,
      reviewCount: 98,
      description:
          'A tightly plotted mystery with elegant clues, smart pacing, and a detective who notices everything.',
      categoryId: 'mystery',
      categoryName: 'Mystery',
      coverColor: Color(0xFF607D5B),
      coverAccent: Color(0xFFE0C98C),
      isPopular: true,
    ),
    BookItem(
      id: 'book-7',
      title: 'The Alchemist',
      author: 'Paulo Coelho',
      coverImageAsset: 'assets/images/books/book_cover_07.png',
      price: 8.95,
      rating: 4.5,
      reviewCount: 78,
      description:
          'A timeless story of purpose and perseverance as a shepherd follows his dream across deserts.',
      categoryId: 'adventure',
      categoryName: 'Adventure',
      coverColor: Color(0xFF7C5A43),
      coverAccent: Color(0xFFE5C18F),
      isPopular: true,
    ),
    BookItem(
      id: 'book-8',
      title: 'Atomic Habits',
      author: 'James Clear',
      coverImageAsset: 'assets/images/books/book_cover_08.png',
      price: 14.20,
      rating: 4.9,
      reviewCount: 201,
      description:
          'Practical behavior design patterns for building better systems, routines, and long-term growth.',
      categoryId: 'fiction',
      categoryName: 'Fiction',
      coverColor: Color(0xFF3D4B64),
      coverAccent: Color(0xFFD7E7FF),
      isPopular: true,
    ),
    BookItem(
      id: 'book-9',
      title: 'The Book Thief',
      author: 'Markus Zusak',
      coverImageAsset: 'assets/images/books/book_cover_09.png',
      price: 10.75,
      rating: 4.6,
      reviewCount: 133,
      description:
          'A moving novel about words, courage, and humanity in the shadows of wartime Germany.',
      categoryId: 'classic',
      categoryName: 'Classic',
      coverColor: Color(0xFF1F242E),
      coverAccent: Color(0xFFF3B03D),
      isPopular: true,
    ),
    BookItem(
      id: 'book-10',
      title: 'Ikigai',
      author: 'Hector Garcia',
      coverImageAsset: 'assets/images/books/book_cover_10.png',
      price: 9.40,
      rating: 4.3,
      reviewCount: 72,
      description:
          'An accessible exploration of purpose, longevity, and everyday joy inspired by Japanese wisdom.',
      categoryId: 'romance',
      categoryName: 'Romance',
      coverColor: Color(0xFFC46B58),
      coverAccent: Color(0xFFFEE0D8),
      isPopular: true,
    ),
    BookItem(
      id: 'book-11',
      title: 'The Midnight Library',
      author: 'Matt Haig',
      coverImageAsset: 'assets/images/books/book_cover_11.png',
      price: 12.10,
      rating: 4.4,
      reviewCount: 90,
      description:
          'A reflective story about regret, possibility, and the alternate lives hidden behind every choice.',
      categoryId: 'mystery',
      categoryName: 'Mystery',
      coverColor: Color(0xFF566E5D),
      coverAccent: Color(0xFFD8C48A),
      isPopular: true,
    ),
    BookItem(
      id: 'book-12',
      title: 'Rich Dad Poor Dad',
      author: 'Robert T. Kiyosaki',
      coverImageAsset: 'assets/images/books/book_cover_12.png',
      price: 11.30,
      rating: 4.7,
      reviewCount: 144,
      description:
          'A foundational personal finance title focused on cash flow, assets, and financial mindset.',
      categoryId: 'fiction',
      categoryName: 'Fiction',
      coverColor: Color(0xFF2E4D6B),
      coverAccent: Color(0xFFE8CC84),
      isPopular: true,
    ),
  ];
});

final storeCategoriesProvider = Provider<List<BookCategory>>((ref) {
  return const [
    BookCategory(
      id: 'classic',
      name: 'Classic',
      color: Color(0xFFF0C08B),
      previewImageAsset: 'assets/images/books/book_cover_01.png',
    ),
    BookCategory(
      id: 'fiction',
      name: 'Fiction',
      color: Color(0xFF7B91C5),
      previewImageAsset: 'assets/images/books/book_cover_02.png',
    ),
    BookCategory(
      id: 'romance',
      name: 'Romance',
      color: Color(0xFFF29F95),
      previewImageAsset: 'assets/images/books/book_cover_03.png',
    ),
    BookCategory(
      id: 'horror',
      name: 'Horror',
      color: Color(0xFF545A66),
      previewImageAsset: 'assets/images/books/book_cover_04.png',
    ),
    BookCategory(
      id: 'adventure',
      name: 'Adventure',
      color: Color(0xFF6FB2A5),
      previewImageAsset: 'assets/images/books/book_cover_05.png',
    ),
    BookCategory(
      id: 'mystery',
      name: 'Mystery',
      color: Color(0xFFB8A270),
      previewImageAsset: 'assets/images/books/book_cover_06.png',
    ),
  ];
});

final storeControllerProvider =
    NotifierProvider<StoreController, StoreState>(StoreController.new);

final class StoreState {
  const StoreState({
    required this.selectedLanguage,
    required this.cartQuantities,
    required this.lastOrder,
  });

  final AppLanguage? selectedLanguage;
  final Map<String, int> cartQuantities;
  final OrderReceipt? lastOrder;

  int quantityFor(String bookId) => cartQuantities[bookId] ?? 0;

  int get totalItems =>
      cartQuantities.values.fold<int>(0, (sum, quantity) => sum + quantity);

  StoreState copyWith({
    AppLanguage? selectedLanguage,
    Map<String, int>? cartQuantities,
    OrderReceipt? lastOrder,
    bool clearLanguage = false,
    bool clearLastOrder = false,
  }) {
    return StoreState(
      selectedLanguage: clearLanguage
          ? null
          : selectedLanguage ?? this.selectedLanguage,
      cartQuantities: cartQuantities ?? this.cartQuantities,
      lastOrder: clearLastOrder ? null : lastOrder ?? this.lastOrder,
    );
  }
}

final class StoreController extends Notifier<StoreState> {
  static const _languageKey = 'selected_language';
  static const _deliveryFee = 2.50;

  late final KeyValueStorage _storage;

  @override
  StoreState build() {
    _storage = ref.watch(keyValueStorageProvider);
    final rawLanguage = _storage.readString(_languageKey);
    AppLanguage? selectedLanguage;

    for (final language in AppLanguage.values) {
      if (language.name == rawLanguage) {
        selectedLanguage = language;
        break;
      }
    }

    return StoreState(
      selectedLanguage: selectedLanguage,
      cartQuantities: const {},
      lastOrder: null,
    );
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = state.copyWith(selectedLanguage: language);
    await _storage.writeString(_languageKey, language.name);
  }

  void addToCart(BookItem book, {int quantity = 1}) {
    final updated = Map<String, int>.from(state.cartQuantities);
    updated.update(book.id, (value) => value + quantity, ifAbsent: () => quantity);
    state = state.copyWith(cartQuantities: updated, clearLastOrder: true);
  }

  void setQuantity(BookItem book, int quantity) {
    final updated = Map<String, int>.from(state.cartQuantities);
    if (quantity <= 0) {
      updated.remove(book.id);
    } else {
      updated[book.id] = quantity;
    }
    state = state.copyWith(cartQuantities: updated);
  }

  void clearCart() {
    state = state.copyWith(cartQuantities: const {});
  }

  double subtotal(List<BookItem> books) {
    return books.fold<double>(
      0,
      (sum, book) => sum + (book.price * state.quantityFor(book.id)),
    );
  }

  double deliveryFee(List<BookItem> books) {
    return books.isEmpty ? 0 : _deliveryFee;
  }

  Future<OrderReceipt> placeOrder({
    required List<BookItem> catalog,
    required CheckoutInput input,
  }) async {
    final items = catalog
        .where((book) => state.quantityFor(book.id) > 0)
        .expand(
          (book) => List<BookItem>.filled(state.quantityFor(book.id), book),
        )
        .toList(growable: false);

    final subtotalAmount = items.fold<double>(0, (sum, item) => sum + item.price);
    final receipt = OrderReceipt(
      orderNumber:
          '#BK${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      customerName: input.name,
      address: '${input.address}, ${input.city}',
      phone: input.phone,
      items: items,
      subtotal: subtotalAmount,
      deliveryFee: deliveryFee(items),
      paymentMethod: input.paymentMethod,
    );

    state = state.copyWith(
      cartQuantities: const {},
      lastOrder: receipt,
    );

    ref.read(orderControllerProvider.notifier).addOrder(OrderModel.fromReceipt(receipt));

    return receipt;
  }

  void clearOrderReceipt() {
    state = state.copyWith(clearLastOrder: true);
  }
}
