import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../core/localization/app_strings.dart';
import '../services/content_service.dart';
import 'content_detail_screen.dart';

class OpportunitiesScreen extends StatefulWidget {
  const OpportunitiesScreen({super.key});

  @override
  State<OpportunitiesScreen> createState() => _OpportunitiesScreenState();
}

class _OpportunitiesScreenState extends State<OpportunitiesScreen> {
  final ContentService _service = ContentService();
  final TextEditingController _search = TextEditingController();

  String? _category;
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _load() {
    final terms = <String>[
      _search.text.trim(),
      if (_category != null) _category!,
    ].where((term) => term.isNotEmpty).join(' ');

    return _service.list(
      type: 'opportunity',
      query: terms.isEmpty ? null : terms,
      perPage: 50,
    );
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  void _applyCategory(String? value) {
    setState(() {
      _category = value;
      _future = _load();
    });
  }

  void _searchNow() {
    FocusScope.of(context).unfocus();
    setState(() => _future = _load());
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  String _plainText(dynamic value) {
    return '${value ?? ''}'
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final categories = <String?, String>{
      null: strings.text('all'),
      'job': strings.text('jobs'),
      'scholarship': strings.text('scholarships'),
      'training': strings.text('training'),
      'volunteer': strings.text('volunteering'),
    };

    return Scaffold(
      appBar: AppBar(title: Text(strings.text('opportunities'))),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _searchNow(),
              decoration: InputDecoration(
                hintText: strings.text('search_opportunities'),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: strings.text('opportunities'),
                  onPressed: _searchNow,
                  icon: const Icon(Icons.arrow_forward),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final entry in categories.entries) ...[
                    ChoiceChip(
                      label: Text(entry.value),
                      selected: _category == entry.key,
                      onSelected: (_) => _applyCategory(entry.key),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              strings.text('latest_opportunities'),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(36),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  final message = snapshot.error is ApiException
                      ? (snapshot.error as ApiException).message
                      : 'Opportunities could not be loaded.';
                  return _StateMessage(
                    icon: Icons.cloud_off_outlined,
                    message: message,
                    actionLabel: strings.text('try_again'),
                    onAction: _refresh,
                  );
                }

                final items = snapshot.data ?? const <Map<String, dynamic>>[];
                if (items.isEmpty) {
                  return _StateMessage(
                    icon: Icons.work_off_outlined,
                    message: strings.text('no_opportunities'),
                  );
                }

                return Column(
                  children: [
                    for (var index = 0; index < items.length; index++) ...[
                      _OpportunityCard(
                        item: items[index],
                        onTap: () {
                          final id = _asInt(items[index]['id']);
                          if (id == null) return;
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => ContentDetailScreen(
                                contentId: id,
                                initialContent: items[index],
                              ),
                            ),
                          );
                        },
                        plainText: _plainText,
                      ),
                      if (index != items.length - 1) const SizedBox(height: 10),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OpportunityCard extends StatelessWidget {
  const _OpportunityCard({
    required this.item,
    required this.onTap,
    required this.plainText,
  });

  final Map<String, dynamic> item;
  final VoidCallback onTap;
  final String Function(dynamic) plainText;

  @override
  Widget build(BuildContext context) {
    final title = '${item['title'] ?? 'Youth opportunity'}';
    final summary = plainText(item['summary'] ?? item['body']);
    final published = '${item['published_at'] ?? ''}'.trim();

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.work_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    if (summary.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        summary,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (published.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.schedule_outlined, size: 16),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              published,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final Future<void> Function()? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 42),
      child: Column(
        children: [
          Icon(icon, size: 48),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.refresh),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
