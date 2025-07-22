import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

// class UserDashboard extends StatefulWidget {
//   const UserDashboard({super.key});

//   @override
//   State<UserDashboard> createState() => _UserDashboard();
// }

// class _UserDashboard extends State<UserDashboard> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('User Dashboard'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.logout),
//             tooltip: 'Logout',
//             onPressed: () {
//               // TODO: Added logic to signing out and destroy session

//               Navigator.pushNamed(context, '/login');
//             },
//           ),
//         ],
//       ),
//       body: const Center(
//         child: Text(
//           'Test',
//           style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//         ),
//       ),
//     );
//   }
// }

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboard();
}

class _UserDashboard extends State<UserDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: Colors.green,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: "Saved"),
          BottomNavigationBarItem(icon: Icon(Icons.alarm), label: "Reminder"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: Column(
            children: [
              // Search bar with filter icon
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search events...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.filter_alt_outlined),
                ],
              ),
              SizedBox(height: 16),
              // Location
              Row(
                children: const [
                  Icon(Icons.location_on_outlined),
                  SizedBox(width: 4),
                  Text('Events in ', style: TextStyle(fontSize: 16)),
                  Text('Kuala Lumpur',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green)),
                ],
              ),
              SizedBox(height: 16),
              // Event list
              Expanded(
                child: ListView.builder(
                  itemCount: 2,
                  itemBuilder: (context, index) => EventCard(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              'assets/ifood_banner.jpg', // Replace with your image asset
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          // Info section
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fri, 11th July, 2:30pm',
                    style: TextStyle(color: Colors.red)),
                SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.black),
                    children: const [
                      TextSpan(
                          text: 'Expo iFood',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: ' by Pavillion Bukit Jalil'),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: const [
                    EventTag(label: "Coffee"),
                    EventTag(label: "Japanese Food"),
                    EventTag(label: "Pastry"),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class EventTag extends StatelessWidget {
  final String label;

  const EventTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 6),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.pinkAccent.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, color: Colors.white),
      ),
    );
  }
}