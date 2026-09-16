import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response['message']?.toString() ??
                'Your prayer request has been submitted safely.',
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

  void _openForm() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                        'Submit a prayer request',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _subject,
                        decoration: const InputDecoration(
                          labelText: 'Subject',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => (value ?? '').trim().isEmpty
                            ? 'Enter a subject.'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _message,
                        minLines: 5,
                        maxLines: 8,
                        decoration: const InputDecoration(
                          labelText: 'Prayer request',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => (value ?? '').trim().isEmpty
                            ? 'Enter your prayer request.'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _visibility,
                        decoration: const InputDecoration(
                          labelText: 'Who can see this?',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'private',
                            child: Text('Private'),
                          ),
                          DropdownMenuItem(
                            value: 'pastoral_team',
                            child: Text('Pastoral team'),
                          ),
                          DropdownMenuItem(
                            value: 'public_anonymous',
                            child: Text('Public, anonymous'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setModalState(() => _visibility = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Sensitive requests may be flagged for safeguarding review so the right support can be provided.',
                      ),
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
                          _submitting ? 'Submitting...' : 'Submit request',
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer & Pastoral Support'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        icon: const Icon(Icons.add),
        label: const Text('Prayer request'),
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
                children: const [
                  SizedBox(height: 120),
                  Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'Prayer requests could not be loaded. Pull down to try again.',
                      ),
                    ),
                  ),
                ],
              );
            }

            final requests = snapshot.data ?? const [];

            if (requests.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: const [
                  SizedBox(height: 80),
                  Icon(Icons.volunteer_activism_outlined, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'You have not submitted any prayer requests yet.',
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
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.volunteer_activism_outlined),
                    ),
                    title: Text(request['subject']?.toString() ?? 'Prayer request'),
                    subtitle: Text(request['message']?.toString() ?? ''),
                    trailing: Chip(
                      label: Text(
                        (request['visibility']?.toString() ?? 'private')
                            .replaceAll('_', ' '),
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
