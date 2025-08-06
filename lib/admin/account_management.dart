import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart' show canLaunchUrl, launchUrl;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';

class OrganizerAccountManagement extends StatefulWidget {
  const OrganizerAccountManagement({super.key});

  @override
  State<OrganizerAccountManagement> createState() =>
      _OrganizerAccountManagementState();
}

class _OrganizerAccountManagementState
    extends State<OrganizerAccountManagement> {
  String statusFilter = 'Approved';
  final List<String> statuses = ['Suspend', 'Approved'];

  @override
  void initState() {
    super.initState();
    // Fetch organiser accounts from the provider or database
    _fetchOrganiserAccounts();
  }

  // TO UPDATE THE STATUS TO SUSPEND AND UNSUSPEND
  Future<void> _updateStatusForSelected(String newStatus) async {
    try {
      final selectedIds =
          _selectedOrganisers.entries
              // entry.value = docID of the selected checkbox
              .where((entry) => entry.value)
              // entry.key = is the boolean true/false.
              .map((entry) => entry.key)
              .toList();
      // WRITE ALL THE SELECTED DOCID INTO LIST {}

      for (String docId in selectedIds) {
        await FirebaseFirestore.instance
            .collection('organisers')
            .doc(docId)
            .update({'status': newStatus});
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Status updated to $newStatus.')));

      await _fetchOrganiserAccounts(); // TO REFRESH
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update status: $e')));
    }
  }
  // UPDATE STATUS SUSPEND & UNSUSPEND END

  final Map<String, bool> _selectedOrganisers = {};

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
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  // DROP DOWN MENU
                  child: DropdownButton<String>(
                    value: statusFilter,
                    onChanged: (String? newValue) {
                      setState(() {
                        statusFilter = newValue!;
                        isLoading = true;
                      });
                      _fetchOrganiserAccounts();
                    },
                    items:
                        statuses.map((status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(
                              'Status: $status',
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
              ],
            ),
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
                            company: org['organizationName'],
                            name: org['picName'],
                            //remarks: org['description'] ?? '',
                            date: org['date'] ?? 'N/A',
                            status: org['status'],
                            attachments: List<String>.from(
                              org['attachments'] ?? [],
                            ),
                            onLaunchUrl: _launchURL,
                            ratingBreakdown: Map<String, dynamic>.from(
                              org['ratingBreakdown'] ?? {},
                            ),
                            docId: org['id'],
                            onStatusChanged: _fetchOrganiserAccounts,
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
                _buildActionButton('Unsuspend', Colors.green, () async {
                  await _updateStatusForSelected('Approved');
                }),
                const SizedBox(width: 10),
                _buildActionButton('Suspend', Colors.red, () async {
                  await _updateStatusForSelected('Suspend');
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

  Future<void> _fetchOrganiserAccounts() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('organisers').get();

      List<Map<String, dynamic>> organiserList = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();

        // FILTER ONLY APPROVED ORGANIZERS
        if ((data['status'] ?? '').toString().trim().toLowerCase() !=
            statusFilter.toLowerCase()) {
          continue;
        }

        data['id'] = doc.id;
        // CONVERTING FIRESSTORE TIMESTAMP
        if (data['createdAt'] is Timestamp) {
          final dt = (data['createdAt'] as Timestamp).toDate();
          data['date'] =
              '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
        } else {
          data['date'] = 'N/A';
        }

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

        organiserList.add(data);
      }

      setState(() {
        _orgAcc = organiserList;
        isLoading = false;
        _selectedOrganisers.clear();
      });
    } catch (e) {
      print('Error fetching organiser accounts: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildRequestCard({
    required BuildContext context,
    required String company,
    required String name,
    //required String remarks,
    required String date,
    required String status,
    required List<String>? attachments,
    required void Function(String) onLaunchUrl,
    required Map<String, dynamic> ratingBreakdown,
    required String docId,
    required VoidCallback onStatusChanged,
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
                  value: _selectedOrganisers[docId] ?? false,
                  onChanged: (bool? newValue) {
                    setState(() {
                      _selectedOrganisers[docId] = newValue ?? false;
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
            //Text(remarks.isNotEmpty ? '* $remarks' : '-'),
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
                                  onTap: () async {
                                    Navigator.pop(context);
                                    final permissionGranted =
                                        await _requestStoragePermission();
                                    // final status =
                                    //     await Permission.storage.request();

                                    if (!permissionGranted) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Storage permission denied',
                                            ),
                                          ),
                                        );
                                      }
                                      return;
                                    }

                                    // if (status.isGranted) {
                                    try {
                                      final directory = Directory(
                                        '/storage/emulated/0/Download',
                                      );
                                      final savePath =
                                          '${directory.path}/$fileName';

                                      await Dio().download(url, savePath);

                                      // final downloadsDir =
                                      //     await getExternalStorageDirectory();
                                      // if (downloadsDir == null) {
                                      //   throw 'Downloads directory not available';
                                      // }

                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Downloaded to $savePath',
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Download failed: $e',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
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
      padding: const EdgeInsets.all(12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 4,
      shadowColor: Colors.black38,
    ),
    child: Row(
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
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

// FUNCTION TO REQUEST WRITE INTERNAL STORAGE
Future<bool> _requestStoragePermission() async {
  if (await Permission.storage.request().isGranted) {
    return true;
  }

  if (await Permission.manageExternalStorage.request().isGranted) {
    return true;
  }

  return false;
}
