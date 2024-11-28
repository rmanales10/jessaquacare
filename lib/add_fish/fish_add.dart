import 'dart:io';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class FishAdd extends StatefulWidget {
  const FishAdd({super.key});

  @override
  State<FishAdd> createState() => _FishAddState();
}

class _FishAddState extends State<FishAdd> {
  // Controllers for input fields
  final TextEditingController _fishTypeController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _foodTypeController = TextEditingController();
  final TextEditingController _waterTemperatureController =
      TextEditingController();

  String? base64Image;
  Uint8List? _imageBytes;

  // Selected feed times
  List<String> selectedFeedTimes = [];
  String selectedChangeWater = "1 Week"; // Default value for Change Water

  bool _isSaving = false; // State to manage save button

  final CollectionReference activities =
      FirebaseFirestore.instance.collection('users');
  final _auth = FirebaseAuth.instance;
  User? get user => _auth.currentUser;

  // Save activity data to Firestore
  Future<void> _saveActivity() async {
    if (_fishTypeController.text.isEmpty ||
        _sizeController.text.isEmpty ||
        _foodTypeController.text.isEmpty ||
        _waterTemperatureController.text.isEmpty ||
        selectedFeedTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields.")),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    String generateFishId() {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final random = math.Random().nextInt(1000).toString().padLeft(3, '0');
      return 'fish-$timestamp$random';
    }

    String fishId = generateFishId();

    try {
      // Save data to Firestore
      await activities.doc(user!.uid).collection('activities').doc(fishId).set({
        'fish_id': fishId,
        'fishType': _fishTypeController.text.trim(),
        'size': _sizeController.text.trim(),
        'foodType': _foodTypeController.text.trim(),
        'waterTemperature': _waterTemperatureController.text.trim(),
        'feedTimes': selectedFeedTimes,
        'changeWater': selectedChangeWater,
        'createdAt': FieldValue.serverTimestamp(),
        'imageUrl': base64Image, // Store base64 image for now
      }, SetOptions(merge: true));
      Get.back();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Activity saved successfully!")),
      );

      // Clear fields after saving
      setState(() {
        _fishTypeController.clear();
        _sizeController.clear();
        _foodTypeController.clear();
        _waterTemperatureController.clear();
        selectedFeedTimes.clear();
        selectedChangeWater = "1 Week";
        base64Image = null; // Reset image data
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving activity: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> pickImageAndProcess() async {
    final ImagePicker picker = ImagePicker();

    try {
      // Pick an image from gallery
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        // Check if the platform is Web
        if (kIsWeb) {
          // Web: Use 'readAsBytes' to process the picked image
          final Uint8List webImageBytes = await pickedFile.readAsBytes();

          setState(() {
            _imageBytes = webImageBytes;
            base64Image =
                base64Encode(webImageBytes); // Store base64 image if needed
          });

          log("Image selected on Web: ${webImageBytes.lengthInBytes} bytes");
        } else {
          // Native (Android/iOS): Use File to get image bytes
          final File nativeImageFile = File(pickedFile.path);

          // Ensure that the file exists
          if (await nativeImageFile.exists()) {
            final Uint8List nativeImageBytes =
                await nativeImageFile.readAsBytes();

            setState(() {
              _imageBytes = nativeImageBytes;
              base64Image = base64Encode(
                  nativeImageBytes); // Store base64 image if needed
            });

            log("Image selected on Native: ${nativeImageFile.path}");
          } else {
            log("File does not exist: ${pickedFile.path}");
          }
        }
      } else {
        log("No image selected.");
      }
    } catch (e) {
      log("Error picking image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // Back Button
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const Text(
                "Schedule Your Activities",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Input Fields
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  children: [
                    buildInputField("Type Of Fish", _fishTypeController),
                    const SizedBox(height: 16),
                    buildInputField("Size", _sizeController),
                    const SizedBox(height: 16),
                    buildInputField("Type of Food", _foodTypeController),
                    const SizedBox(height: 16),
                    buildInputField(
                        "Water Temperature (°C)", _waterTemperatureController),
                    const SizedBox(height: 16),

                    // Feed Time Checkboxes
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Feed Time",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(child: buildCheckbox("7:00 AM")),
                        Expanded(child: buildCheckbox("9:00 AM")),
                        Expanded(child: buildCheckbox("6:00 PM")),
                      ],
                    ),
                    const SizedBox(height: 5),

                    // Change Water Dropdown
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Change Water",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white70, width: 1),
                          ),
                          child: DropdownButton<String>(
                            value: selectedChangeWater,
                            dropdownColor: const Color(0xFF1E1E1E),
                            isExpanded: true,
                            style: const TextStyle(color: Colors.white),
                            underline: const SizedBox(),
                            icon: const Icon(Icons.arrow_drop_down,
                                color: Colors.white),
                            items: ["1 Week", "2 Weeks", "3 Weeks", "4 Weeks"]
                                .map((duration) => DropdownMenuItem(
                                      value: duration,
                                      child: Text(duration),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedChangeWater = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Image Upload Section
                    GestureDetector(
                      onTap: pickImageAndProcess,
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: base64Image == null
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate,
                                        color: Colors.white70, size: 32),
                                    SizedBox(height: 8),
                                    Text(
                                      "Click To Upload Photo",
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              )
                            : Image.memory(
                                _imageBytes!,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Save Button
                    GestureDetector(
                      onTap: _isSaving ? null : _saveActivity,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFF0000),
                              Color.fromARGB(255, 73, 1, 1)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _isSaving ? "Saving..." : "Save",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget to build input fields
  Widget buildInputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          cursorColor: const Color.fromARGB(255, 219, 21, 7),
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1E1E1E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white70),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white70),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 219, 21, 7),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget to build checkboxes
  Widget buildCheckbox(String label) {
    return Row(
      children: [
        Checkbox(
          value: selectedFeedTimes.contains(label),
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                selectedFeedTimes.add(label);
              } else {
                selectedFeedTimes.remove(label);
              }
            });
          },
          activeColor: const Color.fromARGB(255, 219, 21, 7),
          checkColor: Colors.white,
        ),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
