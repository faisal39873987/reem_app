// lib/utils/constants.dart
import 'package:flutter/material.dart';

// 🔵 ألوان المشروع الرسمية
const Color kPrimaryColor = Color(0xFF1877F2); // الأزرق الريمي
const Color kSecondaryColor = Color(0xFF1C93D6);
const Color kAccentColor = Color(0xFF00C6FF);
const Color kTextDark = Color(0xFF222222);
const Color kTextLight = Color(0xFF888888);
const Color kBackgroundColor = Colors.white;

// 🔤 نصوص ثابتة تستخدم في أكثر من مكان
const String kAppName = "ReemVerse";
const String kDefaultAvatar = "https://i.pravatar.cc/300";

// 🕓 Durations & Timings
const Duration kSplashDelay = Duration(seconds: 3);
const Duration kPageTransition = Duration(milliseconds: 300);

// 🔣 مفاتيح الحفظ المحلية
const String kPrefIsLoggedIn = 'isLoggedIn';
const String kPrefIsFirstTime = 'isFirstTime';
const String kPrefIntroDone = 'intro_done';

// 🗂️ Collections في Firestore
const String kPostsCollection = 'posts';
const String kServicesCollection = 'services';
const String kUsersCollection = 'users';
const String kChatsCollection = 'chats';
const String kNotificationsCollection = 'notifications';
