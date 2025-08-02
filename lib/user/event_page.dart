import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

// class EventPage extends StatelessWidget {
//   final String eventId;
//   final String imageUrl;
//   final String title;
//   final String organiser;
//   final String tags;
//   final String date;
//   final List<String> media;
//   final String description;

//   const EventPage({
//     Key? key,
//     required this.eventId,
//     required this.imageUrl,
//     required this.title,
//     required this.organiser,
//     required this.tags,
//     required this.date,
//     required this.media,
//     required this.description,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final tagList = tags.split(',').map((tag) => tag.trim()).toList();

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(title: const Text('Event Page')),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             imageUrl.isNotEmpty
//                 ? Image.network(imageUrl, fit: BoxFit.cover)
//                 : Container(
//                   height: 200,
//                   color: Colors.grey[300],
//                   child: const Center(child: Icon(Icons.image)),
//                 ),
//             const SizedBox(height: 16),
//             Text(date, style: const TextStyle(color: Colors.red)),
//             const SizedBox(height: 8),
//             Text(
//               title,
//               style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 4),
//             Text('by $organiser', style: const TextStyle(fontSize: 16)),
//             const SizedBox(height: 12),
//             Wrap(
//               spacing: 6,
//               children: tagList.map((tag) => Chip(label: Text(tag))).toList(),
//             ),
//             const SizedBox(height: 20),
//             if (media.isNotEmpty) ...[
//               const SizedBox(height: 20),
//               const Text(
//                 'More Media:',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 8),
//               SizedBox(
//                 height: 100,
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: media.length,
//                   itemBuilder: (context, index) {
//                     return Padding(
//                       padding: const EdgeInsets.only(right: 8.0),
//                       child: GestureDetector(
//                         onTap: () {
//                           showDialog(
//                             context: context,
//                             builder:
//                                 (_) => Dialog(
//                                   child: InteractiveViewer(
//                                     panEnabled: true,
//                                     minScale: 0.5,
//                                     maxScale: 4,
//                                     child: Image.network(
//                                       media[index],
//                                       fit: BoxFit.contain,
//                                     ),
//                                   ),
//                                 ),
//                           );
//                         },
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(8),
//                           child: Image.network(
//                             media[index],
//                             width: 120,
//                             height: 100,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//             const Text(
//               'Event Details:',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Text(description),
//           ],
//         ),
//       ),
//     );
//   }
// }


class EventPage extends StatelessWidget {
  final String eventId;
  final String imageUrl;
  final String title;
  final String organiser;
  final String tags;
  final String date;
  // final String location;
  final List<String> media;
  final String description;

  const EventPage({
    Key? key,
    required this.eventId,
    required this.imageUrl,
    required this.title,
    required this.organiser,
    required this.tags,
    required this.date,
    // required this.location,
    required this.media,
    required this.description,
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
          child: imageUrl.isNotEmpty
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
          children: tagList.map((tag) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.pink,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              tag,
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          )).toList(),
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
            Text(
              date,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Coming Soon',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
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
        // Text(location),
        const SizedBox(height: 12),
        // Placeholder for map
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text('Map View (Integrate with Google Maps)'),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(description),
        const SizedBox(height: 16),
        // Sample bullet points
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Text('• '), Text('Lorem ipsum')]),
            SizedBox(height: 4),
            Row(children: [Text('• '), Text('Lorem ipsum')]),
            SizedBox(height: 4),
            Row(children: [Text('• '), Text('Lorem ipsum')]),
            SizedBox(height: 4),
            Row(children: [Text('• '), Text('Lorem ipsum')]),
          ],
        ),
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
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
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
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
      builder: (context) => AlertDialog(
        title: const Text('Vendor Chat'),
        content: const Text('Chat functionality would be implemented here with real-time messaging.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}