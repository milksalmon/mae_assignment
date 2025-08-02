import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

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

  // HELPER FUNCTION FOR TIMESTAMP UI
  String getRelativeTime(Timestamp timestamp) {
    if (timestamp == null) {
      return '';
    }
    // CALCULATE THE DIFFERENCE BETWEEN NOW AND THE TIMESTAMP
    final now = DateTime.now();
    final dateTime = timestamp.toDate();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  // FUNCTION FOR FOLDING FEEDBACK BY EVENT
  Map<String, bool> _expandedEvents = {}; // TO TRACK EXPANDED EVENTS

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

  // PERFORM GROUPING BY VENDOR NAME
  Map<String, List<Map<String, dynamic>>> _groupedFeedbacksByVendor() {
    return _ratingFilter
        .where((item) => item['rating'] == ratingFilter)
        .fold<Map<String, List<Map<String, dynamic>>>>({}, (map, item) {
          // DEFENSIVE FALLBACK TO 'Unknown Vendor' IF NOT FOUND ANY VENDOR
          final eventName = item['eventName'] ?? 'Unknown Event';
          map.putIfAbsent(eventName, () => []).add(item);
          return map;
        });
  }

  // TO RESTRICT COMMENT & FEEDBACK
  Future<void> restrictSelectedFeedback() async {
    final selectedIds =
        _selectedFeedback.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toSet();

    final toUpdate =
        _ratingFilter
            .where((item) => selectedIds.contains(item['id']))
            .toList();

    for (var feedback in toUpdate) {
      try {
        final eventId = feedback['eventId'];
        final feedbackId = feedback['id'];

        await FirebaseFirestore.instance
            .collection('event')
            .doc(eventId)
            .collection('feedback')
            .doc(feedbackId)
            .update({'status': 'Restrict'});
      } catch (e) {
        print('Error updating status for feedback: ${feedback['id']}: $e');
      }
    }

    // REFRESH THE LIST AFTER CHANGING THE STATUS
    await fetchFeedbacks();
    setState(() {
      _selectedFeedback.clear();
    });
  }
  // RESTRICT COMMENT & FEEDBACK END

  // TO DELETE COMMENT
  Future<void> deleteSelectedFeedback() async {
    final selectedIds =
        _selectedFeedback.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toSet();

    final toDelete =
        _ratingFilter
            .where((item) => selectedIds.contains(item['id']))
            .toList();

    for (var feedback in toDelete) {
      try {
        final eventId = feedback['eventId'];
        final feedbackId = feedback['id'];

        await FirebaseFirestore.instance
            .collection('event')
            .doc(eventId)
            .collection('feedback')
            .doc(feedbackId)
            .delete();
      } catch (e) {
        print('Error deleting feedback: ${feedback['id']}: $e');
      }
    }
    // DELETE COMMENT END

    // REFRESH THE UI AFTER DELETION
    await fetchFeedbacks();
    // CLEAR SELECTION
    setState(() {
      _selectedFeedback.clear();
    });
  }

  // FETCHING FEEDBACK DATA FROM FIREBASE
  Future<void> fetchFeedbacks() async {
    try {
      final eventSnapshot =
          await FirebaseFirestore.instance.collection('event').get();
      List<Map<String, dynamic>> allFeedback = [];

      for (var eventDoc in eventSnapshot.docs) {
        final eventId = eventDoc.id;
        final eventData = eventDoc.data();
        final eventName = eventData['eventName'] ?? 'Unknown Event';
        //final vendorName = eventData['orgName'] ?? 'Unknown Vendor';

        final feedbackSnapshot =
            await FirebaseFirestore.instance
                .collection('event')
                .doc(eventId)
                .collection('feedback')
                .get();

        for (var feedbackDoc in feedbackSnapshot.docs) {
          final feedbackData = feedbackDoc.data();

          // ONLY SHOW FEEDBACKS THAT IS "SAFE"
          if ((feedbackData['status'] ?? '').toString().toLowerCase() ==
              'safe') {
            allFeedback.add({
              'id': feedbackDoc.id, // AUTO ID
              'eventId': eventId,
              'name': feedbackData['name'] ?? '',
              'comment': feedbackData['comment'] ?? '',
              'rating': feedbackData['rating'] ?? '',
              'eventName': eventName,
              'timestamp': feedbackData['timestamp'],
              //'vendor': vendorName,
            });
          }
        }
      }

      setState(() {
        _ratingFilter = allFeedback;
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
            //const SizedBox(width: 5),
            Text(
              'Manage Feedback',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // FILTER DROP DOWN
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
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                      children:
                          _groupedFeedbacksByVendor().entries.map((entry) {
                            final eventName = entry.key;
                            final feedbackList = entry.value;
                            final isExpanded =
                                _expandedEvents[eventName] ?? false;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //EVENT HEADER
                                ListTile(
                                  title: Text(
                                    'Event : $eventName',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(
                                      isExpanded
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _expandedEvents[eventName] =
                                            !isExpanded;
                                      });
                                    },
                                  ),
                                ),

                                // SHOW FEEDBACK ONLY IF EXPANDED
                                if (isExpanded)
                                  ...feedbackList.map((item) {
                                    final id = item['id']; // UNIQUE IDENTIFIER
                                    return Card(
                                      color: Colors.pink[100],
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 6,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const CircleAvatar(
                                                  child: Icon(Icons.person),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            item['name'] ??
                                                                'Unknown',
                                                            style:
                                                                const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          Text(
                                                            getRelativeTime(
                                                              item['timestamp'],
                                                            ),
                                                            style: const TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors
                                                                      .black54,
                                                            ),
                                                          ),
                                                        ],
                                                      ),

                                                      const SizedBox(height: 4),
                                                      // REPLACING TEXT RATING WITH STARS
                                                      RatingBarIndicator(
                                                        rating:
                                                            double.tryParse(
                                                              item['rating']
                                                                  .toString()
                                                                  .split(
                                                                    ' ',
                                                                  )[0],
                                                            ) ??
                                                            0.0,
                                                        itemBuilder:
                                                            (
                                                              context,
                                                              index,
                                                            ) => const Icon(
                                                              Icons.star,
                                                              color:
                                                                  Colors.orange,
                                                            ),
                                                        itemCount: 5,
                                                        itemSize: 16.0,
                                                        direction:
                                                            Axis.horizontal,
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        item['comment'] ?? '',
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Checkbox(
                                                  value:
                                                      _selectedFeedback[id] ??
                                                      false,
                                                  onChanged: (bool? value) {
                                                    setState(() {
                                                      _selectedFeedback[id] =
                                                          value!;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                TextButton(
                                                  onPressed: () {},
                                                  child: const Text('Reply'),
                                                ),
                                                TextButton(
                                                  onPressed: () {},
                                                  child: const Text('Message'),
                                                ),
                                                TextButton(
                                                  onPressed: () {},
                                                  child: const Text('Send'),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                              ],
                            );
                          }).toList(),
                    ),
            // END OF VENDOR FEEDBACK LIST
          ),
          // END OF EXPANDED LIST VIEW

          // BOTTOM ACTION BAR
          Container(
            color: Colors.grey[300],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton('Delete', Colors.red, () {
                  deleteSelectedFeedback();
                }),
                _buildActionButton('Restrict', Colors.orange, () {
                  restrictSelectedFeedback();
                }),
                // _buildActionButton('Block', Colors.black, () {
                //   print('Block Button clicked');
                // }),
              ],
            ),
          ),
        ],
      ),
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
