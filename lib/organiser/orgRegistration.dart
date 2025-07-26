import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'orgDashboard.dart';

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

  void _registerOrganiser() {
    if (_formKey.currentState!.validate()) {
      if (_permitFile == null || _ssmFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload both Permit and SSM files.'),
            backgroundColor: Colors.red,
          ),
        );
        return; // Stop registration if files are missing
      }

      // TODO: Upload files, validate data, save to backend

      // Navigate to organiser dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OrganiserDashboard()),
      );
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
      appBar: AppBar(
        title: Text(
          'Register',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
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
              _buildTextField('Organization Name', _orgNameController),
              const SizedBox(height: 12),
              _buildTextField('PIC Name', _picNameController),
              const SizedBox(height: 12),
              _buildTextField('Phone Number', _phoneController),
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
