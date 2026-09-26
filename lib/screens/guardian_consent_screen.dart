import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../core/theme/app_colors.dart';
import '../services/guardian_consent_service.dart';
import '../widgets/youth_screen_scaffold.dart';
import '../widgets/youth_states.dart';

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
    if (!_formKey.currentState!.validate() || !_confirmed || _submitting) {
      return;
    }

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
        SnackBar(
          content: Text(
            '${response['message'] ?? 'Guardian consent submitted.'}',
          ),
        ),
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
    return YouthScreenScaffold(
      title: 'Guardian consent',
      subtitle: 'Manage safeguarding consent for eligible teen accounts.',
      leading: IconButton(
        tooltip: 'Back',
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      child: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primary,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
          children: [
            FutureBuilder<Map<String, dynamic>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 280,
                    child: YouthLoading(label: 'Loading safeguarding status…'),
                  );
                }

                if (snapshot.hasError) {
                  final message = snapshot.error is ApiException
                      ? (snapshot.error as ApiException).message
                      : 'Guardian consent status could not be loaded.';
                  return SizedBox(
                    height: 320,
                    child: YouthErrorState(message: message, onRetry: _refresh),
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
                            Row(
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
                                    Icons.verified_user_outlined,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Safeguarding status',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              required
                                  ? 'Guardian consent is required for this teen account.'
                                  : 'Guardian consent is not required for this age category.',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                            if (status.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Chip(
                                avatar: const Icon(
                                  Icons.family_restroom_outlined,
                                  size: 16,
                                ),
                                label: Text(
                                  'Consent: ${status.replaceAll('_', ' ')}',
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  verified
                                      ? Icons.check_circle_outline_rounded
                                      : Icons.schedule_outlined,
                                  size: 18,
                                  color: verified
                                      ? AppColors.success
                                      : AppColors.warning,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    verified
                                        ? 'Safeguarding verification is complete.'
                                        : 'Safeguarding verification is pending or incomplete.',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Guardian name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter the guardian name.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _relationship,
                decoration: const InputDecoration(
                  labelText: 'Relationship',
                  prefixIcon: Icon(Icons.family_restroom_outlined),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter the relationship.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Guardian phone',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter the guardian phone number.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Guardian email (optional)',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
                value: _confirmed,
                onChanged: (value) =>
                    setState(() => _confirmed = value ?? false),
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
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.verified_user_outlined),
                label: Text(
                  _submitting ? 'Submitting...' : 'Submit for review',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
