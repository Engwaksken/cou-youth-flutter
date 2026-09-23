import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../core/api/api_config.dart';
import '../core/theme/app_colors.dart';
import '../features/events/data/event_service.dart';
import '../widgets/youth_screen_scaffold.dart';
import '../widgets/youth_states.dart';

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({
    super.key,
    required this.eventId,
    this.initialEvent,
  });

  final int eventId;
  final Map<String, dynamic>? initialEvent;

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late final EventService _service;
  late Future<Map<String, dynamic>> _future;
  bool _registering = false;

  bool get _signedIn =>
      ApiConfig.client.authToken != null &&
      ApiConfig.client.authToken!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _service = EventService(ApiConfig.client);
    _future = _load();
  }

  Future<Map<String, dynamic>> _load() async {
    final response = await _service.show(widget.eventId);
    if (response['data'] is Map) {
      return Map<String, dynamic>.from(response['data'] as Map);
    }
    return response;
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  Future<void> _register() async {
    if (!_signedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to register for this event.')),
      );
      return;
    }
    if (_registering) return;
    setState(() => _registering = true);
    try {
      final response = await _service.register(widget.eventId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${response['message'] ?? 'Event registration completed.'}')),
      );
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _registering = false);
    }
  }

  String _text(dynamic value) => '${value ?? ''}'.trim();

  String _plain(dynamic value) => _text(value)
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .trim();

  String _formatDate(dynamic value) {
    final parsed = DateTime.tryParse(_text(value));
    if (parsed == null) return _text(value);
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hour = parsed.hour % 12 == 0 ? 12 : parsed.hour % 12;
    final minute = parsed.minute.toString().padLeft(2, '0');
    final period = parsed.hour >= 12 ? 'PM' : 'AM';
    return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year} • $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return YouthScreenScaffold(
      title: 'Event details',
      subtitle: 'View event information and registration details.',
      leading: IconButton(
        tooltip: 'Back',
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      child: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primary,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _future,
          initialData: widget.initialEvent,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && snapshot.data == null) {
              return const YouthLoading(label: 'Loading event…');
            }
            if (snapshot.hasError && snapshot.data == null) {
              final message = snapshot.error is ApiException
                  ? (snapshot.error as ApiException).message
                  : 'This event could not be loaded.';
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * .6,
                    child: YouthErrorState(message: message, onRetry: _refresh),
                  ),
                ],
              );
            }

            final event = snapshot.data ?? widget.initialEvent ?? <String, dynamic>{};
            final title = _text(event['title']).isEmpty ? 'Youth Event' : _text(event['title']);
            final description = _plain(event['description'] ?? event['summary']);
            final startsAt = _formatDate(event['starts_at']);
            final endsAt = _formatDate(event['ends_at']);
            final venue = _text(event['venue']);
            final address = _text(event['address']);

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.event_outlined, color: AppColors.primary, size: 30),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        if (description.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            description,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              height: 1.55,
                            ),
                          ),
                        ],
                        if (startsAt.isNotEmpty) ...[
                          const SizedBox(height: 18),
                          _DetailRow(icon: Icons.calendar_today_outlined, label: 'Starts', value: startsAt),
                        ],
                        if (endsAt.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _DetailRow(icon: Icons.schedule_outlined, label: 'Ends', value: endsAt),
                        ],
                        if (venue.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _DetailRow(icon: Icons.location_on_outlined, label: 'Venue', value: venue),
                        ],
                        if (address.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _DetailRow(icon: Icons.map_outlined, label: 'Address', value: address),
                        ],
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _registering ? null : _register,
                            icon: _registering
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.how_to_reg_outlined),
                            label: Text(_registering ? 'Registering...' : 'Register for event'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}
