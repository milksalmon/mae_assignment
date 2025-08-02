import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import 'orgAccount.dart';
import 'upload_event.dart';
import '../user/userDashboard.dart';

// CONVERT THE GEOLOCATION FROM FIRESTORE DATABASE TO ACTUAL LOCATION
Future<String> getCityFromGeoPoint(GeoPoint geoPoint) async {
  List<Placemark> placemarks = await placemarkFromCoordinates(
    geoPoint.latitude,
    geoPoint.longitude,
  );

  if (placemarks.isNotEmpty) {
    String city =
        placemarks[0].locality ?? placemarks[0].subLocality ?? 'Unknown';
    String state = placemarks[0].administrativeArea ?? '';

    if (city != 'Unknown' && state.isNotEmpty) {
      return '$city, $state';
    } else if (city != 'Unknown') {
      return city;
    } else if (state.isNotEmpty) {
      return state;
    }
  }
  return 'Unknown';
}

String organiserStatus = "pending"; // Default: pending

class OrganiserDashboard extends StatefulWidget {
  const OrganiserDashboard({Key? key}) : super(key: key);

  @override
  State<OrganiserDashboard> createState() => _OrganiserDashboardState();
}

class _OrganiserDashboardState extends State<OrganiserDashboard> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _organiserEvents = [];
  bool _isLoadingEvents = true;
  String _organiserName = '';

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
        _organiserName = doc['picName'] ?? '';
      });
      
      // Fetch events if approved
      if (organiserStatus.toLowerCase() == "approved") {
        _fetchOrganiserEvents();
      }
    }
  }

  Future<void> _fetchOrganiserEvents() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('event')
          .where('orgName', isEqualTo: _organiserName)
          .get();
      
      List<Map<String, dynamic>> events = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        
        // CONVERT GEOLOCATION TO CITY NAME
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
          'date': DateFormat('yyyy-M-dd HH:mm').format(
            data['startDate']?.toDate().toLocal() ?? DateTime.now()
          ),
          'media': (data['media'] as List?)?.map((m) => m.toString()).toList() ?? [],
          'description': data['description'] ?? '',
          'location': city,
          'geoPoint': data['location'],
          'wsLink': data['wsLink'] ?? '',
          'parking': data['parking'] ?? '',
        });
      }

      setState(() {
        _organiserEvents = events;
        _isLoadingEvents = false;
      });
    } catch (e) {
      print('Error fetching organiser events: $e');
      setState(() {
        _isLoadingEvents = false;
      });
    }
  }

  void toggleSaveEvent(String eventId) {
    // Implement save functionality if needed
    print('Toggle save for event: $eventId');
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      organiserStatus.toLowerCase() == "approved"
          ? OrganiserEventsWidget(
              organiserEvents: _organiserEvents,
              isLoadingEvents: _isLoadingEvents,
              onToggleSave: toggleSaveEvent,
              onUploadEventTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UploadEventForm()),
                );
              },
            )
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

class OrganiserEventsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> organiserEvents;
  final bool isLoadingEvents;
  final Function(String) onToggleSave;
  final VoidCallback onUploadEventTap;

  const OrganiserEventsWidget({
    Key? key,
    required this.organiserEvents,
    required this.isLoadingEvents,
    required this.onToggleSave,
    required this.onUploadEventTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Your Events Section
          Text(
            "Your Events",
            style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFF2F67),
            ),
          ),
          const SizedBox(height: 16),
          
          // Upload Event Button
          Center(
            child: GestureDetector(
              onTap: onUploadEventTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
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
          ),
          const SizedBox(height: 24),
          
          // Events List
          Expanded(
            child: isLoadingEvents
                ? const Center(child: CircularProgressIndicator())
                : organiserEvents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_note, size: 60, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              "No events uploaded yet",
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Upload your first event to get started!",
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: organiserEvents.length,
                        itemBuilder: (context, index) {
                          final event = organiserEvents[index];
                          return EventCard(
                            imageUrl: event['image'],
                            title: event['title'],
                            organiser: event['organiser'],
                            tags: event['tags'],
                            date: event['date'],
                            endDate: event['endDate'],
                            eventId: event['eventId'],
                            media: event['media'],
                            description: event['description'],
                            location: event['location'],
                            geoPoint: event['geoPoint'],
                            wsLink: event['wsLink'],
                            parking: event['parking'],
                            onSaveTap: () => onToggleSave(event['eventId']),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
