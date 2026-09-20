import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../core/api/api_config.dart';
import 'accessibility_screen.dart';
import 'certificates_screen.dart';
import 'chatbot_screen.dart';
import 'notification_preferences_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>>? _profileFuture;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
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
                    title: const Text('Youth Assistant'),
                    subtitle: const Text('Ask about youth resources and opportunities.'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _open(const ChatbotScreen()),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    enabled: _signedIn,
                    leading: const Icon(Icons.workspace_premium_outlined),
                    title: const Text('Certificates'),
                    subtitle: Text(
                      _signedIn
                          ? 'View your completed course certificates.'
                          : 'Sign in to view certificates.',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _signedIn
                        ? () => _open(const CertificatesScreen())
                        : null,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    enabled: _signedIn,
                    leading: const Icon(Icons.notifications_outlined),
                    title: const Text('Notification preferences'),
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
                    leading: const Icon(Icons.accessibility_new_outlined),
                    title: const Text('Accessibility'),
                    subtitle: const Text('Text size, contrast, motion and reading settings.'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _open(const AccessibilityScreen()),
                  ),
                ],
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
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
                        Text('${user['email']}'),
                      if (youthProfile['age_category'] != null) ...[
                        const SizedBox(height: 6),
                        Chip(
                          visualDensity: VisualDensity.compact,
                          label: Text(
                            '${youthProfile['age_category']}'
                                .replaceAll('_', ' '),
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
