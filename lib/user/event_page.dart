import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';

class EventPage extends StatefulWidget {
  final String eventId;
  final String imageUrl;
  final String title;
  final String organiser;
  final String tags;
  final String date;
  final GeoPoint geoPoint;
  final String locationName;
  final List<String> media;
  final String description;
  final String wsLink;
  final String parking;
  final DateTime? endDate;

  const EventPage({
    Key? key,
    required this.eventId,
    required this.imageUrl,
    required this.title,
    required this.organiser,
    required this.tags,
    required this.date,
    required this.geoPoint,
    required this.locationName,
    required this.media,
    required this.description,
    required this.wsLink,
    required this.parking,
    required this.endDate,
  }) : super(key: key);

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  final TextEditingController _feedbackController = TextEditingController();
  String _selectedRating = '5 Ratings';
  String _selectedDisplayRating = '5 Ratings';
  bool _hasSubmittedFeedback = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _checkIfUserHasSubmitted();
  }

  // CHECK FOR EXISTING FEEDBACK FROM THE USER
  Future<void> _checkIfUserHasSubmitted() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final querySnapshot =
        await FirebaseFirestore.instance
            .collection('event')
            .doc(widget.eventId)
            .collection('feedback')
            .where('userId', isEqualTo: user.uid)
            .limit(1)
            .get();

    setState(() {
      _hasSubmittedFeedback = querySnapshot.docs.isNotEmpty;
    });
  }

  // HELPER METHOD TO MAKE USER COMMENT IF THE EVENT IS NOT "COMING SOON"
  String _getEventStatus() {
    final now = DateTime.now();
    DateTime? parsedStartDate;
    try {
      parsedStartDate = DateFormat('yyyy-M-dd HH:m').parse(widget.date);
    } catch (e) {
      parsedStartDate = null;
    }

    if (parsedStartDate != null && widget.endDate != null) {
      if (now.isBefore(parsedStartDate)) {
        return 'Coming Soon';
      } else if (now.isAfter(widget.endDate!)) {
        return 'Ended';
      } else {
        return 'On-Going';
      }
    }
    return 'Unknown';
  }

  // FOR STAR CONVERSION HELPER
  int _extractStarCount(String? ratingText) {
    if (ratingText == null) return 0;

    final match = RegExp(r'\d+').firstMatch(ratingText);
    if (match != null) {
      return int.tryParse(match.group(0) ?? '') ?? 0;
    }
    return 0;
  }

  Future<void> _submitFeedback(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to submit feedback.'),
        ),
      );
      return;
    }
    final feedbackText = _feedbackController.text.trim();
    if (feedbackText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some feedback')),
      );
      return;
    }

    final feedbackData = {
      'userId': user.uid,
      'name': user.displayName ?? 'Anonymous',
      'comment': feedbackText,
      'rating': _selectedRating,
      'status': 'Safe',
      'timestamp': Timestamp.now(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('event')
          .doc(widget.eventId)
          .collection('feedback')
          .add(feedbackData);

      // INCREMENT THE NUMBER
      final organiserSnapshot =
          await FirebaseFirestore.instance
              .collection('organisers')
              .where('organizationName', isEqualTo: widget.organiser)
              .limit(1)
              .get();

      if (organiserSnapshot.docs.isNotEmpty) {
        final organiserId = organiserSnapshot.docs.first.id;
        final ratingDocRef = FirebaseFirestore.instance
            .collection('organisers')
            .doc(organiserId)
            .collection('rating')
            .doc('summary');

        final ratingKey = _selectedRating;

        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final snapshot = await transaction.get(ratingDocRef);

          if (snapshot.exists) {
            final data = snapshot.data()!;
            final currentCount = (data[ratingKey] ?? 0) as int;
            transaction.update(ratingDocRef, {ratingKey: currentCount + 1});
          } else {
            transaction.set(ratingDocRef, {ratingKey: 1});
          }
        });
      }

      _feedbackController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback submitted successfully !')),
      );

      await _checkIfUserHasSubmitted();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error submitting feedback: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tagList = widget.tags.split(',').map((tag) => tag.trim()).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Page'),
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF4CAF50),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main image with media gallery
            _buildImageSection(),
            const SizedBox(height: 16),

            // Title and basic info
            _buildTitleSection(tagList),
            const SizedBox(height: 20),

            // Follow button and group info
            _buildFollowSection(),
            const SizedBox(height: 20),

            // Date & Time
            _buildDateTimeSection(),
            const SizedBox(height: 20),

            // DISPLAYING PARKING
            Text('Parking: ${widget.parking}'),
            const SizedBox(height: 20),
            // Location
            _buildLocationSection(),
            const SizedBox(height: 20),

            // Description
            _buildDescriptionSection(),
            const SizedBox(height: 32),

            // Vendor Chat Section
            _buildVendorChatSection(context),
            const SizedBox(height: 32),

            // Feedback Section
            _buildFeedbackSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child:
              widget.imageUrl.isNotEmpty
                  ? Image.network(
                    widget.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                  : Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Center(child: Icon(Icons.image, size: 50)),
                  ),
        ),
        if (widget.media.length > 1)
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '+${widget.media.length - 1}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTitleSection(List<String> tagList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title.toUpperCase(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children:
              tagList
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.pink,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }

  Widget _buildFollowSection() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, color: Colors.grey),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.organiser,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const Text(
                'Group',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        ElevatedButton(
          //TODO: Onpres
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text('Follow This Event'),
        ),
      ],
    );
  }

  Widget _buildDateTimeSection() {
    // TO MATCH THE LOGIC OF THE TIME OF EVENT EITHER ON-GOING OR NOT
    String eventStatus = 'Unknown';
    final now = DateTime.now();
    DateTime? parsedStartDate;
    try {
      parsedStartDate = DateFormat('yyyy-M-dd HH:m').parse(widget.date);
    } catch (e) {
      parsedStartDate = null;
    }

    if (parsedStartDate != null && widget.endDate != null) {
      if (now.isBefore(parsedStartDate)) {
        eventStatus = 'Coming Soon';
      } else if (now.isAfter(widget.endDate!)) {
        eventStatus = 'Ended';
      } else {
        eventStatus = 'On-Going';
      }
    }
    String formattedStart =
        parsedStartDate != null
            ? DateFormat('d MMMM yyyy, h:mm a').format(parsedStartDate)
            : 'N/A';
    String formattedEnd =
        widget.endDate != null
            ? DateFormat('d MMMM yyyy, h:mm a').format(widget.endDate!)
            : 'N/A';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.access_time, size: 20),
            SizedBox(width: 8),
            Text('Date & Time', style: TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            const Text(
              'Start: ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(formattedStart),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Text('End: ', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(formattedEnd),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(eventStatus, style: const TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    final LatLng latLng = LatLng(
      widget.geoPoint.latitude,
      widget.geoPoint.longitude,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.location_on, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Location:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // GOOGLE MAPS EMBEDDED VIEW
        SizedBox(
          height: 200,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: latLng, zoom: 15),
              markers: {
                Marker(
                  markerId: const MarkerId("event_location"),
                  position: latLng,
                  infoWindow: InfoWindow(title: widget.locationName),
                ),
              },
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              gestureRecognizers: {
                Factory<OneSequenceGestureRecognizer>(
                  () => EagerGestureRecognizer(),
                ),
              },
            ),
          ),
        ),
        const SizedBox(height: 12),

        // TO OPEN GOOGLE MAPS
        GestureDetector(
          onTap: () async {
            final googleMapsUrl = Uri.parse(
              'https://www.google.com/maps/dir/?api=1&destination=${latLng.latitude},${latLng.longitude}',
            );
            if (await canLaunchUrl(googleMapsUrl)) {
              await launchUrl(
                googleMapsUrl,
                mode: LaunchMode.externalApplication,
              );
            } else {
              throw 'Could not launch Google Maps';
            }
          },
          child: Row(
            children: const [
              Icon(Icons.map, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Open in Google Maps',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.media.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text(
            'More Media:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.media.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder:
                            (_) => Dialog(
                              child: InteractiveViewer(
                                panEnabled: true,
                                minScale: 0.5,
                                maxScale: 4,
                                child: Image.network(
                                  widget.media[index],
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.media[index],
                        width: 120,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 10),
        const Text(
          'Description',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(widget.description),
        const SizedBox(height: 16),
        // Sample bullet points
        // const Column(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     Row(children: [Text('• '), Text('Lorem ipsum')]),
        //     SizedBox(height: 4),
        //     Row(children: [Text('• '), Text('Lorem ipsum')]),
        //     SizedBox(height: 4),
        //     Row(children: [Text('• '), Text('Lorem ipsum')]),
        //     SizedBox(height: 4),
        //     Row(children: [Text('• '), Text('Lorem ipsum')]),
        //   ],
        // ),
      ],
    );
  }

  Widget _buildVendorChatSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you a Vendor? Chat with Us.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Navigate to chat or open chat dialog
              _showChatDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Chat'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Feedback section',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),

        // FEEDBACK INPUT START
        if (_getEventStatus() == 'Coming Soon') ...[
          const Text(
            'Feedback will be available once the event starts.',
            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 20),
        ] else if (_hasSubmittedFeedback) ...[
          const Text(
            'You have already submitted your feedback for this event.',
            style: TextStyle(color: Colors.green, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 20),
        ] else ...[
          // FEEDBACK INPUT START
          TextField(
            controller: _feedbackController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Write your feedback...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // RATING DROPDOWN
          DropdownButtonFormField<String>(
            value: _selectedRating,
            items:
                [
                  '1 Ratings',
                  '2 Ratings',
                  '3 Ratings',
                  '4 Ratings',
                  '5 Ratings',
                ].map((rating) {
                  return DropdownMenuItem<String>(
                    value: rating,
                    child: Text(rating),
                  );
                }).toList(),
            onChanged: (value) {
              _selectedRating = value!;
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // SUBMIT BUTTON
          ElevatedButton(
            onPressed: () async => await _submitFeedback(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Submit Feedback'),
          ),
          const SizedBox(height: 20),
        ],

        // Ratings bar
        DropdownButtonFormField<String>(
          value: _selectedDisplayRating,
          items:
              [
                '1 Ratings',
                '2 Ratings',
                '3 Ratings',
                '4 Ratings',
                '5 Ratings',
              ].map((rating) {
                return DropdownMenuItem<String>(
                  value: rating,
                  child: Text(
                    rating,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedDisplayRating = value!;
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.pink,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          dropdownColor: Colors.pink,
          iconEnabledColor: Colors.white,
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 16),

        // Feedback items
        StreamBuilder(
          stream:
              FirebaseFirestore.instance
                  .collection('event')
                  .doc(widget.eventId)
                  .collection('feedback')
                  .where('status', isEqualTo: 'Safe')
                  .where('rating', isEqualTo: _selectedDisplayRating)
                  //.orderBy('timestamp', descending: true)
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Text('No feedback yet.');
            }

            final docs = snapshot.data!.docs;
            // print('Loaded feedback count: ${docs.length}');
            // print('Event ID used: ${widget.eventId}');

            return Column(
              children:
                  snapshot.data!.docs.map((doc) {
                    final Map<String, dynamic> data =
                        doc.data() as Map<String, dynamic>;
                    return _buildFeedbackItem(data);
                  }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeedbackItem(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<DocumentSnapshot>(
            future:
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(data['userId'])
                    .get(),

            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                );
              }

              if (snapshot.hasData && snapshot.data!.exists) {
                final userData = snapshot.data!.data() as Map<String, dynamic>;
                final imageUrl = userData['profileImageUrl'];
                if (imageUrl != null && imageUrl.isNotEmpty) {
                  return CircleAvatar(backgroundImage: NetworkImage(imageUrl));
                }
              }
              return const CircleAvatar(
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              );
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name'] ?? 'Anonymous',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(data['comment'] ?? ''),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(
                    _extractStarCount(data['rating']),
                    (index) =>
                        const Icon(Icons.star, size: 16, color: Colors.orange),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat(
                    'd MMM yyyy h:mm a',
                  ).format((data['timestamp'] as Timestamp).toDate()),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Vendor Chat'),
            content: const Text(
              'Chat with vendor now !!. Dont miss the oppurtunity',
            ),
            actions: [
              TextButton(
                onPressed: () => launchUrl(Uri.parse(widget.wsLink)),
                child: const Text('Join Chat'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}
