import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class NotificationDrawerSheet extends StatelessWidget {
  const NotificationDrawerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final notifService = Provider.of<NotificationService>(context);
    final notifications = notifService.notifications;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.notifications_active_rounded, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Text(
                    'Notifications',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (notifications.isNotEmpty)
                TextButton(
                  onPressed: () => notifService.clearAll(),
                  child: const Text('Clear All'),
                )
            ],
          ),
          const Divider(height: 24),
          if (notifications.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Text(
                  'No new notifications',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: notifications.length,
                separatorBuilder: (ctx, i) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final notif = notifications[i];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryLight,
                      child: const Icon(Icons.build_circle_rounded, color: AppColors.primary),
                    ),
                    title: Text(
                      notif.title,
                      style: TextStyle(
                        fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      notif.message,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    trailing: Text(
                      DateFormat('hh:mm a').format(notif.timestamp),
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                    onTap: () {
                      notifService.markAsRead(notif.id);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
