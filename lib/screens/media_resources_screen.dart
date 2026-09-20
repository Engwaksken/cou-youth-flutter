import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../services/media_service.dart';

class MediaResourcesScreen extends StatefulWidget {
  const MediaResourcesScreen({super.key});

  @override
  State<MediaResourcesScreen> createState() => _MediaResourcesScreenState();
}

class _MediaResourcesScreenState extends State<MediaResourcesScreen> {
  final MediaService _service = MediaService();
  String? _type;
  late Future<List<Map<String, dynamic>>> _future;

  static const _types = <String?, String>{
    null: 'All',
    'video': 'Video',
    'audio': 'Audio',
    'podcast': 'Podcasts',
    'document': 'Documents',
    'image': 'Images',
  };

  @override
  void initState() {
    super.initState();
    _future = _service.list();
  }

  Future<void> _refresh() async {
    setState(() => _future = _service.list(type: _type));
    await _future;
  }

  void _filter(String? type) {
    setState(() {
      _type = type;
      _future = _service.list(type: type);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Media & Resources')),
      body: Column(
        children: [
          SizedBox(
            height: 64,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              scrollDirection: Axis.horizontal,
              children: [
                for (final item in _types.entries) ...[
                  ChoiceChip(
                    label: Text(item.value),
                    selected: _type == item.key,
                    onSelected: (_) => _filter(item.key),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    final message = snapshot.error is ApiException
                        ? (snapshot.error as ApiException).message
                        : 'Media resources could not be loaded.';
                    return ListView(
                      children: [
                        const SizedBox(height: 120),
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              const Icon(Icons.cloud_off_outlined, size: 44),
                              const SizedBox(height: 12),
                              Text(message, textAlign: TextAlign.center),
                              const SizedBox(height: 12),
                              FilledButton.icon(
                                onPressed: _refresh,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Try again'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  final items = snapshot.data ?? const <Map<String, dynamic>>[];
                  if (items.isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(height: 120),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('No published media resources are available yet.'),
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final type = '${item['type'] ?? 'resource'}';
                      final title = '${item['title'] ?? item['name'] ?? 'Youth resource'}';
                      final description = '${item['description'] ?? item['summary'] ?? ''}'.trim();

                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Icon(_icon(type)),
                          ),
                          title: Text(title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(_label(type)),
                              if (description.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                          isThreeLine: description.isNotEmpty,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showDetails(item),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetails(Map<String, dynamic> item) {
    final title = '${item['title'] ?? item['name'] ?? 'Resource'}';
    final description = '${item['description'] ?? item['summary'] ?? ''}'.trim();
    final url = '${item['url'] ?? item['file_url'] ?? item['source_url'] ?? ''}'.trim();

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(description),
              ],
              if (url.isNotEmpty) ...[
                const SizedBox(height: 14),
                const Text(
                  'Resource link',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                SelectableText(url),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _label(String type) => switch (type) {
        'video' => 'Video',
        'audio' => 'Audio',
        'podcast' => 'Podcast',
        'document' => 'Document',
        'image' => 'Image',
        _ => 'Resource',
      };

  IconData _icon(String type) => switch (type) {
        'video' => Icons.play_circle_outline,
        'audio' => Icons.audiotrack_outlined,
        'podcast' => Icons.podcasts_outlined,
        'document' => Icons.description_outlined,
        'image' => Icons.image_outlined,
        _ => Icons.folder_open_outlined,
      };
}
