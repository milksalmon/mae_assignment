import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mae_assignment/admin/manage_feedback.dart';
import 'package:mae_assignment/admin/organiser_registration.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// screens
import 'user/userDashboard.dart';
import 'auth/login.dart';
import 'auth/create_account.dart';
import 'admin/admin_dashboard.dart';
import 'home.dart';
import 'user/event_page.dart';
import 'admin/account_management.dart';

// Providers
import 'providers/auth_provider.dart'; // You should create this if not yet created

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // You may set the permission requests to "provisional" which allows the user to choose what type
  // of notifications they would like to receive once the user receives a notification.
  final notificationSettings = await FirebaseMessaging.instance
      .requestPermission(provisional: true);

  // For apple platforms, ensure the APNS token is available before making any FCM plugin API calls
  final apnsToken = await FirebaseMessaging.instance.getToken();
  if (apnsToken != null) {
    // APNS token is available, make FCM plugin API requests...
    print('FCM Token is:' + apnsToken);
  }

  FirebaseMessaging.instance.onTokenRefresh
      .listen((fcmToken) {
        // TODO: If necessary send token to application server.

        // Note: This callback is fired at each app startup and whenever a new
        // token is generated.
      })
      .onError((err) {
        // Error getting token.
      });

  await FirebaseMessaging.instance.setAutoInitEnabled(true);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppAuthProvider()),
        // Add other providers here if needed
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const _googleClientId =
      '117949893379-n8l75r4vm1f3gu3h4ocs23jfrmfkkb17.apps.googleusercontent.com';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jambu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const CreateAccount(),
        '/adminDashboard': (context) => const AdminDashboard(),
        '/userDashboard': (context) => const UserDashboard(),
        '/organiserRegister': (context) => const OrganiserRegistration(),
        '/manageFeedback': (context) => const ManageFeedback(),
        '/OAM': (context) => const OrganizerAccountManagement(),
        '/event_page': (context) => const EventPage(),
        //'/home': (context) => const HomePage(), // optional
      },
      home: AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const LoginScreen();
    } else {
      return const UserDashboard();
    }
  }
}
