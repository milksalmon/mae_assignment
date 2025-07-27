import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final bool swipeNavigationEnabled;
  final ValueChanged<bool>? onSwipeNavigationChanged;

  const _AccountTab({
    Key? key,
    this.swipeNavigationEnabled = true,
    this.onSwipeNavigationChanged,
  }) : super(key: key);

  @override
  State<_AccountTab> createState() => _AccountTabState();
}

class _SavedTabState extends State<_SavedTab> {
  @override
  Widget build(BuildContext context) {
    // Replace with your actual saved events data
    final savedEvents = [
      'EXPOEVENT.png',
      'COFFEEFEST.png',
      // Add more saved event image names here
    ];

    return Column(
      children: [
        const SizedBox(height: 20),
        Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(left: 20),
                child: Text(
                  "Saved Events", 
                  style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFFFF2F67)),
                ),
              ),
          ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListView.builder(
              itemCount: savedEvents.length,
              itemBuilder: (context, index) {
                return EventCard(imageName: savedEvents[index]);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ReminderTabState extends State<_ReminderTab> {
  @override
  Widget build(BuildContext context) {
    // Replace with your actual reminder data
    final reminders = [
      {'title': 'Expo iFood', 'date': 'Fri, 11th July, 2:30pm'},
      {'title': 'Coffee Fest', 'date': 'Sat, 12th July, 10:00am'},
    ];

    return Column(
      children: [
        const SizedBox(height: 20),
        Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(left: 20),
                child: Text(
                  "Reminders", 
                  style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFFFF2F67)),
                ),
              ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: Icon(Icons.event_note, color: Colors.green),
                  title: Text(reminder['title']!),
                  subtitle: Text(reminder['date']!),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // Remove reminder logic
                    },
                  ),
                ),
              );
            },
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
    final googlePhotoUrl = googleUser?.photoURL;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(left: 20),
                child: Text(
                  "Account", 
                  style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFFFF2F67)),
                ),
              ),
          ),
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey,
            backgroundImage: (googlePhotoUrl != null && googlePhotoUrl.isNotEmpty)
                ? NetworkImage(googlePhotoUrl)
                : null,
            child: (googlePhotoUrl == null || googlePhotoUrl.isEmpty)
                ? const Icon(Icons.person, size: 50, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 10),
          Text(
            googleName,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(googleEmail, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  onPressed: () {},
                  child: const Text(
                    "0 Following",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
              ),
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
            child: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 30, width: double.infinity),
          sectionTitle("Preferences"),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text("Dark Mode"),
            trailing: Switch(value: false, onChanged: (_) {}),
          ),
          Divider(),
          // Tab Swipe toggle
          ListTile(
            leading: const Icon(Icons.airline_stops_sharp),
            title: const Text("Toggle Swiping Tabs"),
            trailing: Switch(
              value: widget.swipeNavigationEnabled,
              onChanged: widget.onSwipeNavigationChanged,
            ),
          ),
          // ListTile(
          //   leading: const Icon(Icons.workspaces),
          //   title: const Text("Followed Organisers"),
          //   onTap: () {},
          // ),
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
                ScaffoldMessenger.of(context,
                ).showSnackBar(const SnackBar(content: Text("You are signed out")));
                return;
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
            child: const Text("Sign Out", style: TextStyle(color: Colors.white)),
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
      padding: const EdgeInsets.symmetric(
        horizontal: double.infinity,
        vertical: 0.5,
      ),
      decoration: BoxDecoration(color: Colors.grey),
    );
  }
}

class _UserDashboard extends State<UserDashboard> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  bool _swipeNavigationEnabled = true;

  List<Widget> get _widgetOptions => <Widget>[
    _HomeTab(),
    _SavedTab(),
    _ReminderTab(),
    _AccountTab(
      swipeNavigationEnabled: _swipeNavigationEnabled,
      onSwipeNavigationChanged: _toggleSwipeNavigation,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleSwipeNavigation(bool value) {
    setState(() {
      _swipeNavigationEnabled = value;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFFECEFE6),
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
        child: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: _widgetOptions,
          physics: _swipeNavigationEnabled ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
        ),
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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Example event data
  final List<Map<String, String>> _allEvents = [
    {
      'image': 'EXPOEVENT.png',
      'title': 'Expo iFood',
      'organiser': 'Pavillion Bukit Jalil',
      'tags': 'Coffee,Japanese Food,Pastry',
      'date': 'Fri, 11th July, 2:30pm',
    },
    {
      'image': 'COFFEEFEST.png',
      'title': 'Coffee Fest',
      'organiser': 'KLCC',
      'tags': 'Coffee,Pastry',
      'date': 'Sat, 12th July, 10:00am',
    },
    // Add more events as needed
  ];

  List<Map<String, String>> get _filteredEvents {
    if (_searchQuery.isEmpty) return _allEvents;
    return _allEvents.where((event) {
      final query = _searchQuery.toLowerCase();
      return event['title']!.toLowerCase().contains(query) ||
             event['organiser']!.toLowerCase().contains(query) ||
             event['tags']!.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search events...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
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
              itemCount: _filteredEvents.length,
              itemBuilder: (context, index) {
                final event = _filteredEvents[index];
                return EventCard(imageName: event['image'] ?? 'EXPOEVENT.png');
              },
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
