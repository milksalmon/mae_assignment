import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class OrganiserRegistration extends StatefulWidget {
  const OrganiserRegistration({super.key});

  @override
  State<OrganiserRegistration> createState() => _OrganiserRegistration();
}

class _OrganiserRegistration extends State<OrganiserRegistration> {
  String statusFilter = 'Pending';
  final List<String> statuses = ['Pending', 'Approved', 'Rejected'];

  List<Map<String, dynamic>> requests = [];
  bool isLoading = true;

  // RUN THIS CODE WHEN THE SCREENS OPEN
  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  // URL LAUNCHER FUNCTION
  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open attachment.')));
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
            //const SizedBox(width: 5), // ADDING SPACE BETWEEN LOGO AND TEXT
            Text(
              'Organiser Registration',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),

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
                  //DROP DOWN MENU START
                  child: DropdownButton<String>(
                    value: statusFilter,
                    onChanged: (String? newValue) {
                      setState(() {
                        statusFilter = newValue!;
                      });
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
                    //underline: SizedBox(),
                  ),
                  //DROP DOWN END
                ),
              ],
            ),
            //const SizedBox(height: 10),

            // LIST OF REQUEST CARD
            Expanded(
              child:
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ListView(
                        children:
                            requests
                                .where((item) => item['status'] == statusFilter)
                                .map(
                                  (item) => buildRequestCard(
                                    context: context,
                                    company: item['organizationName'],
                                    name: item['picName'],
                                    remarks: item['description'],
                                    date: item['createdAt'],
                                    status: item['status'],
                                    attachments:
                                        item['attachments'] != null
                                            ? List<String>.from(
                                              item['attachments'],
                                            )
                                            : [],
                                    onLaunchURL: _launchURL,
                                    docId: item['id'], // PASS THE DOCID
                                    onStatusChanged: fetchRequests,
                                  ),
                                )
                                .toList(),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchRequests() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('organisers').get();

      setState(() {
        requests =
            snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;

              if (data['createdAt'] is Timestamp) {
                final dt = (data['createdAt'] as Timestamp).toDate();
                data['createdAt'] =
                    '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute}';
              } else {
                data['createdAt'] = 'N/A';
              }
              return data;
            }).toList();
        isLoading = false;
      });
    } catch (e) {
      print('ERROR FETCHING REQUESTS: $e');
      setState(() {
        isLoading = false;
      });
    }
  }
}

// BUILD REQUEST THE CARD OF ORGANISER
Widget buildRequestCard({
  required BuildContext context,
  required String company,
  required String name,
  required String remarks,
  required String date,
  required String status, // TO ENABLE FILTERING CARD
  required List<String>? attachments, // FOR ATTACHING FILE
  required void Function(String) onLaunchURL,
  required String docId,
  required VoidCallback onStatusChanged, // TO REFRESH PAGE AFTER UPDATE
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
          Text(company, style: const TextStyle(color: Colors.pink)),
          const SizedBox(height: 6),
          Row(
            children: [
              const CircleAvatar(child: Icon(Icons.person)),
              const SizedBox(width: 8),
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Remarks',
            style: TextStyle(decoration: TextDecoration.underline),
          ),
          Text(remarks.isNotEmpty ? remarks : '-'),
          //const Text('Lorem Ipsum Dolor Sit Amet'),
          const SizedBox(height: 10),
          // FOR ATTACHMENT
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
                                trailing: const Icon(Icons.download),
                                onTap: () async {
                                  Navigator.pop(context);
                                  final status =
                                      await Permission.storage.request();
                                  // final path =
                                  //     '${downloadsDir!.path}/$fileName';

                                  if (status.isGranted) {
                                    // final dir =
                                    //     await getExternalStorageDirectory();

                                    try {
                                      final downloadsDir =
                                          await getExternalStorageDirectories(
                                            type: StorageDirectory.downloads,
                                          );
                                      if (downloadsDir == null ||
                                          downloadsDir.isEmpty) {
                                        throw 'Downloads directory not available';
                                      }
                                      final savePath =
                                          '${downloadsDir.first.path}/$fileName';
                                      await Dio().download(url, savePath);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Downlaoded to $savePath',
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
                                  } else {
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
                                  }
                                },
                              );
                            }).toList(),
                      ),
                );
              },
              icon: const Icon(Icons.attach_file),
              label: Text('${attachments.length} Attachment'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.grey[300],
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date),
              if (status == 'Pending') ...[
                // ONLY SHOW IF PENDING STATUS
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('organisers')
                            .doc(docId)
                            .update({'status': 'Approved'});
                        onStatusChanged();
                      },
                    ),
                    const Text('Approve'),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('organisers')
                            .doc(docId)
                            .update({'status': 'Rejected'});
                        onStatusChanged();
                      },
                    ),
                    const Text('Reject'),
                  ],
                ),
              ] else if (status == 'Rejected') ...[
                const Text('Rejected', style: TextStyle(color: Colors.red)),
              ] else if (status == 'Approved') ...[
                const Text('Approved', style: TextStyle(color: Colors.green)),
              ],
            ],
          ),
        ],
      ),
    ),
  );
}
