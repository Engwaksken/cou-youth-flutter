import 'package:flutter/material.dart';

import '../core/api/api_config.dart';
import '../core/localization/module_strings.dart';
import '../services/notification_service.dart';
import '../widgets/brand_header.dart';

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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(ModuleStrings.text(context, 'notifications'))),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(18),
                children: [
                  const BrandHeader(compact: true),
                  const SizedBox(height: 32),
                  Icon(
                    Icons.cloud_off_outlined,
                    size: 44,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ModuleStrings.text(context, 'notifications_load_failed'),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }

            final rows = snapshot.data ?? const <Map<String, dynamic>>[];

            if (rows.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(18),
                children: [
                  const BrandHeader(compact: true),
                  const SizedBox(height: 32),
                  Icon(
                    Icons.notifications_none_outlined,
                    size: 48,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ModuleStrings.text(context, 'no_notifications'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              itemCount: rows.length + 1,
              separatorBuilder: (_, index) => index == 0
                  ? const SizedBox(height: 18)
                  : const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const BrandHeader(compact: true, showTagline: false);
                }

                final row = rows[index - 1];
                final receiptId = row['receipt_id'] ?? row['id'];
                final readAt = row['read_at'];
                final unread = readAt == null;
                final title = (row['title'] ??
                        ModuleStrings.text(context, 'notification'))
                    .toString();
                final message = (row['message'] ?? row['body'] ?? '').toString();

                return Semantics(
                  button: receiptId is int && unread,
                  label: '${unread ? 'Unread' : 'Read'} notification. $title. $message',
                  child: Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: receiptId is int && unread
                          ? () async {
                              try {
                                await _service.markAsRead(receiptId);
                                if (mounted) {
                                  setState(() => _future = _service.list());
                                }
                              } catch (_) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        ModuleStrings.text(
                                          context,
                                          'notification_update_failed',
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              }
                            }
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: unread
                                  ? scheme.primaryContainer
                                  : scheme.surfaceContainerHighest,
                              child: Icon(
                                unread
                                    ? Icons.notifications_active_outlined
                                    : Icons.notifications_none,
                                color: unread
                                    ? scheme.primary
                                    : scheme.onSurfaceVariant,
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
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
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
                                          decoration: BoxDecoration(
                                            color: scheme.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (message.trim().isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      message,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(height: 1.45),
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
