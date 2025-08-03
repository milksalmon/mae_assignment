import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mae_assignment/admin/manage_feedback.dart';
import 'package:mae_assignment/admin/organiser_registration.dart';
import 'package:mae_assignment/auth/forgot_password.dart';
import 'package:mae_assignment/organiser/orgDashboard.dart';
import 'package:provider/provider.dart';
import 'package:mae_assignment/organiser/orgRegistration.dart';
import 'firebase_options.dart';

// screens
import 'user/userDashboard.dart';
import 'auth/login.dart';
import 'auth/create_account.dart';
import 'admin/admin_dashboard.dart';
import 'admin/account_management.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';

// Services
import 'services/notification_service.dart';

Future<void> main() async {
  await startApp();
}

Future<void> startApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize FCM notifications
  await NotificationService.initialize();
  
  // Clean up expired reminders
  await NotificationService.cleanupExpiredReminders();

  final notificationSettings = await FirebaseMessaging.instance
      .requestPermission(provisional: true);

  try {
    final apnsToken = await FirebaseMessaging.instance.getToken();
    if (apnsToken != null) {
      print('FCM Token is:' + apnsToken);
      
      // Store FCM token if user is already logged in
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await NotificationService.ensureFCMTokenStored();
      }
    }
  } catch (e) {
    print('Error fetching FCM token: $e');
  }

  FirebaseMessaging.instance.onTokenRefresh
      .listen((fcmToken) {})
      .onError((err) {});

  await FirebaseMessaging.instance.setAutoInitEnabled(true);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppAuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // Add other providers here if needed
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Jambu',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.themeData,
          routes: {
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const CreateAccount(),
            '/adminDashboard': (context) => const AdminDashboard(),
            '/userDashboard': (context) => const UserDashboard(),
            '/organiserRegister': (context) => const OrganiserRegistration(),
            '/manageFeedback': (context) => const ManageFeedback(),
            '/OAM': (context) => const OrganizerAccountManagement(),
            //'/event_page': (context) => const EventPage(),
            '/orgReg': (context) => const OrganiserRegister(),
            '/forgot': (context) => const ForgotPasswordScreen(),
            '/orgDashboard': (context) => const OrganiserDashboard(),
            //'/home': (context) => const HomePage(), // optional
          },
          home: AuthGate(),
        );
      },
    );
  }
}

// FCM TOKEN METHOD
// Future<void> _saveFcmToken(String uid) async {
//   try {
//     final fcmToken = await FirebaseMessaging.instance.getToken();
//     if (fcmToken != null) {
//       await FirebaseFirestore.instance.collection('organisers').doc(uid).update(
//         {'fcmToken': fcmToken},
//       );
//       print('FCM token saved for organiser: $fcmToken');
//     }
//   } catch (e) {
//     print('Error saving FCM token: $e');
//   }
// }

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const LoginScreen();
    } else {
      // FETCH USER ROLE FROM FIRESTORE (non-async workaround using FutureBuilder)
      return FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const LoginScreen();
          }

          final role = snapshot.data?.get('role');

          if (role == 'admin') {
            return const AdminDashboard();
          } else if (role == 'user') {
            return const UserDashboard();
          } else if (role == 'organiser') {
            // _saveFcmToken(user.uid);
            return const OrganiserDashboard();
          } else {
            return const LoginScreen();
          }
        },
      );
    }
  }
}
