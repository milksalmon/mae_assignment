import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'upload_event.dart';

String organiserStatus = "pending"; // Default: pending

class OrganiserDashboard extends StatefulWidget {
  const OrganiserDashboard({Key? key}) : super(key: key);

  @override
  State<OrganiserDashboard> createState() => _OrganiserDashboardState();
}

class _OrganiserDashboardState extends State<OrganiserDashboard> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    organiserStatus == "approved"
        ? UploadEventForm()
        : pendingApprovalWidget(), // Show UploadEventForm if approved, else show OrganiserRegister
    Center(child: Text("Your Events")),
    Center(child: Text("Notification")),
    Center(child: Text("Account")),
  ];

//   @override
// void initState() {
//   super.initState();
//   fetchOrganiserStatus();
// }

// Future<void> fetchOrganiserStatus() async {
//   final user = FirebaseAuth.instance.currentUser;
//   final doc = await FirebaseFirestore.instance.collection('organisers').doc(user!.uid).get();

//   if (doc.exists) {
//     setState(() {
//       organiserStatus = doc['status']; // e.g., 'approved' or 'pending'
//     });
//   }
// }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Row(
            children: [
              Image.asset('assets/logo.png', height: 80, width: 80),
              const SizedBox(width: 12),
              // Welcome text
              Text(
                'Welcome',
                style: GoogleFonts.montserrat(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),
      body: _pages[_selectedIndex],

      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFFECEFE6),
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        indicatorColor: Colors.green,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: "Your Events",
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: "Notifications",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: "Account",
          ),
        ],
      ),
    );
  }
}
Widget pendingApprovalWidget() {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 60, color: Colors.pink),
          const SizedBox(height: 20),
          Text(
            "Account Pending Approval",
            style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            "You are allowed to post events after your account is approved.",
            style: GoogleFonts.montserrat(
              fontSize: 16,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            "If you have any inquiries, reach out to us.",
            style: GoogleFonts.montserrat(
              fontSize: 16,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
