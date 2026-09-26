import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../core/localization/app_strings.dart';
import '../core/theme/app_colors.dart';
import '../services/content_service.dart';
import '../widgets/youth_screen_scaffold.dart';
import '../widgets/youth_states.dart';
import 'content_detail_screen.dart';

class YouthHubsScreen extends StatefulWidget {
  const YouthHubsScreen({super.key, this.initialType = 'mission'});

  final String initialType;

  @override
  State<YouthHubsScreen> createState() => _YouthHubsScreenState();
}

class _YouthHubsScreenState extends State<YouthHubsScreen> {
  final ContentService _service = ContentService();
  final TextEditingController _search = TextEditingController();
  late String _type;
  late Future<List<Map<String, dynamic>>> _future;

  static const _types = <String>['mission', 'talent', 'youth_business'];

  @override
  void initState() {
    super.initState();
    _type = _types.contains(widget.initialType) ? widget.initialType : 'mission';
    _future = _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _load() {
    return _service.list(
      type: _type,
      query: _search.text.trim().isEmpty ? null : _search.text.trim(),
      perPage: 50,
    );
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  void _changeType(String type) {
    if (_type == type) return;
    setState(() {
      _type = type;
      _future = _load();
    });
  }

  void _searchNow() {
    FocusScope.of(context).unfocus();
    setState(() => _future = _load());
  }

  int? _asInt(dynamic value) => value is int ? value : int.tryParse(value?.toString() ?? '');

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return YouthScreenScaffold(
      title: strings.text('youth_hubs'),
      subtitle: 'Explore missions, talents and youth-led businesses.',
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
                hintText: strings.text('search_youth_hubs'),
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  tooltip: _search.text.isEmpty ? strings.text('search') : 'Clear',
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
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _HubChip(
                    label: strings.text('missions'),
                    icon: Icons.public_outlined,
                    selected: _type == 'mission',
                    onSelected: () => _changeType('mission'),
                  ),
                  const SizedBox(width: 8),
                  _HubChip(
                    label: strings.text('talent_hub'),
                    icon: Icons.auto_awesome_outlined,
                    selected: _type == 'talent',
                    onSelected: () => _changeType('talent'),
                  ),
                  const SizedBox(width: 8),
                  _HubChip(
                    label: strings.text('youth_businesses'),
                    icon: Icons.storefront_outlined,
                    selected: _type == 'youth_business',
                    onSelected: () => _changeType('youth_business'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            _Header(type: _type),
            const SizedBox(height: 12),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(height: 280, child: YouthLoading(label: 'Loading youth hub content…'));
                }
                if (snapshot.hasError) {
                  final message = snapshot.error is ApiException
                      ? (snapshot.error as ApiException).message
                      : strings.text('youth_hubs_load_failed');
                  return SizedBox(height: 320, child: YouthErrorState(message: message, onRetry: _refresh));
                }
                final items = snapshot.data ?? const <Map<String, dynamic>>[];
                if (items.isEmpty) {
                  return SizedBox(
                    height: 320,
                    child: YouthEmptyState(
                      icon: _iconFor(_type),
                      title: strings.text('no_youth_hub_items'),
                      message: 'New youth hub content will appear here when published.',
                    ),
                  );
                }
                return Column(
                  children: [
                    for (var index = 0; index < items.length; index++) ...[
                      _HubCard(
                        item: items[index],
                        type: _type,
                        onTap: () {
                          final id = _asInt(items[index]['id']);
                          if (id == null) return;
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => ContentDetailScreen(contentId: id, initialContent: items[index]),
                            ),
                          );
                        },
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

  static IconData _iconFor(String type) => switch (type) {
        'mission' => Icons.public_outlined,
        'talent' => Icons.auto_awesome_outlined,
        'youth_business' => Icons.storefront_outlined,
        _ => Icons.article_outlined,
      };
}

class _Header extends StatelessWidget {
  const _Header({required this.type});
  final String type;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final title = switch (type) {
      'mission' => strings.text('missions'),
      'talent' => strings.text('talent_hub'),
      'youth_business' => strings.text('youth_businesses'),
      _ => strings.text('youth_hubs'),
    };
    final subtitle = switch (type) {
      'mission' => strings.text('missions_description'),
      'talent' => strings.text('talent_description'),
      'youth_business' => strings.text('business_description'),
      _ => '',
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(15)),
          child: Icon(_YouthHubsScreenState._iconFor(type), color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, height: 1.4)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _HubChip extends StatelessWidget {
  const _HubChip({required this.label, required this.icon, required this.selected, required this.onSelected});
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? Colors.white : AppColors.primaryDark;
    return ChoiceChip(
      avatar: Icon(icon, size: 18, color: foreground),
      label: Text(
        label,
        style: TextStyle(color: foreground, fontWeight: FontWeight.w700),
      ),
      selected: selected,
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
      onSelected: (_) => onSelected(),
    );
  }
}

class _HubCard extends StatelessWidget {
  const _HubCard({required this.item, required this.type, required this.onTap});
  final Map<String, dynamic> item;
  final String type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = '${item['title'] ?? 'Youth resource'}';
    final summary = _plainText(item['summary'] ?? item['body']);
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
                child: Icon(_YouthHubsScreenState._iconFor(type), color: AppColors.primary),
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

  String _plainText(dynamic value) => '${value ?? ''}'
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .trim();
}
