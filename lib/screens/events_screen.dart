import 'package:flutter/material.dart';

import '../core/api/api_config.dart';
import '../core/localization/module_strings.dart';
import '../core/theme/app_colors.dart';
import '../features/events/data/event_service.dart';
import '../widgets/youth_screen_scaffold.dart';
import '../widgets/youth_states.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key, this.onOpenDrawer});

  final VoidCallback? onOpenDrawer;

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  late final EventService _service;
  late Future<List<Map<String, dynamic>>> _events;

  @override
  void initState() {
    super.initState();
    _service = EventService(ApiConfig.client);
    _events = _service.list();
  }

  Future<void> _refresh() async {
    final future = _service.list();
    setState(() => _events = future);
    await future;
  }

  String _formatDate(dynamic value) {
    if (value == null) return '';
    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) return value.toString();

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

    return '${parsed.day.toString().padLeft(2, '0')} ${months[parsed.month - 1]} ${parsed.year}';
  }

  @override
  Widget build(BuildContext context) {
    return YouthScreenScaffold(
      title: ModuleStrings.text(context, 'events'),
      subtitle: 'Join worship, fellowship, mission and youth activities.',
      leading: widget.onOpenDrawer == null
          ? null
          : IconButton(
              tooltip: 'Open menu',
              onPressed: widget.onOpenDrawer,
              icon: const Icon(Icons.menu_rounded),
            ),
      child: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primary,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _events,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const YouthLoading(label: 'Loading events…');
            }

            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * .55,
                    child: YouthErrorState(
                      title: ModuleStrings.text(context, 'events_load_failed'),
                      onRetry: _refresh,
                    ),
                  ),
                ],
              );
            }

            final events = snapshot.data ?? const <Map<String, dynamic>>[];
            if (events.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * .55,
                    child: YouthEmptyState(
                      icon: Icons.event_outlined,
                      title: ModuleStrings.text(context, 'no_events'),
                      message: 'Upcoming youth activities will appear here when published.',
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              itemCount: events.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final event = events[index];
                final venue = (event['venue'] ?? '').toString().trim();
                final date = _formatDate(event['starts_at']);
                final title = (event['title'] ??
                        event['name'] ??
                        ModuleStrings.text(context, 'youth_event'))
                    .toString();

                return Card(
                  child: ListTile(
                    minVerticalPadding: 14,
                    leading: Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.event_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    title: Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (date.isNotEmpty)
                            _MetaRow(icon: Icons.calendar_today_outlined, text: date),
                          if (venue.isNotEmpty) ...[
                            const SizedBox(height: 5),
                            _MetaRow(icon: Icons.location_on_outlined, text: venue),
                          ],
                        ],
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textMuted,
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

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}
