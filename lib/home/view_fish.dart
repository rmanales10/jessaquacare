import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gwapo/home/fish_controller.dart';
import 'package:gwapo/home/home.dart';
import 'package:gwapo/home/navigation.dart';

// ignore: must_be_immutable
class ScheduledActivitiesPage extends StatefulWidget {
  String fishId;
  ScheduledActivitiesPage({super.key, required this.fishId});

  @override
  State<ScheduledActivitiesPage> createState() =>
      _ScheduledActivitiesPageState();
}

class _ScheduledActivitiesPageState extends State<ScheduledActivitiesPage> {
  final _controller = Get.put(FishController());
  final fishType = TextEditingController();
  final foodType = TextEditingController();
  final fishSize = TextEditingController();
  final fishTemperature = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _controller.getSpecificFishData(widget.fishId);
    final fish = _controller.specificFishData;
    fishType.text = fish['fishType'] ?? 'Default';
    foodType.text = fish['foodType'] ?? 'Default';
    fishSize.text = fish['foodType'] ?? 'Default';
    fishTemperature.text = fish['waterTemperature'] ?? 'Default';
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Back Button
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Get.back(),
              ),

              // Title
              const Center(
                child: Text(
                  "Scheduled Activities",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Input Fields and Image Section
              Obx(() {
                _controller.getSpecificFishData(widget.fishId);
                final fish = _controller.specificFishData;
                final List feedTimes = fish['feedTimes'] ?? [];
                final List<String> deletedFeedTimes = [];
                String selectedWaterChange = fish['changeWater'] ?? 'Default';
                Uint8List decodedImageBytes;
                if (fish['imageUrl'] != null) {
                  decodedImageBytes = base64Decode(fish['imageUrl']);
                } else {
                  decodedImageBytes = Uint8List.fromList([]);
                }
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Fish Image
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 34, 33, 33),
                                  Colors.black87
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: SizedBox(
                                width: 120,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    decodedImageBytes,
                                    fit: BoxFit.cover,
                                    gaplessPlayback: true,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Fields
                          Expanded(
                            child: Column(
                              children: [
                                buildInputField(fishType), // Fish Type
                                const SizedBox(height: 16),
                                buildInputField(fishSize), // Size
                                const SizedBox(height: 16),
                                buildInputField(foodType), // Food Type
                                const SizedBox(height: 16),
                                buildInputField(
                                    fishTemperature), // Water Temperature
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Feed Time Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Feed Time",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Feed Time List
                          Column(
                            children: feedTimes.map((time) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 16), // Consistent spacing
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 16),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1E1E1E),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: Colors.white70, width: 1),
                                        ),
                                        child: Text(
                                          time,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                        width:
                                            16), // Space between field and icon
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          feedTimes.remove(time);
                                          deletedFeedTimes.add(time);
                                          _controller.deletedFeedTimes(
                                              widget.fishId, feedTimes);
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.white),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Icon(
                                          Icons.delete,
                                          color:
                                              Color.fromARGB(255, 219, 21, 7),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),

                          // Add Feed Time Button
                          if (feedTimes.length != 3)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  // Define the list of feed times
                                  final List feedTimeList = [
                                    '9:00 AM',
                                    '7:00 AM',
                                    '6:00 PM',
                                  ];

                                  // Find the first missing time from feedTimeList and add it to feedTimes
                                  for (var time in feedTimeList) {
                                    if (!feedTimes.contains(time)) {
                                      feedTimes.add(time);
                                      break; // Exit the loop after adding one time
                                    }
                                  }

                                  // Update the controller with the modified feedTimes list
                                  _controller.deletedFeedTimes(
                                      widget.fishId, feedTimes);
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(top: 12),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child:
                                    const Icon(Icons.add, color: Colors.white),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Change Water Dropdown
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Water Change",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: Colors.white70, width: 1),
                            ),
                            child: DropdownButton<String>(
                              value: selectedWaterChange,
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
                                  _controller.updateWater(
                                      widget.fishId, value!);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Delete and Save Buttons
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                Get.dialog(AlertDialog(
                                  backgroundColor: Colors.red.withOpacity(.6),
                                  title: const Text('Confirm',
                                      style: TextStyle(color: Colors.white)),
                                  content: const Text(
                                      'Are you sure you want to delete this ?',
                                      style: TextStyle(color: Colors.white)),
                                  actions: [
                                    OutlinedButton(
                                        onPressed: () async {
                                          await _controller
                                              .deleteActivities(widget.fishId);
                                          Get.off(() => const Navigation());
                                          Get.snackbar('Success',
                                              'Scheduled deleted successfully!');
                                        },
                                        child: const Text(
                                          'Confirm',
                                          style: TextStyle(color: Colors.white),
                                        )),
                                    ElevatedButton(
                                        onPressed: () async {
                                          return Get.back();
                                        },
                                        child: const Text(
                                          'Back',
                                        )),
                                  ],
                                ));
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 131, 128, 128),
                                      Color(0xFF141414)
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Delete",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                await _controller.updateFish(
                                  widget.fishId,
                                  fishType.text,
                                  fishSize.text,
                                  foodType.text,
                                  fishTemperature.text,
                                );
                                Get.back();
                                Get.snackbar('Success',
                                    'Scheduled activities saved successfully!');
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
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
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // Input Field Widget
  Widget buildInputField(TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white70, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextFormField(
        controller: controller,
        cursorColor: const Color.fromARGB(255, 219, 21, 7),
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintStyle: TextStyle(color: Colors.white54),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
