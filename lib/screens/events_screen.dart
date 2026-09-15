import 'package:flutter/material.dart';
import '../features/events/data/event_service.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final EventService _service = EventService();
  late Future<List<dynamic>> _events;

  @override
  void initState() {
    super.initState();
    _events = _service.list();
  }

  Future<void> _refresh() async {
    setState(() => _events = _service.list());
    await _events;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Events')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<dynamic>>(
          future: _events,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(children: const [
                SizedBox(height: 120),
                Center(child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Events could not be loaded. Pull down to try again.'),
                )),
              ]);
            }
            final events = snapshot.data ?? const [];
            if (events.isEmpty) {
              return ListView(children: const [
                SizedBox(height: 120),
                Center(child: Text('No upcoming events are available.')),
              ]);
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final event = Map<String, dynamic>.from(events[index] as Map);
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.event),
                    title: Text('${event['name'] ?? event['title'] ?? 'Youth event'}'),
                    subtitle: Text('${event['venue'] ?? ''}${event['starts_at'] != null ? '\n${event['starts_at']}' : ''}'),
                    isThreeLine: event['starts_at'] != null,
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
