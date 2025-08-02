// import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

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
  bool isUploadingImage = false;
  String? selectedReason;
  
  final ImagePicker _picker = ImagePicker();

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
          final data = doc.data()!;
          setState(() {
            organisationName = data['organizationName'] ?? '';
            picName = data['picName'] ?? '';
            organiserEmail = data['email'] ?? user.email ?? '';
            // Only need profileImageUrl for organiser accounts
            organiserPhotoUrl = data['profileImageUrl'] ?? '';
            phoneNumber = data['phoneNumber'] ?? '';
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

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      
      if (image != null) {
        setState(() {
          isUploadingImage = true;
        });

        // Upload image to Firebase Storage
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child('organiser_profile_images')
              .child('${user.uid}.jpg');
          
          await ref.putFile(File(image.path));
          final downloadUrl = await ref.getDownloadURL();

          // Update Firestore with new image URL
          await FirebaseFirestore.instance
              .collection('organisers')
              .doc(user.uid)
              .update({
            'profileImageUrl': downloadUrl,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          // Update local state
          setState(() {
            organiserPhotoUrl = downloadUrl;
            isUploadingImage = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated successfully')),
          );
        }
      }
    } catch (e) {
      setState(() {
        isUploadingImage = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile picture: $e')),
      );
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
              // Profile Picture with Edit Button
              Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF4CAF50),
                        width: 3,
                      ),
                    ),
                    child: ClipOval(
                      child: organiserPhotoUrl.isNotEmpty
                          ? Image.network(
                              organiserPhotoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                    'assets/default_profile.jpg',
                                    fit: BoxFit.cover,
                                  ),
                            )
                          : Image.asset(
                              'assets/default_profile.jpg',
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: isUploadingImage ? null : _pickAndUploadImage,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                        child: isUploadingImage
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 16,
                              ),
                      ),
                    ),
                  ),
                ],
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
                                      child: const Text("CANCEL"),
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
                                '/login',
                                (route) => false,
                              );
                            }
                          }
                        },
                        child: const Text("Log Out"),
                      ),

                      const SizedBox(height: 10), // <-- consistent spacing
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          final reason = await showDialog<String>(
                            context: context,
                            builder: (context) {
                              String? selectedReason;
                              return AlertDialog(
                                title: const Text(
                                  "Why are you deleting your account?",
                                ),
                                content: StatefulBuilder(
                                  builder: (context, setState) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        RadioListTile<String>(
                                          title: const Text("Privacy concerns"),
                                          value: "Privacy concerns",
                                          groupValue: selectedReason,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedReason = value;
                                            });
                                          },
                                        ),
                                        RadioListTile<String>(
                                          title: const Text(
                                            "Too many notifications",
                                          ),
                                          value: "Too many notifications",
                                          groupValue: selectedReason,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedReason = value;
                                            });
                                          },
                                        ),
                                        RadioListTile<String>(
                                          title: const Text(
                                            "Not User Friendly",
                                          ),
                                          value: "Not User Friendly",
                                          groupValue: selectedReason,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedReason = value;
                                            });
                                          },
                                        ),
                                        RadioListTile<String>(
                                          title: const Text(
                                            "I found a better app",
                                          ),
                                          value: "I found a better app",
                                          groupValue: selectedReason,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedReason = value;
                                            });
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("CANCEL"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      if (selectedReason != null) {
                                        Navigator.pop(context, selectedReason);
                                      }
                                    },
                                    child: const Text("CONTINUE"),
                                  ),
                                ],
                              );
                            },
                          );

                          if (reason != null) {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text("Confirm Deletion"),
                                    content: const Text(
                                      "Are you sure you want to delete your account?\nThis action cannot be undone.",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, false),
                                        child: const Text("No, I love JAMBU"),
                                      ),
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, true),
                                        child: const Text(
                                          "Yes, I don't like JAMBU",
                                        ),
                                      ),
                                    ],
                                  ),
                            );

                            if (confirm == true) {
                              // 1. Prompt the user for their password (e.g., with a dialog)
                              String? password = await showDialog<String>(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) {
                                  final _formKey = GlobalKey<FormState>();
                                  String input = '';
                                  bool isLoading = false;
                                  String? errorText;

                                  return StatefulBuilder(
                                    builder: (context, setState) {
                                      return AlertDialog(
                                        title: Text('Re-enter your password'),
                                        content: Form(
                                          key: _formKey,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              TextFormField(
                                                obscureText: true,
                                                decoration: InputDecoration(
                                                  labelText: 'Password',
                                                  errorText: errorText,
                                                ),
                                                onChanged: (value) => input = value,
                                                validator: (value) {
                                                  if (value == null || value.isEmpty) {
                                                    return 'Please enter your password';
                                                  }
                                                  return null;
                                                },
                                              ),
                                              if (isLoading) CircularProgressIndicator(),
                                            ],
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, null),
                                            child: Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              if (_formKey.currentState!.validate()) {
                                                setState(() => isLoading = true);
                                                final user = FirebaseAuth.instance.currentUser;
                                                try {
                                                  final credential = EmailAuthProvider.credential(
                                                    email: user!.email!,
                                                    password: input,
                                                  );
                                                  await user.reauthenticateWithCredential(credential);
                                                  setState(() => isLoading = false);
                                                  Navigator.pop(context, input); // Only pop if correct
                                                } on FirebaseAuthException catch (e) {
                                                  setState(() {
                                                    isLoading = false;
                                                    errorText = e.code == 'wrong-password'
                                                      ? 'Incorrect password. Please try again.'
                                                      : 'Re-authentication failed: ${e.message}';
                                                  });
                                                }
                                              }
                                            },
                                            child: Text('OK'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              );
                              final user = FirebaseAuth.instance.currentUser;

                            bool reauthSuccess = false;
                            if (password != null && user?.email != null) {
                              final credential = EmailAuthProvider.credential(
                                email: user!.email!,
                                password: password,
                              );
                              try {
                                await user.reauthenticateWithCredential(credential);
                                reauthSuccess = true;
                              } on FirebaseAuthException catch (e) {
                                if (e.code == 'wrong-password') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Incorrect password. Please try again.')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Re-authentication failed: ${e.message}')),
                                  );
                                }
                              }
                            }
                            if (reauthSuccess) {
                              // Proceed with deletion logic

                              try {

                                final uid = user?.uid;

                                if (uid != null) {
                                  // Fetch organiser data from Firestore
                                  final docSnapshot =
                                      await FirebaseFirestore.instance
                                          .collection('organisers')
                                          .doc(uid)
                                          .get();

                                  final organiserData =
                                      docSnapshot.data() ?? {};

                                  // Save to deleted_accounts collection
                                  await FirebaseFirestore.instance
                                    .collection('deleted_accounts')
                                    .doc(user?.uid)
                                    .set({
                                  'email': user?.email ?? '',
                                  'organizationName': organiserData['organizationName'] ?? '',
                                  'phoneNumber': organiserData['phoneNumber'] ?? '',
                                  'picName': organiserData['picName'] ?? '',
                                  'reason': selectedReason ?? '',
                                  'status': 'deleted',
                                  'deletedAt': FieldValue.serverTimestamp(),
                                });

                                  await FirebaseFirestore.instance.collection('organisers').doc(user?.uid).delete();

                                  // delete user account
                                  await user?.delete();

                                  // Navigate to login page
                                  if (context.mounted) {
                                    Navigator.of(
                                      context,
                                    ).pushNamedAndRemoveUntil(
                                      '/login',
                                      (r) => false,
                                    );
                                  }
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Error deleting account: $e"),
                                  ),
                                );
                              }
                            }
                            }
                          }
                        },

                        child: const Text("Delete Account"),
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
