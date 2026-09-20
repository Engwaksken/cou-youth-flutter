import 'package:flutter/material.dart';

import '../core/api/api_config.dart';
import '../core/auth/session_store.dart';
import '../screens/login_screen.dart';
import '../services/auth_service.dart';

typedef AuthenticatedBuilder = Widget Function(
  BuildContext context,
  Future<void> Function() exitSession,
);

class AuthGate extends StatefulWidget {
  const AuthGate({
    super.key,
    required this.authenticatedBuilder,
  });

  final AuthenticatedBuilder authenticatedBuilder;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final AuthService _authService;
  bool _checkingSession = true;
  bool _signedIn = false;
  bool _guest = false;

  @override
  void initState() {
    super.initState();
    _authService = AuthService(ApiConfig.client, SessionStore());
    _restore();
  }

  Future<void> _restore() async {
    final restored = await _authService.restoreSession();

    if (!mounted) return;

    setState(() {
      _signedIn = restored;
      _checkingSession = false;
    });
  }

  Future<void> _exitSession() async {
    if (_signedIn) {
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

  @override
  Widget build(BuildContext context) {
    if (_checkingSession) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_signedIn || _guest) {
      return widget.authenticatedBuilder(context, _exitSession);
    }

    return LoginScreen(
      authService: _authService,
      onSignedIn: () {
        setState(() {
          _signedIn = true;
          _guest = false;
        });
      },
      onContinueAsGuest: () {
        setState(() {
          _guest = true;
          _signedIn = false;
        });
      },
    );
  }
}
