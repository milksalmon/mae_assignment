import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'orgAccount.dart';
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

  @override
  void initState() {
    super.initState();
    fetchOrganiserStatus();
  }

  Future<void> fetchOrganiserStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    final doc =
        await FirebaseFirestore.instance
            .collection('organisers')
            .doc(user!.uid)
            .get();

    if (doc.exists) {
      setState(() {
        organiserStatus = doc['status'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      organiserStatus.toLowerCase() == "approved"
          ? accountApprovedWidget(
            context,
          ) //to help with merging yes accept this one
          : pendingApprovalWidget(),
      Center(child: Text("Notification")),
      OrganiserAccountTab(
        swipeNavigationEnabled: true,
        onSwipeNavigationChanged: (value) {
          //accept this for merge
          // Handle swipe state if needed
        },
      ),
    ];

    return Scaffold(
      appBar:
          _selectedIndex == 0
              ? AppBar(
                automaticallyImplyLeading: false,
                title: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      Image.asset('assets/logo.png', height: 80, width: 80),
                      const SizedBox(width: 12),
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
              )
              : null,
      body: pages[_selectedIndex],
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
            style: GoogleFonts.montserrat(fontSize: 16, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            "If you have any inquiries, reach out to us.",
            style: GoogleFonts.montserrat(fontSize: 16, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

@override //are u merging hahaha yes accept this
Widget accountApprovedWidget(BuildContext context) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UploadEventForm()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.pink),
                  const SizedBox(width: 8),
                  Text(
                    "UPLOAD EVENT",
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.pink,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
