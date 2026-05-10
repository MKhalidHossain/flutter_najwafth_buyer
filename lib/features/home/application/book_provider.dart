import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/result.dart';
import '../../../core/network/network_providers.dart';
import '../data/book_repository.dart';
import '../domain/store_models.dart';

final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return BookRepository(ref.watch(apiClientProvider));
});

final bookDetailProvider =
    FutureProvider.family<BookItem, String>((ref, id) async {
  final result = await ref.read(bookRepositoryProvider).getBook(id);
  return switch (result) {
    Success(data: final b) => b,
    ResultFailure(error: final e) => throw e,
  };
});

final booksAsyncProvider =
    AsyncNotifierProvider<BooksNotifier, List<BookItem>>(BooksNotifier.new);

final class BooksNotifier extends AsyncNotifier<List<BookItem>> {
  String _searchQuery = '';
  String _categoryId = '';

  @override
  Future<List<BookItem>> build() => _fetch();

  Future<List<BookItem>> _fetch() async {
    final result = await ref.read(bookRepositoryProvider).getBooks(
      search: _searchQuery.isEmpty ? null : _searchQuery,
      categoryId: _categoryId.isEmpty ? null : _categoryId,
    );
    return switch (result) {
      Success(data: final r) => r.books,
      ResultFailure(error: final e) => throw e,
    };
  }

  Future<void> search(String query) async {
    _searchQuery = query.trim();
    _categoryId = '';
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> filterByCategory(String categoryId) async {
    _categoryId = categoryId;
    _searchQuery = '';
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> clearFilters() async {
    _searchQuery = '';
    _categoryId = '';
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}
