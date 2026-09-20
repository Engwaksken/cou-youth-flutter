import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../core/api/api_config.dart';
import '../services/moderation_service.dart';

class SafetyCenterScreen extends StatefulWidget {
  const SafetyCenterScreen({super.key});

  @override
  State<SafetyCenterScreen> createState() => _SafetyCenterScreenState();
}

class _SafetyCenterScreenState extends State<SafetyCenterScreen> {
  final ModerationService _service = ModerationService();
  final _formKey = GlobalKey<FormState>();
  final _reportableId = TextEditingController();
  final _reason = TextEditingController();
  final _details = TextEditingController();

  String _type = 'content';
  bool _busy = false;
  String? _message;
  String? _error;
  late Future<List<Map<String, dynamic>>> _blockedFuture;

  bool get _signedIn =>
      ApiConfig.client.authToken != null &&
      ApiConfig.client.authToken!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _blockedFuture = _signedIn
        ? _service.blocked()
        : Future.value(const <Map<String, dynamic>>[]);
  }

  @override
  void dispose() {
    _reportableId.dispose();
    _reason.dispose();
    _details.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_signedIn) {
      setState(() => _error = 'Please sign in before submitting a safeguarding report.');
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final id = int.tryParse(_reportableId.text.trim());
    if (id == null || id < 1) return;

    setState(() {
      _busy = true;
      _message = null;
      _error = null;
    });

    try {
      final response = await _service.report(
        type: _type,
        id: id,
        reason: _reason.text,
        details: _details.text,
      );
      if (!mounted) return;
      setState(() {
        _message = '${response['message'] ?? 'Report submitted for review.'}';
        _reportableId.clear();
        _reason.clear();
        _details.clear();
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'The report could not be submitted. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _unblock(int userId) async {
    try {
      final response = await _service.unblock(userId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${response['message'] ?? 'User unblocked.'}')),
      );
      setState(() => _blockedFuture = _service.blocked());
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Safety Centre')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Report a safety concern',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Use this form to report inappropriate content, a user, a Life Group, media item or prayer request for safeguarding review.',
                  ),
                  const SizedBox(height: 16),
                  if (_message != null) ...[
                    _StatusBox(message: _message!, success: true),
                    const SizedBox(height: 12),
                  ],
                  if (_error != null) ...[
                    _StatusBox(message: _error!, success: false),
                    const SizedBox(height: 12),
                  ],
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _type,
                          decoration: const InputDecoration(
                            labelText: 'What are you reporting?',
                          ),
                          items: const [
                            DropdownMenuItem(value: 'content', child: Text('Content')),
                            DropdownMenuItem(value: 'user', child: Text('User')),
                            DropdownMenuItem(value: 'life_group', child: Text('Life Group')),
                            DropdownMenuItem(value: 'media_asset', child: Text('Media resource')),
                            DropdownMenuItem(value: 'prayer_request', child: Text('Prayer request')),
                          ],
                          onChanged: _busy
                              ? null
                              : (value) => setState(() => _type = value ?? 'content'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _reportableId,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Item or user ID',
                            helperText: 'Use the ID shown on the relevant item or profile.',
                          ),
                          validator: (value) {
                            final id = int.tryParse((value ?? '').trim());
                            if (id == null || id < 1) return 'Enter a valid ID.';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _reason,
                          maxLength: 120,
                          decoration: const InputDecoration(labelText: 'Reason'),
                          validator: (value) => (value ?? '').trim().isEmpty
                              ? 'Tell us why you are reporting this.'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _details,
                          minLines: 3,
                          maxLines: 6,
                          maxLength: 3000,
                          decoration: const InputDecoration(
                            labelText: 'Additional details (optional)',
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _busy ? null : _submit,
                            icon: _busy
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.report_outlined),
                            label: Text(_busy ? 'Submitting...' : 'Submit report'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Blocked accounts',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 10),
          if (!_signedIn)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Text('Sign in to view and manage blocked accounts.'),
              ),
            )
          else
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _blockedFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Text('Blocked accounts could not be loaded.'),
                    ),
                  );
                }
                final rows = snapshot.data ?? const <Map<String, dynamic>>[];
                if (rows.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Text('You have not blocked any accounts.'),
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final row in rows) ...[
                      Card(
                        child: ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person_off_outlined)),
                          title: Text(
                            '${row['blocked'] is Map ? (row['blocked'] as Map)['name'] ?? 'Blocked user' : 'Blocked user'}',
                          ),
                          subtitle: row['reason'] == null ? null : Text('${row['reason']}'),
                          trailing: TextButton(
                            onPressed: () {
                              final blocked = row['blocked'];
                              final id = blocked is Map
                                  ? int.tryParse('${blocked['id'] ?? ''}')
                                  : int.tryParse('${row['blocked_id'] ?? ''}');
                              if (id != null) _unblock(id);
                            },
                            child: const Text('Unblock'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _StatusBox extends StatelessWidget {
  const _StatusBox({required this.message, required this.success});

  final String message;
  final bool success;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: success ? scheme.primaryContainer : scheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message),
    );
  }
}
