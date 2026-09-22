import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../core/api/api_config.dart';
import '../core/theme/app_colors.dart';
import '../services/life_group_service.dart';
import '../widgets/youth_screen_scaffold.dart';
import '../widgets/youth_states.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The Life Group could not be joined. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _joiningId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return YouthScreenScaffold(
      title: 'Life Groups',
      subtitle: 'Find a small group for fellowship, discipleship and community.',
      leading: IconButton(
        tooltip: 'Back',
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      child: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primary,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const YouthLoading(label: 'Loading Life Groups…');
            }

            if (snapshot.hasError) {
              final message = snapshot.error is ApiException
                  ? (snapshot.error as ApiException).message
                  : 'Life Groups could not be loaded.';
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

            final groups = snapshot.data ?? const <Map<String, dynamic>>[];
            if (groups.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(
                    height: 420,
                    child: YouthEmptyState(
                      icon: Icons.groups_2_outlined,
                      title: 'No active Life Groups yet',
                      message: 'New fellowship groups will appear here when available.',
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              itemCount: groups.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final group = groups[index];
                final id = int.tryParse('${group['id'] ?? ''}');
                final members = int.tryParse('${group['members_count'] ?? 0}') ?? 0;
                final limit = int.tryParse('${group['member_limit'] ?? 0}') ?? 0;
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
                            Container(
                              width: 48,
                              height: 48,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Icon(
                                Icons.groups_2_outlined,
                                color: AppColors.primary,
                              ),
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
                                        ?.copyWith(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                  if (group['description'] != null) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      '${group['description']}',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        height: 1.4,
                                      ),
                                    ),
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
                              avatar: const Icon(Icons.people_outline, size: 18),
                              label: Text(
                                limit > 0 ? '$members / $limit members' : '$members members',
                              ),
                            ),
                            if (group['meeting_day'] != null)
                              Chip(
                                avatar: const Icon(Icons.event_repeat_outlined, size: 18),
                                label: Text('${group['meeting_day']}'),
                              ),
                            if (group['meeting_time'] != null)
                              Chip(
                                avatar: const Icon(Icons.schedule_outlined, size: 18),
                                label: Text('${group['meeting_time']}'),
                              ),
                          ],
                        ),
                        if (group['location'] != null) ...[
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '${group['location']}',
                                  style: const TextStyle(color: AppColors.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 14),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton.icon(
                            onPressed: full || joining ? null : () => _join(group),
                            icon: joining
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
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
