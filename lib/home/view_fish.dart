import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gwapo/home/fish_controller.dart';

class ScheduledActivitiesPage extends StatefulWidget {
  String fishId;
  ScheduledActivitiesPage({super.key, required this.fishId});

  @override
  State<ScheduledActivitiesPage> createState() =>
      _ScheduledActivitiesPageState();
}

class _ScheduledActivitiesPageState extends State<ScheduledActivitiesPage> {
  final List<String> feedTimes = ["7:00 am", "8:00 am", "6:00 pm"];
  final List<String> deletedFeedTimes = [];
  String selectedWaterChange = "2 weeks"; // Default value
  final _controller = Get.put(FishController());
  final fishType = TextEditingController();
  final foodType = TextEditingController();
  final fishSize = TextEditingController();
  final fishTemperature = TextEditingController();

  @override
  Widget build(BuildContext context) {
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

                fishType.text = fish['fishType'] ?? 'Default';
                foodType.text = fish['foodType'] ?? 'Default';
                fishSize.text = fish['foodType'] ?? 'Default';
                fishTemperature.text = fish['waterTemperature'] ?? 'Default';

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
                                height: 150,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    'assets/fishda.png',
                                    fit: BoxFit.cover,
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
                          if (deletedFeedTimes.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (deletedFeedTimes.isNotEmpty) {
                                    final restoredTime =
                                        deletedFeedTimes.removeLast();
                                    feedTimes.add(restoredTime);
                                  }
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
                              items: ["1 week", "2 weeks", "3 weeks", "4 weeks"]
                                  .map((duration) => DropdownMenuItem(
                                        value: duration,
                                        child: Text(duration),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedWaterChange = value!;
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
                              onTap: () {
                                // Delete functionality
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
                              onTap: () {
                                // Save functionality
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
        decoration: InputDecoration(
          hintStyle: const TextStyle(color: Colors.white54),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
