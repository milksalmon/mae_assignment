import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mae_assignment/services/auth_services.dart';
import 'package:mae_assignment/services/notification_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/login_jambu.png', // replace with your image path
              height: 120,
            ),

            const SizedBox(height: 20),

            Text(
                  'Login',
                  style: GoogleFonts.montserrat(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                  ),
                ),
            const SizedBox(height: 30),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            //  Password
            TextField(
              controller: passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            //  Login Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () async {
                  final email = emailController.text.trim();
                  final password = passwordController.text.trim();

                  if (emailController.text.isEmpty &&
                      passwordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter credentials')),
                    );
                  } else {
                    try {
                      final auth = FirebaseAuth.instance;
                      final firestore = FirebaseFirestore.instance;

                      // LOGIN WITH EMAIL & PASSWORD
                      final UserCredential = await auth
                          .signInWithEmailAndPassword(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                          );
                      final uid = UserCredential.user!.uid;

                      // Store FCM token for push notifications
                      await NotificationService.ensureFCMTokenStored();

                      //STEP 2: GET ROLE FROM FIRESTORE
                      final userDoc =
                          await firestore.collection('users').doc(uid).get();
                      final role = userDoc.data()?['role'];

                      //STEP 3 NAVIGATE BASED ON ROLE
                      if (role == 'admin') {
                        Navigator.pushReplacementNamed(
                          context,
                          '/adminDashboard',
                        );
                      } else if (role == 'user') {
                        Navigator.pushReplacementNamed(
                          context,
                          '/userDashboard',
                        );
                      } else if (role == 'organiser') {
                        Navigator.pushReplacementNamed(
                          context,
                          '/orgDashboard',
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Access denied')),
                        );
                      }
                    } on FirebaseAuthException catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.message ?? 'Login failed')),
                      );
                    }
                  }
                },
                child: Text(
                  'Login',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            //  Forgot Password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/forgot');
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ),

            const SizedBox(height: 10),

            const Text("Or", style: TextStyle(fontSize: 16)),

            const SizedBox(height: 10),

            //  Google Sign in Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () async {
                  UserCredential? user = await AuthService().signInWithGoogle();
                  if (user != null) {
                    final uid = user.user!.uid;

                    // Store FCM token for push notifications
                    await NotificationService.ensureFCMTokenStored();

                    final doc =
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(uid)
                            .get();

                    final role = doc.data()?['role'];

                    // final firestore = FirebaseFirestore.instance;
                    // final userDoc =
                    //     await firestore.collection('users').doc(uid).get();
                    // final role = userDoc.data()?['role'];

                    if (role == 'admin') {
                      Navigator.pushReplacementNamed(
                        context,
                        '/adminDashboard',
                      );
                    } else if (role == 'user') {
                      Navigator.pushReplacementNamed(context, '/userDashboard');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Access denied: unknown role'),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Google Sign-In failed')),
                    );
                  }
                },

                icon: Image.asset('assets/google.png', height: 24),
                label: const Text('Sign in with Google'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.green),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 25, height: 20),

            // Sign Up
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?"),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green, // default text color
                  ).copyWith(
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.hovered)) {
                        return const Color.fromRGBO(
                          255,
                          47,
                          103,
                          100,
                        ); // on hover
                      }
                      return Colors.green; // default
                    }),
                  ),

                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
