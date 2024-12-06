import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gwapo/auth_screens/login/signin.dart';

class SignupController extends GetxController {
  // Firestore and FirebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  User? get currentUser => _auth.currentUser;

  // Observables
  RxBool obscurePassword = true.obs;
  RxBool obscureConfirmPassword = true.obs;
  RxBool termsAccepted = false.obs;

  // Text Controllers
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Save user to Firebase and Firestore
  Future<void> saveToFirestore() async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      Get.snackbar("Error", "All fields are required!",
          colorText: Colors.white);
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar("Error", "Passwords do not match!", colorText: Colors.white);
      return;
    }

    if (!termsAccepted.value) {
      Get.snackbar("Error", "You must accept the terms and conditions!",
          colorText: Colors.white);
      return;
    }

    try {
      // Firebase Authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Email Verification
      await userCredential.user!.sendEmailVerification();

      // Add to Firestore
      // await usersCollection.add({
      //   'username': username,
      //   'email': email,
      //   'created_at': FieldValue.serverTimestamp(),
      // });

      await usersCollection.doc(currentUser!.uid).set({
        'username': username,
        'email': email,
        'created_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      Get.snackbar("Success",
          "User registered successfully! Check your email for verification.",
          colorText: Colors.white);
      Get.offAll(() => const SignInScreen());
    } catch (e) {
      Get.snackbar("Error", e.toString(), colorText: Colors.white);
    }
  }
}
