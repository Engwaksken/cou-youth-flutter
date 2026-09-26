import 'package:flutter/material.dart';

import '../core/api/api_config.dart';
import '../core/localization/module_strings.dart';
import '../core/theme/app_colors.dart';
import '../services/notification_service.dart';
import '../widgets/youth_screen_scaffold.dart';
import '../widgets/youth_states.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final NotificationService _service;
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _service = NotificationService(ApiConfig.client);
    _future = _service.list();
  }

  Future<void> _refresh() async {
    final future = _service.list();
    setState(() => _future = future);
    await future;
  }

  Future<void> _markAsRead(int receiptId) async {
    try {
      await _service.markAsRead(receiptId);
      if (mounted) {
        setState(() => _future = _service.list());
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ModuleStrings.text(context, 'notification_update_failed'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return YouthScreenScaffold(
      title: ModuleStrings.text(context, 'notifications'),
      subtitle: 'Stay up to date with youth ministry messages and alerts.',
      leading: IconButton(
        tooltip: 'Back',
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      child: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primary,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const YouthLoading(label: 'Loading notifications…');
            }

            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * .55,
                    child: YouthErrorState(
                      title: ModuleStrings.text(
                        context,
                        'notifications_load_failed',
                      ),
                      onRetry: _refresh,
                    ),
                  ),
                ],
              );
            }

            final rows = snapshot.data ?? const <Map<String, dynamic>>[];
            if (rows.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * .55,
                    child: YouthEmptyState(
                      icon: Icons.notifications_none_rounded,
                      title: ModuleStrings.text(context, 'no_notifications'),
                      message: 'New ministry updates and reminders will appear here.',
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              itemCount: rows.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final row = rows[index];
                final receiptId = row['receipt_id'] ?? row['id'];
                final unread = row['read_at'] == null;
                final title = (row['title'] ??
                        ModuleStrings.text(context, 'notification'))
                    .toString();
                final message = (row['message'] ?? row['body'] ?? '').toString();

                return Semantics(
                  button: receiptId is int && unread,
                  label:
                      '${unread ? 'Unread' : 'Read'} notification. $title. $message',
                  child: Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: receiptId is int && unread
                          ? () => _markAsRead(receiptId)
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: unread
                                    ? AppColors.primaryLight
                                    : AppColors.surfaceMuted,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                unread
                                    ? Icons.notifications_active_outlined
                                    : Icons.notifications_none_rounded,
                                color: unread
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          title,
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontWeight: unread
                                                ? FontWeight.w800
                                                : FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      if (unread)
                                        Container(
                                          width: 9,
                                          height: 9,
                                          decoration: const BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (message.trim().isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      message,
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        height: 1.45,
                                      ),
                                    ),
                                  ],
                                  if (unread) ...[
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Tap to mark as read',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
