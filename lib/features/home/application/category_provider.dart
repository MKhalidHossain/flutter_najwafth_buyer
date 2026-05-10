import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/result.dart';
import '../../../core/network/network_providers.dart';
import '../data/category_repository.dart';
import '../domain/store_models.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(ref.watch(apiClientProvider));
});

final categoriesAsyncProvider = FutureProvider<List<BookCategory>>((ref) async {
  final result = await ref.read(categoryRepositoryProvider).getCategories();
  return switch (result) {
    Success(data: final categories) => categories,
    ResultFailure(error: final e) => throw e,
  };
});
