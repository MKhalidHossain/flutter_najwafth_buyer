import '../../../core/errors/result.dart';
import '../../../core/network/api_client.dart';
import '../domain/notification_models.dart';

final class NotificationRepository {
  const NotificationRepository(this._client);

  final ApiClient _client;

  Future<Result<NotificationsPageData>> getMyNotifications({
    int page = 1,
    int limit = 20,
  }) {
    return _client.get<NotificationsPageData>(
      '/notifications',
      queryParameters: {'page': page, 'limit': limit},
      parser: (data) {
        if (data is! Map<String, dynamic>) {
          throw Exception('Invalid notifications response');
        }
        if (data['success'] == false) {
          throw Exception(data['message']?.toString() ?? 'Request failed');
        }

        final rootData = data['data'] as Map<String, dynamic>? ?? {};
        final notifications =
            (rootData['notifications'] as List<dynamic>? ?? const [])
                .whereType<Map<String, dynamic>>()
                .map(AppNotification.fromJson)
                .toList(growable: false);

        return NotificationsPageData(
          items: notifications,
          unreadCount: (rootData['unreadCount'] as num?)?.toInt() ?? 0,
        );
      },
    );
  }

  Future<Result<int>> getUnreadCount() {
    return _client.get<int>(
      '/notifications/unread-count',
      parser: (data) {
        if (data is! Map<String, dynamic>) {
          throw Exception('Invalid unread count response');
        }
        if (data['success'] == false) {
          throw Exception(data['message']?.toString() ?? 'Request failed');
        }
        final rootData = data['data'] as Map<String, dynamic>? ?? {};
        return (rootData['unreadCount'] as num?)?.toInt() ?? 0;
      },
    );
  }

  Future<Result<void>> markAsRead(String id) async {
    final result = await _client.patch<dynamic>('/notifications/$id/read');
    return switch (result) {
      Success() => const Success(null),
      ResultFailure(error: final e) => ResultFailure(e),
    };
  }

  Future<Result<void>> markAllAsRead() async {
    final result = await _client.patch<dynamic>('/notifications/read-all');
    return switch (result) {
      Success() => const Success(null),
      ResultFailure(error: final e) => ResultFailure(e),
    };
  }
}
