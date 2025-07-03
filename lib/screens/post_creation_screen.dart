import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart'; // حذف الاستيراد لأنه غير مستخدم
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/constants.dart';
import '../models/post.dart';
import '../widgets/media_picker_widget.dart';

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
  // bool _showDistance = false; // حذف خيار المسافة
  bool _isLoading = false;
  // double? _latitude;
  // double? _longitude;
  String _selectedCategory = 'General';
  bool _isMarketplace = false; // جديد: خيار النشر في الماركت بليس

  // TODO: Use Supabase Storage for media upload with progress and error handling
  // TODO: Modularize image/video picker as a reusable widget
  // TODO: Add permission checks for post creation (admin/mod/user/guest)

  void _submit() async {
    if (widget.testOnSubmit != null) {
      // Bypass all validation in test mode
      widget.testOnSubmit!(
        Post(
          id: 'test',
          imageUrl: '',
          images: const [],
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

    if (_isMarketplace && _priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter a price.")));
      return;
    }

    if (_selectedCategory.isEmpty) {
      _selectedCategory = 'General';
    }

    // تم حذف شرط المسافة

    try {
      setState(() => _isLoading = true);
      if (_isMarketplace) {
        // نشر في الماركت بليس
        final user = Supabase.instance.client.auth.currentUser;
        if (user == null) throw Exception('Not authenticated');
        await Supabase.instance.client.from('marketplace').insert({
          'user_id': user.id,
          'title': _descriptionController.text.trim(),
          'description': _descriptionController.text.trim(),
          'price': double.tryParse(_priceController.text) ?? 0.0,
          'image_url': '', // TODO: دعم رفع صورة المنتج
          'created_at': DateTime.now().toIso8601String(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Product posted to marketplace!")),
        );
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/marketplace');
          }
        });
      } else {
        // نشر كمنشور عادي
        // Send postData to your backend or database
        // await sendDataToBackend(postData);
        debugPrint('POST: Post uploaded successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Post created successfully!")),
        );
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/landing');
          }
        });
      }
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
                  // TODO: Add more actions if needed (e.g., save draft, preview)
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    MediaPickerWidget(
                      onChanged: (file) => setState(() => _imageFile = file),
                      initialFile: _imageFile,
                      size: 150,
                      isVideo: false, // TODO: Add video support
                    ),
                    const SizedBox(height: 20),
                    SwitchListTile(
                      title: const Text("Post as product in marketplace?"),
                      value: _isMarketplace,
                      onChanged: (val) => setState(() => _isMarketplace = val),
                    ),
                    if (_isMarketplace) ...[
                      MediaPickerWidget(
                        onChanged: (file) => setState(() => _imageFile = file),
                        initialFile: _imageFile,
                        size: 150,
                        isVideo: false,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Price (AED)",
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: "Description",
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),
                    if (!_isMarketplace) ...[
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
                            (value) =>
                                setState(() => _selectedCategory = value!),
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    SwitchListTile(
                      title: const Text("Post as anonymous?"),
                      value: _isAnonymous,
                      onChanged: (val) => setState(() => _isAnonymous = val),
                    ),
                    // تم حذف خيار المسافة
                    const SizedBox(height: 30),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: blueColor,
                          ),
                          child: Text(
                            _isMarketplace
                                ? "نشر في الماركت بليس"
                                : "Submit Post",
                          ),
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
