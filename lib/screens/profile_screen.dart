import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/constants.dart';
import '../models/profile.dart';

class ProfileScreen extends StatefulWidget {
  final bool isOwner;

  const ProfileScreen({super.key, this.isOwner = true});

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
  bool _showInReemYouth = true;

  @override
  void initState() {
    super.initState();
    _protectIfNotLoggedIn();
    _loadUserData();
  }

  Future<void> _protectIfNotLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isGuest = prefs.getBool('isGuest') ?? false;
    final session = Supabase.instance.client.auth.currentSession;
    if (isGuest || session == null) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: const Text('Login Required'),
              content: const Text('Login is required to access this page.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
      ).then((_) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      });
    }
  }

  Future<void> _loadUserData() async {
    debugPrint('PROFILE: Loading user data');
    try {
      if (!mounted) return;
      setState(() => _isLoading = true);
      final user = Supabase.instance.client.auth.currentUser;
      debugPrint('SUPABASE: Current user = $user');
      if (user == null) return;
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
        _showInReemYouth = profile?.showInReemYouth ?? true;
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

    try {
      String newImageUrl = _photoUrl;

      if (_profileImage != null) {
        // Upload new profile image and get the URL
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
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
      }

      // Save profile data to Supabase
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client
            .from('profiles')
            .update({
              'bio': _bioController.text.trim(),
              'phone': _phoneController.text.trim(),
              'note': _noteController.text.trim(),
              'avatar_url': newImageUrl,
              'show_in_reem_youth': _showInReemYouth,
            })
            .eq('id', user.id);
      }

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

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (!mounted) return;
    if (picked != null) {
      setState(() => _profileImage = File(picked.path));
    }
  }

  Widget _buildAvatar() {
    ImageProvider imageProvider;
    if (_profileImage != null) {
      imageProvider = FileImage(_profileImage!);
    } else if (_photoUrl.isNotEmpty) {
      imageProvider = NetworkImage(_photoUrl);
    } else {
      imageProvider = NetworkImage(
        'https://ui-avatars.com/api/?name=${Uri.encodeComponent(_userName)}&background=0D8ABC&color=fff',
      );
    }
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey[200],
          backgroundImage: imageProvider,
        ),
        if (widget.isOwner)
          IconButton(
            icon: const Icon(Icons.camera_alt, color: kPrimaryColor),
            onPressed: _pickImage,
          ),
      ],
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
                      children: [
                        _buildAvatar(),
                        if (isOwner)
                          IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              color: kPrimaryColor,
                            ),
                            onPressed: _pickImage,
                          ),
                      ],
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
                    if (isOwner)
                      SwitchListTile(
                        title: const Text("Appear in Reem Youth"),
                        value: _showInReemYouth,
                        onChanged: (val) {
                          if (!mounted) return;
                          setState(() => _showInReemYouth = val);
                        },
                      ),
                  ],
                ),
              ),
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
