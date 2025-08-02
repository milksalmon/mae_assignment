import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EventPage extends StatelessWidget {
  final String eventId;
  final String imageUrl;
  final String title;
  final String organiser;
  final String tags;
  final String date;
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
    required this.media,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tagList = tags.split(',').map((tag) => tag.trim()).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Event Page')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imageUrl.isNotEmpty
                ? Image.network(imageUrl, fit: BoxFit.cover)
                : Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.image)),
                ),
            const SizedBox(height: 16),
            Text(date, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('by $organiser', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              children: tagList.map((tag) => Chip(label: Text(tag))).toList(),
            ),
            const SizedBox(height: 20),
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
              'Event Details:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(description),
          ],
        ),
      ),
    );
  }
}
