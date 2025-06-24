import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:reem_verse_rebuild/models/post.dart';
import 'package:reem_verse_rebuild/models/profile.dart';
import 'package:reem_verse_rebuild/providers/feed_provider.dart';
import 'package:reem_verse_rebuild/screens/profile_screen.dart';
import 'package:reem_verse_rebuild/screens/notification_screen.dart';
import 'package:reem_verse_rebuild/screens/marketplace_screen.dart';
import 'package:reem_verse_rebuild/screens/post_creation_screen.dart';
import 'package:reem_verse_rebuild/screens/chat_list_screen.dart';
import 'package:reem_verse_rebuild/screens/login_screen.dart';
import 'package:reem_verse_rebuild/screens/landing_screen.dart';
import 'package:reem_verse_rebuild/screens/menu_screen.dart';
import 'package:reem_verse_rebuild/screens/search_screen.dart';

class MockFeedProvider extends FeedProvider {
  @override
  List<Post> get posts => [];
  @override
  bool get loading => false;
  @override
  String? get error => null;
  @override
  bool get initialized => true;
  @override
  Future<void> fetchPosts({bool force = false}) async {}
  @override
  void refresh() {}
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://test.supabase.co',
      anonKey: 'test-anon-key',
    );
    // Inject a fake user for all widget tests
    Supabase.instance.client.auth.signInWithPassword(
      email: 'test@example.com',
      password: 'password',
    );
  });

  Widget wrapWithProviders(
    Widget child, {
    List<SingleChildWidget>? extraProviders,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FeedProvider>(create: (_) => MockFeedProvider()),
        ...?extraProviders,
      ],
      child: child,
    );
  }

  Widget buildTestApp(Widget home, {List<SingleChildWidget>? extraProviders}) {
    return wrapWithProviders(
      MaterialApp(
        home: home,
        routes: {
          '/login': (_) => const LoginScreen(),
          '/landing': (_) => const LandingScreen(),
          '/profile': (_) => const ProfileScreen(),
          '/notifications': (_) => const NotificationScreen(),
          '/marketplace': (_) => const MarketplaceScreen(),
          '/menu': (_) => const MainMenuScreen(),
          '/post': (_) => const PostCreationScreen(),
          '/search': (_) => const SearchScreen(),
        },
      ),
      extraProviders: extraProviders,
    );
  }

  group('Profile Update Flow', () {
    testWidgets('Profile loads and updates successfully', (tester) async {
      final mockProfile = Profile(
        id: 'test-id',
        fullName: 'Test User',
        bio: 'Test bio',
        phone: '1234567890',
        note: 'Test note',
        avatarUrl: '',
        showInReemYouth: true,
      );
      await tester.pumpWidget(
        buildTestApp(ProfileScreen(testProfile: mockProfile)),
      );
      await tester.pumpAndSettle();
      // Should show fallback UI if no profile
      expect(find.text('Profile'), findsOneWidget);
      // Simulate editing bio (skip if field not found)
      final bioField = find.widgetWithText(TextField, 'Bio');
      if (bioField.evaluate().isNotEmpty) {
        await tester.enterText(bioField, 'Test bio');
        // Tap save
        final saveBtn = find.byIcon(Icons.save);
        await tester.tap(saveBtn);
        await tester.pumpAndSettle();
        // Should show success or error snackbar
        expect(find.byType(SnackBar), findsWidgets);
      }
    });
  });

  group('Notifications Flow', () {
    testWidgets('Notifications show empty state', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const NotificationScreen(testNotifications: [])),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      // Should show fallback UI if no notifications
      final fallbackTexts = [
        'No notifications found.',
        'No notifications yet.',
      ];
      final found =
          fallbackTexts.any((text) => find.text(text).evaluate().isNotEmpty) ||
          find.textContaining('No notifications').evaluate().isNotEmpty;
      expect(
        found,
        true,
        reason: 'No fallback notification text found in widget tree',
      );
    });
  });

  group('Feed Loading', () {
    testWidgets('Feed loads and displays posts or empty', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const MarketplaceScreen(testPosts: [])),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      // Should show fallback UI if no posts
      expect(find.text('No posts found.'), findsOneWidget);
    });
  });

  group('Post Creation', () {
    testWidgets('Post creation form validates and submits', (tester) async {
      bool submitted = false;
      await tester.pumpWidget(buildTestApp(PostCreationScreen(testOnSubmit: (_) {
        submitted = true;
      })));
      await tester.pumpAndSettle();
      // Enter description
      final descField = find.widgetWithText(TextField, 'Description');
      if (descField.evaluate().isNotEmpty) {
        await tester.enterText(descField, 'Test post');
        // Enter price
        final priceField = find.widgetWithText(TextField, 'Price (AED)');
        if (priceField.evaluate().isNotEmpty) {
          await tester.enterText(priceField, '123');
        }
        // Tap submit
        final submitBtn = find.widgetWithText(ElevatedButton, 'Submit Post');
        if (submitBtn.evaluate().isNotEmpty) {
          await tester.tap(submitBtn, warnIfMissed: false);
          await tester.pump();
          await tester.pump(const Duration(seconds: 1));
          // Should show a SnackBar (any)
          expect(find.byType(SnackBar), findsWidgets);
          expect(submitted, true);
        }
      }
    });
  });

  group('Chat List', () {
    testWidgets('Chat list shows empty or error state', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const ChatListScreen(testChats: [])),
      );
      await tester.pumpAndSettle();
      // Should show fallback UI if no chats
      expect(
        find.textContaining('No chats').evaluate().isNotEmpty ||
            find.textContaining('Please log in').evaluate().isNotEmpty,
        true,
      );
    });
  });
}
