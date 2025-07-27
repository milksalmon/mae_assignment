import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential?> signInWithGoogle() async {
    print('Start google sign in');
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        print('Google sign in aborted');
        return null;
      }

      print('Google user selected: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) return null;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      // Add to Firestore if not exists
      if (!userDoc.exists) {
        // AUTO CREATED FIRESTORE USER
        await _firestore.collection('users').doc(user.uid).set({
          'email': user.email,
          'name': user.displayName,
          'role': 'user',
          'createdAt': FieldValue.serverTimestamp(),
        });
        print('New User created');
      }

      print('User UID: ${user.uid}');
      print('User email: ${user.email}');
      print('Firestore user exists: ${userDoc.exists}');

      return userCredential;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }
}
