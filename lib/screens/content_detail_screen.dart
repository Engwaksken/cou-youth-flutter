import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../services/content_service.dart';

class ContentDetailScreen extends StatefulWidget {
  const ContentDetailScreen({
    super.key,
    required this.contentId,
    this.initialContent,
  });

  final int contentId;
  final Map<String, dynamic>? initialContent;

  @override
  State<ContentDetailScreen> createState() => _ContentDetailScreenState();
}

class _ContentDetailScreenState extends State<ContentDetailScreen> {
  final ContentService _service = ContentService();
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.show(widget.contentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.initialContent?['type'] ?? 'Resource'}'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        initialData: widget.initialContent,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError && snapshot.data == null) {
            final message = snapshot.error is ApiException
                ? (snapshot.error as ApiException).message
                : 'This resource could not be loaded.';
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(message, textAlign: TextAlign.center),
              ),
            );
          }

          final item = snapshot.data ?? widget.initialContent ?? const {};
          final title = '${item['title'] ?? 'Youth resource'}';
          final summary = _plainText('${item['summary'] ?? ''}');
          final body = _plainText('${item['body'] ?? item['content'] ?? ''}');
          final type = '${item['type'] ?? 'resource'}'.replaceAll('_', ' ');
          final published = item['published_at'] ?? item['created_at'];

          return SelectionArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(label: Text(type)),
                    if (published != null)
                      Chip(
                        avatar: const Icon(Icons.calendar_today_outlined, size: 16),
                        label: Text(_formatDate('$published')),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                if (summary.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    summary,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          height: 1.5,
                        ),
                  ),
                ],
                const SizedBox(height: 20),
                Text(
                  body.isEmpty ? 'No additional details are available.' : body,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.65,
                      ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _plainText(String value) {
    return value
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();
  }

  String _formatDate(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) return value;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
