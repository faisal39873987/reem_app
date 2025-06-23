import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message.dart';

final supabase = Supabase.instance.client;

/// Stream all messages for the current user (sender or receiver)
/// Uses Supabase RLS policy: auth.uid() = sender_id OR auth.uid() = receiver_id
Stream<List<Message>> userMessagesStream() {
  final user = supabase.auth.currentUser;
  if (user == null) {
    return const Stream.empty();
  }
  // Supabase Flutter does NOT support .or for streams, so we fetch all and filter in Dart.
  // This is a limitation of the current SDK. Backend is secure due to RLS.
  return supabase
      .from('messages')
      .stream(primaryKey: ['id'])
      .order('created_at')
      .map(
        (data) =>
            List<Map<String, dynamic>>.from(data)
                .where(
                  (msg) =>
                      msg['sender_id'] == user.id ||
                      msg['receiver_id'] == user.id,
                )
                .map((msg) => Message.fromMap(msg))
                .toList(),
      );
}

/// Send a message (production ready)
Future<void> sendMessage({
  required String receiverId,
  required String content,
}) async {
  final user = supabase.auth.currentUser;
  if (user == null) throw Exception('Not authenticated');
  await supabase.from('messages').insert({
    'sender_id': user.id,
    'receiver_id': receiverId,
    'content': content,
    'is_read': false,
    'created_at': DateTime.now().toIso8601String(),
  });
}

// To test: call sendMessage and check the Supabase dashboard. Listen to messagesStream for real-time updates.
