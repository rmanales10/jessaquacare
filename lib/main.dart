import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:gwapo/home/home.dart';
import 'package:gwapo/home/view_fish.dart';
import 'package:gwapo/notification/notif.dart';
import 'package:gwapo/auth_screens/forgot.dart';
import 'package:gwapo/onboarding/page1.dart';
import 'package:gwapo/onboarding/page2.dart';
import 'package:gwapo/onboarding/page3.dart';
import 'package:gwapo/auth_screens/login/signin.dart';

import 'package:gwapo/profile/about.dart';
import 'package:gwapo/profile/profile.dart';
import 'package:gwapo/profile/profile_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyBEsroKVNz6iT6c2wGrO4rxiDZ6H5nSzdY",
          authDomain: "aquacare-1ce87.firebaseapp.com",
          projectId: "aquacare-1ce87",
          storageBucket: "aquacare-1ce87.firebasestorage.app",
          messagingSenderId: "623546761262",
          appId: "1:623546761262:web:753ac348b7c264996edfbf"));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AquaCare',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoadingScreen(),
        '/onboard1': (context) => Onboarding1(),
        '/onboard2': (context) => const Onboarding2(),
        '/signin': (context) => const SignInScreen(),
        // '/forgot': (context) => const ForgotPasswordPage(),
        '/profile': (context) => const ProfilePage(),
        // '/profileSettings': (context) => const ProfileSettingsPage(),
        '/about': (context) => const AboutPage(),
        '/home': (context) => const HomePage(),
        // '/add': (context) => const ScheduleActivitiesPage(),
        // '/view': (context) => const ScheduledActivitiesPage(),
        '/notif': (context) => const NotificationPage(),
      },
    );
  }
}
