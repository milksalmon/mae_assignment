import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

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
                                    company: item['company'],
                                    name: item['name'],
                                    remarks: List<String>.from(item['remarks']),
                                    date: item['date'],
                                    status: item['status'],
                                    attachments:
                                        item['attachments'] != null
                                            ? List<String>.from(
                                              item['attachments'],
                                            )
                                            : [],
                                    onLaunchURL: _launchURL,
                                  ),
                                )
                                .toList(),
                      ),
              // child: ListView(
              //   children: [
              //     // LIST OF ALL CARD
              //     buildRequestCard(
              //       company: 'Kawkandy Solo',
              //       name: 'Arfan Arhan',
              //       remarks: [
              //         'Organizing event at Johor Bharu Skudai',
              //         'Inviting food halal vendors',
              //       ],
              //       date: '20 July 2024',
              //       status: 'Pending',
              //     ),
              //     buildRequestCard(
              //       company: 'TV3 Marketing',
              //       name: 'Sangkau Liyau',
              //       remarks: ['Ting tang ting', 'Tung tung tung sahur'],
              //       date: '20 July 2024',
              //       status: 'Rejected',
              //     ),
              //     // ADD ANOTHER CARD BELOW
              //   ],
              //   // FILTERING THE LIST
              //   //.where((widget) => widget.status == statusFilter).toList(),
              // ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchRequests() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('organizers').get();

      setState(() {
        requests =
            snapshot.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();
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
  required List<String> remarks,
  required String date,
  required String status, // TO ENABLE FILTERING CARD
  required List<String>? attachments, // FOR ATTACHING FILE
  required void Function(String) onLaunchURL,
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
          ...remarks.map((text) => Text(". $text")).toList(),
          const SizedBox(height: 10),
          const Text('Lorem Ipsum Dolor Sit Amet'),
          const SizedBox(height: 10),
          if (attachments != null && attachments.isNotEmpty) ...[
            TextButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder:
                      (_) => ListView(
                        children:
                            attachments.map((url) {
                              final fileName =
                                  url.split('/').last.split('?').first;
                              return ListTile(
                                leading: const Icon(Icons.attach_file),
                                title: Text(fileName),
                                trailing: const Icon(Icons.download),
                                onTap: () => onLaunchURL(url),
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
                      onPressed: () {},
                    ),
                    const Text('Approve'),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {},
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
