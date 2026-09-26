import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../core/theme/app_colors.dart';
import '../services/media_service.dart';
import '../widgets/youth_screen_scaffold.dart';
import '../widgets/youth_states.dart';

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
    return YouthScreenScaffold(
      title: 'Media & Resources',
      subtitle: 'Watch, listen and explore youth ministry resources.',
      leading: IconButton(
        tooltip: 'Back',
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 66,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              color: AppColors.primary,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const YouthLoading(label: 'Loading media resources…');
                  }

                  if (snapshot.hasError) {
                    final message = snapshot.error is ApiException
                        ? (snapshot.error as ApiException).message
                        : 'Media resources could not be loaded.';
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * .55,
                          child: YouthErrorState(message: message, onRetry: _refresh),
                        ),
                      ],
                    );
                  }

                  final items = snapshot.data ?? const <Map<String, dynamic>>[];
                  if (items.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(
                          height: 420,
                          child: YouthEmptyState(
                            icon: Icons.folder_open_outlined,
                            title: 'No published resources yet',
                            message: 'New videos, audio, podcasts and documents will appear here.',
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final type = '${item['type'] ?? 'resource'}';
                      final title =
                          '${item['title'] ?? item['name'] ?? 'Youth resource'}';
                      final description =
                          '${item['description'] ?? item['summary'] ?? ''}'.trim();

                      return Card(
                        child: ListTile(
                          minVerticalPadding: 12,
                          leading: Container(
                            width: 48,
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(_icon(type), color: AppColors.primary),
                          ),
                          title: Text(
                            title,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _label(type),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (description.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          isThreeLine: description.isNotEmpty,
                          trailing: const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textMuted,
                          ),
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
    final url = '${item['url'] ?? item['file_url'] ?? item['source_url'] ?? ''}'
        .trim();

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
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _icon('${item['type'] ?? 'resource'}'),
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ],
              ),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
              if (url.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Resource link',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                SelectableText(
                  url,
                  style: const TextStyle(color: AppColors.primary),
                ),
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
