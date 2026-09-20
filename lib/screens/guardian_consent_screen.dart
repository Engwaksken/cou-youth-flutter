import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../services/guardian_consent_service.dart';

class GuardianConsentScreen extends StatefulWidget {
  const GuardianConsentScreen({super.key});

  @override
  State<GuardianConsentScreen> createState() => _GuardianConsentScreenState();
}

class _GuardianConsentScreenState extends State<GuardianConsentScreen> {
  final _service = GuardianConsentService();
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _relationship = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();

  late Future<Map<String, dynamic>> _future;
  bool _submitting = false;
  bool _confirmed = false;

  @override
  void initState() {
    super.initState();
    _future = _service.status();
  }

  @override
  void dispose() {
    _name.dispose();
    _relationship.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() => _future = _service.status());
    await _future;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || !_confirmed || _submitting) return;

    setState(() => _submitting = true);
    try {
      final response = await _service.submit(
        guardianName: _name.text,
        relationship: _relationship.text,
        guardianPhone: _phone.text,
        guardianEmail: _email.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${response['message'] ?? 'Guardian consent submitted.'}')),
      );
      await _refresh();
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guardian consent')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FutureBuilder<Map<String, dynamic>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  final message = snapshot.error is ApiException
                      ? (snapshot.error as ApiException).message
                      : 'Guardian consent status could not be loaded.';
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Text(message),
                    ),
                  );
                }

                final data = snapshot.data ?? const <String, dynamic>{};
                final required = data['required'] == true;
                final verified = data['safeguarding_verified'] == true;
                final consent = data['consent'] is Map
                    ? Map<String, dynamic>.from(data['consent'] as Map)
                    : null;
                final status = '${consent?['status'] ?? ''}'.trim();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Safeguarding status',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 10),
                            Text(required
                                ? 'Guardian consent is required for this teen account.'
                                : 'Guardian consent is not required for this age category.'),
                            if (status.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Chip(label: Text('Consent: ${status.replaceAll('_', ' ')}')),
                            ],
                            const SizedBox(height: 6),
                            Text(verified
                                ? 'Safeguarding verification is complete.'
                                : 'Safeguarding verification is pending or incomplete.'),
                          ],
                        ),
                      ),
                    ),
                    if (required && status != 'approved') ...[
                      const SizedBox(height: 16),
                      _buildForm(),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Guardian details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Guardian name'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter the guardian name.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _relationship,
                decoration: const InputDecoration(labelText: 'Relationship'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter the relationship.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Guardian phone'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter the guardian phone number.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Guardian email (optional)'),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _confirmed,
                onChanged: (value) => setState(() => _confirmed = value ?? false),
                title: const Text(
                  'I confirm that the guardian has provided these details and consented to this submission.',
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _confirmed && !_submitting ? _submit : null,
                icon: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.verified_user_outlined),
                label: Text(_submitting ? 'Submitting...' : 'Submit for review'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
