import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class OrganizerAccountManagement extends StatefulWidget {
  const OrganizerAccountManagement({super.key});

  @override
  State<OrganizerAccountManagement> createState() =>
      _OrganizerAccountManagementState();
}

class _OrganizerAccountManagementState
    extends State<OrganizerAccountManagement> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, '/adminDashboard');
          },
        ),
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 50),
            // const SizedBox(width: 5),
            Expanded(
              child: Text(
                'Organiser Account Management',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
            //const Text('Account Management'),
          ],
        ),
      ),
      //backgroundColor: Colors.red[300],

      // BODY START HERE
    );
  }
}
