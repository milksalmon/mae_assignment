/**
 * Firebase Cloud Functions for Event Reminders
 * Checks for due reminders every minute and sends FCM notifications
 */

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

// Initialize Firebase Admin SDK
admin.initializeApp();

/**
 * Scheduled function that runs every minute to check for due reminders
 * and send FCM notifications to users
 */
export const sendEventReminders = functions
  .runWith({
    memory: '128MB',
    timeoutSeconds: 60,
  })
  .pubsub.schedule('every 1 minutes').onRun(async (context) => {
  console.log("Starting reminder check...");
  
  try {
    const now = admin.firestore.Timestamp.now();
    
    // Ultra-fast check: count pending reminders due in the next hour
    const nextHour = admin.firestore.Timestamp.fromDate(
      new Date(now.toDate().getTime() + 60 * 60 * 1000)
    );
    
    const upcomingQuery = await admin.firestore()
      .collection('scheduled_reminders')
      .where('status', '==', 'pending')
      .where('reminderTime', '<=', nextHour)
      .limit(1)
      .get();
    
    if (upcomingQuery.empty) {
      console.log("No reminders due in next hour, skipping check");
      return;
    }
    
    // Query for reminders that are due RIGHT NOW (reminderTime <= now)
    const dueRemindersQuery = await admin.firestore()
      .collection('scheduled_reminders')
      .where('reminderTime', '<=', now)
      .where('status', '==', 'pending')
      .get();
    
    console.log(`Found ${dueRemindersQuery.docs.length} due reminders`);
    
    if (dueRemindersQuery.empty) {
      console.log("No due reminders found");
      return;
    }
    
    // Process each due reminder
    const results = [];
    
    for (const doc of dueRemindersQuery.docs) {
      const reminderData = doc.data();
      const {userId, eventTitle, organiserName, eventId} = reminderData;
      
      console.log(`Processing reminder for user ${userId}, event: ${eventTitle}`);
      
      try {
        // Get user's FCM token from their user document
        const userDoc = await admin.firestore()
          .collection('users')
          .doc(userId)
          .get();
          
        if (!userDoc.exists) {
          console.warn(`User document not found for userId: ${userId}`);
          await doc.ref.update({ 
            status: 'failed', 
            sentAt: admin.firestore.FieldValue.serverTimestamp(),
            error: 'User document not found'
          });
          continue;
        }
        
        const userData = userDoc.data();
        const fcmToken = userData?.fcmToken;
        
        if (!fcmToken) {
          console.warn(`No FCM token found for user: ${userId}`);
          // Mark as sent even if no token (to avoid retrying)
          await doc.ref.update({ 
            status: 'sent', 
            sentAt: admin.firestore.FieldValue.serverTimestamp(),
            error: 'No FCM token found'
          });
          continue;
        }
        
        // Prepare FCM message
        const message = {
          notification: {
            title: `Event Reminder`,
            body: `"${eventTitle}" by ${organiserName} starts in 3 days!`,
          },
          android: {
            notification: {
              icon: 'ic_notification',
              color: '#4CAF50',
              sound: 'default'
            }
          },
          data: {
            eventId: eventId,
            eventTitle: eventTitle,
            organiserName: organiserName,
            type: 'event_reminder'
          },
          token: fcmToken
        };
        
        // Send FCM notification and update status immediately
        try {
          const response = await admin.messaging().send(message);
          console.log(`Successfully sent notification to user ${userId}: ${response}`);
          
          await doc.ref.update({ 
            status: 'sent', 
            sentAt: admin.firestore.FieldValue.serverTimestamp(),
            fcmResponse: response
          });
          
          results.push({ userId, status: 'sent', response });
        } catch (sendError: any) {
          console.error(`Error sending notification to user ${userId}:`, sendError);
          
          await doc.ref.update({ 
            status: 'failed', 
            sentAt: admin.firestore.FieldValue.serverTimestamp(),
            error: sendError.message
          });
          
          results.push({ userId, status: 'failed', error: sendError.message });
        }
        
      } catch (error: any) {
        console.error(`Error processing reminder for user ${userId}:`, error);
        await doc.ref.update({ 
          status: 'failed', 
          sentAt: admin.firestore.FieldValue.serverTimestamp(),
          error: error instanceof Error ? error.message : 'Unknown error'
        });
        
        results.push({ userId, status: 'failed', error: error.message });
      }
    }
    
    console.log(`Processed ${results.length} reminders:`, results);
    
    console.log("Reminder check completed successfully");
    
  } catch (error: any) {
    console.error("Error in sendEventReminders function:", error);
    throw error;
  }
});

/**
 * Manual test function to reset a failed reminder and send test notification
 */
export const testReminders = functions.https.onRequest(async (req, res) => {
  console.log("Manual test triggered");
  
  try {
    // Check all scheduled reminders
    const allReminders = await admin.firestore()
      .collection('scheduled_reminders')
      .get();
    
    console.log(`Total reminders in collection: ${allReminders.docs.length}`);
    
    // Reset any failed reminders to pending for testing
    const batch = admin.firestore().batch();
    let resetCount = 0;
    
    allReminders.docs.forEach(doc => {
      const data = doc.data();
      console.log(`Reminder: ${doc.id}`, {
        eventTitle: data.eventTitle,
        reminderTime: data.reminderTime.toDate(),
        status: data.status,
        userId: data.userId
      });
      
      // Reset failed reminders to pending
      if (data.status === 'failed') {
        batch.update(doc.ref, { 
          status: 'pending',
          error: admin.firestore.FieldValue.delete(),
          sentAt: admin.firestore.FieldValue.delete()
        });
        resetCount++;
      }
    });
    
    if (resetCount > 0) {
      await batch.commit();
      console.log(`Reset ${resetCount} failed reminders to pending`);
    }
    
    const now = admin.firestore.Timestamp.now();
    console.log(`Current time: ${now.toDate()}`);
    
    // Check for pending reminders
    const pendingReminders = await admin.firestore()
      .collection('scheduled_reminders')
      .where('status', '==', 'pending')
      .get();
    
    console.log(`Pending reminders: ${pendingReminders.docs.length}`);
    
    // Check for due reminders
    const dueReminders = await admin.firestore()
      .collection('scheduled_reminders')
      .where('reminderTime', '<=', now)
      .where('status', '==', 'pending')
      .get();
    
    console.log(`Due reminders: ${dueReminders.docs.length}`);
    
    res.json({
      success: true,
      totalReminders: allReminders.docs.length,
      pendingReminders: pendingReminders.docs.length,
      dueReminders: dueReminders.docs.length,
      resetCount: resetCount,
      currentTime: now.toDate(),
      reminders: allReminders.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
        reminderTime: doc.data().reminderTime.toDate()
      }))
    });
    
  } catch (error: any) {
    console.error("Error in test function:", error);
    res.status(500).json({ error: error.message });
  }
});
