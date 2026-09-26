import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/api/api_client.dart';
import '../core/api/api_config.dart';
import '../core/theme/app_colors.dart';
import '../services/branding_service.dart';
import '../widgets/youth_screen_scaffold.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _school = TextEditingController();
  final _picker = ImagePicker();

  bool _loading = true;
  bool _saving = false;
  bool _profilePublic = false;
  String? _profilePhotoUrl;
  XFile? _pickedPhoto;
  Uint8List? _pickedBytes;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _school.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final response = await ApiConfig.client.get('/me');
      final user = response['user'] is Map
          ? Map<String, dynamic>.from(response['user'] as Map)
          : <String, dynamic>{};
      final profile = response['youth_profile'] is Map
          ? Map<String, dynamic>.from(response['youth_profile'] as Map)
          : <String, dynamic>{};

      if (!mounted) return;
      _name.text = '${user['name'] ?? ''}';
      _email.text = '${user['email'] ?? ''}';
      _school.text = '${profile['school_institution'] ?? ''}';
      setState(() {
        _profilePublic = profile['profile_public'] == true || profile['profile_public'] == 1;
        _profilePhotoUrl = BrandingService.resolveUrl('${profile['profile_photo'] ?? ''}');
        _loading = false;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _error = 'Your profile could not be loaded.'; _loading = false; });
    }
  }

  Future<void> _pickPhoto() async {
    final photo = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 82,
    );
    if (photo == null) return;
    final bytes = await photo.readAsBytes();
    if (!mounted) return;
    setState(() {
      _pickedPhoto = photo;
      _pickedBytes = bytes;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    setState(() { _saving = true; _error = null; });

    try {
      final body = <String, dynamic>{
        'name': _name.text.trim(),
        'email': _email.text.trim(),
        'school_institution': _school.text.trim().isEmpty ? null : _school.text.trim(),
        'profile_public': _profilePublic,
      };

      if (_pickedPhoto != null && _pickedBytes != null) {
        body['profile_photo_base64'] = base64Encode(_pickedBytes!);
        body['profile_photo_name'] = _pickedPhoto!.name;
      }

      await ApiConfig.client.patch('/me', body);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'We could not update your profile. Please try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return YouthScreenScaffold(
      title: 'Edit profile',
      subtitle: 'Keep your youth profile details up to date.',
      leading: IconButton(
        tooltip: 'Back',
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      child: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FutureBuilder<BrandingData>(
                            future: BrandingService.load(),
                            builder: (context, snapshot) {
                              final logoUrl = snapshot.data?.logoUrl;
                              ImageProvider<Object>? imageProvider;
                              if (_pickedBytes != null) {
                                imageProvider = MemoryImage(_pickedBytes!);
                              } else if (_profilePhotoUrl != null) {
                                imageProvider = NetworkImage(_profilePhotoUrl!);
                              } else if (logoUrl != null) {
                                imageProvider = NetworkImage(logoUrl);
                              }

                              return Center(
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    CircleAvatar(
                                      radius: 46,
                                      backgroundColor: AppColors.primaryLight,
                                      backgroundImage: imageProvider,
                                      child: imageProvider == null
                                          ? const Icon(Icons.person_outline, size: 42, color: AppColors.primary)
                                          : null,
                                    ),
                                    Positioned(
                                      right: -4,
                                      bottom: -4,
                                      child: IconButton.filled(
                                        tooltip: 'Change profile photo',
                                        onPressed: _saving ? null : _pickPhoto,
                                        icon: const Icon(Icons.photo_camera_outlined),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          if (_error != null) ...[
                            Text(_error!, style: const TextStyle(color: AppColors.error)),
                            const SizedBox(height: 14),
                          ],
                          TextFormField(
                            controller: _name,
                            decoration: const InputDecoration(
                              labelText: 'Full name',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (value) => (value ?? '').trim().isEmpty ? 'Enter your full name.' : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email address',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (value) {
                              final text = (value ?? '').trim();
                              if (text.isEmpty) return 'Enter your email address.';
                              if (!text.contains('@')) return 'Enter a valid email address.';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _school,
                            decoration: const InputDecoration(
                              labelText: 'School / institution',
                              prefixIcon: Icon(Icons.school_outlined),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            value: _profilePublic,
                            title: const Text('Public youth profile'),
                            subtitle: const Text(
                              'Allow approved platform users to see your public profile information.',
                            ),
                            onChanged: _saving ? null : (value) => setState(() => _profilePublic = value),
                          ),
                          const SizedBox(height: 18),
                          FilledButton.icon(
                            onPressed: _saving ? null : _save,
                            icon: _saving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.save_outlined),
                            label: Text(_saving ? 'Saving...' : 'Save changes'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
