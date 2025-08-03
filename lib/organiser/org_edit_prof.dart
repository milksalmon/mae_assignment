import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class OrganiserProfileEdit extends StatefulWidget {
  final String organiserId;
  final String organiserName;

  OrganiserProfileEdit({
    required this.organiserId,
    required this.organiserName,
  });

  @override
  _OrganiserProfileEditState createState() => _OrganiserProfileEditState();
}

class _OrganiserProfileEditState extends State<OrganiserProfileEdit> {
  final ImagePicker _picker = ImagePicker();
  File? _newAttachment;
  bool _isLoading = false;

  Future<void> _pickAttachment() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _newAttachment = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadAttachment() async {
    if (_newAttachment == null) return;

    setState(() => _isLoading = true);

    // GET FILE EXTENSION PATH
    final fileExtension = _newAttachment!.path.split('.').last;
    // FILENAME
    final fileName =
        'new_ssm_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

    final storageRef = FirebaseStorage.instance.ref().child(
      'organisers/${widget.organiserName}/attachments/$fileName',
    );

    await storageRef.putFile(_newAttachment!);

    final downloadUrl = await storageRef.getDownloadURL();

    await FirebaseFirestore.instance
        .collection('organisers')
        .doc(widget.organiserId)
        .update({
          'attachments': FieldValue.arrayUnion([downloadUrl]),
        });

    setState(() => _isLoading = false);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Attachments')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickAttachment,
              child: Text('Select New Attachment'),
            ),
            SizedBox(height: 20),
            _newAttachment != null
                ? Image.file(_newAttachment!, height: 200)
                : Text('No new attachment selected.'),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _uploadAttachment,
                  child: Text('Upload and Save'),
                ),
          ],
        ),
      ),
    );
  }
}
