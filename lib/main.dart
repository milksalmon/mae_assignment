import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'auth/login.dart';
import 'auth/create_account.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
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
      home: const LoginScreen(), // ← Set your login screen here
    );
  }
}
