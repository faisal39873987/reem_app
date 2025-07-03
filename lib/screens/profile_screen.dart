import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/constants.dart';
import '../models/profile.dart';
import '../utils/test_user_override.dart';
import '../widgets/media_picker_widget.dart';
import '../widgets/rv_bottom_nav_bar.dart';

class ProfileScreen extends StatefulWidget {
  final bool isOwner;
  final Profile? testProfile;

  const ProfileScreen({super.key, this.isOwner = true, this.testProfile});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String _userName = '';
  File? _profileImage;
  String _photoUrl = '';
  bool _isLoading = true;

  Profile? _profile;

  @override
  void initState() {
    super.initState();
    if (widget.testProfile != null) {
      _profile = widget.testProfile;
      _userName = _profile?.fullName ?? 'User';
      _bioController.text = _profile?.bio ?? '';
      _phoneController.text = _profile?.phone ?? '';
      _noteController.text = _profile?.note ?? '';
      _photoUrl = _profile?.avatarUrl ?? '';
      setState(() => _isLoading = false);
    } else {
      _protectIfNotLoggedIn();
      _loadUserData();
    }
  }

  Future<void> _protectIfNotLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isGuest = prefs.getBool('isGuest') ?? false;
    final user = getCurrentUser();
    if (isGuest || user == null) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
      return;
    }
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    final user = getCurrentUser();
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final profileData =
          await Supabase.instance.client
              .from('profiles')
              .select()
              .eq('id', user.id)
              .maybeSingle();
      debugPrint('SUPABASE: Profile = $profileData');
      if (!mounted) return;
      final profile = profileData != null ? Profile.fromMap(profileData) : null;
      setState(() {
        _userName = profile?.fullName ?? 'User';
        _bioController.text = profile?.bio ?? '';
        _phoneController.text = profile?.phone ?? '';
        _noteController.text = profile?.note ?? '';
        _photoUrl = profile?.avatarUrl ?? '';
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('PROFILE: Error loading user data: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final user = getCurrentUser();
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      String newImageUrl = _photoUrl;

      if (_profileImage != null) {
        // Upload new profile image and get the URL
        final bytes = await _profileImage!.readAsBytes();
        final fileName =
            'avatars/${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await Supabase.instance.client.storage
            .from('avatars')
            .uploadBinary(
              fileName,
              bytes,
              fileOptions: const FileOptions(
                upsert: true,
                contentType: 'image/jpeg',
              ),
            );
        final publicUrl = Supabase.instance.client.storage
            .from('avatars')
            .getPublicUrl(fileName);
        newImageUrl = publicUrl;
      }

      // Save profile data to Supabase
      await Supabase.instance.client
          .from('profiles')
          .update({
            'bio': _bioController.text.trim(),
            'phone': _phoneController.text.trim(),
            'note': _noteController.text.trim(),
            'avatar_url': newImageUrl,
          })
          .eq('id', user.id);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ Profile updated")));
      setState(() {
        _photoUrl = newImageUrl;
        _profileImage = null;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('PROFILE: Failed to update profile: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to update profile. Please try again later."),
        ),
      );
    }
  }

  Widget _buildAvatar() {
    return MediaPickerWidget(
      onChanged: (file) => setState(() => _profileImage = file),
      initialFile: _profileImage,
      size: 120,
      isVideo: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('BUILD: ProfileScreen');
    final isOwner = widget.isOwner;

    const blue = kPrimaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(color: blue)),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.save, color: blue),
              onPressed: _saveProfile,
            ),
        ],
        iconTheme: const IconThemeData(color: blue),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [_buildAvatar()],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _userName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildEditableField("Bio", _bioController, isOwner),
                    const SizedBox(height: 16),
                    _buildEditableField("Phone", _phoneController, isOwner),
                    const SizedBox(height: 16),
                    _buildEditableField("Note", _noteController, isOwner),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
      bottomNavigationBar: const RVBottomNavBar(currentIndex: 4),
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller,
    bool enabled,
  ) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      maxLines: label == "Note" ? 3 : 1,
    );
  }
}

// All Firebase dependencies and usage have been removed. Supabase is fully integrated for profile operations.
