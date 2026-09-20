import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../services/content_service.dart';
import 'chatbot_screen.dart';
import 'church_locator_screen.dart';
import 'content_detail_screen.dart';
import 'donation_checkout_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final ContentService _service = ContentService();
  final TextEditingController _search = TextEditingController();

  String? _type;
  late Future<List<Map<String, dynamic>>> _future;

  static const _filters = <String?, String>{
    null: 'All',
    'news': 'News',
    'announcement': 'Announcements',
    'devotion': 'Devotions',
    'opportunity': 'Opportunities',
  };

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
    return _service.list(
      type: _type,
      query: _search.text,
    );
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  void _applyFilter(String? type) {
    setState(() {
      _type = type;
      _future = _load();
    });
  }

  void _searchNow() {
    FocusScope.of(context).unfocus();
    setState(() => _future = _load());
  }

  void _open(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _search,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _searchNow(),
                      decoration: InputDecoration(
                        hintText: 'Search news, devotions and opportunities',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          tooltip: 'Search',
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
                          for (final filter in _filters.entries) ...[
                            ChoiceChip(
                              label: Text(filter.value),
                              selected: _type == filter.key,
                              onSelected: (_) => _applyFilter(filter.key),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Explore more',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 116,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _ModuleCard(
                            icon: Icons.smart_toy_outlined,
                            title: 'Youth Assistant',
                            onTap: () => _open(const ChatbotScreen()),
                          ),
                          _ModuleCard(
                            icon: Icons.location_on_outlined,
                            title: 'Church Locator',
                            onTap: () => _open(const ChurchLocatorScreen()),
                          ),
                          _ModuleCard(
                            icon: Icons.handshake_outlined,
                            title: 'Donate',
                            onTap: () => _open(const DonationCheckoutScreen()),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      _type == null
                          ? 'Latest resources'
                          : _filters[_type] ?? 'Resources',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  final message = snapshot.error is ApiException
                      ? (snapshot.error as ApiException).message
                      : 'Resources could not be loaded. Pull down to try again.';
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_off_outlined, size: 46),
                          const SizedBox(height: 12),
                          Text(message, textAlign: TextAlign.center),
                          const SizedBox(height: 14),
                          FilledButton.icon(
                            onPressed: _refresh,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try again'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final items = snapshot.data ?? const <Map<String, dynamic>>[];
                if (items.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No matching resources are available yet.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final id = _asInt(item['id']);
                      final type = '${item['type'] ?? 'resource'}';
                      final summary = _plainText('${item['summary'] ?? ''}');

                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Icon(_iconForType(type)),
                          ),
                          title: Text('${item['title'] ?? 'Youth resource'}'),
                          subtitle: summary.isEmpty
                              ? Text(_labelForType(type))
                              : Text(
                                  summary,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: id == null
                              ? null
                              : () => _open(
                                    ContentDetailScreen(
                                      contentId: id,
                                      initialContent: item,
                                    ),
                                  ),
                        ),
                      );
                    },
                  ),
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

  String _plainText(String value) {
    return value
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .trim();
  }

  String _labelForType(String type) {
    return switch (type) {
      'news' => 'News',
      'announcement' => 'Announcement',
      'devotion' => 'Devotion',
      'opportunity' => 'Opportunity',
      _ => 'Youth resource',
    };
  }

  IconData _iconForType(String type) {
    return switch (type) {
      'news' => Icons.newspaper_outlined,
      'announcement' => Icons.campaign_outlined,
      'devotion' => Icons.menu_book_outlined,
      'opportunity' => Icons.work_outline,
      _ => Icons.article_outlined,
    };
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: SizedBox(
        width: 132,
        child: Card(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
