import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../core/localization/app_strings.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    required this.authService,
    required this.onRegistered,
  });

  final AuthService authService;
  final VoidCallback onRegistered;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _school = TextEditingController();
  final _guardianName = TextEditingController();
  final _guardianRelationship = TextEditingController();
  final _guardianPhone = TextEditingController();
  final _guardianEmail = TextEditingController();

  DateTime? _dateOfBirth;
  bool _busy = false;
  bool _obscurePassword = true;
  bool _guardianConfirmed = false;
  String? _error;

  @override
  void dispose() {
    for (final controller in [
      _name,
      _email,
      _password,
      _school,
      _guardianName,
      _guardianRelationship,
      _guardianPhone,
      _guardianEmail,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  int? get _age {
    final dob = _dateOfBirth;
    if (dob == null) return null;
    final now = DateTime.now();
    var years = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      years--;
    }
    return years;
  }

  bool get _showGuardianFields {
    final age = _age;
    return age != null && age >= 12 && age <= 17;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final value = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 35 - 1),
      lastDate: DateTime(now.year - 12, now.month, now.day),
      initialDate: DateTime(now.year - 18, now.month, now.day),
    );

    if (value != null && mounted) {
      setState(() {
        _dateOfBirth = value;
        _guardianConfirmed = false;
      });
    }
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  Future<void> _submit() async {
    final strings = AppStrings.of(context);

    if (!_formKey.currentState!.validate()) return;
    if (_dateOfBirth == null) {
      setState(() => _error = strings.text('select_birth_error'));
      return;
    }

    final age = _age;
    if (age == null || age < 12 || age > 35) {
      setState(() => _error = strings.text('age_range'));
      return;
    }

    if (_showGuardianFields && !_guardianConfirmed) {
      setState(() => _error = strings.text('guardian_confirmation_required'));
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await widget.authService.register(
        name: _name.text,
        email: _email.text,
        password: _password.text,
        dateOfBirth: _formatDate(_dateOfBirth!),
        schoolInstitution: _school.text,
        guardianName: _showGuardianFields ? _guardianName.text : null,
        guardianRelationship:
            _showGuardianFields ? _guardianRelationship.text : null,
        guardianPhone: _showGuardianFields ? _guardianPhone.text : null,
        guardianEmail: _showGuardianFields ? _guardianEmail.text : null,
        guardianConfirmed: _showGuardianFields && _guardianConfirmed,
      );

      if (mounted) widget.onRegistered();
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = strings.text('registration_failed'));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.text('create_account'))),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                strings.text('join_youth_community'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(strings.text('registration_intro')),
              const SizedBox(height: 6),
              Text(
                strings.text('age_range'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(_error!),
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _name,
                decoration: InputDecoration(
                  labelText: strings.text('full_name'),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => (value ?? '').trim().isEmpty
                    ? strings.text('enter_full_name')
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: strings.text('email_address'),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  final text = (value ?? '').trim();
                  if (text.isEmpty) return strings.text('enter_email');
                  if (!text.contains('@')) return strings.text('valid_email');
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _password,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: strings.text('password'),
                  helperText: strings.text('password_help'),
                  border: const OutlineInputBorder(),
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
                validator: (value) => (value ?? '').length < 8
                    ? strings.text('password_min')
                    : null,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.cake_outlined),
                label: Text(
                  _dateOfBirth == null
                      ? strings.text('select_date_birth')
                      : '${strings.text('date_of_birth')}: ${_formatDate(_dateOfBirth!)}',
                ),
              ),
              if (_age != null) ...[
                const SizedBox(height: 8),
                Text(
                  '${strings.text('date_of_birth')}: ${_formatDate(_dateOfBirth!)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _school,
                decoration: InputDecoration(
                  labelText: strings.text('school_optional'),
                  border: const OutlineInputBorder(),
                ),
              ),
              if (_showGuardianFields) ...[
                const SizedBox(height: 20),
                Text(
                  strings.text('guardian_consent'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _guardianName,
                  decoration: InputDecoration(
                    labelText: strings.text('guardian_name'),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) => _showGuardianFields &&
                          (value ?? '').trim().isEmpty
                      ? strings.text('enter_guardian_name')
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _guardianRelationship,
                  decoration: InputDecoration(
                    labelText: strings.text('guardian_relationship'),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) => _showGuardianFields &&
                          (value ?? '').trim().isEmpty
                      ? strings.text('enter_relationship')
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _guardianPhone,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: strings.text('guardian_phone'),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) => _showGuardianFields &&
                          (value ?? '').trim().isEmpty
                      ? strings.text('enter_guardian_phone')
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _guardianEmail,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: strings.text('guardian_email_optional'),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 6),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _guardianConfirmed,
                  onChanged: _busy
                      ? null
                      : (value) => setState(
                            () => _guardianConfirmed = value ?? false,
                          ),
                  title: Text(strings.text('guardian_confirmation')),
                ),
              ],
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: _busy ? null : _submit,
                icon: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.person_add_alt_1),
                label: Text(
                  _busy
                      ? strings.text('creating_account')
                      : strings.text('create_account'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
