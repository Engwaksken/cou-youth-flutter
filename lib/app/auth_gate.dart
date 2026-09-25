import 'dart:async';

import 'package:flutter/material.dart';

import '../core/api/api_config.dart';
import '../core/auth/session_store.dart';
import '../core/theme/app_colors.dart';
import '../screens/login_screen.dart';
import '../services/auth_service.dart';
import '../services/push_notification_service.dart';

typedef AuthenticatedBuilder =
    Widget Function(BuildContext context, Future<void> Function() exitSession);

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.authenticatedBuilder});

  final AuthenticatedBuilder authenticatedBuilder;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final AuthService _authService;
  late final PushNotificationService _pushNotifications;
  bool _checkingSession = true;
  bool _signedIn = false;
  bool _guest = false;

  @override
  void initState() {
    super.initState();
    _authService = AuthService(ApiConfig.client, SessionStore());
    _pushNotifications = PushNotificationService();
    _restore();
  }

  Future<void> _restore() async {
    final restored = await _authService.restoreSession();

    if (restored) {
      await _pushNotifications.start();
    }

    if (!mounted) return;

    setState(() {
      _signedIn = restored;
      _checkingSession = false;
    });
  }

  Future<void> _exitSession() async {
    if (_signedIn) {
      await _pushNotifications.stop();

      try {
        await _authService.logout();
      } catch (_) {
        ApiConfig.client.clearAuthToken();
        await _authService.sessionStore.clear();
      }
    } else {
      ApiConfig.client.clearAuthToken();
      await _authService.sessionStore.clear();
    }

    if (!mounted) return;

    setState(() {
      _signedIn = false;
      _guest = false;
    });
  }

  void _signedInSuccessfully() {
    if (!mounted) return;

    setState(() {
      _signedIn = true;
      _guest = false;
    });

    unawaited(_pushNotifications.start());
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingSession) {
      return const _AppSplash();
    }

    if (_signedIn || _guest) {
      return widget.authenticatedBuilder(context, _exitSession);
    }

    return LoginScreen(
      authService: _authService,
      onSignedIn: _signedInSuccessfully,
      onContinueAsGuest: () {
        setState(() {
          _guest = true;
          _signedIn = false;
        });
      },
    );
  }
}

class _AppSplash extends StatelessWidget {
  const _AppSplash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/branding/splash_logo.png',
                    width: 96,
                    height: 96,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/branding/logo.png',
                        width: 88,
                        height: 88,
                        fit: BoxFit.contain,
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'COU Youth Platform',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Faith • Community • Opportunity',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
