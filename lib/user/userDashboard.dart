import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'search_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'event_page.dart';
import 'package:geocoding/geocoding.dart';

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

// CONVERT THE GEOLOCATION FROM FIRESTORE DATABASE
Future<String> getCityFromGeoPoint(GeoPoint geoPoint) async {
  List<Placemark> placemarks = await placemarkFromCoordinates(
    geoPoint.latitude,
    geoPoint.longitude,
  );

  if (placemarks.isNotEmpty) {
    return placemarks[0].locality ?? 'Unknown';
  }
  return 'Unknown';
}
// CONVERT GEOLOCATION END

class _SavedTabState extends State<_SavedTab> {
  @override
  Widget build(BuildContext context) {
    // FETCHING ACTAUL EVENT DATA
    Future<List<Map<String, dynamic>>> fetchSavedEvents() async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return [];

      final savedSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('savedEvents')
              .get();

      List<Map<String, dynamic>> savedEvents = [];

      for (var doc in savedSnapshot.docs) {
        final eventId = doc.id;
        final eventSnapshot =
            await FirebaseFirestore.instance
                .collection('event')
                .doc(eventId)
                .get();

        if (eventSnapshot.exists) {
          final data = eventSnapshot.data()!;
          savedEvents.add({
            'eventId': eventId,
            'image': data['images'] ?? '',
            'title': data['eventName'] ?? '',
            'organiser': data['orgName'] ?? '',
            'tags': (data['tags'] as List?)?.join(',') ?? '',
            'date': DateFormat(
              'yyyy-M-dd HH:mm',
            ).format(data['startDate']?.toDate().toLocal() ?? DateTime.now()),
            'media':
                (data['media'] as List?)?.map((m) => m.toString()).toList() ??
                [],
            'description': data['description'] ?? '',
            'location': data['location'],
          });
        }
      }
      return savedEvents;
    }

    return Column(
      children: [
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(left: 20),
            child: Text(
              "Saved Events",
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFF2F67),
              ),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchSavedEvents(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No Saved Events'));
              }

              final savedEvents = snapshot.data!;
              return ListView.builder(
                itemCount: savedEvents.length,
                itemBuilder: (context, index) {
                  final event = savedEvents[index];
                  return EventCard(
                    imageUrl: event['image'],
                    title: event['title'],
                    organiser: event['organiser'],
                    tags: event['tags'],
                    date: event['date'],
                    eventId: event['eventId'],
                    media: event['media'],
                    description: event['description'],
                    onSaveTap: () {
                      // RE FETCHING ON UNSAVE
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .collection('savedEvents')
                          .doc(event['eventId'])
                          .delete()
                          .then((_) {
                            setState(() {
                              // RE-TRIGGERED FILTERED RESULTS
                            });
                          });
                    },
                  );
                },
              );
            },
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
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFF2F67),
              ),
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

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog first
                try {
                  await FirebaseAuth.instance.signOut();
                  Provider.of<AppAuthProvider>(context, listen: false).logout();
                  Navigator.pushReplacementNamed(context, '/login');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("You are logged out")),
                  );
                } catch (e) {
                  print('Log out failed, Error: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Logout failed: $e")),
                  );
                }
              },
              child: const Text('LOGOUT'),
            ),
          ],
        );
      },
    );
  }

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
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFF2F67),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey,
            backgroundImage:
                (googlePhotoUrl != null && googlePhotoUrl.isNotEmpty)
                    ? NetworkImage(googlePhotoUrl)
                    : null,
            child:
                (googlePhotoUrl == null || googlePhotoUrl.isEmpty)
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
            child: const Text(
              "Edit Profile",
              style: TextStyle(color: Colors.white),
            ),
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
          // sectionTitle("Connected Accounts"),
          // ListTile(
          //   leading: Image.asset(
          //     "assets/google.png",
          //     height: 24,
          //   ), // Replace with your asset
          //   title: Text(
          //     "Google\n$googleEmail",
          //     style: const TextStyle(height: 1.5),
          //   ),
          //   trailing: TextButton(
          //     onPressed: () {},
          //     child: const Text("Disconnect"),
          //   ),
          // ),
          // sectionTitle("Rules & Regulations"),
          // ListTile(
          //   leading: const Icon(Icons.description_outlined),
          //   title: const Text("Privacy Policy"),
          //   onTap: () {},
          // ),
          const SizedBox(height: 80),
          ElevatedButton(
            onPressed: () {
              _showLogoutConfirmationDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            ),
            child: const Text(
              "Log Out",
              style: TextStyle(color: Colors.white),
            ),
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
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
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
      // backgroundColor: Colors.white,
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
          physics:
              _swipeNavigationEnabled
                  ? const BouncingScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
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

  List<Map<String, dynamic>> _allEvents = [];
  bool _isLoading = true;

  // LOGIC OF SAVED EVENTS
  Future<void> toggleSaveEvent(String eventId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final savedRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('savedEvents')
        .doc(eventId);

    final doc = await savedRef.get();

    if (doc.exists) {
      await savedRef.delete(); // TO UNSAVE
    } else {
      await savedRef.set({'savedAt': FieldValue.serverTimestamp()});
    }
  }

  // LOGIC SAVED EVENTS END
  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('event').get();
      List<Map<String, dynamic>> events = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        String city = 'Unknown';
        try {
          if (data['location'] != null && data['location'] is GeoPoint) {
            city = await getCityFromGeoPoint(
              data['location'],
            ).timeout(Duration(seconds: 3), onTimeout: () => 'Unknown');
          }
        } catch (e) {
          print('Failed to fetch city: $e');
          city = 'Unknown';
        }

        events.add({
          'eventId': doc.id,
          'image': data['images'] ?? '',
          'title': data['eventName'] ?? '',
          'organiser': data['orgName'] ?? '',
          'tags': (data['tags'] as List?)?.join(',') ?? '',
          'date': DateFormat(
            'yyyy-M-dd HH:mm',
          ).format(data['startDate']?.toDate().toLocal() ?? DateTime.now()),
          'media':
              (data['media'] as List?)?.map((m) => m.toString()).toList() ?? [],
          'description': data['description'] ?? '',
          'location': city,
        });
      }

      setState(() {
        _allEvents = events;
        _isLoading = false;
      });
      print('Finished loading events: ${events.length}');
    } catch (e) {
      print('Error fetching events: $e');
    }
  }

  List<Map<String, dynamic>> get _filteredEvents {
    final query = _searchQuery.toLowerCase();
    if (query.isEmpty) return _allEvents;
    return _allEvents.where((event) {
      return event['title'].toLowerCase().contains(query) ||
          event['organiser'].toLowerCase().contains(query) ||
          event['tags'].toLowerCase().contains(query);
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
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search events...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24.0),
              ),
            ),
          ),
          const SizedBox(height: 16),
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
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                      itemCount: _filteredEvents.length,
                      itemBuilder: (contet, index) {
                        final event = _filteredEvents[index];
                        return EventCard(
                          imageUrl: event['image'],
                          title: event['title'],
                          organiser: event['organiser'],
                          tags: event['tags'],
                          date: event['date'],
                          eventId: event['eventId'],
                          media: event['media'],
                          description: event['description'],
                          onSaveTap: () => toggleSaveEvent(event['eventId']),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String organiser;
  final String tags;
  final String date;
  final String eventId;
  final List<String> media;
  final String description;
  final VoidCallback onSaveTap;

  const EventCard({
    required this.imageUrl,
    required this.title,
    required this.organiser,
    required this.tags,
    required this.date,
    required this.eventId,
    required this.media,
    required this.description,
    required this.onSaveTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tagList = tags.split(',').map((tag) => tag.trim()).toList();

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => EventPage(
                  eventId: eventId, // PASS EVENT ID
                  imageUrl: imageUrl,
                  title: title,
                  organiser: organiser,
                  tags: tags,
                  date: date,
                  media: media,
                  description: description,
                ),
          ),
        );
      },
      child: Card(
        color: const Color(0xFFF9FDF0),
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child:
                      imageUrl.isEmpty
                          ? Container(
                            height: 160,
                            color: Colors.grey[300],
                            child: const Center(child: Icon(Icons.image)),
                          )
                          : Image.network(
                            imageUrl,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: Icon(Icons.bookmark_border),
                    onPressed: onSaveTap,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(date, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: ' by $organiser'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    children:
                        tagList.map((tag) => EventTag(label: tag)).toList(),
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
