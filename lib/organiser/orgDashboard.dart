import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrganiserDashboard extends StatelessWidget {
  const OrganiserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Organiser Dashboard',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Text(
          'Welcome to the Organiser Dashboard!',
          style: GoogleFonts.montserrat(fontSize: 18),
        ),
      ),
    );
  }
}
