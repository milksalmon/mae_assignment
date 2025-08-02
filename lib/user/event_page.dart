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

class EventPage extends StatelessWidget {
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tagList = tags.split(',').map((tag) => tag.trim()).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Event Page'),
        backgroundColor: Colors.white,
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
            Text('Parking: $parking'),
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
              imageUrl.isNotEmpty
                  ? Image.network(
                    imageUrl,
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
        if (media.length > 1)
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
                '+${media.length - 1}',
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
          title.toUpperCase(),
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
                organiser,
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
            padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 12),
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
    DateTime? parsedDate;
    try {
      parsedDate = DateFormat('yyyy-M-dd HH:mm').parse(date);
    } catch (e) {
      parsedDate = null;
    }

    String eventStatus;
    if (parsedDate != null) {
      eventStatus =
          parsedDate.isAfter(DateTime.now()) ? 'Coming Soon' : 'On-Going';
    } else {
      eventStatus = 'Unknown';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.access_time, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Date & Time',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(date, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(eventStatus, style: const TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    final LatLng latLng = LatLng(geoPoint.latitude, geoPoint.longitude);

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
                  infoWindow: InfoWindow(title: locationName),
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
        if (media.isNotEmpty) ...[
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
              itemCount: media.length,
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
                                  media[index],
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        media[index],
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
        const Text(
          'Description',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(description),
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
        color: Colors.grey[50],
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

        // Ratings bar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.pink,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '5 Ratings',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(Icons.keyboard_arrow_down, color: Colors.white),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Feedback items
        ...List.generate(3, (index) => _buildFeedbackItem()),
      ],
    );
  }

  Widget _buildFeedbackItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                const Text(
                  'Mr Kun',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
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
                onPressed: () => launchUrl(Uri.parse(wsLink)),
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
