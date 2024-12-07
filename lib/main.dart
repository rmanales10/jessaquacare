import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gwapo/firebase_options.dart';
import 'package:gwapo/home/home.dart';
import 'package:gwapo/notification/notif.dart';
import 'package:gwapo/onboarding/page1.dart';
import 'package:gwapo/onboarding/page2.dart';
import 'package:gwapo/onboarding/page3.dart';
import 'package:gwapo/auth_screens/login/signin.dart';
import 'package:gwapo/profile/about.dart';
import 'package:gwapo/profile/profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Aqua Care',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoadingScreen(),
        '/onboard1': (context) => const Onboarding1(),
        '/onboard2': (context) => const Onboarding2(),
        '/signin': (context) => const SignInScreen(),
        // '/forgot': (context) => const ForgotPasswordPage(),
        '/profile': (context) => ProfilePage(),
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
