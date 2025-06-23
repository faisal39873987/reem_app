// lib/utils/constants.dart
import 'package:flutter/material.dart';

// 🔵 ألوان المشروع الرسمية
const Color kPrimaryColor = Color(0xFF007AFF); // unified blue
const Color kSecondaryColor = Colors.white;
const Color kAccentColor = Color(0xFF007AFF); // blue accent
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

// رابط و مفتاح سوبر بايس
const String supabaseUrl = 'https://achyjrdkriusgdbxvswl.supabase.co';
const String supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFjaHlqcmRrcml1c2dkYnh2c3dsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDkwMjE5MTIsImV4cCI6MjA2NDU5NzkxMn0.NLFeeZbuaUuTEIC6U6Dmvj04R066N8kMS2QWrLs1A58';
