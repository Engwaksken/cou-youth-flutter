import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../core/api/api_config.dart';
import '../core/localization/app_locale_controller.dart';
import '../core/localization/app_strings.dart';
import '../widgets/youth_app_icon.dart';
import 'accessibility_screen.dart';
import 'certificates_screen.dart';
import 'chatbot_screen.dart';
import 'guardian_consent_screen.dart';
import 'notification_preferences_screen.dart';
import 'opportunities_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.onExitSession});

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
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  void _openSignedInOnly(Widget screen) {
    if (!_signedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to use this feature.')),
      );
      return;
    }
    _open(screen);
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
            RadioGroup<String>(
              groupValue: current,
              onChanged: (value) => Navigator.of(context).pop(value),
              child: Column(
                children: [
                  RadioListTile<String>(
                    value: 'en',
                    title: Text(strings.text('english')),
                  ),
                  RadioListTile<String>(
                    value: 'lg',
                    title: Text(strings.text('luganda')),
                  ),
                ],
              ),
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
    final tools = <Widget>[
      YouthAppIcon(
        icon: Icons.smart_toy_outlined,
        label: strings.text('youth_assistant'),
        onTap: () => _open(const ChatbotScreen()),
      ),
      YouthAppIcon(
        icon: Icons.work_outline,
        label: strings.text('opportunities'),
        onTap: () => _open(const OpportunitiesScreen()),
      ),
      YouthAppIcon(
        icon: Icons.family_restroom_outlined,
        label: 'Guardian',
        semanticLabel: 'Guardian consent',
        onTap: () async {
          if (!_signedIn) {
            _openSignedInOnly(const GuardianConsentScreen());
            return;
          }
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const GuardianConsentScreen(),
            ),
          );
          if (mounted) await _refresh();
        },
      ),
      YouthAppIcon(
        icon: Icons.workspace_premium_outlined,
        label: strings.text('certificates'),
        onTap: () => _openSignedInOnly(const CertificatesScreen()),
      ),
      YouthAppIcon(
        icon: Icons.notifications_outlined,
        label: 'Alerts',
        semanticLabel: strings.text('notification_preferences'),
        onTap: () => _openSignedInOnly(const NotificationPreferencesScreen()),
      ),
      YouthAppIcon(
        icon: Icons.language_outlined,
        label: strings.text('language'),
        onTap: _chooseLanguage,
      ),
      YouthAppIcon(
        icon: Icons.accessibility_new_outlined,
        label: strings.text('accessibility'),
        onTap: () => _open(const AccessibilityScreen()),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(strings.text('profile'))),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildProfileCard(context),
            const SizedBox(height: 20),
            Text(
              'My tools',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: youthShortcutGridDelegate(
                context,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: tools.length,
              itemBuilder: (context, index) => tools[index],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
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
                  textAlign: TextAlign.center,
                ),
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
              CircleAvatar(
                radius: 28,
                child: Icon(Icons.person_outline, size: 30),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Guest',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Sign in to view your profile, progress and certificates.',
                    ),
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

        final consentRequired =
            safeguarding['guardian_consent_required'] == true;
        final consentStatus = '${safeguarding['guardian_consent_status'] ?? ''}'
            .trim();
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
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (user['email'] != null)
                        Text(
                          '${user['email']}',
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                      if (youthProfile['age_category'] != null) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          children: [
                            Chip(
                              visualDensity: VisualDensity.compact,
                              label: Text(
                                '${youthProfile['age_category']}'.replaceAll(
                                  '_',
                                  ' ',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (consentRequired ||
                          verified ||
                          consentStatus.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            if (consentRequired)
                              Chip(
                                avatar: const Icon(
                                  Icons.family_restroom_outlined,
                                  size: 16,
                                ),
                                label: Text(
                                  consentStatus.isEmpty
                                      ? 'Guardian consent required'
                                      : 'Consent: ${consentStatus.replaceAll('_', ' ')}',
                                ),
                              ),
                            if (verified)
                              const Chip(
                                avatar: Icon(
                                  Icons.verified_user_outlined,
                                  size: 16,
                                ),
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
