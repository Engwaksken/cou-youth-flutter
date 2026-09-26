import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../services/connectivity_service.dart';

class ConnectivityGate extends StatefulWidget {
  const ConnectivityGate({super.key, required this.child});

  final Widget child;

  @override
  State<ConnectivityGate> createState() => _ConnectivityGateState();
}

class _ConnectivityGateState extends State<ConnectivityGate> {
  StreamSubscription<bool>? _subscription;
  bool? _online;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _subscription = ConnectivityService.instance.statusChanges.listen((online) {
      if (!mounted) return;
      setState(() {
        _online = online;
        _checking = false;
      });
    });
  }

  Future<void> _checkConnectivity() async {
    final online = await ConnectivityService.instance.isOnline;
    if (!mounted) return;
    setState(() {
      _online = online;
      _checking = false;
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const _ConnectivityCheckingScreen();
    }

    if (_online != true) {
      return _OfflineRequiredScreen(onRetry: _checkConnectivity);
    }

    return widget.child;
  }
}

class _ConnectivityCheckingScreen extends StatelessWidget {
  const _ConnectivityCheckingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.6,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _OfflineRequiredScreen extends StatelessWidget {
  const _OfflineRequiredScreen({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E1EE)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 24,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2EDF9),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.wifi_off_rounded,
                        size: 34,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Internet connection required',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Turn on mobile data or connect to Wi-Fi to continue using the COU Youth app.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.5,
                        height: 1.55,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => AppSettings.openAppSettings(
                          type: AppSettingsType.wifi,
                        ),
                        icon: const Icon(Icons.wifi_rounded),
                        label: const Text('Open Wi-Fi settings'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => AppSettings.openAppSettings(),
                        icon: const Icon(Icons.settings_rounded),
                        label: const Text('Open device settings'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('I am connected - retry'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
