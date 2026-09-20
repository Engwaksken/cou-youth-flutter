import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../core/localization/app_strings.dart';
import '../services/prayer_service.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  final PrayerService _service = PrayerService();
  final _formKey = GlobalKey<FormState>();
  final _subject = TextEditingController();
  final _message = TextEditingController();

  String _visibility = 'private';
  bool _submitting = false;
  late Future<List<Map<String, dynamic>>> _requests;

  @override
  void initState() {
    super.initState();
    _requests = _service.mine();
  }

  @override
  void dispose() {
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() => _requests = _service.mine());
    await _requests;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    try {
      final response = await _service.submit(
        subject: _subject.text,
        message: _message.text,
        visibility: _visibility,
      );

      if (!mounted) return;

      _subject.clear();
      _message.clear();

      final strings = AppStrings.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response['message']?.toString() ?? strings.text('prayer_submitted'),
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
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _visibilityLabel(AppStrings strings, String visibility) {
    return switch (visibility) {
      'pastoral_team' => strings.text('pastoral_team'),
      'public_anonymous' => strings.text('public_anonymous'),
      _ => strings.text('private'),
    };
  }

  void _openForm() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final strings = AppStrings.of(context);
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        strings.text('submit_prayer_request'),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _subject,
                        decoration: InputDecoration(
                          labelText: strings.text('subject'),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) => (value ?? '').trim().isEmpty
                            ? strings.text('enter_subject')
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _message,
                        minLines: 5,
                        maxLines: 8,
                        decoration: InputDecoration(
                          labelText: strings.text('prayer_request_label'),
                          alignLabelWithHint: true,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) => (value ?? '').trim().isEmpty
                            ? strings.text('enter_prayer_request')
                            : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _visibility,
                        decoration: InputDecoration(
                          labelText: strings.text('who_can_see'),
                          border: const OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'private',
                            child: Text(strings.text('private')),
                          ),
                          DropdownMenuItem(
                            value: 'pastoral_team',
                            child: Text(strings.text('pastoral_team')),
                          ),
                          DropdownMenuItem(
                            value: 'public_anonymous',
                            child: Text(strings.text('public_anonymous')),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setModalState(() => _visibility = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      Text(strings.text('prayer_safeguarding_note')),
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed: _submitting
                            ? null
                            : () async {
                                await _submit();
                                if (mounted && !_submitting) {
                                  Navigator.of(context).pop();
                                }
                              },
                        icon: _submitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.send_outlined),
                        label: Text(
                          _submitting
                              ? strings.text('submitting')
                              : strings.text('submit_request'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.text('prayer_support')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        icon: const Icon(Icons.add),
        label: Text(strings.text('prayer_request')),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _requests,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(strings.text('prayer_load_failed')),
                    ),
                  ),
                ],
              );
            }

            final requests = snapshot.data ?? const [];

            if (requests.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 80),
                  const Icon(Icons.volunteer_activism_outlined, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    strings.text('no_prayer_requests'),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final request = requests[index];
                final visibility = request['visibility']?.toString() ?? 'private';

                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.volunteer_activism_outlined),
                    ),
                    title: Text(
                      request['subject']?.toString() ??
                          strings.text('prayer_request'),
                    ),
                    subtitle: Text(request['message']?.toString() ?? ''),
                    trailing: Chip(
                      label: Text(_visibilityLabel(strings, visibility)),
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
