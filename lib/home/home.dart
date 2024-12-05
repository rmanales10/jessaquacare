import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gwapo/home/view_fish/fish_controller.dart';
import 'package:gwapo/home/view_fish/view_fish.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedCategory = "All"; // Default value for dropdown
  final _controller = Get.put(FishController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestPermissions();
    initCat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF282828),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    padding: const EdgeInsets.all(5),
                    child: Obx(() {
                      _controller.getUserInfo();
                      Uint8List decodedImageBytes;
                      if (_controller.userInfo['image'] != null) {
                        decodedImageBytes =
                            base64Decode(_controller.userInfo['image']);
                      } else {
                        decodedImageBytes = Uint8List.fromList([]);
                      }

                      return Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Hello",
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 14),
                                ),
                                Text(
                                  _controller.userInfo['username'] ??
                                      'Default User',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          decodedImageBytes.isEmpty
                              ? const Center(child: CircularProgressIndicator())
                              : ClipOval(
                                  child: Image.memory(
                                    decodedImageBytes,
                                    width: 50,
                                    height: 50,
                                    gaplessPlayback: true,
                                    fit: BoxFit.cover,
                                  ),
                                )
                        ],
                      );
                    }),
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/notif');
                      },
                      child: const Icon(Icons.notifications_outlined,
                          color: Colors.white)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Title Section
                  const Text(
                    "Dive in and make",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    "fish care simple!",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Dropdown Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      DropdownButton<String>(
                        dropdownColor: Colors.black,
                        value: selectedCategory,
                        style: const TextStyle(color: Colors.white),
                        underline: Container(),
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Colors.white),
                        items: ["All", "Small", "Medium", "Large"]
                            .map((category) => DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(category),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                            _controller.getFishData(size: selectedCategory);
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Obx(() {
                    return GridView.builder(
                      shrinkWrap:
                          true, // Important if this is inside a scrollable parent
                      physics:
                          const NeverScrollableScrollPhysics(), // Prevents independent scrolling
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 2 columns
                        childAspectRatio: 1, // Square cards
                        crossAxisSpacing:
                            12, // Horizontal spacing between grid items
                        mainAxisSpacing:
                            12, // Vertical spacing between grid items
                      ),
                      itemCount: _controller
                          .fishData.length, // Total number of fish cards
                      itemBuilder: (context, index) {
                        final fish = _controller.fishData[index];
                        final Uint8List imageBytes =
                            base64Decode(fish['imageUrl']);

                        return fishCard(
                            fish['fishType'], imageBytes, fish['fish_id']);
                      },
                    );
                  }),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fish Card Widget
  Widget fishCard(String name, Uint8List imagePath, String fishId) {
    return GestureDetector(
      onTap: () => Get.to(() => ScheduledActivitiesPage(
            fishId: fishId,
          )),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color.fromARGB(255, 34, 33, 33), Colors.black87],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 100,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  imagePath,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> requestPermissions() async {
    // Request permissions available in permission_handler
    final statusWakeLock = await Permission.notification
        .request(); // Requesting permission for wake lock
    final statusIgnoreBatteryOptimizations = await Permission
        .ignoreBatteryOptimizations
        .request(); // Request battery optimization permission
    final statusScheduleExactAlarm = await Permission.notification
        .request(); // Request exact alarm permission

    // Permissions not available in permission_handler like RECEIVE_BOOT_COMPLETED need special handling
    // For RECEIVE_BOOT_COMPLETED, you can only check if permission is granted by the system
    // No way to request this permission via Flutter at runtime, so just show feedback to the user if necessary

    if (statusWakeLock.isGranted &&
        statusIgnoreBatteryOptimizations.isGranted &&
        statusScheduleExactAlarm.isGranted) {
      // All permissions granted
      // showSnackBar('All permissions granted!');
    } else {
      // Some permissions were not granted, guide the user to settings if needed
      // showSnackBar('Some permissions are missing!');
      openAppSettings();
    }
  }

  // Function to show a SnackBar for feedback
  void showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // Function to open app settings for manual permission granting
  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  Future<void> initCat() async {
    await _controller.getFishData(size: selectedCategory);
  }
}
