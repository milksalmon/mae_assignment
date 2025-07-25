import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboard();
}

class _SavedTab extends StatefulWidget {
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
        Center(
          child: Text(
            'Saved',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
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
        Center(
          child: Text(
            'Reminder',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

// Account Widgets
class _AccountTabState extends State<_AccountTab> {
  // Add state, async calls, etc. here

  @override
  Widget build(BuildContext context) {
    final googleUser = FirebaseAuth.instance.currentUser;
    final googleName = googleUser?.displayName ?? 'No name';
    final googleEmail = googleUser?.email ?? 'No email';
    final googlePhotoUrl = googleUser?.photoURL ?? 'No photo';
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          const Text(
            "Account Details",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey,
            backgroundImage: googlePhotoUrl != null ? NetworkImage(googlePhotoUrl) : null,
            child: googlePhotoUrl == null
                ? const Icon(Icons.person, size: 50, color: Colors.grey)
                : null,
          ),
          const SizedBox(height: 10),
          Text(googleName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(googleEmail, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "0 Following",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              // SizedBox(width: 20),
              // Text(
              //   "0 Followers",
              //   style: TextStyle(fontWeight: FontWeight.bold),
              // ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            child: const Text("Edit Profile"),
          ),
          const SizedBox(height: 30, width: double.infinity),
          sectionTitle("Preferences"),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text("Dark Mode"),
            trailing: Switch(value: false, onChanged: (_) {}),
          ),
          Divider(),
          ListTile(
            leading: const Icon(Icons.workspaces),
            title: const Text("Followed Organisers"),

          ),
          sectionTitle("Connected Accounts"),
          ListTile(
            leading: Image.asset(
              "assets/google.png",
              height: 24,
            ), // Replace with your asset
            title: Text(
              "Google\n$googleEmail",
              style: const TextStyle(height: 1.5),
            ),
            trailing: TextButton(
              onPressed: () {},
              child: const Text("Disconnect"),
            ),
          ),
          // ListTile(
          //   leading: const Icon(Icons.apple),
          //   title: const Text("Apple"),
          //   trailing: TextButton(
          //     onPressed: () {},
          //     child: const Text("Connect"),
          //   ),
          // ),
          sectionTitle("Rules & Regulations"),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text("Privacy Policy"),
            onTap: () {},
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                Provider.of<AppAuthProvider>(context, listen: false).logout();
                Navigator.pushReplacementNamed(context, '/login');
              } catch (e) {
                print('Sign out failed, Error: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            ),
            child: const Text("Sign Out"),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(top: 8, bottom: 8),

      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.pinkAccent),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget Divider() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: double.infinity, vertical: 0.5),
      decoration: BoxDecoration(color: Colors.grey),


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
        backgroundColor: const Color(0xFFFFFFFF),
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
      body: SafeArea(child: _widgetOptions[_selectedIndex]),
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
              Text(
                'Kuala Lumpur',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          // Event list
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder:
                  (context, index) => EventCard(imageName: 'EXPOEVENT.png'),
            ),
          ),
        ],
      ),
    );
  }
}

class EventCard extends StatefulWidget {
  final String imageName;
  const EventCard({this.imageName = 'EXPOEVENT.png', Key? key})
    : super(key: key);

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final ref = FirebaseStorage.instance.ref().child(
        'event_images/${widget.imageName}',
      );
      final url = await ref.getDownloadURL();
      setState(() {
        imageUrl = url;
      });
    } catch (e) {
      // Optionally handle error, e.g. set a default imageUrl or log
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/event_page');
      },
      child: Card(
        color: Color(0xFFF9FDF0),
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child:
                  imageUrl == null
                      ? Container(
                        height: 160,
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      )
                      : Image.network(
                        imageUrl!,
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
                  Text(
                    'Fri, 11th July, 2:30pm',
                    style: TextStyle(color: Colors.red),
                  ),
                  SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black),
                      children: const [
                        TextSpan(
                          text: 'Expo iFood',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
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
                  ),
                ],
              ),
            ),
          ],
        ),
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
        color: Colors.pinkAccent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, color: Colors.white)),
    );
  }
}
