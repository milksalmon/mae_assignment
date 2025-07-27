import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchPage extends StatefulWidget {
  final List<Map<String, String>> allEvents;
  const SearchPage({Key? key, required this.allEvents}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String _searchQuery = '';
  // String _location = ''; // Removed unused variable

  List<Map<String, String>> get _filteredEvents {
    if (_searchQuery.isEmpty) return widget.allEvents;
    return widget.allEvents.where((event) {
      final query = _searchQuery.toLowerCase();
      return event['title']!.toLowerCase().contains(query) ||
          event['organiser']!.toLowerCase().contains(query) ||
          event['tags']!.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search events...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey),
          ),
          style: GoogleFonts.montserrat(fontSize: 18, color: Colors.black),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enter Location field
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: 'Enter Location',
                prefixIcon: Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  // Optionally use location for filtering
                });
              },
            ),
            SizedBox(height: 16),
            Expanded(
              child: _filteredEvents.isEmpty
                  ? Center(child: Text('No events found.'))
                  : ListView.builder(
                      itemCount: _filteredEvents.length,
                      itemBuilder: (context, index) {
                        final event = _filteredEvents[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.pinkAccent,
                            child: Icon(Icons.event, color: Colors.white),
                          ),
                          title: Text(event['title'] ?? ''),
                          subtitle: Text(event['organiser'] ?? ''),
                          onTap: () {
                            // Optionally navigate to event details
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
