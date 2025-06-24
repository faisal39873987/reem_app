import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/constants.dart';
import '../models/post.dart';

class PostCreationScreen extends StatefulWidget {
  final void Function(Post)? testOnSubmit;
  const PostCreationScreen({super.key, this.testOnSubmit});

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
    final messenger = ScaffoldMessenger.of(context);
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.unableToDetermine) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text("Location permission is required to show distance."),
        ),
      );
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    if (!mounted) return;
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
    });
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (!mounted) return;
      if (pickedFile != null) {
        setState(() => _imageFile = File(pickedFile.path));
      }
    } catch (e) {
      if (!mounted) return;
      _showSnack('Failed to pick image: ${e.toString()}');
    }
  }

  void _submit() async {
    if (widget.testOnSubmit != null) {
      // Bypass all validation in test mode
      widget.testOnSubmit!(
        Post(
          id: 'test',
          imageUrl: '',
          description: _descriptionController.text,
          price: double.tryParse(_priceController.text) ?? 0.0,
          creatorId: 'test',
          category: 'test',
          isAnonymous: false,
          latitude: 0.0,
          longitude: 0.0,
          timestamp: DateTime.now(),
        ),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Test post submitted!')));
      return;
    }

    debugPrint('POST: Uploading post');

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a description.")),
      );
      return;
    }

    if (_priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter a price.")));
      return;
    }

    if (_selectedCategory.isEmpty) {
      _selectedCategory = 'General';
    }

    if (_showDistance && (_latitude == null || _longitude == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please allow location access to show distance."),
        ),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);
      // Send postData to your backend or database
      // await sendDataToBackend(postData);
      debugPrint('POST: Post uploaded successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Post created successfully!")),
      );
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          debugPrint('NAVIGATE: To /landing (from PostCreationScreen)');
          Navigator.of(context).pushReplacementNamed('/landing');
        }
      });
    } catch (e) {
      debugPrint("❌ Upload Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Something went wrong. Try again.")),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _protectIfNotLoggedIn();
  }

  Future<void> _protectIfNotLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isGuest = prefs.getBool('isGuest') ?? false;
    final session = Supabase.instance.client.auth.currentSession;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    if (isGuest || session == null) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Login is required to access this page')),
      );
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      navigator.pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('BUILD: PostCreationScreen');

    const blueColor = kPrimaryColor;

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
                      child:
                          _imageFile == null
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
                      value:
                          _selectedCategory.isEmpty
                              ? 'General'
                              : _selectedCategory,
                      items: const [
                        DropdownMenuItem(
                          value: 'General',
                          child: Text('General'),
                        ),
                        DropdownMenuItem(
                          value: 'For Sale',
                          child: Text('For Sale'),
                        ),
                        DropdownMenuItem(
                          value: 'For Rent',
                          child: Text('For Rent'),
                        ),
                        DropdownMenuItem(
                          value: 'Public Service',
                          child: Text('Public Service'),
                        ),
                        DropdownMenuItem(
                          value: 'Advertisement',
                          child: Text('Advertisement'),
                        ),
                      ],
                      onChanged:
                          (value) => setState(() => _selectedCategory = value!),
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: "Description",
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Price (AED)",
                      ),
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
                          onPressed: _submit,
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
