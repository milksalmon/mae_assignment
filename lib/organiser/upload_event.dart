import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:mae_assignment/user/userDashboard.dart';

class UploadEventForm extends StatefulWidget {
  @override
  _UploadEventFormState createState() => _UploadEventFormState();
}

class _UploadEventFormState extends State<UploadEventForm> {
  final _formKey = GlobalKey<FormState>();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload Event Details")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
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
              SizedBox(
                height: 200,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(3.1390, 101.6869), // Kuala Lumpur
                    zoom: 14.0,
                  ),
                  markers: {
                    Marker(
                      markerId: MarkerId("selected-location"),
                      position: LatLng(3.1390, 101.6869),
                    ),
                  },
                  onMapCreated: (GoogleMapController controller) {
                    // Optional: store controller in a variable if needed
                  },
                  myLocationEnabled: true,
                  zoomControlsEnabled: false,
                ),
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
                decoration: InputDecoration(labelText: "WhatsApp Link"),
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              SizedBox(height: 16),
              Text("Add More Media (optional)"),
              Container(
                height: 100,
                color: Colors.grey[200],
                child: Center(child: Text("Image/Video picker placeholder")),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
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
    );
  }
}
