import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gwapo/profile/profile_controller.dart';
import 'package:image_picker/image_picker.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final _controller = Get.put(ProfileController());

  final _username = TextEditingController();

  final _email = TextEditingController();

  final _password = TextEditingController();

  String? base64Image;
  Uint8List? _imageBytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Obx(() {
            _controller.getUserInfo();
            final Map<String, dynamic> profile = _controller.userInfo;
            // Decode the base64 image from the user info
            Uint8List? imageBytess;
            try {
              if (profile['image'] != null) {
                imageBytess = base64Decode(profile['image']);
              }
            } catch (e) {
              log('Error $e');
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 100),
                // Back button
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  "Profile Settings",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Your Profile",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 50),

                // Profile Avatar with Edit Icon
                Stack(
                  children: [
                    ClipOval(
                        child: imageBytess != null
                            ? Image.memory(
                                imageBytess,
                                height: 110,
                                width: 110,
                                fit: BoxFit.cover,
                                gaplessPlayback: true,
                              )
                            : Image.asset(
                                'assets/fish.png',
                                height: 110,
                                width: 110,
                                fit: BoxFit.cover,
                                gaplessPlayback: true,
                              )),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                          width: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color.fromARGB(255, 1, 40, 71),
                            border: Border.all(
                              color: Colors.white,
                              width: 1,
                            ),
                          ),
                          child: IconButton(
                              onPressed: pickImageAndProcess,
                              icon: const Icon(
                                Icons.edit,
                                size: 12,
                                color: Colors.white,
                              ))),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Name Field
                buildInputField(
                    profile['username'] ?? 'Default', true, _username),
                const SizedBox(height: 16),

                // Save Button
                GestureDetector(
                  onTap: () async {
                    await _controller.updateUserInfo(
                        _username.text == ""
                            ? profile['username']
                            : _username.text,
                        base64Image!);
                    Get.back();
                    Get.snackbar('Success', 'Profile updated successfully',
                        colorText: Colors.white);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
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
                      child: const Center(
                        child: Text(
                          "Save",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // Reusable Input Field Widget
  Widget buildInputField(
    String hint,
    bool enable,
    TextEditingController controller, {
    bool isObscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        enabled: enable,
        cursorColor: Colors.white,
        obscureText: isObscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white70),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
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

  // Function to load image bytes into ImageProvider
}
