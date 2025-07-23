import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';


class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboard();
}
class _SavedTab extends StatefulWidget{
  const _SavedTab();

  @override
  State<_SavedTab> createState() => _SavedTabState();

}

class _ReminderTab extends StatefulWidget {
  const _ReminderTab();

  @override
  State<_ReminderTab> createState() => _ReminderTabState();


}

class _AccountTab extends StatefulWidget {
  const _AccountTab();

  @override
  State<_AccountTab> createState() => _AccountTabState();
}

class _SavedTabState extends State<_SavedTab> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(child: Text('Saved', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
      ],
    );
  }
}

class _ReminderTabState extends State<_ReminderTab> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Account info, settings, log out button, etc.
        Center(child: Text('Reminder', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
      ],
    );
  }

}


class _AccountTabState extends State<_AccountTab> {
  // Add state, async calls, etc. here

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(child: Text('Saved', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
        // Account info, settings, log out button, etc.
      ],
    );
  }
}


class _UserDashboard extends State<UserDashboard> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    _HomeTab(),
    _SavedTab(),
    _ReminderTab(),
    _AccountTab(),
  ];



  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        indicatorColor: Colors.green,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            selectedIcon: Icon(Icons.bookmark),
            label: "Saved",
          ),
          NavigationDestination(
            icon: Icon(Icons.alarm_outlined),
            selectedIcon: Icon(Icons.alarm),
            label: "Reminder",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: "Account",
          ),
        ],
      ),
      body: SafeArea(
        child: _widgetOptions[_selectedIndex],
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  @override
  Widget build(BuildContext context) {
    return Padding(
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
              'assets/EXPOEVENT.png', // Replace with your image asset
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