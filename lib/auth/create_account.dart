import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../organiser/orgRegistration.dart';
import '../user/userDashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  // final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void _createAccount() async {
    if (_formKey.currentState!.validate()) {
      if (passwordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
        return;
      }
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text.trim(),
            );

        await userCredential.user?.updateDisplayName(
          '${nameController.text}',
        );

        // Save to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user?.uid)
            .set({
              'createdAt': FieldValue.serverTimestamp(),
              'name': nameController.text.trim(),
              // 'lastName': lastNameController.text.trim(),
              'email': emailController.text.trim(),
              'role': 'user',
            });

        // Send email verification
        await userCredential.user?.sendEmailVerification();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Account created! Please check your email to verify your account.',
            ),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserDashboard()),
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Registration failed')),
        );
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    // lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create an Account',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFFF2F67),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: const Color.fromARGB(255, 246, 245, 245),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 10),

                // Center(
                //   child: Text(
                //     "Create an Account",
                //     style: GoogleFonts.montserrat(
                //       fontSize: 40,
                //       fontWeight: FontWeight.w800, //extra bold
                //       color: const Color(0xFFFF2F67),
                //     ),
                //   ),
                // ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: GoogleFonts.montserrat(),
                    border: const OutlineInputBorder(),
                  ),
                  validator:
                      (value) =>
                          value!.isEmpty
                              ? 'Please enter your name'
                              : null,
                ),
                // const SizedBox(height: 20),
                // TextFormField(
                //   controller: lastNameController,
                //   decoration: InputDecoration(
                //     labelText: 'Last Name',
                //     labelStyle: GoogleFonts.montserrat(),
                //     border: const OutlineInputBorder(),
                //   ),
                //   validator:
                //       (value) =>
                //           value!.isEmpty ? 'Please enter your last name' : null,
                // ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: GoogleFonts.montserrat(),
                    border: const OutlineInputBorder(),
                  ),
                  validator:
                      (value) =>
                          value!.isEmpty ? 'Please enter your email' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: GoogleFonts.montserrat(),
                    border: const OutlineInputBorder(),
                  ),
                  validator:
                      (value) =>
                          value!.length < 6
                              ? 'Password must be at least 6 characters'
                              : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    labelStyle: GoogleFonts.montserrat(),
                    border: const OutlineInputBorder(),
                  ),
                  validator:
                      (value) =>
                          value!.isEmpty
                              ? 'Please confirm your password'
                              : null,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _createAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),

                  child: Text(
                    'Sign Up',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20), // spacing
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/orgReg');
                  },
                  child: Text(
                    'Register as an Event Organiser',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
