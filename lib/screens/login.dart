import 'package:flutter/material.dart';

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
            // 🍧 Logo
            Image.asset(
              'assets/logo.png', // replace with your image path
              height: 120,
            ),

            const SizedBox(height: 20),

            const Text(
              'Login',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.pink,
              ),
            ),

            const SizedBox(height: 30),

            // ✉️ Email
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
                  borderSide: const BorderSide(color: Colors.green),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔒 Password
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

            // ✅ Login Button
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
                onPressed: () {
                  // TODO: Handle login logic
                },
                child: const Text('Login'),
              ),
            ),

            const SizedBox(height: 10),

            // 🔗 Forgot Password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // TODO: Forgot password logic
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

            // 🔵 Google Sign-in Button
            OutlinedButton.icon(
              onPressed: () {
                // TODO: Google Sign-In
              },
              icon: Image.asset(
                'assets/images/google_logo.png',
                height: 24,
              ), // replace with your asset
              label: const Text('Sign in with Google'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.green),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🟢 Sign Up
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?"),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to sign up
                  },
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(color: Colors.green),

                    //                     TextButton(
                    //   onPressed: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => const CreateAccount(),
                    //       ),
                    //     );
                    //   },
                    //   child: const Text(
                    //     "Don't have an account? Sign up",
                    //     style: TextStyle(color: Colors.green),
                    //   ),
                    // ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
