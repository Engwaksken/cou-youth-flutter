import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../core/localization/app_strings.dart';
import '../core/theme/app_colors.dart';
import '../services/content_service.dart';
import '../widgets/youth_screen_scaffold.dart';
import '../widgets/youth_states.dart';
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
    return _service.list(type: 'opportunity', query: terms.isEmpty ? null : terms, perPage: 50);
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

  int? _asInt(dynamic value) => value is int ? value : int.tryParse(value?.toString() ?? '');

  String _plainText(dynamic value) => '${value ?? ''}'
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .trim();

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

    return YouthScreenScaffold(
      title: strings.text('opportunities'),
      subtitle: 'Find jobs, training, scholarships and ways to serve.',
      leading: IconButton(
        tooltip: 'Back',
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      child: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primary,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
          children: [
            TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _searchNow(),
              decoration: InputDecoration(
                hintText: strings.text('search_opportunities'),
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  tooltip: _search.text.isEmpty ? 'Search' : 'Clear',
                  onPressed: () {
                    if (_search.text.isEmpty) {
                      _searchNow();
                    } else {
                      _search.clear();
                      _searchNow();
                    }
                  },
                  icon: Icon(_search.text.isEmpty ? Icons.arrow_forward_rounded : Icons.close_rounded),
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
                      label: Text(
                        entry.value,
                        style: TextStyle(
                          color: _category == entry.key ? Colors.white : AppColors.primaryDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      selected: _category == entry.key,
                      selectedColor: AppColors.primary,
                      checkmarkColor: Colors.white,
                      onSelected: (_) => _applyCategory(entry.key),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text(
              strings.text('latest_opportunities'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(height: 280, child: YouthLoading(label: 'Loading opportunities…'));
                }
                if (snapshot.hasError) {
                  final message = snapshot.error is ApiException
                      ? (snapshot.error as ApiException).message
                      : 'Opportunities could not be loaded.';
                  return SizedBox(height: 320, child: YouthErrorState(message: message, onRetry: _refresh));
                }
                final items = snapshot.data ?? const <Map<String, dynamic>>[];
                if (items.isEmpty) {
                  return SizedBox(
                    height: 320,
                    child: YouthEmptyState(
                      icon: Icons.work_off_outlined,
                      title: strings.text('no_opportunities'),
                      message: 'New youth opportunities will appear here when published.',
                    ),
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
                              builder: (_) => ContentDetailScreen(contentId: id, initialContent: items[index]),
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
  const _OpportunityCard({required this.item, required this.onTap, required this.plainText});
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
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(15)),
                child: const Icon(Icons.work_outline, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
                    if (summary.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(summary, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textSecondary, height: 1.4)),
                    ],
                    if (published.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(children: [
                        const Icon(Icons.schedule_outlined, size: 16, color: AppColors.primary),
                        const SizedBox(width: 5),
                        Expanded(child: Text(published, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))),
                      ]),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
