import '../../../core/errors/result.dart';
import '../../../core/network/api_client.dart';
import '../domain/store_models.dart';

final class CategoryRepository {
  const CategoryRepository(this._client);

  final ApiClient _client;

  Future<Result<List<BookCategory>>> getCategories() async {
    final treeResult = await _client.get<List<BookCategory>>(
      '/categories/tree',
      parser: _parseCategories,
    );

    return switch (treeResult) {
      Success(data: final data) when data.isNotEmpty => Success(data),
      _ => _client.get<List<BookCategory>>(
        '/categories',
        parser: _parseCategories,
      ),
    };
  }

  static List<BookCategory> _parseCategories(dynamic data) {
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid category response');
    }

    if (data['success'] == false) {
      throw Exception(data['message']?.toString() ?? 'Category request failed');
    }

    final items = data['data'];
    if (items is! List) return const [];

    return items
        .whereType<Map<String, dynamic>>()
        .map(BookCategory.fromJson)
        .toList(growable: false);
  }
}
