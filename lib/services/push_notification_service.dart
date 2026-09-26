import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'device_registration_service.dart';

class PushNotificationService {
  PushNotificationService({DeviceRegistrationService? devices})
    : _devices = devices ?? DeviceRegistrationService();

  final DeviceRegistrationService _devices;

  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  String? _registeredToken;
  bool _started = false;

  bool get isStarted => _started;

  Future<void> start() async {
    if (_started || kIsWeb) return;

    final platform = _platformName();
    if (platform == null) return;

    try {
      await Firebase.initializeApp();

      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        return;
      }

      final token = await messaging.getToken();
      if (token != null && token.trim().isNotEmpty) {
        await _registerToken(platform, token);
      }

      _tokenSubscription = messaging.onTokenRefresh.listen((token) async {
        try {
          await _registerToken(platform, token);
        } catch (error, stackTrace) {
          debugPrint('Push token refresh registration failed: $error');
          debugPrintStack(stackTrace: stackTrace);
        }
      });

      _foregroundSubscription = FirebaseMessaging.onMessage.listen((message) {
        final title = message.notification?.title ?? 'Notification received';
        debugPrint('Foreground push: $title');
      });

      _started = true;
    } catch (error, stackTrace) {
      // Firebase configuration is intentionally optional during development.
      // The app should remain usable until google-services / iOS Firebase
      // configuration has been added to the project.
      debugPrint('Push notifications are not configured: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> stop() async {
    await _tokenSubscription?.cancel();
    await _foregroundSubscription?.cancel();
    _tokenSubscription = null;
    _foregroundSubscription = null;

    final token = _registeredToken;
    if (token != null && token.trim().isNotEmpty) {
      try {
        await _devices.unregister(token);
      } catch (error) {
        debugPrint('Push token unregister failed: $error');
      }
    }

    _registeredToken = null;
    _started = false;
  }

  Future<void> _registerToken(String platform, String token) async {
    final cleanToken = token.trim();
    if (cleanToken.isEmpty || cleanToken == _registeredToken) return;

    await _devices.register(
      platform: platform,
      pushToken: cleanToken,
      deviceName: 'COU Youth Flutter',
    );

    _registeredToken = cleanToken;
  }

  String? _platformName() {
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      _ => null,
    };
  }
}
