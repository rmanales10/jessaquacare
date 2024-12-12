import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign In method
  Future<String?> signIn(String email, String password) async {
    try {
      // Sign in the user with the provided email and password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if the user's email is verified
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        await _auth.signOut(); // Log out if the email is not verified
        return "Please verify your email before signing in.";
      }

      // Retrieve user data from Firestore (e.g., status, sign-up date)
      await _updateUserStatusToOnline(userCredential.user!.uid);

      return null; // No error if sign-in is successful
    } catch (e) {
      return e.toString(); // Return error message if sign-in fails
    }
  }

  // Update the user's status to "online" when they sign in
  Future<void> _updateUserStatusToOnline(String userId) async {
    try {
      // Update the user's status to "online" in Firestore
      await _firestore.collection('users').doc(userId).set({
        'status': 'online',
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      log("Error updating user status: $e");
    }
  }

  // Forgot password method
  Future<void> forgotPassword(String email) async {
    try {
      // Send password reset email
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      log("Error sending password reset email: $e");
    }
  }

  // Sign out method
  Future<void> signOut() async {
    try {
      // Sign out the user
      await _auth.signOut();
      await _firestore.collection('users').doc(_auth.currentUser!.uid).set({
        'status': 'offline',
      }, SetOptions(merge: true));
    } catch (e) {
      log("Error signing out: $e");
    }
  }
}
