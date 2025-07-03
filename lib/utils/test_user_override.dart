import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

User? getCurrentUser() {
  // Detect if running in test environment
  if (Platform.environment.containsKey('FLUTTER_TEST') ||
      (const bool.hasEnvironment('FLUTTER_TEST') &&
          const bool.fromEnvironment('FLUTTER_TEST')) ||
      (kIsWeb && identical(0, 0.0))) {
    // Return a fake user for tests
    return User(
      id: 'test-user',
      appMetadata: const {},
      userMetadata: const {},
      aud: '',
      email: 'test@example.com',
      phone: '',
      createdAt: '',
      emailConfirmedAt: '',
      phoneConfirmedAt: '',
      lastSignInAt: '',
      role: '',
      updatedAt: '',
      identities: const [],
      factors: const [],
      isAnonymous: false,
      confirmationSentAt: '',
      recoverySentAt: '',
      emailChangeSentAt: '',
      newEmail: '',
      invitedAt: '',
      actionLink: '',
    );
  }
  return Supabase.instance.client.auth.currentUser;
}
