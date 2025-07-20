import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

// CREATING A STATEFUL WIDGET
class ManageFeedback extends StatefulWidget {
  const ManageFeedback({super.key});

  @override
  // CREATE STATE METHOD = TELLS FLUTTER WHICH STATE CLASS TO USE WITH WIDGET
  State<ManageFeedback> createState() => _ManageFeedback();
  // _MANAGEFEEDBACK IS WHERE EVERYTHING HAPPENED
}

class _ManageFeedback extends State<ManageFeedback> {
  @override
  void initState() {
    super.initState();
    fetchFeedbacks();
  }

  String ratingFilter = '5 Ratings';
  final List<String> filters = [
    '5 Ratings',
    '4 Ratings',
    '3 Ratings',
    '2 Ratings',
    '1 Ratings',
    'No Ratings',
  ];

  // FOR CHEKCBOX
  final Map<String, bool> _selectedFeedback = {};

  List<Map<String, dynamic>> _ratingFilter = [];
  bool isLoading = true;

  // FETCHING FEEDBACK DATA FROM FIREBASE
  Future<void> fetchFeedbacks() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('feedback').get();

      setState(() {
        _ratingFilter =
            snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'id': doc.id, // AUTO ID
                'name': data['name'] ?? '',
                'comment': data['comment'] ?? '',
                'rating': data['rating'] ?? '',
                'vendor': data['vendor'] ?? '',
              };
            }).toList();

        isLoading = false;
      });
    } catch (e) {
      print('Error fetching feedbacks: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // RETURNING THE UI TO STATEFUL WIDGET (MANAGEFEEDBACK)
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 50),
            const SizedBox(width: 5),
            const Text('Manage Feedback'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  // 2ND DROP DOWN MENU START
                  child: DropdownButton<String>(
                    value: ratingFilter,
                    onChanged: (String? newValue) {
                      setState(() {
                        ratingFilter = newValue!;
                      });
                    },
                    items:
                        filters.map((rating) {
                          return DropdownMenuItem(
                            value: rating,
                            child: Text(
                              rating,
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          );
                        }).toList(),
                    dropdownColor: Colors.pink[100],
                    style: const TextStyle(color: Colors.black),
                    iconEnabledColor: Colors.black,
                  ),
                ),
                // 2ND DROP DOWN BUTTON END
              ],
            ),
          ),

          final groupedFeedbacks = _groupFeedbacksByVendor();

          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                      children:
                          groupedFeedbacks.entries.map((entry) {
                            final vendor = entry.key;
                            final feedbackList = entry.value;

                            return Column(
                              crossAxisAlignment : CrossAxisAlignment.start,
                              children[
                                Padding(
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: Text(
                                    vendor,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                  ),
                              ]
                            )
                          })
                          _ratingFilter
                              .where((item) => item['rating'] == ratingFilter)
                              .map((item) {
                                final id = item['id']; // UNIQUE IDENTIFIER
                                return Card(
                                  color: Colors.pink[100],
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  child: ListTile(
                                    leading: const CircleAvatar(
                                      child: Icon(Icons.person),
                                    ),
                                    title: Text(item['name'] ?? 'Unknown'),
                                    subtitle: Text(item['comment'] ?? ''),
                                    trailing: Checkbox(
                                      value: _selectedFeedback[id] ?? false,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          _selectedFeedback[id] = value!;
                                        });
                                      },
                                    ),
                                  ),
                                );
                              })
                              .toList(),
                    ),
          ),

          // BOTTOM ACTION BAR
          Container(
            color: Colors.grey[300],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton('Delete', Colors.red, () {
                  print('Deleting selected comments');
                }),
                _buildActionButton('Restrict', Colors.orange, () {
                  print('Restricting selected users');
                }),
                _buildActionButton('Block', Colors.black, () {
                  print('Blocking selected users');
                }),
              ],
            ),
          ),
        ],
      ), // ADDED : BOTTOM ACTION BAR
    );
  }

  // REUSABLE ACTION BUTTON
  Widget _buildActionButton(String label, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
}
