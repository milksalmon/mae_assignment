import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrganiserDashboard extends StatefulWidget {
  const OrganiserDashboard({Key? key}) : super(key: key);

  @override
  State<OrganiserDashboard> createState() => _OrganiserDashboardState();
}

class _OrganiserDashboardState extends State<OrganiserDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    Center(child: Text("Your Events")),
    Center(child: Text("Notification")),
    Center(child: Text("Account")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
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
      body: Center(
        child: Text(
          'Welcome to the Organiser Dashboard!',
          style: GoogleFonts.montserrat(fontSize: 18),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.green,
        child: BottomNavigationBar(
          selectedLabelStyle: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          backgroundColor: Colors.green,
          selectedItemColor: const Color(0xFFFF2F67),
          unselectedItemColor: Colors.white,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.event),
              label: 'Your Events',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}
