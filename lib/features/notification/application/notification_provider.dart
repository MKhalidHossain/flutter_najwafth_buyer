import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/result.dart';
import '../../../core/network/network_providers.dart';
import '../data/notification_repository.dart';
import '../domain/notification_models.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.watch(apiClientProvider));
});

final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  final result = await ref
      .read(notificationRepositoryProvider)
      .getUnreadCount();
  return switch (result) {
    Success(data: final count) => count,
    ResultFailure(error: final e) => throw e,
  };
});

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, NotificationsPageData>(
      NotificationsNotifier.new,
    );

final class NotificationsNotifier extends AsyncNotifier<NotificationsPageData> {
  @override
  Future<NotificationsPageData> build() => _fetch();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> markRead(String id) async {
    final current = state.asData?.value;
    if (current == null) return;

    final mark = await ref.read(notificationRepositoryProvider).markAsRead(id);
    if (mark is ResultFailure<void>) return;

    final updatedItems = current.items
        .map((item) => item.id == id ? item.copyWith(isRead: true) : item)
        .toList(growable: false);
    final unread = updatedItems.where((e) => !e.isRead).length;

    state = AsyncData(
      NotificationsPageData(items: updatedItems, unreadCount: unread),
    );
    ref.invalidate(unreadNotificationCountProvider);
  }

  Future<void> markAllRead() async {
    final current = state.asData?.value;
    if (current == null) return;

    final mark = await ref.read(notificationRepositoryProvider).markAllAsRead();
    if (mark is ResultFailure<void>) return;

    final updatedItems = current.items
        .map((item) => item.copyWith(isRead: true))
        .toList(growable: false);
    state = AsyncData(
      NotificationsPageData(items: updatedItems, unreadCount: 0),
    );
    ref.invalidate(unreadNotificationCountProvider);
  }

  Future<NotificationsPageData> _fetch() async {
    final result = await ref
        .read(notificationRepositoryProvider)
        .getMyNotifications();
    return switch (result) {
      Success(data: final data) => data,
      ResultFailure(error: final e) => throw e,
    };
  }
}
