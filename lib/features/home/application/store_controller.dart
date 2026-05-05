import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/key_value_storage.dart';
import '../../../core/storage/storage_providers.dart';
import '../domain/store_models.dart';
import '../../order/application/order_controller.dart';
import '../../order/domain/order_models.dart';
import 'book_provider.dart';
import 'category_provider.dart';

// Sync view of the async books cache — returns [] while loading
final storeCatalogProvider = Provider<List<BookItem>>((ref) {
  return ref.watch(booksAsyncProvider).asData?.value ?? const [];
});

final storeCategoriesProvider = Provider<List<BookCategory>>((ref) {
  return ref.watch(categoriesAsyncProvider).asData?.value ?? const [];
});

final storeControllerProvider = NotifierProvider<StoreController, StoreState>(
  StoreController.new,
);

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
    updated.update(
      book.id,
      (value) => value + quantity,
      ifAbsent: () => quantity,
    );
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

    final subtotalAmount = items.fold<double>(
      0,
      (sum, item) => sum + item.price,
    );
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

    state = state.copyWith(cartQuantities: const {}, lastOrder: receipt);

    ref
        .read(orderControllerProvider.notifier)
        .addOrder(OrderModel.fromReceipt(receipt));

    return receipt;
  }

  void clearOrderReceipt() {
    state = state.copyWith(clearLastOrder: true);
  }
}
