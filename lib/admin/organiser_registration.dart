import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class OrganiserRegistration extends StatefulWidget {
  const OrganiserRegistration({super.key});

  @override
  State<OrganiserRegistration> createState() => _OrganiserRegistration();
}

class _OrganiserRegistration extends State<OrganiserRegistration> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/adminDashboard');
          },
        ),
        title: const Text('Organiser Registration'),
      ),
    );
  }
}
