import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

//your mergin ah??? accept this
class OrganiserAccountTab extends StatefulWidget {
  final bool swipeNavigationEnabled;
  final ValueChanged<bool> onSwipeNavigationChanged;

  const OrganiserAccountTab({
    super.key,
    required this.swipeNavigationEnabled,
    required this.onSwipeNavigationChanged,
  });

  @override
  State<OrganiserAccountTab> createState() => _OrganiserAccountTabState();
}

class _OrganiserAccountTabState extends State<OrganiserAccountTab> {
  String organisationName = '';
  String picName = '';
  String organiserEmail = '';
  String organiserPhotoUrl = '';
  String phoneNumber = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrganiserDetails();
  }

  Future<void> fetchOrganiserDetails() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final uid = user.uid;
        final doc =
            await FirebaseFirestore.instance
                .collection('organisers')
                .doc(uid)
                .get();

        if (doc.exists) {
          setState(() {
            organisationName = doc['organizationName'] ?? '';
            picName = doc['picName'] ?? '';
            organiserEmail = doc['email'] ?? user.email ?? '';
            organiserPhotoUrl = user.photoURL ?? '';
            phoneNumber = doc['phoneNumber'] ?? '';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error fetching organiser details: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 80.0,
          ), // Adjust top padding as needed
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 48,
                backgroundImage:
                    organiserPhotoUrl.isNotEmpty
                        ? NetworkImage(organiserPhotoUrl)
                        : const AssetImage("assets/default_profile.jpg")
                            as ImageProvider,
              ),
              const SizedBox(height: 20),
              Text(
                organisationName,
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "PIC: $picName",
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                organiserEmail,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 40),

              // Make the details box narrower
              Center(
                child: Container(
                  width: 320, // Set box width here
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      sectionTitle("Organisation Details"),
                      const SizedBox(height: 10),
                      Text(
                        "Organisation: $organisationName",
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "PIC: $picName",
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "Phone Number: $phoneNumber",
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      sectionTitle("Account Controls"),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to edit organiser profile
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Edit Profile"),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          bool? confirmLogout = await showDialog<bool>(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text("Confirm Logout"),
                                  content: const Text(
                                    "Logout from your account?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, false),
                                      child: const Text("BACK"),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, true),
                                      child: const Text("LOGOUT"),
                                    ),
                                  ],
                                ),
                          );

                          if (confirmLogout == true) {
                            await FirebaseAuth.instance.signOut();
                            if (context.mounted) {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/login', // Replace with your actual login route name
                                (route) => false,
                              );
                            }
                          }
                        },
                        child: const Text("Log Out"),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.montserrat(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }
}
