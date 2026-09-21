import 'package:flutter/material.dart';

import '../core/api/api_config.dart';
import '../core/localization/module_strings.dart';
import '../features/events/data/event_service.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

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
    return Scaffold(
      appBar: AppBar(title: Text(ModuleStrings.text(context, 'events'))),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _events,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        ModuleStrings.text(context, 'events_load_failed'),
                        textAlign: TextAlign.center,
                      ),
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
                  const SizedBox(height: 120),
                  Center(child: Text(ModuleStrings.text(context, 'no_events'))),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final event = events[index];
                final venue = (event['venue'] ?? '').toString().trim();
                final date = _formatDate(event['starts_at']);

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.event_outlined),
                      ),
                      title: Text(
                        (event['title'] ??
                                event['name'] ??
                                ModuleStrings.text(context, 'youth_event'))
                            .toString(),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (date.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Flexible(child: Text(date)),
                              ],
                            ),
                          ],
                          if (venue.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Flexible(child: Text(venue)),
                              ],
                            ),
                          ],
                        ],
                      ),
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
