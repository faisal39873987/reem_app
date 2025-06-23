import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

/// Uploads a file to Supabase Storage and returns the public URL
Future<String> uploadImage(File file, String bucket, String fileName) async {
  final bytes = await file.readAsBytes();
  final storageResponse = await supabase.storage
      .from(bucket)
      .uploadBinary(
        fileName,
        bytes,
        fileOptions: const FileOptions(upsert: true),
      );
  if (storageResponse.isEmpty) throw Exception('Upload failed');
  final publicUrl = supabase.storage.from(bucket).getPublicUrl(fileName);
  return publicUrl;
}

// To test: call uploadImage with a File, bucket name (e.g. 'avatars'), and a unique fileName. Check Supabase Storage and returned URL.
