import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'services/auth_service.dart';
import 'auth/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/admin_screen.dart';

Future<void> main() async {
  final sw = Stopwatch()..start();
  WidgetsFlutterBinding.ensureInitialized();

  // Performance Fix: Disable runtime fetching to avoid UI thread blocks
  GoogleFonts.config.allowRuntimeFetching = false;
  GoogleFonts.config.allowRuntimeFetching = false;

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Do not await this, as fetching the FCM token can hang and prevent the app from starting.
  NotificationService.initialize();

  log('App Startup Time: ${sw.elapsedMilliseconds}ms');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SupportFlow Platform',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  String? _role;

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  Future<void> _checkUser() async {
    final sw = Stopwatch()..start();
    User? user = _authService.getCurrentUser();
    if (user != null) {
      _role = await _authService.getUserRole(user.uid);
      // Sync FCM token asynchronously in the background
      _authService.saveFcmToken(user.uid);

      if (_role == 'admin') {
        try {
          await FirebaseMessaging.instance.subscribeToTopic('admins');
        } catch (e) {
          log('Topic subscription failed: $e');
        }
      } else {
        try {
          await FirebaseMessaging.instance.unsubscribeFromTopic('admins');
        } catch (e) {
          log('Topic unsubscription failed: $e');
        }
      }
    }
    setState(() {
      _isLoading = false;
    });
    log('AuthWrapper User Check Time: ${sw.elapsedMilliseconds}ms');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_authService.getCurrentUser() == null) {
      return const LoginScreen();
    }

    if (_role == 'admin') {
      return const AdminScreen();
    }

    return const HomeScreen();
  }
}
