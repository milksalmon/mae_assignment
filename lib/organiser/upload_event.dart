import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UploadEventForm extends StatefulWidget {
  @override
  _UploadEventFormState createState() => _UploadEventFormState();
}

class _UploadEventFormState extends State<UploadEventForm> {
  final _formKey = GlobalKey<FormState>();
  XFile? _coverImage;
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _eventTime;
  bool _parkingAvailable = false;
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
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
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

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _eventTime = picked;
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
                  child: _coverImage == null
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
                decoration: InputDecoration(labelText: "Hashtags"),
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _pickDate(isStart: true),
                      child: Text(_startDate == null
                          ? "Pick Start Date"
                          : "Start: ${_startDate!.toLocal()}".split(' ')[0]),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _pickDate(isStart: false),
                      child: Text(_endDate == null
                          ? "Pick End Date"
                          : "End: ${_endDate!.toLocal()}".split(' ')[0]),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: _pickTime,
                child: Text(_eventTime == null
                    ? "Pick Time"
                    : "Time: ${_eventTime!.format(context)}"),
              ),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(labelText: "Event Description"),
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              SizedBox(height: 16),
              Text("Location (Google Maps placeholder)"),
              Container(
                height: 200,
                color: Colors.grey[300],
                child: Center(child: Text("Map goes here")), // Replace with real map
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
                    CheckboxListTile(
                      title: Text("Free Parking"),
                      value: _parkingOptions.contains("Free"),
                      onChanged: (val) {
                        setState(() {
                          if (val!) {
                            _parkingOptions.add("Free");
                          } else {
                            _parkingOptions.remove("Free");
                          }
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: Text("Paid Parking"),
                      value: _parkingOptions.contains("Paid"),
                      onChanged: (val) {
                        setState(() {
                          if (val!) {
                            _parkingOptions.add("Paid");
                          } else {
                            _parkingOptions.remove("Paid");
                          }
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