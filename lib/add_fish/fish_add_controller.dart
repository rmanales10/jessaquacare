import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gwapo/notification/notification_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:developer';

class FishAddController extends GetxController {
  final NotificationService _notificationService = NotificationService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference activities =
      FirebaseFirestore.instance.collection('users');

  // Controllers for text fields
  final TextEditingController fishTypeController = TextEditingController();
  final TextEditingController foodTypeController = TextEditingController();
  final TextEditingController waterTemperatureController =
      TextEditingController();
  final TextEditingController dateController = TextEditingController();

  // State variables
  RxBool isSaving = false.obs;
  final base64Image = RxnString(null);
  RxList<String> feedTimes = <String>[].obs;
  String? selectedSize;

  User? get user => _auth.currentUser;

  Future<void> pickImageAndProcess() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final Uint8List imageBytes = await pickedFile.readAsBytes();
        base64Image.value = base64Encode(imageBytes);
      } else {
        log("No image selected.");
      }
    } catch (e) {
      log("Error picking image: $e");
    }
  }

  Future<void> saveActivity() async {
    if (fishTypeController.text.isEmpty ||
        selectedSize == null ||
        selectedSize!.isEmpty ||
        foodTypeController.text.isEmpty ||
        waterTemperatureController.text.isEmpty ||
        feedTimes.isEmpty ||
        dateController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill in all fields with valid data.',
          colorText: Colors.white);
      isSaving.value = false;
      return;
    }

    isSaving.value = true;

    String fishId = generateFishId();

    try {
      await activities.doc(user!.uid).collection('activities').doc(fishId).set({
        'fish_id': fishId,
        'fishType': fishTypeController.text.trim(),
        'size': selectedSize,
        'foodType': foodTypeController.text.trim(),
        'waterTemperature':
            double.parse(waterTemperatureController.text.trim()),
        'feedTimes': feedTimes.toList(),
        'changeWater': dateController.text,
        'createdAt': FieldValue.serverTimestamp(),
        'imageUrl': base64Image.value ?? '',
      });

      Get.back(closeOverlays: true);
      Get.snackbar('Success', 'Fish activity saved successfully!',
          colorText: Colors.white);
      resetFields();
    } catch (e) {
      if (e is FirebaseException && e.code == 'invalid-argument') {
        Get.snackbar('Error', 'Invalid data. Please review your inputs.',
            colorText: Colors.white);
      } else {
        Get.snackbar('Error', 'Error saving activity: ${e.toString()}',
            colorText: Colors.white);
      }
    } finally {
      isSaving.value = false;
    }
  }

  String generateFishId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final random = math.Random().nextInt(1000).toString().padLeft(3, '0');
    return 'fish-$timestamp$random';
  }

  void resetFields() {
    fishTypeController.clear();
    selectedSize;
    foodTypeController.clear();
    waterTemperatureController.clear();
    feedTimes.clear();
    base64Image.value = null;
  }

  void addFeedTime(String time) {
    feedTimes.add(time);
    _notificationService.scheduleAlarm(feedTimes.length, 'Feed Fish',
        'It\'s time to feed your fish!', DateTime.now());
  }

  void removeFeedTime(String time) {
    feedTimes.remove(time);
  }
}
