import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mae_assignment/user/userDashboard.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

// Screens
import 'auth/login.dart';
import 'auth/create_account.dart';
import 'admin/admin_dashboard.dart';
import 'home.dart'; // Optional, if you use it

// Providers
import 'providers/auth_provider.dart'; // You should create this if not yet created

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
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
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const CreateAccount(),
        '/adminDashboard': (context) => const AdminDashboard(),
        '/userDashboard': (context) => const UserDashboard(),
        //'/home': (context) => const HomePage(), // optional
      },
    );
  }
}
