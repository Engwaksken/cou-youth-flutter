import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../core/api/api_config.dart';
import '../core/localization/app_locale_controller.dart';
import '../core/localization/app_strings.dart';
import 'accessibility_screen.dart';
import 'certificates_screen.dart';
import 'chatbot_screen.dart';
import 'guardian_consent_screen.dart';
import 'notification_preferences_screen.dart';
import 'opportunities_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.onExitSession,
  });

  final Future<void> Function() onExitSession;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>>? _profileFuture;
  bool _exiting = false;

  bool get _signedIn =>
      ApiConfig.client.authToken != null &&
      ApiConfig.client.authToken!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _profileFuture = _signedIn ? ApiConfig.client.get('/me') : null;
  }

  void _open(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  Future<void> _refresh() async {
    if (!_signedIn) return;
    setState(() => _profileFuture = ApiConfig.client.get('/me'));
    await _profileFuture;
  }

  Future<void> _exitSession() async {
    if (_exiting) return;
    setState(() => _exiting = true);
    try {
      await widget.onExitSession();
    } finally {
      if (mounted) setState(() => _exiting = false);
    }
  }

  Future<void> _chooseLanguage() async {
    final strings = AppStrings.of(context);
    final current = AppLocaleController.instance.value.languageCode;
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(strings.text('language')),
            ),
            RadioListTile<String>(
              value: 'en',
              groupValue: current,
              title: Text(strings.text('english')),
              onChanged: (value) => Navigator.of(context).pop(value),
            ),
            RadioListTile<String>(
              value: 'lg',
              groupValue: current,
              title: Text(strings.text('luganda')),
              onChanged: (value) => Navigator.of(context).pop(value),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (selected == null || !mounted) return;
    AppLocaleController.instance.setLocale(Locale(selected));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(strings.text('language_updated'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.text('profile'))),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildProfileCard(context),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.smart_toy_outlined),
                    title: Text(strings.text('youth_assistant')),
                    subtitle: const Text('Ask about youth resources and opportunities.'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _open(const ChatbotScreen()),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.work_outline),
                    title: Text(strings.text('opportunities')),
                    subtitle: const Text('Jobs, scholarships, training and volunteering.'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _open(const OpportunitiesScreen()),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    enabled: _signedIn,
                    leading: const Icon(Icons.family_restroom_outlined),
                    title: const Text('Guardian consent'),
                    subtitle: Text(
                      _signedIn
                          ? 'Review teen safeguarding and guardian-consent status.'
                          : 'Sign in to manage guardian consent.',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _signedIn
                        ? () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const GuardianConsentScreen(),
                              ),
                            );
                            if (mounted) await _refresh();
                          }
                        : null,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    enabled: _signedIn,
                    leading: const Icon(Icons.workspace_premium_outlined),
                    title: Text(strings.text('certificates')),
                    subtitle: Text(
                      _signedIn
                          ? 'View your completed course certificates.'
                          : 'Sign in to view certificates.',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _signedIn ? () => _open(const CertificatesScreen()) : null,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    enabled: _signedIn,
                    leading: const Icon(Icons.notifications_outlined),
                    title: Text(strings.text('notification_preferences')),
                    subtitle: Text(
                      _signedIn
                          ? 'Choose the updates you want to receive.'
                          : 'Sign in to manage notification preferences.',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _signedIn
                        ? () => _open(const NotificationPreferencesScreen())
                        : null,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.language_outlined),
                    title: Text(strings.text('language')),
                    subtitle: Text(
                      AppLocaleController.instance.value.languageCode == 'lg'
                          ? strings.text('luganda')
                          : strings.text('english'),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _chooseLanguage,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.accessibility_new_outlined),
                    title: Text(strings.text('accessibility')),
                    subtitle: const Text('Text size, contrast, motion and reading settings.'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _open(const AccessibilityScreen()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _exiting ? null : _exitSession,
              icon: _exiting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(_signedIn ? Icons.logout : Icons.login),
              label: Text(
                _exiting
                    ? 'Please wait...'
                    : _signedIn
                        ? strings.text('sign_out')
                        : strings.text('sign_in_create'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    if (!_signedIn) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(radius: 28, child: Icon(Icons.person_outline, size: 30)),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Guest', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    SizedBox(height: 4),
                    Text('Sign in to view your profile, progress and certificates.'),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          final message = snapshot.error is ApiException
              ? (snapshot.error as ApiException).message
              : 'Your profile could not be loaded.';
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(message),
            ),
          );
        }

        final response = snapshot.data ?? const <String, dynamic>{};
        final user = response['user'] is Map
            ? Map<String, dynamic>.from(response['user'] as Map)
            : <String, dynamic>{};
        final youthProfile = response['youth_profile'] is Map
            ? Map<String, dynamic>.from(response['youth_profile'] as Map)
            : <String, dynamic>{};
        final safeguarding = response['safeguarding'] is Map
            ? Map<String, dynamic>.from(response['safeguarding'] as Map)
            : <String, dynamic>{};

        final consentRequired = safeguarding['guardian_consent_required'] == true;
        final consentStatus = '${safeguarding['guardian_consent_status'] ?? ''}'.trim();
        final verified = safeguarding['safeguarding_verified'] == true;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  child: Text(
                    _initials('${user['name'] ?? 'Youth Member'}'),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user['name'] ?? 'Youth Member'}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      if (user['email'] != null) Text('${user['email']}'),
                      if (youthProfile['age_category'] != null) ...[
                        const SizedBox(height: 6),
                        Chip(
                          visualDensity: VisualDensity.compact,
                          label: Text('${youthProfile['age_category']}'.replaceAll('_', ' ')),
                        ),
                      ],
                      if (consentRequired || verified || consentStatus.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            if (consentRequired)
                              Chip(
                                avatar: const Icon(Icons.family_restroom_outlined, size: 16),
                                label: Text(
                                  consentStatus.isEmpty
                                      ? 'Guardian consent required'
                                      : 'Consent: ${consentStatus.replaceAll('_', ' ')}',
                                ),
                              ),
                            if (verified)
                              const Chip(
                                avatar: Icon(Icons.verified_user_outlined, size: 16),
                                label: Text('Safeguarding verified'),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .toList();
    if (parts.isEmpty) return 'Y';
    return parts.map((part) => part[0].toUpperCase()).join();
  }
}
