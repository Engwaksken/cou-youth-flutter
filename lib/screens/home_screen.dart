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
    final columns = youthShortcutColumnCount(context);

    final shortcuts = <Widget>[
      YouthAppIcon(
        icon: Icons.menu_book_outlined,
        label: strings.text('discipleship'),
        onTap: () => _open(context, const CoursesScreen()),
      ),
      YouthAppIcon(
        icon: Icons.event_outlined,
        label: strings.text('events'),
        onTap: () => _open(context, const EventsScreen()),
      ),
      YouthAppIcon(
        icon: Icons.location_on_outlined,
        label: strings.text('church_locator'),
        onTap: () => _open(context, const ChurchLocatorScreen()),
      ),
      YouthAppIcon(
        icon: Icons.groups_2_outlined,
        label: strings.text('life_groups'),
        onTap: () => _open(context, const LifeGroupsScreen()),
      ),
      YouthAppIcon(
        icon: Icons.volunteer_activism_outlined,
        label: strings.text('prayer'),
        onTap: () => _open(context, const PrayerScreen()),
      ),
      YouthAppIcon(
        icon: Icons.handshake_outlined,
        label: strings.text('donate'),
        onTap: () => _open(context, const DonationCheckoutScreen()),
      ),
      YouthAppIcon(
        icon: Icons.folder_open_outlined,
        label: strings.text('media_resources'),
        onTap: () => _open(context, const MediaResourcesScreen()),
      ),
      YouthAppIcon(
        icon: Icons.work_outline,
        label: strings.text('opportunities'),
        onTap: () => _open(context, const OpportunitiesScreen()),
      ),
      YouthAppIcon(
        icon: Icons.public_outlined,
        label: strings.text('missions'),
        onTap: () => _open(
          context,
          const YouthHubsScreen(initialType: 'mission'),
        ),
      ),
      YouthAppIcon(
        icon: Icons.auto_awesome_outlined,
        label: strings.text('talent_hub'),
        onTap: () => _open(
          context,
          const YouthHubsScreen(initialType: 'talent'),
        ),
      ),
      YouthAppIcon(
        icon: Icons.storefront_outlined,
        label: strings.text('youth_businesses'),
        onTap: () => _open(
          context,
          const YouthHubsScreen(initialType: 'youth_business'),
        ),
      ),
      YouthAppIcon(
        icon: Icons.shield_outlined,
        label: strings.text('safe_support'),
        onTap: () => _open(context, const SafetyCenterScreen()),
      ),
      YouthAppIcon(
        icon: Icons.smart_toy_outlined,
        label: strings.text('youth_assistant'),
        onTap: () => _open(context, const ChatbotScreen()),
      ),
      YouthAppIcon(
        icon: Icons.notifications_active_outlined,
        label: strings.text('notifications'),
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
      title: strings.text('welcome'),
      subtitle: 'Connect, grow in faith and discover youth opportunities.',
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
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.church_outlined,
                    color: AppColors.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Church of Uganda Youth',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        strings.text('tagline'),
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
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: Text(
                  strings.text('quick_access'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              Text(
                columns == 4 ? '4 per row' : 'Accessible layout',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: youthShortcutGridDelegate(context),
            itemCount: shortcuts.length,
            itemBuilder: (context, index) => shortcuts[index],
          ),
          const SizedBox(height: 18),
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.primaryLight,
                foregroundColor: AppColors.primary,
                child: Icon(Icons.shield_outlined),
              ),
              title: const Text(
                'Safe and inclusive youth community',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: const Text(
                'Prayer, pastoral support, safeguarding and accessibility are built into the platform.',
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
