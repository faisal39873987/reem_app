import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Modular, reusable media picker for images/videos with preview, error, and progress handling.
class MediaPickerWidget extends StatefulWidget {
  final void Function(File? file) onChanged;
  final File? initialFile;
  final double size;
  final bool isVideo;
  const MediaPickerWidget({
    super.key,
    required this.onChanged,
    this.initialFile,
    this.size = 150,
    this.isVideo = false,
  });

  @override
  State<MediaPickerWidget> createState() => _MediaPickerWidgetState();
}

class _MediaPickerWidgetState extends State<MediaPickerWidget> {
  File? _file;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _file = widget.initialFile;
  }

  Future<void> _pick() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final picker = ImagePicker();
      final picked =
          widget.isVideo
              ? await picker.pickVideo(source: ImageSource.gallery)
              : await picker.pickImage(source: ImageSource.gallery);
      if (!mounted) return;
      if (picked != null) {
        setState(() => _file = File(picked.path));
        widget.onChanged(_file);
      }
    } catch (e) {
      setState(() => _error = 'Failed to pick media: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pick,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child:
            _loading
                ? const Center(child: CircularProgressIndicator())
                : _file == null
                ? Icon(
                  widget.isVideo ? Icons.videocam : Icons.add_a_photo,
                  size: 50,
                )
                : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child:
                      widget.isVideo
                          ? const Icon(
                            Icons.videocam,
                            size: 50,
                          ) // TODO: Video preview
                          : Image.file(
                            _file!,
                            width: widget.size,
                            height: widget.size,
                            fit: BoxFit.cover,
                          ),
                ),
      ),
    );
  }
}
