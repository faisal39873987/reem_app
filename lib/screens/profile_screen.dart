import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'login_screen.dart';
import '../utils/constants.dart';

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
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data();

      if (!mounted) return;
      setState(() {
        _userName = data?['name'] ?? 'User';
        _bioController.text = data?['bio'] ?? '';
        _phoneController.text = data?['phone'] ?? '';
        _noteController.text = data?['note'] ?? '';
        _photoUrl = data?['photoUrl'] ?? '';
        _showInReemYouth = data?['showInReemYouth'] ?? true;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      String newImageUrl = _photoUrl;

      if (_profileImage != null) {
        final filePath = 'user_images/${user.uid}.jpg';
        final ref = FirebaseStorage.instance.ref().child(filePath);
        await ref.putFile(_profileImage!);
        newImageUrl = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': user.displayName ?? 'User',
        'bio': _bioController.text.trim(),
        'phone': _phoneController.text.trim(),
        'note': _noteController.text.trim(),
        'photoUrl': newImageUrl,
        'showInReemYouth': _showInReemYouth,
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Profile updated")),
      );
      setState(() {
        _photoUrl = newImageUrl;
        _profileImage = null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to update profile")),
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

    return CircleAvatar(
      radius: 60,
      backgroundColor: Colors.grey[200],
      backgroundImage: imageProvider,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = widget.isOwner;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.isAnonymous) {
      Future.microtask(() {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
            )
        ],
        iconTheme: const IconThemeData(color: blue),
      ),
      body: _isLoading
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
                          icon: const Icon(Icons.camera_alt, color: kPrimaryColor),
                          onPressed: _pickImage,
                        )
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(_userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                      onChanged: (val) => setState(() => _showInReemYouth = val),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, bool enabled) {
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
