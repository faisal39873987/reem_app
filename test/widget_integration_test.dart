import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reem_verse_rebuild/screens/profile_screen.dart';
import 'package:reem_verse_rebuild/screens/notification_screen.dart';
import 'package:reem_verse_rebuild/screens/marketplace_screen.dart';
import 'package:reem_verse_rebuild/screens/post_creation_screen.dart';
import 'package:reem_verse_rebuild/screens/chat_list_screen.dart';

void main() {
  group('Profile Update Flow', () {
    testWidgets('Profile loads and updates successfully', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
      await tester.pumpAndSettle();
      // Should show loading then profile fields
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Profile'), findsOneWidget);
      // Simulate editing bio
      final bioField = find.widgetWithText(TextField, 'Bio');
      await tester.enterText(bioField, 'Test bio');
      // Tap save
      final saveBtn = find.byIcon(Icons.save);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();
      // Should show success snackbar
      expect(find.textContaining('Profile updated'), findsOneWidget);
    });
  });

  group('Notifications Flow', () {
    testWidgets('Notifications show empty state', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: NotificationScreen()));
      await tester.pumpAndSettle();
      // Should show loading then empty state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      expect(find.textContaining('No notifications yet.'), findsWidgets);
    });
  });

  group('Feed Loading', () {
    testWidgets('Feed loads and displays posts or empty', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: MarketplaceScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(ListView), findsWidgets);
      // Should show fallback UI if no posts
      expect(find.textContaining('No posts'), findsWidgets);
    });
  });

  group('Post Creation', () {
    testWidgets('Post creation form validates and submits', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: PostCreationScreen()));
      await tester.pumpAndSettle();
      // Enter description
      await tester.enterText(
        find.widgetWithText(TextField, 'Description'),
        'Test post',
      );
      // Enter price
      await tester.enterText(
        find.widgetWithText(TextField, 'Price (AED)'),
        '123',
      );
      // Tap submit
      final submitBtn = find.widgetWithText(ElevatedButton, 'Submit Post');
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();
      // Should show success or error snackbar
      expect(find.byType(SnackBar), findsWidgets);
    });
  });

  group('Chat List', () {
    testWidgets('Chat list shows empty or error state', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ChatListScreen()));
      await tester.pumpAndSettle();
      // Should show loading then empty/error state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      expect(
        find.textContaining('No chats yet').evaluate().isNotEmpty ||
            find.textContaining('Please log in').evaluate().isNotEmpty,
        true,
      );
    });
  });
}
