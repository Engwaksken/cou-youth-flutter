import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../services/auth_recovery_service.dart';
import '../widgets/brand_header.dart';

class AuthRecoveryScreen extends StatefulWidget {
  const AuthRecoveryScreen({super.key, required this.onSignedIn});

  final VoidCallback onSignedIn;

  @override
  State<AuthRecoveryScreen> createState() => _AuthRecoveryScreenState();
}

class _AuthRecoveryScreenState extends State<AuthRecoveryScreen> {
  final AuthRecoveryService _service = AuthRecoveryService();
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _passwordConfirmation = TextEditingController();

  bool _otpMode = false;
  bool _codeSent = false;
  bool _busy = false;
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;
  String? _message;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _password.dispose();
    _passwordConfirmation.dispose();
    super.dispose();
  }

  bool _validEmail(String value) {
    final email = value.trim();
    return email.contains('@') && email.contains('.');
  }

  bool _strongPassword(String value) {
    return value.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(value) &&
        RegExp(r'[a-z]').hasMatch(value) &&
        RegExp(r'[0-9]').hasMatch(value);
  }

  Future<void> _requestCode() async {
    if (!_validEmail(_email.text)) {
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
          _message = _otpMode
              ? 'If the account exists, a sign-in code has been sent.'
              : 'If the account exists, a password reset code has been sent.';
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              _error = 'The request could not be completed. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify() async {
    final code = _code.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      setState(() => _error = 'Enter the six-digit verification code.');
      return;
    }

    if (!_otpMode) {
      if (!_strongPassword(_password.text)) {
        setState(
          () => _error =
              'Use at least 8 characters with uppercase, lowercase and a number.',
        );
        return;
      }
      if (_password.text != _passwordConfirmation.text) {
        setState(() => _error = 'The password confirmation does not match.');
        return;
      }
    }

    setState(() {
      _busy = true;
      _error = null;
      _message = null;
    });

    try {
      if (_otpMode) {
        await _service.verifyOtp(_email.text, code);
        if (mounted) widget.onSignedIn();
      } else {
        await _service.resetPassword(_email.text, code, _password.text);
        if (mounted) {
          setState(() {
            _message =
                'Password updated. Return to login and use your new password.';
            _codeSent = false;
            _code.clear();
            _password.clear();
            _passwordConfirmation.clear();
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

  void _switchMode(bool otpMode) {
    setState(() {
      _otpMode = otpMode;
      _codeSent = false;
      _code.clear();
      _password.clear();
      _passwordConfirmation.clear();
      _error = null;
      _message = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_otpMode ? 'Sign in with code' : 'Forgot password'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
              children: [
                const BrandHeader(compact: true),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment<bool>(
                              value: false,
                              icon: Icon(Icons.lock_reset_outlined),
                              label: Text('Reset password'),
                            ),
                            ButtonSegment<bool>(
                              value: true,
                              icon: Icon(Icons.password_outlined),
                              label: Text('OTP sign in'),
                            ),
                          ],
                          selected: {_otpMode},
                          onSelectionChanged: _busy
                              ? null
                              : (selection) => _switchMode(selection.first),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          _otpMode
                              ? 'Sign in with a one-time code'
                              : 'Reset your password',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _otpMode
                              ? 'Request a secure one-time sign-in code sent to your registered email address.'
                              : 'Enter your registered email. We will send a six-digit code so you can choose a new password.',
                          textAlign: TextAlign.center,
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
                          autofillHints: const [AutofillHints.email],
                          decoration: const InputDecoration(
                            labelText: 'Email address',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        if (_codeSent) ...[
                          const SizedBox(height: 12),
                          TextField(
                            controller: _code,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            autofillHints: const [AutofillHints.oneTimeCode],
                            decoration: const InputDecoration(
                              labelText: 'Six-digit verification code',
                              prefixIcon: Icon(Icons.pin_outlined),
                              counterText: '',
                            ),
                          ),
                          if (!_otpMode) ...[
                            const SizedBox(height: 12),
                            TextField(
                              controller: _password,
                              obscureText: _obscurePassword,
                              autofillHints: const [AutofillHints.newPassword],
                              decoration: InputDecoration(
                                labelText: 'New password',
                                helperText:
                                    '8+ characters, uppercase, lowercase and a number',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  tooltip: _obscurePassword
                                      ? 'Show password'
                                      : 'Hide password',
                                  onPressed: () => setState(
                                    () => _obscurePassword =
                                        !_obscurePassword,
                                  ),
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _passwordConfirmation,
                              obscureText: _obscureConfirmation,
                              autofillHints: const [AutofillHints.newPassword],
                              decoration: InputDecoration(
                                labelText: 'Confirm new password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  tooltip: _obscureConfirmation
                                      ? 'Show password'
                                      : 'Hide password',
                                  onPressed: () => setState(
                                    () => _obscureConfirmation =
                                        !_obscureConfirmation,
                                  ),
                                  icon: Icon(
                                    _obscureConfirmation
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 50,
                          child: FilledButton.icon(
                            onPressed: _busy
                                ? null
                                : (_codeSent ? _verify : _requestCode),
                            icon: _busy
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(
                                    _codeSent
                                        ? Icons.verified_outlined
                                        : Icons.send_outlined,
                                  ),
                            label: Text(
                              _busy
                                  ? 'Please wait...'
                                  : _codeSent
                                      ? (_otpMode
                                          ? 'Verify and sign in'
                                          : 'Update password')
                                      : 'Send code',
                            ),
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
                                      _password.clear();
                                      _passwordConfirmation.clear();
                                    });
                                  },
                            child: const Text('Use a different email address'),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBox extends StatelessWidget {
  const _StatusBox({required this.text, this.error = false});

  final String text;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: error ? scheme.errorContainer : scheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text),
      ),
    );
  }
}
