//import 'dart:nativewrappers/_internal/vm/lib/ffi_native_type_patch.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboard();
}

class _UserDashboard extends State<UserDashboard> {
  int _selectedIndex = 0;

  // PAGES FOR EACH TAB
  final List<Widget> _pages = [
    Center(child: Text('Home Page', style: TextStyle(fontSize: 24))),
    Center(child: Text('Event Page', style: TextStyle(fontSize: 24))),
    Center(child: Text('Profile Page', style: TextStyle(fontSize: 24))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('User Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex], // TO SHOW SELECTED PAGES
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        backgroundColor: Colors.lightGreen,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
      bottomSheet: Container(
        color: Colors.white,
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // NEED TO USED ELEVATED BUTTON TO WRAP IT AND HAVE A GAP EQUALLY
            // CANNOT USED SIZED BOX SINCE IT HARD TO MANAGE THE WIDTH
            ElevatedButton(
              onPressed: () {
                print('Button 1 Pressed');
              },
              child: Text('Delete'),
            ),
            ElevatedButton(
              onPressed: () {
                print('Button 2 Pressed');
              },
              child: Text('Block'),
            ),
            ElevatedButton(
              onPressed: () {
                print('Button 3 Pressed');
              },
              child: Text('Update'),
            ),
          ],
        ),
        // child: SizedBox(
        //   width: double.infinity,
        //   child: ElevatedButton(
        //     onPressed: () {
        //       print('Button Pressed');
        //     },
        //     child: Text('Continue'),
        //   ),
        // ),
      ),
    );
  }
}
