import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../core/theme/app_colors.dart';
import '../services/notification_preferences_service.dart';
import '../widgets/youth_screen_scaffold.dart';
import '../widgets/youth_states.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key, this.service});

  final NotificationPreferencesService? service;

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  late final NotificationPreferencesService _service;
  Map<String, dynamic> _preferences = <String, dynamic>{};
  bool _loading = true;
  String? _error;
  String? _savingKey;

  static const _labels = <String, String>{
    'in_app': 'In-app notifications',
    'push': 'Push notifications',
    'email': 'Email notifications',
    'events': 'Events',
    'discipleship': 'Discipleship',
    'opportunities': 'Opportunities',
    'donations': 'Donations',
    'life_groups': 'Life Groups',
  };

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? NotificationPreferencesService();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _service.load();
      if (!mounted) return;
      setState(() => _preferences = result);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error =
            'Notification preferences could not be loaded. Please try again.';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _set(String key, bool value) async {
    final previous = _preferences[key];

    setState(() {
      _preferences[key] = value;
      _savingKey = key;
    });

    try {
      final updated = await _service.update(<String, dynamic>{key: value});
      if (!mounted) return;
      setState(() => _preferences.addAll(updated));
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _preferences[key] = previous);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _preferences[key] = previous);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Your preference could not be saved. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _savingKey = null);
    }
  }

  bool _valueFor(String key) {
    final value = _preferences[key];
    if (value is bool) return value;
    if (value is int) return value == 1;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return YouthScreenScaffold(
      title: 'Notification preferences',
      subtitle: 'Choose which youth updates you want to receive.',
      leading: IconButton(
        tooltip: 'Back',
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      child: _loading
          ? const YouthLoading(label: 'Loading preferences…')
          : _error != null
              ? YouthErrorState(message: _error!, onRetry: _load)
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
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
                                Icons.notifications_active_outlined,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Stay connected without unnecessary noise. You can change these choices any time.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Column(
                        children: [
                          for (var index = 0;
                              index < _labels.entries.length;
                              index++) ...[
                            Builder(
                              builder: (context) {
                                final entry = _labels.entries.elementAt(index);
                                return SwitchListTile(
                                  activeThumbColor: AppColors.primary,
                                  secondary: _savingKey == entry.key
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.primary,
                                          ),
                                        )
                                      : Container(
                                          width: 42,
                                          height: 42,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryLight,
                                            borderRadius:
                                                BorderRadius.circular(13),
                                          ),
                                          child: Icon(
                                            _iconFor(entry.key),
                                            color: AppColors.primary,
                                          ),
                                        ),
                                  title: Text(
                                    entry.value,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  value: _valueFor(entry.key),
                                  onChanged: _savingKey == null
                                      ? (value) => _set(entry.key, value)
                                      : null,
                                );
                              },
                            ),
                            if (index != _labels.entries.length - 1)
                              const Divider(height: 1),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  IconData _iconFor(String key) {
    return switch (key) {
      'in_app' => Icons.notifications_outlined,
      'push' => Icons.phone_android_outlined,
      'email' => Icons.email_outlined,
      'events' => Icons.event_outlined,
      'discipleship' => Icons.menu_book_outlined,
      'opportunities' => Icons.work_outline,
      'donations' => Icons.volunteer_activism_outlined,
      'life_groups' => Icons.groups_outlined,
      _ => Icons.tune_rounded,
    };
  }
}
