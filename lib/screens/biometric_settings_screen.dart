import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../services/biometric_auth_service.dart';
import '../widgets/youth_screen_scaffold.dart';

class BiometricSettingsScreen extends StatefulWidget {
  const BiometricSettingsScreen({super.key});

  @override
  State<BiometricSettingsScreen> createState() => _BiometricSettingsScreenState();
}

class _BiometricSettingsScreenState extends State<BiometricSettingsScreen> {
  final BiometricAuthService _biometrics = BiometricAuthService();

  bool _loading = true;
  bool _available = false;
  bool _enabled = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final available = await _biometrics.isAvailable();
    final enabled = await _biometrics.isEnabled();
    if (!mounted) return;
    setState(() {
      _available = available;
      _enabled = available && enabled;
      _loading = false;
    });
  }

  Future<void> _setEnabled(bool value) async {
    if (_saving) return;

    if (!_available) {
      _show('Fingerprint or biometric authentication is not configured on this device.');
      return;
    }

    setState(() => _saving = true);

    try {
      if (value) {
        final authenticated = await _biometrics.authenticate(
          reason: 'Confirm your fingerprint or biometrics to enable biometric login.',
        );
        if (!authenticated) {
          if (mounted) _show('Biometric verification was not completed.');
          return;
        }
      }

      await _biometrics.setEnabled(value);
      if (!mounted) return;
      setState(() => _enabled = value);
      _show(value
          ? 'Fingerprint login enabled.'
          : 'Fingerprint login disabled.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _show(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return YouthScreenScaffold(
      title: 'Fingerprint Login',
      subtitle: 'Use your device biometrics for faster and secure sign in.',
      leading: IconButton(
        tooltip: 'Back',
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      child: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.fingerprint_rounded,
                            size: 42,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _available
                              ? 'Biometric security is available'
                              : 'Biometric security is unavailable',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _available
                              ? 'When enabled, the app will ask for your fingerprint or other enrolled biometric before restoring your saved session.'
                              : 'Add a fingerprint or other biometric in your phone settings first, then return here to enable biometric login.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Card(
                  child: SwitchListTile.adaptive(
                    value: _enabled,
                    onChanged: !_available || _saving ? null : _setEnabled,
                    activeColor: AppColors.primary,
                    secondary: const Icon(
                      Icons.fingerprint_rounded,
                      color: AppColors.primary,
                    ),
                    title: const Text(
                      'Enable fingerprint login',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    subtitle: const Text(
                      'Your fingerprint stays on your device. The app only receives whether biometric verification succeeded.',
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
