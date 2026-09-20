import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../services/notification_preferences_service.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({
    super.key,
    NotificationPreferencesService? service,
  }) : _service = service;

  final NotificationPreferencesService? _service;

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
    _service = widget._service ?? NotificationPreferencesService();
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
        _error = 'Notification preferences could not be loaded. Please try again.';
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
          content: Text('Your preference could not be saved. Please try again.'),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Notification preferences')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.notifications_off_outlined, size: 48),
                        const SizedBox(height: 12),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _load,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try again'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    for (final entry in _labels.entries)
                      SwitchListTile(
                        secondary: _savingKey == entry.key
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(_iconFor(entry.key)),
                        title: Text(entry.value),
                        value: _valueFor(entry.key),
                        onChanged: _savingKey == null
                            ? (value) => _set(entry.key, value)
                            : null,
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
      _ => Icons.tune,
    };
  }
}
