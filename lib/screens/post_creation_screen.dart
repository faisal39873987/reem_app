import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

import 'package:reem_verse_rebuild/screens/landing_screen.dart';
import 'package:reem_verse_rebuild/screens/notification_screen.dart';
import 'package:reem_verse_rebuild/screens/chat_list_screen.dart';
import 'package:reem_verse_rebuild/screens/search_screen.dart';

class PostCreationScreen extends StatefulWidget {
  const PostCreationScreen({super.key});

  @override
  State<PostCreationScreen> createState() => _PostCreationScreenState();
}

class _PostCreationScreenState extends State<PostCreationScreen> {
  File? _imageFile;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  bool _isAnonymous = false;
  bool _showDistance = false;
  bool _isLoading = false;
  double? _latitude;
  double? _longitude;
  String _selectedCategory = 'General';

  final picker = ImagePicker();

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.unableToDetermine) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      _showSnack("Location permission is required to show distance.");
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _uploadPost() async {
await FirebaseAuth.instance.currentUser?.reload();
final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      _showSnack("You must be logged in to create a post.");
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.of(context).pushReplacementNamed('/login');
      });
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      _showSnack("Please enter a description.");
      return;
    }

    if (_priceController.text.trim().isEmpty) {
      _showSnack("Please enter a price.");
      return;
    }

    if (_selectedCategory.isEmpty) {
      _selectedCategory = 'General';
    }

    if (_showDistance && (_latitude == null || _longitude == null)) {
      _showSnack("Please allow location access to show distance.");
      return;
    }

    try {
      setState(() => _isLoading = true);
      String? imageUrl;

      if (_imageFile != null) {
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final ref = FirebaseStorage.instance.ref().child('post_images').child('$fileName.jpg');
        await ref.putFile(_imageFile!);
        imageUrl = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('posts').add({
        'creatorId': user.uid,
        'imageUrl': imageUrl ?? '',
        'description': _descriptionController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'timestamp': FieldValue.serverTimestamp(),
        'isAnonymous': _isAnonymous,
        'showDistance': _showDistance,
        'category': _selectedCategory,
        'location': _showDistance
            ? {
                'latitude': _latitude,
                'longitude': _longitude,
              }
            : null,
      });

      _showSnack("✅ Post created successfully!");
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const LandingScreen(initialIndex: 0),
          ),
        );
      });
    } catch (e) {
      print("❌ Upload Error: $e");
      _showSnack("❌ Something went wrong. Try again.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const blueColor = Color(0xFF1877F2);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: blueColor),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    "Create Post",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: blueColor,
                    ),
                  ),
                  const Spacer(),
                  if (user != null && !user.isAnonymous) ...[
                    IconButton(
                      icon: const Icon(Icons.notifications_none, color: blueColor),
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationScreen())),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline, color: blueColor),
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChatListScreen())),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search, color: blueColor),
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SearchScreen())),
                    ),
                  ],
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: _imageFile == null
                          ? Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.add_a_photo, size: 50),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _imageFile!,
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory.isEmpty ? 'General' : _selectedCategory,
                      items: const [
                        DropdownMenuItem(value: 'General', child: Text('General')),
                        DropdownMenuItem(value: 'For Sale', child: Text('For Sale')),
                        DropdownMenuItem(value: 'For Rent', child: Text('For Rent')),
                        DropdownMenuItem(value: 'Public Service', child: Text('Public Service')),
                        DropdownMenuItem(value: 'Advertisement', child: Text('Advertisement')),
                      ],
                      onChanged: (value) => setState(() => _selectedCategory = value!),
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: "Description"),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Price (AED)"),
                    ),
                    const SizedBox(height: 20),
                    SwitchListTile(
                      title: const Text("Post as anonymous?"),
                      value: _isAnonymous,
                      onChanged: (val) => setState(() => _isAnonymous = val),
                    ),
                    SwitchListTile(
                      title: const Text("Show distance to post?"),
                      value: _showDistance,
                      onChanged: (val) async {
                        setState(() => _showDistance = val);
                        if (val) await _getLocation();
                      },
                    ),
                    const SizedBox(height: 30),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _uploadPost,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: blueColor,
                            ),
                            child: const Text("Submit Post"),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
