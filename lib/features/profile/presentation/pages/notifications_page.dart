import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../notification/application/notification_provider.dart';
import '../../../notification/domain/notification_models.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.chevron_left,
            color: Color(0xFF243041),
            size: 28,
          ),
        ),
        title: Text(
          l10n.notifications,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF243041),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                ref.read(notificationsProvider.notifier).markAllRead(),
            child: Text(l10n.markAllRead),
          ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF5A91C4)),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.failedToLoadNotifications),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () =>
                    ref.read(notificationsProvider.notifier).refresh(),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (data) {
          final unread = data.items
              .where((item) => !item.isRead)
              .toList(growable: false);
          final read = data.items
              .where((item) => item.isRead)
              .toList(growable: false);

          if (data.items.isEmpty) {
            return Center(
              child: Text(
                l10n.noNotificationsYet,
                style: TextStyle(fontSize: 14, color: Color(0xFF8E98A5)),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(notificationsProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const SizedBox(height: 10),
                if (unread.isNotEmpty) ...[
                  Text(
                    l10n.newLabel,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF243041),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...unread.map((item) => _NotificationTile(item: item)),
                  const SizedBox(height: 20),
                ],
                if (read.isNotEmpty) ...[
                  Text(
                    l10n.earlier,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF243041),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...read.map((item) => _NotificationTile(item: item)),
                ],
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.item});

  final AppNotification item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => ref.read(notificationsProvider.notifier).markRead(item.id),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: item.isRead ? Colors.white : const Color(0xFFF4F9FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8EBF0)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.isRead
                      ? const Color(0xFFC2CBD8)
                      : const Color(0xFF5A91C4),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF243041),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.message,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF4F5B6A),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _relative(context, item.createdAt),
                style: const TextStyle(fontSize: 11, color: Color(0xFF8E98A5)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _relative(BuildContext context, DateTime date) {
  final l10n = AppLocalizations.of(context);
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return l10n.now;
  if (diff.inMinutes < 60) return l10n.minutesAgoShort(diff.inMinutes);
  if (diff.inHours < 24) return l10n.hoursAgoShort(diff.inHours);
  return l10n.daysAgoShort(diff.inDays);
}
