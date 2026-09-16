import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../services/auth_recovery_service.dart';

class AuthRecoveryScreen extends StatefulWidget {
  const AuthRecoveryScreen({
    super.key,
    required this.onSignedIn,
  });

  final VoidCallback onSignedIn;

  @override
  State<AuthRecoveryScreen> createState() => _AuthRecoveryScreenState();
}

class _AuthRecoveryScreenState extends State<AuthRecoveryScreen> {
  final AuthRecoveryService _service = AuthRecoveryService();
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();

  bool _otpMode = true;
  bool _codeSent = false;
  bool _busy = false;
  bool _obscurePassword = true;
  String? _message;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    if (!_email.text.contains('@')) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
      _message = null;
    });

    try {
      if (_otpMode) {
        await _service.requestOtp(_email.text);
      } else {
        await _service.requestPasswordReset(_email.text);
      }

      if (mounted) {
        setState(() {
          _codeSent = true;
          _message = 'A verification code has been sent if the account is eligible.';
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'The request could not be completed. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify() async {
    if (_code.text.trim().isEmpty) {
      setState(() => _error = 'Enter the verification code.');
      return;
    }

    if (!_otpMode && _password.text.length < 8) {
      setState(() => _error = 'Use a new password of at least 8 characters.');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
      _message = null;
    });

    try {
      if (_otpMode) {
        await _service.verifyOtp(_email.text, _code.text);
        if (mounted) widget.onSignedIn();
      } else {
        await _service.resetPassword(
          _email.text,
          _code.text,
          _password.text,
        );
        if (mounted) {
          setState(() {
            _message = 'Password updated. You can now sign in with your new password.';
            _codeSent = false;
            _code.clear();
            _password.clear();
          });
        }
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Verification failed. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account access')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment<bool>(
                value: true,
                icon: Icon(Icons.password_outlined),
                label: Text('OTP sign in'),
              ),
              ButtonSegment<bool>(
                value: false,
                icon: Icon(Icons.lock_reset_outlined),
                label: Text('Reset password'),
              ),
            ],
            selected: {_otpMode},
            onSelectionChanged: _busy
                ? null
                : (selection) {
                    setState(() {
                      _otpMode = selection.first;
                      _codeSent = false;
                      _code.clear();
                      _password.clear();
                      _error = null;
                      _message = null;
                    });
                  },
          ),
          const SizedBox(height: 24),
          Text(
            _otpMode ? 'Sign in with a one-time code' : 'Reset your password',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _otpMode
                ? 'Request a secure one-time code sent to your registered email address.'
                : 'Request a reset code, then enter the code and your new password.',
          ),
          const SizedBox(height: 20),
          if (_error != null) ...[
            _StatusBox(text: _error!, error: true),
            const SizedBox(height: 12),
          ],
          if (_message != null) ...[
            _StatusBox(text: _message!),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _email,
            enabled: !_codeSent,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email address',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          if (_codeSent) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _code,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Verification code',
                prefixIcon: Icon(Icons.pin_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            if (!_otpMode) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'New password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () => setState(
                      () => _obscurePassword = !_obscurePassword,
                    ),
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              ),
            ],
          ],
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _busy ? null : (_codeSent ? _verify : _requestCode),
            icon: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(_codeSent ? Icons.verified_outlined : Icons.send_outlined),
            label: Text(
              _busy
                  ? 'Please wait...'
                  : _codeSent
                      ? (_otpMode ? 'Verify and sign in' : 'Update password')
                      : 'Send code',
            ),
          ),
          if (_codeSent)
            TextButton(
              onPressed: _busy
                  ? null
                  : () {
                      setState(() {
                        _codeSent = false;
                        _code.clear();
                      });
                    },
              child: const Text('Use a different email address'),
            ),
        ],
      ),
    );
  }
}

class _StatusBox extends StatelessWidget {
  const _StatusBox({
    required this.text,
    this.error = false,
  });

  final String text;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: error ? scheme.errorContainer : scheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text),
    );
  }
}
