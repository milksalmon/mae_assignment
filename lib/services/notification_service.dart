import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // Request permission for notifications
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      // Store FCM token for current user
      await _storeFCMToken();
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
      // Store FCM token for current user
      await _storeFCMToken();
    } else {
      print('User declined or has not accepted permission');
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    // Handle notification taps
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      // Handle navigation based on message data
    });

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      print('FCM Token refreshed: $newToken');
      _updateFCMToken(newToken);
    });
  }

  // Store FCM token in user's Firestore document
  static Future<void> _storeFCMToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('No user logged in, cannot store FCM token');
        return;
      }

      final token = await _messaging.getToken();
      if (token != null) {
        print('Storing FCM token for user ${user.uid}: $token');
        
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'fcmToken': token,
          'tokenUpdatedAt': FieldValue.serverTimestamp(),
        });
        
        print('FCM token stored successfully');
      } else {
        print('Failed to get FCM token');
      }
    } catch (e) {
      print('Error storing FCM token: $e');
    }
  }

  // Update FCM token when it refreshes
  static Future<void> _updateFCMToken(String newToken) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'fcmToken': newToken,
        'tokenUpdatedAt': FieldValue.serverTimestamp(),
      });
      
      print('FCM token updated successfully');
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }

  // Call this method when user logs in to ensure FCM token is stored
  static Future<void> ensureFCMTokenStored() async {
    await _storeFCMToken();
  }

  static Future<void> clearFCMToken() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({
      'fcmToken': FieldValue.delete(),
      'tokenUpdatedAt': FieldValue.serverTimestamp(),
    });
    
    print('FCM token cleared on logout');
  } catch (e) {
    print('Error clearing FCM token: $e');
  }
}

  static Future<void> scheduleEventReminder({
    required String eventId,
    required String eventTitle,
    required String organiserName,
    required DateTime eventStartDate,
  }) async {
    // Calculate reminder time (3 days before event)
    final reminderTime = eventStartDate.subtract(const Duration(days: 3));
    
    print('DEBUG NotificationService: Event start date: $eventStartDate');
    print('DEBUG NotificationService: Reminder time: $reminderTime');
    print('DEBUG NotificationService: Current time: ${DateTime.now()}');
    print('DEBUG NotificationService: Is reminder in future? ${reminderTime.isAfter(DateTime.now())}');
    
    // Only schedule if reminder time is in the future
    if (reminderTime.isAfter(DateTime.now())) {
      print('DEBUG NotificationService: Storing reminder in Firestore');
      // Store reminder in Firestore with trigger time
      await _storeReminderInFirestore(
        eventId, 
        reminderTime, 
        eventTitle, 
        organiserName
      );
      print('DEBUG NotificationService: Reminder stored successfully');
    } else {
      print('DEBUG NotificationService: Reminder time is in the past, not storing');
    }
  }

  static Future<void> cancelEventReminder(String eventId) async {
    // Remove reminder from Firestore
    await _removeReminderFromFirestore(eventId);
  }

  static Future<void> _storeReminderInFirestore(
    String eventId, 
    DateTime reminderTime,
    String eventTitle,
    String organiserName,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('reminders')
        .doc(eventId)
        .set({
      'eventId': eventId,
      'eventTitle': eventTitle,
      'organiserName': organiserName,
      'reminderTime': Timestamp.fromDate(reminderTime),
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'active',
      'userId': user.uid,
    });

    // Also store in a global reminders collection for cloud function processing
    await FirebaseFirestore.instance
        .collection('scheduled_reminders')
        .doc('${user.uid}_$eventId')
        .set({
      'eventId': eventId,
      'eventTitle': eventTitle,
      'organiserName': organiserName,
      'reminderTime': Timestamp.fromDate(reminderTime),
      'userId': user.uid,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> _removeReminderFromFirestore(String eventId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Remove from user's reminders
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('reminders')
        .doc(eventId)
        .delete();

    // Remove from global scheduled reminders
    await FirebaseFirestore.instance
        .collection('scheduled_reminders')
        .doc('${user.uid}_$eventId')
        .delete();
  }

  // Get all active reminders for the current user
  static Future<List<Map<String, dynamic>>> getUserReminders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('DEBUG getUserReminders: No user logged in');
      return [];
    }

    print('DEBUG getUserReminders: Fetching reminders for user: ${user.uid}');

    try {
      // Remove orderBy to avoid composite index requirement
      final remindersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('reminders')
          .where('status', isEqualTo: 'active')
          .get();

      print('DEBUG getUserReminders: Found ${remindersSnapshot.docs.length} reminder documents');

      List<Map<String, dynamic>> reminders = [];
      
      for (var doc in remindersSnapshot.docs) {
        final reminderData = doc.data();
        final eventId = reminderData['eventId'];
        
        print('DEBUG getUserReminders: Processing reminder for eventId: $eventId');
        print('DEBUG getUserReminders: Reminder data: $reminderData');
        
        // Fetch event details
        final eventDoc = await FirebaseFirestore.instance
            .collection('event')
            .doc(eventId)
            .get();
            
        if (eventDoc.exists) {
          final eventData = eventDoc.data()!;
          print('DEBUG getUserReminders: Found event data for $eventId: ${eventData['eventName']}');
          
          reminders.add({
            'eventId': eventId,
            'eventTitle': eventData['eventName'] ?? 'Unknown Event',
            'organiserName': eventData['orgName'] ?? 'Unknown Organiser',
            'eventDate': eventData['startDate']?.toDate(),
            'reminderTime': reminderData['reminderTime']?.toDate(),
          });
        } else {
          print('DEBUG getUserReminders: Event document not found for eventId: $eventId');
        }
      }
      
      // Sort reminders by reminder time on the client side
      reminders.sort((a, b) {
        final aTime = a['reminderTime'] as DateTime?;
        final bTime = b['reminderTime'] as DateTime?;
        if (aTime == null || bTime == null) return 0;
        return aTime.compareTo(bTime);
      });
      
      print('DEBUG getUserReminders: Returning ${reminders.length} reminders');
      return reminders;
    } catch (e) {
      print('DEBUG getUserReminders: Error fetching reminders: $e');
      return [];
    }
  }

  // Check and clean up expired reminders
  static Future<void> cleanupExpiredReminders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    
    // Clean up user reminders
    final remindersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('reminders')
        .where('reminderTime', isLessThan: Timestamp.fromDate(now))
        .get();

    for (var doc in remindersSnapshot.docs) {
      await doc.reference.delete();
    }

    // Clean up global scheduled reminders
    final scheduledSnapshot = await FirebaseFirestore.instance
        .collection('scheduled_reminders')
        .where('userId', isEqualTo: user.uid)
        .where('reminderTime', isLessThan: Timestamp.fromDate(now))
        .get();

    for (var doc in scheduledSnapshot.docs) {
      await doc.reference.delete();
    }
  }
}
