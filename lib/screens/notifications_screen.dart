import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _service = NotificationService();
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.list();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final rows = snapshot.data ?? const [];
          if (rows.isEmpty) return const Center(child: Text('You have no notifications.'));
          return ListView.separated(
            itemCount: rows.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final row = Map<String, dynamic>.from(rows[index] as Map);
              return ListTile(
                leading: Icon(row['read_at'] == null ? Icons.notifications_active_outlined : Icons.notifications_none),
                title: Text('${row['title'] ?? 'Notification'}'),
                subtitle: Text('${row['message'] ?? ''}'),
                onTap: () async {
                  final id = row['receipt_id'] ?? row['id'];
                  if (id != null) await _service.markRead(id as int);
                  if (mounted) setState(() => _future = _service.list());
                },
              );
            },
          );
        },
      ),
    );
  }
}
