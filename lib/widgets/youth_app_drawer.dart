import 'package:flutter/material.dart';

import '../core/api/api_config.dart';
import '../core/theme/app_colors.dart';
import '../screens/accessibility_screen.dart';
import '../screens/chatbot_screen.dart';
import '../screens/church_locator_screen.dart';
import '../screens/donation_checkout_screen.dart';
import '../screens/life_groups_screen.dart';
import '../screens/media_resources_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/opportunities_screen.dart';
import '../screens/prayer_screen.dart';
import '../screens/safety_center_screen.dart';
import '../services/branding_service.dart';

class YouthAppDrawer extends StatelessWidget {
  const YouthAppDrawer({
    super.key,
    required this.currentIndex,
    required this.onSelectMainTab,
  });

  final int currentIndex;
  final ValueChanged<int> onSelectMainTab;

  void _selectMain(BuildContext context, int index) {
    Navigator.of(context).pop();
    onSelectMainTab(index);
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  Future<Map<String, dynamic>?> _profile() async {
    final token = ApiConfig.client.authToken;
    if (token == null || token.trim().isEmpty) return null;
    try {
      return await ApiConfig.client.get('/me');
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.primary,
      child: SafeArea(
        child: Column(
          children: [
            FutureBuilder<BrandingData>(
              future: BrandingService.load(),
              builder: (context, brandSnapshot) {
                final brand = brandSnapshot.data ?? BrandingData.fallback;
                return FutureBuilder<Map<String, dynamic>?>(
                  future: _profile(),
                  builder: (context, profileSnapshot) {
                    final response = profileSnapshot.data;
                    final user = response?['user'] is Map
                        ? Map<String, dynamic>.from(response!['user'] as Map)
                        : <String, dynamic>{};
                    final youthProfile = response?['youth_profile'] is Map
                        ? Map<String, dynamic>.from(response!['youth_profile'] as Map)
                        : <String, dynamic>{};
                    final profilePhoto = BrandingService.resolveUrl(
                      '${youthProfile['profile_photo'] ?? ''}',
                    );
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                      child: Row(
                        children: [
                          _DrawerAvatar(
                            profilePhoto: profilePhoto,
                            logoUrl: brand.logoUrl,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${user['name'] ?? brand.shortName}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${user['email'] ?? 'Faith • Community • Opportunity'}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFFE7DFF5),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            const Divider(height: 1, color: Color(0x33FFFFFF)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  const _SectionLabel('Main'),
                  _DrawerItem(icon: Icons.home_outlined, label: 'Home', selected: currentIndex == 0, onTap: () => _selectMain(context, 0)),
                  _DrawerItem(icon: Icons.explore_outlined, label: 'Discover', selected: currentIndex == 1, onTap: () => _selectMain(context, 1)),
                  const _SectionLabel('Faith'),
                  _DrawerItem(icon: Icons.menu_book_outlined, label: 'Discipleship', selected: currentIndex == 2, onTap: () => _selectMain(context, 2)),
                  _DrawerItem(icon: Icons.groups_2_outlined, label: 'Life Groups', onTap: () => _open(context, const LifeGroupsScreen())),
                  _DrawerItem(icon: Icons.volunteer_activism_outlined, label: 'Prayer & Support', onTap: () => _open(context, const PrayerScreen())),
                  const _SectionLabel('Community'),
                  _DrawerItem(icon: Icons.event_outlined, label: 'Events', selected: currentIndex == 3, onTap: () => _selectMain(context, 3)),
                  _DrawerItem(icon: Icons.location_on_outlined, label: 'Church Locator', onTap: () => _open(context, const ChurchLocatorScreen())),
                  _DrawerItem(icon: Icons.folder_open_outlined, label: 'Media & Resources', onTap: () => _open(context, const MediaResourcesScreen())),
                  _DrawerItem(icon: Icons.work_outline, label: 'Opportunities', onTap: () => _open(context, const OpportunitiesScreen())),
                  const _SectionLabel('Support'),
                  _DrawerItem(icon: Icons.handshake_outlined, label: 'Donate', onTap: () => _open(context, const DonationCheckoutScreen())),
                  _DrawerItem(icon: Icons.smart_toy_outlined, label: 'Youth Assistant', onTap: () => _open(context, const ChatbotScreen())),
                  _DrawerItem(icon: Icons.shield_outlined, label: 'Safety Centre', onTap: () => _open(context, const SafetyCenterScreen())),
                  const _SectionLabel('Account'),
                  _DrawerItem(icon: Icons.notifications_none_rounded, label: 'Notifications', onTap: () => _open(context, const NotificationsScreen())),
                  _DrawerItem(icon: Icons.person_outline, label: 'Profile', selected: currentIndex == 4, onTap: () => _selectMain(context, 4)),
                  _DrawerItem(icon: Icons.accessibility_new_outlined, label: 'Accessibility', onTap: () => _open(context, const AccessibilityScreen())),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerAvatar extends StatelessWidget {
  const _DrawerAvatar({this.profilePhoto, this.logoUrl});
  final String? profilePhoto;
  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    final imageUrl = profilePhoto ?? logoUrl;
    return CircleAvatar(
      radius: 27,
      backgroundColor: Colors.white,
      child: imageUrl == null
          ? const Icon(Icons.church_outlined, color: AppColors.primary, size: 28)
          : ClipOval(
              child: Image.network(
                imageUrl,
                width: 54,
                height: 54,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.church_outlined,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
            ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 6),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: const Color(0xFFD9CFF0),
              fontWeight: FontWeight.w800,
              letterSpacing: .8,
            ),
      ),
    );
  }
}

class _DrawerItem extends StatefulWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  State<_DrawerItem> createState() => _DrawerItemState();
}

class _DrawerItemState extends State<_DrawerItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected || _hovered;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Semantics(
        button: true,
        selected: widget.selected,
        label: widget.label,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
          child: ListTile(
            selected: widget.selected,
            tileColor: active ? Colors.white.withValues(alpha: .16) : Colors.transparent,
            selectedTileColor: Colors.white.withValues(alpha: .20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            leading: Icon(widget.icon, color: Colors.white),
            title: Text(
              widget.label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: widget.selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
            trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white70),
            onTap: widget.onTap,
          ),
        ),
      ),
    );
  }
}
