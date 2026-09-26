import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../core/api/api_config.dart';
import '../core/localization/app_locale_controller.dart';
import '../core/localization/app_strings.dart';
import '../core/theme/app_colors.dart';
import '../services/branding_service.dart';
import '../widgets/youth_app_icon.dart';
import '../widgets/youth_screen_scaffold.dart';
import '../widgets/youth_states.dart';
import 'accessibility_screen.dart';
import 'biometric_settings_screen.dart';
import 'certificates_screen.dart';
import 'chatbot_screen.dart';
import 'edit_profile_screen.dart';
import 'guardian_consent_screen.dart';
import 'notification_preferences_screen.dart';
import 'opportunities_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.onExitSession,
    this.onOpenDrawer,
  });

  final Future<void> Function() onExitSession;
  final VoidCallback? onOpenDrawer;

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

  Future<void> _openEditProfile() async {
    if (!_signedIn) {
      _openSignedInOnly(const EditProfileScreen());
      return;
    }

    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const EditProfileScreen()),
    );
    if (changed == true && mounted) {
      await _refresh();
    }
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
              onChanged: (value) => Navigator.of(context).pop(value),
              title: Text(strings.text('english')),
            ),
            RadioListTile<String>(
              value: 'lg',
              groupValue: current,
              onChanged: (value) => Navigator.of(context).pop(value),
              title: Text(strings.text('luganda')),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (selected == null || !mounted) return;
    AppLocaleController.instance.setLocale(Locale(selected));
    if (!mounted) return;
    final updatedStrings = AppStrings.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(updatedStrings.text('language_updated'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final tools = <Widget>[
      YouthAppIcon(
        icon: Icons.edit_outlined,
        label: 'Edit Profile',
        onTap: _openEditProfile,
      ),
      YouthAppIcon(
        icon: Icons.fingerprint_rounded,
        label: 'Fingerprint',
        semanticLabel: 'Fingerprint login settings',
        onTap: () => _openSignedInOnly(const BiometricSettingsScreen()),
      ),
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
            MaterialPageRoute<void>(builder: (_) => const GuardianConsentScreen()),
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

    return YouthScreenScaffold(
      title: strings.text('profile'),
      subtitle: 'Manage your youth account, preferences and participation.',
      leading: widget.onOpenDrawer == null
          ? null
          : IconButton(
              tooltip: 'Open menu',
              onPressed: widget.onOpenDrawer,
              icon: const Icon(Icons.menu_rounded),
            ),
      child: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primary,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
          children: [
            _buildProfileCard(context),
            const SizedBox(height: 22),
            Text(
              'My tools',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
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
            const SizedBox(height: 20),
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
                    : Icon(_signedIn ? Icons.logout_rounded : Icons.login_rounded),
                label: Text(
                  _exiting
                      ? 'Please wait...'
                      : _signedIn
                          ? strings.text('sign_out')
                          : strings.text('sign_in_create'),
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
                backgroundColor: AppColors.primaryLight,
                foregroundColor: AppColors.primary,
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
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Sign in to view and update your profile.',
                      style: TextStyle(color: AppColors.textSecondary),
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
            child: SizedBox(
              height: 150,
              child: YouthLoading(label: 'Loading profile…'),
            ),
          );
        }

        if (snapshot.hasError) {
          final message = snapshot.error is ApiException
              ? (snapshot.error as ApiException).message
              : 'Your profile could not be loaded.';
          return Card(
            child: SizedBox(
              height: 220,
              child: YouthErrorState(message: message, onRetry: _refresh),
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

        final profilePhoto = BrandingService.resolveUrl(
          '${youthProfile['profile_photo'] ?? ''}',
        );

        return FutureBuilder<BrandingData>(
          future: BrandingService.load(),
          builder: (context, brandSnapshot) {
            final fallbackLogo = brandSnapshot.data?.logoUrl;
            final avatarUrl = profilePhoto ?? fallbackLogo;

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.primaryLight,
                      backgroundImage: avatarUrl == null ? null : NetworkImage(avatarUrl),
                      child: avatarUrl == null
                          ? Text(
                              _initials('${user['name'] ?? 'Youth Member'}'),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${user['name'] ?? 'Youth Member'}',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: 'Edit profile',
                                onPressed: _openEditProfile,
                                icon: const Icon(Icons.edit_outlined),
                              ),
                            ],
                          ),
                          if (user['email'] != null)
                            Text(
                              '${user['email']}',
                              style: const TextStyle(color: AppColors.textSecondary),
                            ),
                          if ('${youthProfile['school_institution'] ?? ''}'.trim().isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              '${youthProfile['school_institution']}',
                              style: const TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                          if (youthProfile['age_category'] != null) ...[
                            const SizedBox(height: 8),
                            Chip(
                              visualDensity: VisualDensity.compact,
                              label: Text(
                                '${youthProfile['age_category']}'.replaceAll('_', ' '),
                              ),
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
