import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'orgDashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class OrganiserRegister extends StatefulWidget {
  const OrganiserRegister({super.key});

  @override
  State<OrganiserRegister> createState() => _OrganiserRegisterState();
}

class _OrganiserRegisterState extends State<OrganiserRegister> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _orgNameController = TextEditingController();
  final _picNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  File? _permitFile;
  File? _ssmFile;

  void _pickPermitFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      setState(() {
        _permitFile = File(result.files.single.path!);
      });
    }
  }

  void _pickSSMFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      setState(() {
        _ssmFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _registerOrganiser() async {
    final organiserName = _orgNameController.text.trim();

    if (_formKey.currentState!.validate()) {
      if (_permitFile == null || _ssmFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload both Permit and SSM files.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        // Create organiser account
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        final uid = userCredential.user?.uid;
        if (uid == null) throw Exception('User ID not found');

        // Upload files to Firebase Storage
        final permitRef = FirebaseStorage.instance.ref().child(
          'organisers/$organiserName/attachment/permit.${_permitFile!.path.split('.').last}',
        );
        final ssmRef = FirebaseStorage.instance.ref().child(
          'organisers/$organiserName/attachment/ssm.${_ssmFile!.path.split('.').last}',
        );

        final permitUploadTask = permitRef.putFile(_permitFile!);
        final ssmUploadTask = ssmRef.putFile(_ssmFile!);

        final permitSnapshot = await permitUploadTask;
        final ssmSnapshot = await ssmUploadTask;

        final permitUrl = await permitSnapshot.ref.getDownloadURL();
        final ssmUrl = await ssmSnapshot.ref.getDownloadURL();

        // Save organiser details to Firestore
        await FirebaseFirestore.instance.collection('organisers').doc(uid).set({
          'createdAt': FieldValue.serverTimestamp(),
          'organizationName': _orgNameController.text.trim(),
          'picName': _picNameController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
          'attachments': [permitUrl, ssmUrl],
          'description': '',
          'status': 'Pending',
        });

        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'createdAt': FieldValue.serverTimestamp(),
          'name': _picNameController.text.trim(),
          'email': _emailController.text.trim(),
          'role': 'organiser',
        });

        // Optionally send email verification
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
          MaterialPageRoute(builder: (context) => const OrganiserDashboard()),
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Registration failed')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F3),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Register',
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                'Organisation Name',
                _orgNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your organisation name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildTextField(
                'PIC Name',
                _picNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter the person in charge name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildTextField(
                'Phone Number',
                _phoneController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your phone number';
                  } else if (!RegExp(r'^\d{10,11}$').hasMatch(value)) {
                    return 'Enter a valid 10–11 digit number';
                  }
                  return null;
                },
              ),
            const SizedBox(height: 12),
            _buildTextField(
              'Email',
              _emailController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }

                  final emailRegex = RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+(com|org|net|my|edu)$',
                  );
                  if (!emailRegex.hasMatch(value)) {
                    return 'Please enter a valid email like user@email.com';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildTextField(
                'Password',
                _passwordController,
                obscure: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildTextField(
                'Confirm Password',
                _confirmPasswordController,
                obscure: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // File pickers
              ElevatedButton(
                onPressed: _pickPermitFile,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                child: Text(
                  _permitFile == null
                      ? 'Upload Permit'
                      : 'Permit Selected: ${_permitFile?.path.split('/').last ?? 'No file selected'}',
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _pickSSMFile,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                child: Text(
                  _ssmFile == null
                      ? 'Upload SSM'
                      : 'SSM Selected: ${_ssmFile?.path.split('/').last ?? 'No file selected'}',
                ),
              ),

              const SizedBox(height: 24),

              // Register button
              ElevatedButton(
                onPressed: _registerOrganiser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Register',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
