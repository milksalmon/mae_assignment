import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPage();

}

class _EventPage extends State<EventPage> {
  // add states?

  @override
  Widget build (BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Event Page')),
      body: Center(
        child: Text('Hello, Event!')

      )


    );

  }
    
}