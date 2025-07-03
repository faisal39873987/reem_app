// إضافة شاشة إضافة منتج للماركت بليس مع خيار رفع صورة
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/media_picker_widget.dart';

class MarketplaceAddProductScreen extends StatefulWidget {
  const MarketplaceAddProductScreen({super.key});

  @override
  State<MarketplaceAddProductScreen> createState() =>
      _MarketplaceAddProductScreenState();
}

class _MarketplaceAddProductScreenState
    extends State<MarketplaceAddProductScreen> {
  File? _imageFile;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  bool _isLoading = false;

  Future<String?> _uploadImage(File? file) async {
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    final fileName = 'marketplace/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final storage = Supabase.instance.client.storage;
    await storage
        .from('marketplace')
        .uploadBinary(
          fileName,
          bytes,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );
    return storage.from('marketplace').getPublicUrl(fileName);
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }
    setState(() => _isLoading = true);
    String? imageUrl;
    if (_imageFile != null) {
      imageUrl = await _uploadImage(_imageFile);
    }
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Not authenticated')));
      setState(() => _isLoading = false);
      return;
    }
    await Supabase.instance.client.from('marketplace').insert({
      'user_id': user.id,
      'title': _titleController.text.trim(),
      'description': _descController.text.trim(),
      'price': double.tryParse(_priceController.text) ?? 0.0,
      'image_url': imageUrl ?? '',
      'created_at': DateTime.now().toIso8601String(),
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('✅ Product added!')));
    if (mounted) Navigator.of(context).pop();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product to Marketplace')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MediaPickerWidget(
              onChanged: (file) => setState(() => _imageFile = file),
              initialFile: _imageFile,
              size: 120,
              isVideo: false,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Product Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price (AED)'),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Add Product'),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
