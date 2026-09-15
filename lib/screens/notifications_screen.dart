import 'package:flutter/material.dart';

import '../core/api/api_config.dart';
import '../services/notification_service.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
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
                children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Notifications could not be loaded. Pull down to try again.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              );
            }

            final rows = snapshot.data ?? const <Map<String, dynamic>>[];

            if (rows.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('You have no notifications.')),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: rows.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final row = rows[index];
                final receiptId = row['receipt_id'] ?? row['id'];
                final readAt = row['read_at'];

                return ListTile(
                  leading: CircleAvatar(
                    child: Icon(
                      readAt == null
                          ? Icons.notifications_active_outlined
                          : Icons.notifications_none,
                    ),
                  ),
                  title: Text((row['title'] ?? 'Notification').toString()),
                  subtitle: Text((row['message'] ?? '').toString()),
                  onTap: receiptId is int && readAt == null
                      ? () async {
                          try {
                            await _service.markAsRead(receiptId);
                            if (mounted) {
                              setState(() => _future = _service.list());
                            }
                          } catch (_) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Could not update the notification.'),
                                ),
                              );
                            }
                          }
                        }
                      : null,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
