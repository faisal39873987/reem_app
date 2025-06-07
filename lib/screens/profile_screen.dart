import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
  String _imageUrl = '';
  bool _isLoading = false;
  bool _showInReemYouth = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final data = doc.data();

    setState(() {
      _userName = user.displayName ?? '';
      _bioController.text = data?['bio'] ?? '';
      _phoneController.text = data?['phone'] ?? '';
      _noteController.text = data?['note'] ?? '';
      _imageUrl = data?['imageUrl'] ?? '';
      _showInReemYouth = data?['showInReemYouth'] ?? true;
    });
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      String newImageUrl = _imageUrl;

      if (_profileImage != null) {
        final ref = FirebaseStorage.instance.ref().child('user_images/${user.uid}.jpg');
        final uploadTask = ref.putFile(_profileImage!).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw TimeoutException("Upload timeout");
          },
        );
        await uploadTask;
        newImageUrl = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': user.displayName ?? 'User',
        'bio': _bioController.text.trim(),
        'phone': _phoneController.text.trim(),
        'note': _noteController.text.trim(),
        'imageUrl': newImageUrl,
        'showInReemYouth': _showInReemYouth,
      }, SetOptions(merge: true));

      await user.reload();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Profile updated")),
      );
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Upload error: ${e.message}")),
      );
    } on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Upload timed out")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Unexpected error")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = widget.isOwner;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.isAnonymous) {
      Future.microtask(() {
        Navigator.of(context).pushReplacementNamed('/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    const blueColor = Color(0xFF1877F2);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text("Profile", style: TextStyle(color: blueColor, fontWeight: FontWeight.bold)),
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.save, color: blueColor),
              onPressed: _saveProfile,
            )
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16).copyWith(bottom: 32),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : (_imageUrl.isNotEmpty ? NetworkImage(_imageUrl) : null) as ImageProvider?,
                          child: _imageUrl.isEmpty && _profileImage == null
                              ? const Icon(Icons.person, size: 60, color: Colors.white)
                              : null,
                        ),
                        if (isOwner)
                          IconButton(
                            icon: const Icon(Icons.camera_alt, color: Colors.blue),
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
                        onChanged: (value) => setState(() => _showInReemYouth = value),
                      ),
                  ],
                ),
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
