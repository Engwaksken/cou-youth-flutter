import 'package:flutter/material.dart';

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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onOpenDrawer});

  final VoidCallback? onOpenDrawer;

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
      leading: onOpenDrawer == null
          ? null
          : IconButton(
              tooltip: 'Open menu',
              onPressed: onOpenDrawer,
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
          const _WelcomePanel(),
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
  const _WelcomePanel();

  @override
  Widget build(BuildContext context) {
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
                    Icons.church_outlined,
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
                        'Welcome',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Connecting young people to faith and opportunity.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.45,
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
