import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../core/localization/app_strings.dart';
import '../services/content_service.dart';
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
    _type = _types.contains(widget.initialType)
        ? widget.initialType
        : 'mission';
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

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.text('youth_hubs'))),
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
                hintText: strings.text('search_youth_hubs'),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: strings.text('search'),
                  onPressed: _searchNow,
                  icon: const Icon(Icons.arrow_forward),
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
            const SizedBox(height: 20),
            _Header(type: _type),
            const SizedBox(height: 12),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  final message = snapshot.error is ApiException
                      ? (snapshot.error as ApiException).message
                      : strings.text('youth_hubs_load_failed');
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
                    icon: _iconFor(_type),
                    message: strings.text('no_youth_hub_items'),
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
                              builder: (_) => ContentDetailScreen(
                                contentId: id,
                                initialContent: items[index],
                              ),
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

  int? _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  static IconData _iconFor(String type) {
    return switch (type) {
      'mission' => Icons.public_outlined,
      'talent' => Icons.auto_awesome_outlined,
      'youth_business' => Icons.storefront_outlined,
      _ => Icons.article_outlined,
    };
  }
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        if (subtitle.isNotEmpty) ...[const SizedBox(height: 4), Text(subtitle)],
      ],
    );
  }
}

class _HubChip extends StatelessWidget {
  const _HubChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      selected: selected,
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
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  _YouthHubsScreenState._iconFor(type),
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

  String _plainText(dynamic value) {
    return '${value ?? ''}'
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .trim();
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
