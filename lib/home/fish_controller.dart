import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:get/get.dart';

class FishController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;

  RxList<Map<String, dynamic>> fishData = <Map<String, dynamic>>[].obs;
  Future<void> getFishData() async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('activities')
        .get();
    fishData.value = querySnapshot.docs
        .map((doc) => {
              'changeWater': doc['changeWater'],
              'createdAt': doc['createdAt'],
              'feedTimes': doc['feedTimes'],
              'fishType': doc['fishType'],
              'fish_id': doc['fish_id'],
              'foodType': doc['foodType'],
              'imageUrl': doc['imageUrl'],
              'size': doc['size'],
              'waterTemperature': doc['waterTemperature'],
            })
        .toList();
  }

  RxMap<String, dynamic> specificFishData = <String, dynamic>{}.obs;
  Future<void> getSpecificFishData(String fishId) async {
    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('activities')
          .doc(fishId)
          .get();

      if (documentSnapshot.exists) {
        specificFishData.value =
            documentSnapshot.data() as Map<String, dynamic>;
        // log('Success: $specificFishData');
      } else {
        log('Document does not exist');
      }
    } catch (e) {
      log('Error $e');
    }
  }

  Future<void> deletedFeedTimes(String fishId, List feedTimes) async {
    try {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('activities')
          .doc(fishId)
          .set({'feedTimes': feedTimes}, SetOptions(merge: true));
    } catch (t) {
      log('Error $t');
    }
  }

  Future<void> updateWater(String fishId, String water) async {
    try {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('activities')
          .doc(fishId)
          .set({'changeWater': water}, SetOptions(merge: true));
    } catch (t) {
      log('Error $t');
    }
  }

  Future<void> updateFish(String fishId, String fishType, String size,
      String foodType, String waterTemperature) async {
    try {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('activities')
          .doc(fishId)
          .set({
        'fishType': fishType,
        'size': size,
        'foodType': foodType,
        'waterTemperature': waterTemperature,
      }, SetOptions(merge: true));
    } catch (t) {
      log('Error $t');
    }
  }

  Future<void> deleteActivities(String fishId) async {
    await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('activities')
        .doc(fishId)
        .delete();
  }

  RxMap<String, dynamic> userInfo = <String, dynamic>{}.obs;
  Future<void> getUserInfo() async {
    try {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection('users').doc(currentUser!.uid).get();
      if (documentSnapshot.exists) {
        userInfo.value = documentSnapshot.data() as Map<String, dynamic>;
      }
    } catch (e) {
      log('Errror $e');
    }
  }
}
