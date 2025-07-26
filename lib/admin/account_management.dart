import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' show canLaunchUrl, launchUrl;
import 'package:url_launcher/url_launcher_string.dart';
import '../providers/auth_provider.dart';

class OrganizerAccountManagement extends StatefulWidget {
  const OrganizerAccountManagement({super.key});

  @override
  State<OrganizerAccountManagement> createState() =>
      _OrganizerAccountManagementState();
}

class _OrganizerAccountManagementState
    extends State<OrganizerAccountManagement> {
  @override
  void initState() {
    super.initState();
    // Fetch organizer accounts from the provider or database
    _fetchOrganizerAccounts();
  }

  final Map<String, bool> _selectedOrganizers = {};

  List<Map<String, dynamic>> _orgAcc = [];
  bool isLoading = true;

  // URL LAUNCHER FUNCTION
  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, '/adminDashboard');
          },
        ),
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 50),
            // const SizedBox(width: 5),
            Expanded(
              child: Text(
                'Organiser Account Management',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
            //const Text('Account Management'),
          ],
        ),
      ),
      //backgroundColor: Colors.red[300],

      // BODY START HERE
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                        itemCount: _orgAcc.length,
                        itemBuilder: (context, index) {
                          final org = _orgAcc[index];
                          return buildRequestCard(
                            context: context,
                            company: org['company'],
                            name: org['name'],
                            remarks: List<String>.from(org['remarks'] ?? []),
                            date: org['date'],
                            status: org['status'],
                            attachments: List<String>.from(
                              org['attachments'] ?? [],
                            ),
                            onLaunchUrl: _launchURL,
                            ratingBreakdown: Map<String, dynamic>.from(
                              org['ratingBreakdown'] ?? {},
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      //BOTTOM ACTION BAR START HERE
      bottomNavigationBar: Container(
        color: Colors.grey[300],
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: 12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionButton('Suspend', Colors.black, () {
                  print('Suspend Button Clicked');
                }),
              ],
            ),
          ),
        ),
      ),
    );
    // BOTTON ACTION BAR END HERE
  }
  // BODY END HERE

  Future<void> _fetchOrganizerAccounts() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('organizers').get();

      List<Map<String, dynamic>> organizerList = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();

        // FILTER ONLY APPROVED ORGANIZERS
        if ((data['status'] ?? '').toString().trim().toLowerCase() !=
            'approved') {
          continue;
        }

        data['id'] = doc.id;

        // FETCH RATING SUBCOLLECTION
        final ratingSnap = await doc.reference.collection('rating').get();

        if (ratingSnap.docs.isNotEmpty) {
          final ratingData = ratingSnap.docs.first.data();
          double totalWeighted = 0;
          int totalCount = 0;

          for (int i = 1; i <= 5; i++) {
            if (ratingData.containsKey(i.toString())) {
              final count = ratingData[i.toString()];
              if (count != null) {
                totalWeighted += i * (count as num).toDouble();
                totalCount += (count as num).toInt();
              }
            }
          }
          double avgRating = totalCount > 0 ? totalWeighted / totalCount : 0.0;
          data['averageRating'] = avgRating;
          final normalizedRatingData = {
            for (final entry in ratingData.entries)
              entry.key.toString(): entry.value,
          };
          data['ratingBreakdown'] = normalizedRatingData;
        }

        organizerList.add(data);
      }

      setState(() {
        _orgAcc = organizerList;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching organizer accounts: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildRequestCard({
    required BuildContext context,
    required String company,
    required String name,
    required List<String> remarks,
    required String date,
    required String status,
    required List<String>? attachments,
    required void Function(String) onLaunchUrl,
    required Map<String, dynamic> ratingBreakdown,
  }) {
    return Card(
      color: const Color(0xFFFFE3E3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // COMPANY
            Text(company, style: const TextStyle(color: Colors.pink)),
            const SizedBox(height: 6),

            // NAME + AVATAR
            Row(
              children: [
                const CircleAvatar(child: Icon(Icons.person)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Checkbox(
                  value: _selectedOrganizers[name] ?? false,
                  onChanged: (bool? newValue) {
                    setState(() {
                      _selectedOrganizers[name] = newValue ?? false;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // STAR RATING BREAKDOWN
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(5, (index) {
                int star = 5 - index;
                int count = (ratingBreakdown['$star Ratings'] ?? 0) as int;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Row(
                        children: List.generate(star, (_) {
                          return const Icon(
                            Icons.star,
                            size: 18,
                            color: Colors.orange,
                          );
                        }),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formatCount(count),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),

            // REMARKS
            ...remarks.map((remark) => Text('* $remark')).toList(),
            const SizedBox(height: 12),

            // ATTACHMENT SECTION (Only show if attachments exist)
            if (attachments != null && attachments.isNotEmpty) ...[
              TextButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder:
                        (_) => ListView(
                          children:
                              attachments.map((url) {
                                final fileName = Uri.decodeFull(
                                  url.split('/').last.split('?').first,
                                );
                                return ListTile(
                                  leading: const Icon(Icons.attach_file),
                                  title: Text(fileName),
                                  trailing: const Icon(
                                    Icons.download_rounded,
                                    color: Colors.black,
                                  ),
                                  onTap: () => onLaunchUrl(url),
                                );
                              }).toList(),
                        ),
                  );
                },
                icon: const Icon(Icons.attach_file),
                label: Text(
                  '${attachments.length} Attachment${attachments.length > 1 ? "s" : ""}',
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.grey[300],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

Widget _buildActionButton(String label, Color color, VoidCallback onTap) {
  return ElevatedButton(
    onPressed: onTap,
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 4,
      shadowColor: Colors.black38,
    ),
    child: Text(
      label,
      style: GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
  );
}

String _formatCount(int value) {
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}M';
  } else if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(1)}K';
  } else {
    return value.toString();
  }
}
