import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UploadEventForm extends StatefulWidget {
  @override
  _UploadEventFormState createState() => _UploadEventFormState();
}

class EventMap extends StatelessWidget {
  final LatLng selectedLocation;
  final Set<Marker> markers;
  final Function(LatLng) onMapTap;
  final Function(GoogleMapController) onMapCreated;

  const EventMap({
    Key? key,
    required this.selectedLocation,
    required this.markers,
    required this.onMapTap,
    required this.onMapCreated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: selectedLocation,
          zoom: 14.0,
        ),
        markers: markers,
        onTap: onMapTap,
        onMapCreated: onMapCreated,
        zoomControlsEnabled: true,
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        gestureRecognizers: {
          Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
        },
      ),
    );
  }
}

LatLng _selectedLocation = LatLng(3.1390, 101.6869); // Kuala Lumpur
Set<Marker> _markers = {};

class _UploadEventFormState extends State<UploadEventForm> {
  bool _isUploading = false;
  late GoogleMapController _mapController;
  final _formKey = GlobalKey<FormState>();

  //accept this for merging
  List<XFile> _mediaFiles = [];
  final ImagePicker _picker = ImagePicker();

  XFile? _coverImage;
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _eventStartTime;
  TimeOfDay? _eventEndTime;
  bool _parkingAvailable = false;
  String? _selectedParkingType;
  List<String> _parkingOptions = [];
  LatLng? _selectedLocation;

  final _eventNameController = TextEditingController();
  final _hashtagsController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _whatsappLinkController = TextEditingController();

  @override
  void dispose() {
    _mapController.dispose();
    _eventNameController.dispose();
    _hashtagsController.dispose();
    _descriptionController.dispose();
    _whatsappLinkController.dispose();
    super.dispose();
  }

  // TO CHECK OF UNAUTHENTICATED USER
  @override
  void initState() {
    super.initState();
    if (FirebaseAuth.instance.currentUser == null) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _coverImage = pickedImage;
      });
    }
  }

  //accept this for merging
  Future<void> _pickMedia() async {
    final List<XFile>? selected = await _picker.pickMultiImage();

    if (selected != null && selected.isNotEmpty) {
      setState(() {
        _mediaFiles.addAll(selected);
      });
    }
  }

  //accept this for merging
  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);

    if (video != null) {
      setState(() {
        _mediaFiles.add(video);
      });
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2050),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _eventStartTime = picked;
        } else {
          _eventEndTime = picked;
        }
      });
    }
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedLocation = position;
      _markers = {
        Marker(markerId: MarkerId("selected-location"), position: position),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload Event Details")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child:
                        _coverImage == null
                            ? Icon(Icons.add_a_photo, size: 50)
                            : Image.file(
                              File(_coverImage!.path),
                              fit: BoxFit.cover,
                            ),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _eventNameController,
                  decoration: InputDecoration(labelText: "Event Name"),
                  validator: (value) => value!.isEmpty ? "Required" : null,
                ),
                TextFormField(
                  controller: _hashtagsController,
                  decoration: InputDecoration(labelText: "Tags"),
                  validator: (value) => value!.isEmpty ? "Required" : null,
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _pickDate(isStart: true),
                        child: Text(
                          _startDate == null
                              ? "Pick Start Date"
                              : "Start: ${_startDate!.toLocal().toString().split(' ')[0]}",
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _pickDate(isStart: false),
                        child: Text(
                          _endDate == null
                              ? "Pick End Date"
                              : "End: ${_endDate!.toLocal().toString().split(' ')[0]}",
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _pickTime(isStart: true),
                        child: Text(
                          _eventStartTime == null
                              ? "Pick Start Time"
                              : "Start Time: ${_eventStartTime!.format(context)}",
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _pickTime(isStart: false),
                        child: Text(
                          _eventEndTime == null
                              ? "Pick End Time"
                              : "End Time: ${_eventEndTime!.format(context)}",
                        ),
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(labelText: "Event Description"),
                  validator: (value) => value!.isEmpty ? "Required" : null,
                ),
                //AIzaSyB30HgRfK2vOxqIffJO-SBMH5K6diEg7LM - gmaps api key
                SizedBox(height: 16),
                Text("Location"),
                EventMap(
                  selectedLocation:
                      _selectedLocation ?? LatLng(3.1390, 101.6869),
                  markers: _markers,
                  onMapTap: _onMapTap,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                ),
                SizedBox(height: 10),
                Text(
                  "Lat: ${_selectedLocation?.latitude}, Lng: ${_selectedLocation?.longitude}",
                  style: TextStyle(fontSize: 14),
                ),
                ElevatedButton(
                  onPressed: () {
                    print("Saved location: $_selectedLocation");
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Location saved!')));
                  },
                  child: Text("Save Location"),
                ),

                SizedBox(height: 16),
                SwitchListTile(
                  title: Text("Parking Available"),
                  value: _parkingAvailable,
                  onChanged: (value) {
                    setState(() {
                      _parkingAvailable = value;
                      _parkingOptions.clear();
                    });
                  },
                ),
                if (_parkingAvailable)
                  Column(
                    children: [
                      RadioListTile<String>(
                        title: Text("Free Parking"),
                        value: "Free",
                        groupValue: _selectedParkingType,
                        onChanged: (value) {
                          setState(() {
                            _selectedParkingType = value;
                          });
                        },
                      ),
                      RadioListTile<String>(
                        title: Text("Paid Parking"),
                        value: "Paid",
                        groupValue: _selectedParkingType,
                        onChanged: (value) {
                          setState(() {
                            _selectedParkingType = value;
                          });
                        },
                      ),
                    ],
                  ),
                TextFormField(
                  controller: _whatsappLinkController,
                  decoration: InputDecoration(
                    labelText: "WhatsApp Number",
                    helperText:
                        "Enter Whatsapp Number (e.g., 0123456789)", //accept when merging
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (!RegExp(r'[0-9]{10}$').hasMatch(value)) {
                      return 'Enter valid format: 0123456789';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Text("Add More Media (optional)"),
                SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _pickMedia,
                      child: Text("Pick Images"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _pickVideo,
                      child: Text("Pick Video"),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Container(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _mediaFiles.length,
                    itemBuilder: (context, index) {
                      final file = _mediaFiles[index];
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child:
                            file.path.endsWith('.mp4') ||
                                    file.path.endsWith('.mov')
                                ? Icon(Icons.videocam, size: 60)
                                : Image.file(
                                  File(file.path),
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  //accept when merging
                  child:
                      _isUploading
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),

                            onPressed: () async {
                              print(
                                'Current User:  ${FirebaseAuth.instance.currentUser}',
                              );
                              if (_formKey.currentState!.validate()) {
                                if (_coverImage == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Please select a cover image before submitting.',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                setState(() {
                                  _isUploading = true;
                                });

                                try {
                                  // GETTING ORGANISER NAME
                                  final uid =
                                      FirebaseAuth.instance.currentUser?.uid;
                                  String organiserName = '';

                                  if (uid != null) {
                                    final orgDoc =
                                        await FirebaseFirestore.instance
                                            .collection('organisers')
                                            .doc(uid)
                                            .get();
                                    if (orgDoc.exists) {
                                      organiserName =
                                          orgDoc.data()?['organizationName'] ??
                                          '';
                                    }
                                  }

                                  final orgNameForPath = organiserName
                                      .replaceAll(' ', '_');
                                  final organiserPath =
                                      'organisers/$orgNameForPath/events';

                                  // WHATSAPP LOGIC LINK HERE
                                  final String whatsappNumber =
                                      _whatsappLinkController.text.trim();
                                  final String whatsappUrl =
                                      'https://wa.me/$whatsappNumber';
                                  // COMBINING DATE AND TIME START
                                  final DateTime startDateTime = DateTime(
                                    _startDate!.year,
                                    _startDate!.month,
                                    _startDate!.day,
                                    _eventStartTime?.hour ?? 0,
                                    _eventStartTime?.minute ?? 0,
                                  );

                                  final DateTime endDateTime = DateTime(
                                    _endDate!.year,
                                    _endDate!.month,
                                    _endDate!.day,
                                    _eventEndTime?.hour ?? 0,
                                    _eventEndTime?.minute ?? 0,
                                  );
                                  // COMBINING DATE AND TIME END

                                  // UPLOADING COVER IMAGES
                                  String? coverImageUrl;
                                  if (_coverImage != null) {
                                    coverImageUrl = await uploadFile(
                                      _coverImage!,
                                      organiserPath,
                                    );
                                  }

                                  //UPLOADING OTHER MEDIA FILES
                                  List<String> mediaUrls = [];
                                  for (var media in _mediaFiles) {
                                    final url = await uploadFile(
                                      media,
                                      organiserPath,
                                    );
                                    mediaUrls.add(url);
                                  }

                                  // PREPARE DATA MAP
                                  Map<String, dynamic> eventData = {
                                    'eventName':
                                        _eventNameController.text.trim(),
                                    'tags':
                                        _hashtagsController.text
                                            .trim()
                                            .split(',')
                                            .map((e) => e.trim())
                                            .toList(),
                                    'startDate': Timestamp.fromDate(
                                      startDateTime,
                                    ),
                                    'endDate': Timestamp.fromDate(endDateTime),
                                    'description':
                                        _descriptionController.text.trim(),
                                    'location': GeoPoint(
                                      _selectedLocation!.latitude,
                                      _selectedLocation!.longitude,
                                    ),
                                    'parking':
                                        _parkingAvailable
                                            ? _selectedParkingType ?? "Unknown"
                                            : "None",
                                    'wsLink': whatsappUrl,
                                    'images':
                                        coverImageUrl ??
                                        '', //IMPLEMENT IMAGE UPLOAD
                                    'media': mediaUrls,
                                    'orgName': organiserName,
                                  };
                                  await FirebaseFirestore.instance
                                      .collection('event')
                                      .add(eventData);
                                  setState(() {
                                    _isUploading = false;
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Event uploaded successfully!",
                                      ),
                                    ),
                                  );

                                  // OPTIONAL AFTER CLICK TO CLEAR FORM OR NAVIGATE
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/orgDashboard',
                                  );
                                } catch (e, st) {
                                  print('Upload error: $e\n$st');
                                  setState(() {
                                    _isUploading = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Error uploading event: $e",
                                      ),
                                    ),
                                  );
                                }

                                // Submit logic here
                                // ScaffoldMessenger.of(context).showSnackBar(
                                //   SnackBar(content: Text("Event submitted!")),
                                // );
                              }
                            },
                            child: Text("Submit Event"),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// HELPER TO UPLOAD FILE TO FIREBASE STORAGE
Future<String> uploadFile(XFile file, String fullPath) async {
  final ref = FirebaseStorage.instance.ref().child(
    '$fullPath/${DateTime.now().millisecondsSinceEpoch}_${file.name}',
  );
  await ref.putFile(File(file.path));
  return await ref.getDownloadURL();
}
