import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../core/api/api_config.dart';
import '../services/life_group_service.dart';

class LifeGroupsScreen extends StatefulWidget {
  const LifeGroupsScreen({super.key});

  @override
  State<LifeGroupsScreen> createState() => _LifeGroupsScreenState();
}

class _LifeGroupsScreenState extends State<LifeGroupsScreen> {
  final LifeGroupService _service = LifeGroupService();
  late Future<List<Map<String, dynamic>>> _future;
  int? _joiningId;

  bool get _signedIn =>
      ApiConfig.client.authToken != null &&
      ApiConfig.client.authToken!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _future = _service.list();
  }

  Future<void> _refresh() async {
    setState(() => _future = _service.list());
    await _future;
  }

  Future<void> _join(Map<String, dynamic> group) async {
    final id = int.tryParse('${group['id'] ?? ''}');
    if (id == null) return;

    if (!_signedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to join a Life Group.')),
      );
      return;
    }

    setState(() => _joiningId = id);

    try {
      final response = await _service.join(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${response['message'] ?? 'You have joined the Life Group.'}',
          ),
        ),
      );
      await _refresh();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'The Life Group could not be joined. Please try again.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _joiningId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Life Groups')),
      body: RefreshIndicator(
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
                  : 'Life Groups could not be loaded.';
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(child: Text(message)),
                  ),
                ],
              );
            }

            final groups = snapshot.data ?? const <Map<String, dynamic>>[];
            if (groups.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No active Life Groups are available yet.'),
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: groups.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final group = groups[index];
                final id = int.tryParse('${group['id'] ?? ''}');
                final members =
                    int.tryParse('${group['members_count'] ?? 0}') ?? 0;
                final limit =
                    int.tryParse('${group['member_limit'] ?? 0}') ?? 0;
                final full = limit > 0 && members >= limit;
                final joining = id != null && _joiningId == id;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CircleAvatar(
                              child: Icon(Icons.groups_2_outlined),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${group['name'] ?? group['title'] ?? 'Life Group'}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  if (group['description'] != null) ...[
                                    const SizedBox(height: 6),
                                    Text('${group['description']}'),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Chip(
                              avatar: const Icon(
                                Icons.people_outline,
                                size: 18,
                              ),
                              label: Text(
                                limit > 0
                                    ? '$members / $limit members'
                                    : '$members members',
                              ),
                            ),
                            if (group['meeting_day'] != null)
                              Chip(
                                avatar: const Icon(
                                  Icons.event_repeat_outlined,
                                  size: 18,
                                ),
                                label: Text('${group['meeting_day']}'),
                              ),
                            if (group['meeting_time'] != null)
                              Chip(
                                avatar: const Icon(
                                  Icons.schedule_outlined,
                                  size: 18,
                                ),
                                label: Text('${group['meeting_time']}'),
                              ),
                          ],
                        ),
                        if (group['location'] != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 18),
                              const SizedBox(width: 6),
                              Expanded(child: Text('${group['location']}')),
                            ],
                          ),
                        ],
                        const SizedBox(height: 14),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton.icon(
                            onPressed: full || joining
                                ? null
                                : () => _join(group),
                            icon: joining
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.group_add_outlined),
                            label: Text(
                              full
                                  ? 'Group full'
                                  : joining
                                  ? 'Joining...'
                                  : 'Join Life Group',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
