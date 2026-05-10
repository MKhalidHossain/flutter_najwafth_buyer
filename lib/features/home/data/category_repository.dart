import '../../../core/errors/result.dart';
import '../../../core/network/api_client.dart';
import '../domain/store_models.dart';

final class CategoryRepository {
  const CategoryRepository(this._client);

  final ApiClient _client;

  Future<Result<List<BookCategory>>> getCategories() async {
    final treeResult = await _client.get<List<BookCategory>>(
      '/category/tree/all',
      parser: _parseCategories,
    );

    return switch (treeResult) {
      Success(data: final data) when data.isNotEmpty => Success(data),
      _ => _client.get<List<BookCategory>>(
        '/category',
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

    final flattened = <Map<String, dynamic>>[];
    for (final item in items.whereType<Map<String, dynamic>>()) {
      _collectTree(item, flattened);
    }

    final seen = <String>{};
    final categories = <BookCategory>[];
    for (final json in flattened) {
      final id = json['_id']?.toString() ?? '';
      if (id.isEmpty || seen.contains(id)) continue;
      seen.add(id);
      categories.add(BookCategory.fromJson(json));
    }

    return categories;
  }

  static void _collectTree(
    Map<String, dynamic> node,
    List<Map<String, dynamic>> bucket,
  ) {
    bucket.add(node);
    final children = node['children'];
    if (children is! List) return;
    for (final child in children.whereType<Map<String, dynamic>>()) {
      _collectTree(child, bucket);
    }
  }
}
