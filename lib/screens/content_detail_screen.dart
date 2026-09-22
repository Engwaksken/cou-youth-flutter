import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../core/theme/app_colors.dart';
import '../services/content_service.dart';
import '../widgets/youth_screen_scaffold.dart';
import '../widgets/youth_states.dart';

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

  void _retry() {
    setState(() => _future = _service.show(widget.contentId));
  }

  @override
  Widget build(BuildContext context) {
    final initialType = '${widget.initialContent?['type'] ?? 'Resource'}'
        .replaceAll('_', ' ');

    return YouthScreenScaffold(
      title: initialType,
      subtitle: 'Youth news, resources and ministry information.',
      leading: IconButton(
        tooltip: 'Back',
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      child: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        initialData: widget.initialContent,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              snapshot.data == null) {
            return const YouthLoading(label: 'Loading resource…');
          }

          if (snapshot.hasError && snapshot.data == null) {
            final message = snapshot.error is ApiException
                ? (snapshot.error as ApiException).message
                : 'This resource could not be loaded.';
            return YouthErrorState(message: message, onRetry: _retry);
          }

          final item = snapshot.data ?? widget.initialContent ?? const {};
          final title = '${item['title'] ?? 'Youth resource'}';
          final summary = _plainText('${item['summary'] ?? ''}');
          final body = _plainText('${item['body'] ?? item['content'] ?? ''}');
          final type = '${item['type'] ?? 'resource'}'.replaceAll('_', ' ');
          final published = item['published_at'] ?? item['created_at'];

          return SelectionArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            _iconForType('${item['type'] ?? 'resource'}'),
                            color: AppColors.primary,
                            size: 27,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Chip(label: Text(type)),
                            if (published != null)
                              Chip(
                                avatar: const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 16,
                                ),
                                label: Text(_formatDate('$published')),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          title,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                                height: 1.25,
                              ),
                        ),
                        if (summary.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Text(
                            summary,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 18),
                        Text(
                          body.isEmpty
                              ? 'No additional details are available.'
                              : body,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.textPrimary,
                                height: 1.65,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  IconData _iconForType(String type) {
    return switch (type) {
      'news' => Icons.newspaper_outlined,
      'announcement' => Icons.campaign_outlined,
      'devotion' => Icons.menu_book_outlined,
      'opportunity' => Icons.work_outline,
      'mission' => Icons.public_outlined,
      'talent' => Icons.auto_awesome_outlined,
      'youth_business' => Icons.storefront_outlined,
      _ => Icons.article_outlined,
    };
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
