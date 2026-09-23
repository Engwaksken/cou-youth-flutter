import 'package:flutter/material.dart';

import '../core/api/api_config.dart';
import '../core/localization/app_strings.dart';
import '../core/theme/app_colors.dart';
import '../widgets/youth_app_icon.dart';
import '../widgets/youth_screen_scaffold.dart';
import 'accessibility_screen.dart';
import 'chatbot_screen.dart';
import 'church_locator_screen.dart';
import 'courses_screen.dart';
import 'donation_checkout_screen.dart';
import 'events_screen.dart';
import 'life_groups_screen.dart';
import 'media_resources_screen.dart';
import 'notifications_screen.dart';
import 'opportunities_screen.dart';
import 'prayer_screen.dart';
import 'safety_center_screen.dart';
import 'youth_hubs_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onOpenDrawer});

  final VoidCallback? onOpenDrawer;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _firstName;

  bool get _signedIn =>
      ApiConfig.client.authToken != null &&
      ApiConfig.client.authToken!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadMemberName();
  }

  Future<void> _loadMemberName() async {
    if (!_signedIn) return;
    try {
      final response = await ApiConfig.client.get('/me');
      final user = response['user'] is Map
          ? Map<String, dynamic>.from(response['user'] as Map)
          : <String, dynamic>{};
      final fullName = '${user['name'] ?? ''}'.trim();
      if (fullName.isEmpty || !mounted) return;
      final first = fullName.split(RegExp(r'\s+')).first;
      setState(() => _firstName = first);
    } catch (_) {
      // Personalisation is optional; keep Home usable if profile loading fails.
    }
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    final shortcuts = <Widget>[
      YouthAppIcon(
        icon: Icons.menu_book_outlined,
        label: 'Discipleship',
        onTap: () => _open(context, const CoursesScreen()),
      ),
      YouthAppIcon(
        icon: Icons.event_outlined,
        label: 'Events',
        onTap: () => _open(context, const EventsScreen()),
      ),
      YouthAppIcon(
        icon: Icons.location_on_outlined,
        label: 'Church Locator',
        onTap: () => _open(context, const ChurchLocatorScreen()),
      ),
      YouthAppIcon(
        icon: Icons.groups_2_outlined,
        label: 'Life Groups',
        onTap: () => _open(context, const LifeGroupsScreen()),
      ),
      YouthAppIcon(
        icon: Icons.volunteer_activism_outlined,
        label: 'Prayer',
        onTap: () => _open(context, const PrayerScreen()),
      ),
      YouthAppIcon(
        icon: Icons.handshake_outlined,
        label: 'Donate',
        onTap: () => _open(context, const DonationCheckoutScreen()),
      ),
      YouthAppIcon(
        icon: Icons.folder_open_outlined,
        label: 'Media',
        onTap: () => _open(context, const MediaResourcesScreen()),
      ),
      YouthAppIcon(
        icon: Icons.work_outline,
        label: 'Opportunities',
        onTap: () => _open(context, const OpportunitiesScreen()),
      ),
      YouthAppIcon(
        icon: Icons.public_outlined,
        label: 'Missions',
        onTap: () => _open(
          context,
          const YouthHubsScreen(initialType: 'mission'),
        ),
      ),
      YouthAppIcon(
        icon: Icons.auto_awesome_outlined,
        label: 'Talent Hub',
        onTap: () => _open(
          context,
          const YouthHubsScreen(initialType: 'talent'),
        ),
      ),
      YouthAppIcon(
        icon: Icons.storefront_outlined,
        label: 'Youth Business',
        onTap: () => _open(
          context,
          const YouthHubsScreen(initialType: 'youth_business'),
        ),
      ),
      YouthAppIcon(
        icon: Icons.shield_outlined,
        label: 'Safety',
        onTap: () => _open(context, const SafetyCenterScreen()),
      ),
      YouthAppIcon(
        icon: Icons.smart_toy_outlined,
        label: 'Youth Assistant',
        onTap: () => _open(context, const ChatbotScreen()),
      ),
      YouthAppIcon(
        icon: Icons.notifications_active_outlined,
        label: 'Notifications',
        onTap: () => _open(context, const NotificationsScreen()),
      ),
      YouthAppIcon(
        icon: Icons.accessibility_new_outlined,
        label: 'Accessibility',
        semanticLabel: 'Open accessibility settings',
        onTap: () => _open(context, const AccessibilityScreen()),
      ),
    ];

    return YouthScreenScaffold(
      title: 'COU Youth',
      subtitle: 'Faith • Community • Opportunity',
      leading: widget.onOpenDrawer == null
          ? null
          : IconButton(
              tooltip: 'Open menu',
              onPressed: widget.onOpenDrawer,
              icon: const Icon(Icons.menu_rounded),
            ),
      actions: [
        IconButton(
          tooltip: 'Accessibility',
          onPressed: () => _open(context, const AccessibilityScreen()),
          icon: const Icon(Icons.accessibility_new_outlined, color: Colors.white),
        ),
        IconButton(
          tooltip: strings.text('notifications'),
          onPressed: () => _open(context, const NotificationsScreen()),
          icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          _WelcomePanel(firstName: _firstName),
          const SizedBox(height: 24),
          Text(
            'Quick Access',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Explore the platform.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: youthShortcutGridDelegate(context),
            itemCount: shortcuts.length,
            itemBuilder: (context, index) => shortcuts[index],
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: AppColors.primary,
                child: Icon(Icons.shield_outlined),
              ),
              title: const Text(
                'Safe community',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: const Text(
                'Prayer, safeguarding and accessibility support.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _open(context, const SafetyCenterScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel({this.firstName});

  final String? firstName;

  static const _verses = <({String text, String reference})>[
    (
      text: 'Let no man despise thy youth; but be thou an example of the believers.',
      reference: '1 Timothy 4:12',
    ),
    (
      text: 'Trust in the Lord with all thine heart; and lean not unto thine own understanding.',
      reference: 'Proverbs 3:5',
    ),
    (
      text: 'I can do all things through Christ which strengtheneth me.',
      reference: 'Philippians 4:13',
    ),
    (
      text: 'Thy word is a lamp unto my feet, and a light unto my path.',
      reference: 'Psalm 119:105',
    ),
    (
      text: 'Be strong and of a good courage; be not afraid.',
      reference: 'Joshua 1:9',
    ),
    (
      text: 'Rejoice evermore. Pray without ceasing.',
      reference: '1 Thessalonians 5:16–17',
    ),
    (
      text: 'We walk by faith, not by sight.',
      reference: '2 Corinthians 5:7',
    ),
  ];

  ({String text, String reference}) get _todayVerse {
    final now = DateTime.now();
    final day = DateTime(now.year, now.month, now.day)
        .difference(DateTime(now.year, 1, 1))
        .inDays;
    return _verses[day % _verses.length];
  }

  @override
  Widget build(BuildContext context) {
    final verse = _todayVerse;
    final name = firstName?.trim();
    final welcome = name == null || name.isEmpty ? 'Welcome' : 'Welcome, $name';

    return Semantics(
      header: true,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderStrong),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: .09),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -26,
              child: Container(
                width: 116,
                height: 116,
                decoration: const BoxDecoration(
                  color: AppColors.primaryFaint,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: 24,
              bottom: -34,
              child: Container(
                width: 78,
                height: 78,
                decoration: const BoxDecoration(
                  color: AppColors.secondaryLight,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Row(
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
                  child: const Icon(
                    Icons.auto_stories_outlined,
                    color: AppColors.primary,
                    size: 29,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        welcome,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Daily Bible Verse',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '“${verse.text}”',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.5,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        verse.reference,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
