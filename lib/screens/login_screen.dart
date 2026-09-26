import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../core/localization/app_strings.dart';
import '../core/theme/app_colors.dart';
import '../services/auth_service.dart';
import '../widgets/brand_header.dart';
import 'auth_recovery_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.authService,
    required this.onSignedIn,
    required this.onContinueAsGuest,
  });

  final AuthService authService;
  final VoidCallback onSignedIn;
  final VoidCallback onContinueAsGuest;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await widget.authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (mounted) widget.onSignedIn();
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = AppStrings.of(context).text('login_failed'));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openRegister() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => RegisterScreen(
          authService: widget.authService,
          onRegistered: () {
            Navigator.of(context).pop();
            widget.onSignedIn();
          },
        ),
      ),
    );
  }

  Future<void> _openRecovery() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => AuthRecoveryScreen(
          onSignedIn: () {
            Navigator.of(context).pop();
            widget.onSignedIn();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: BrandHeader(
                      compact: true,
                      showTagline: false,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Card(
                    elevation: 2,
                    shadowColor: Colors.black12,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Welcome back',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Sign in to your COU Youth account.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13.5,
                              ),
                            ),
                            const SizedBox(height: 22),
                            if (_error != null) ...[
                              Semantics(
                                liveRegion: true,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: scheme.errorContainer,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    _error!,
                                    style: TextStyle(
                                      color: scheme.onErrorContainer,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                            ],
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.email],
                              decoration: InputDecoration(
                                labelText: strings.text('email_address'),
                                hintText: 'name@example.com',
                                prefixIcon: const Icon(Icons.email_outlined),
                              ),
                              validator: (value) {
                                final text = value?.trim() ?? '';
                                if (text.isEmpty) {
                                  return strings.text('enter_email');
                                }
                                if (!text.contains('@')) {
                                  return strings.text('valid_email');
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              autofillHints: const [AutofillHints.password],
                              onFieldSubmitted: (_) {
                                if (!_loading) _submit();
                              },
                              decoration: InputDecoration(
                                labelText: strings.text('password'),
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  tooltip: _obscurePassword
                                      ? strings.text('show_password')
                                      : strings.text('hide_password'),
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
                              validator: (value) => (value ?? '').isEmpty
                                  ? strings.text('enter_password')
                                  : null,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _loading ? null : _openRecovery,
                                child: Text(
                                  strings.text('forgot_password_otp'),
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            SizedBox(
                              height: 50,
                              child: FilledButton.icon(
                                onPressed: _loading ? null : _submit,
                                icon: _loading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.login_rounded),
                                label: Text(
                                  _loading
                                      ? strings.text('signing_in')
                                      : strings.text('sign_in'),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                const Expanded(child: Divider()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Text(
                                    'New to COU Youth?',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                                const Expanded(child: Divider()),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 50,
                              child: OutlinedButton.icon(
                                onPressed: _loading ? null : _openRegister,
                                icon: const Icon(Icons.person_add_alt_1_rounded),
                                label: Text(
                                  strings.text('create_youth_account'),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _loading
                                  ? null
                                  : widget.onContinueAsGuest,
                              child: Text(strings.text('continue_guest')),
                            ),
                          ],
                        ),
                      ),
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
