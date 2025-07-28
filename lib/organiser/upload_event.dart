import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UploadEventForm extends StatefulWidget {
  @override
  _UploadEventFormState createState() => _UploadEventFormState();
}

LatLng _selectedLocation = LatLng(3.1390, 101.6869); // Kuala Lumpur
Set<Marker> _markers = {};

class _UploadEventFormState extends State<UploadEventForm> {
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
    _eventNameController.dispose();
    _hashtagsController.dispose();
    _descriptionController.dispose();
    _whatsappLinkController.dispose();
    super.dispose();
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
                GestureDetector(
                  onVerticalDragDown: (_) {},
                  child: SizedBox(
                    height: 200,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _selectedLocation ?? LatLng(3.1390, 101.6869),
                        zoom: 14.0,
                      ),
                      markers: _markers,
                      onTap: (LatLng tappedPoint) {
                        setState(() {
                          _selectedLocation = tappedPoint;
                          _markers = {
                            Marker(
                              markerId: MarkerId("selected-location"),
                              position: tappedPoint,
                            ),
                          };
                        });
                      },
                      onMapCreated: (GoogleMapController controller) {
                        setState(() {
                          _markers = {
                            Marker(
                              markerId: MarkerId("selected-location"),
                              position:
                                  _selectedLocation ?? LatLng(3.1390, 101.6869),
                            ),
                          };
                        });
                      }, //accept when merging
                      zoomControlsEnabled: true,
                      zoomGesturesEnabled: true,
                      scrollGesturesEnabled: true,
                      rotateGesturesEnabled: true,
                      tiltGesturesEnabled: true,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      compassEnabled: true,
                      gestureRecognizers: {
                        Factory<OneSequenceGestureRecognizer>(
                          //accept when merging
                          () => EagerGestureRecognizer(),
                        ),
                      },
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Lat: ${_selectedLocation?.latitude}, Lng: ${_selectedLocation?.longitude}",
                  style: TextStyle(fontSize: 14),
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Save to Firebase
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
                    labelText: "WhatsApp Link",
                    helperText: "Format: https://wa.me/60XXXXXXXXXX", //acceopt when merging
                  ),
                  validator: (value) => value!.isEmpty ? "Required" : null,
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
                Center( //accept when merging
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Submit logic here
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Event submitted!")),
                        );
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
