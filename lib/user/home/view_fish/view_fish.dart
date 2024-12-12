import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gwapo/user/home/navigation.dart';
import 'package:gwapo/user/notification/notification_service.dart';
import 'package:intl/intl.dart';
import 'fish_controller.dart';

class ScheduledActivitiesPage extends StatefulWidget {
  final String fishId;

  const ScheduledActivitiesPage({super.key, required this.fishId});

  @override
  State<ScheduledActivitiesPage> createState() =>
      _ScheduledActivitiesPageState();
}

class _ScheduledActivitiesPageState extends State<ScheduledActivitiesPage> {
  final _controller = Get.put(FishController());
  final fishType = TextEditingController();
  final foodType = TextEditingController();
  final fishSize = ''.obs;
  final fishTemperature = TextEditingController();
  final dateController = TextEditingController();
  final NotificationService _notificationService = NotificationService();
  final isEdit = false.obs;

  @override
  void initState() {
    super.initState();
    initFishData();
  }

  @override
  Widget build(BuildContext context) {
    _controller.getSpecificFishData(widget.fishId);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Obx(() {
            final fish = _controller.specificFishData;
            final List<String> feedTimes = List<String>.from(
                fish['feedTimes'] ??
                    []); // Ensure feedTimes is a list of strings
            final List<String> deletedFeedTimes = [];
            String selectedWaterChange = fish['changeWater'] ?? 'Default';

            Uint8List decodedImageBytes;
            if (fish['imageUrl'] != null) {
              decodedImageBytes = base64Decode(fish['imageUrl']);
            } else {
              decodedImageBytes = Uint8List.fromList([]);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
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

                // Fish Image and Details
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 34, 33, 33),
                            Colors.black87,
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
                          child: decodedImageBytes.isEmpty
                              ? const Center(child: CircularProgressIndicator())
                              : ClipRRect(
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
                    Expanded(
                      child: Obx(() {
                        _controller.getSpecificFishData(widget.fishId);
                        return Column(
                          children: [
                            buildInputField(
                                fishType, 'Fish Type', isEdit.value),
                            const SizedBox(height: 16),
                            _buildDropdDownSize('Fish Size'),
                            const SizedBox(height: 16),
                            buildInputField(
                                foodType, 'Food Type', isEdit.value),
                            const SizedBox(height: 16),
                            buildInputField(
                                fishTemperature, 'Temperature', isEdit.value),
                          ],
                        );
                      }),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Feed Time",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Obx(() => TextButton(
                        onPressed: () => isEdit.value = !isEdit.value,
                        child: Text(
                          isEdit.value ? 'Done' : 'Edit',
                          style: const TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                        )))
                  ],
                ),
                const SizedBox(height: 10),

                // Feed Times List
                Column(
                  children: feedTimes.map((time) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E1E),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white70,
                                  width: 1,
                                ),
                              ),
                              child: Text(time,
                                  style: TextStyle(
                                      color: isEdit.value
                                          ? Colors.white
                                          : Colors.grey)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          isEdit.value
                              ? GestureDetector(
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
                                      border: Border.all(color: Colors.white),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.delete,
                                      color: Color.fromARGB(255, 219, 21, 7),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink()
                        ],
                      ),
                    );
                  }).toList(),
                ),

                // Add Feed Time Button
                if (feedTimes.length < 3 && isEdit.value)
                  GestureDetector(
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );

                      if (pickedTime != null) {
                        DateTime now = DateTime.now();
                        DateTime scheduledTime = DateTime(
                          now.year,
                          now.month,
                          now.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );

                        if (scheduledTime.isBefore(now)) {
                          scheduledTime =
                              scheduledTime.add(const Duration(days: 1));
                        }

                        setState(() {
                          final formattedTime =
                              DateFormat('hh:mm a').format(scheduledTime);
                          feedTimes.add(formattedTime);

                          _controller.deletedFeedTimes(
                              widget.fishId, feedTimes);

                          _notificationService.scheduleAlarm(
                            feedTimes.length,
                            'Feed Fish',
                            'It\'s time to feed your ${fishType.text} fish!',
                            scheduledTime,
                          );

                          Get.snackbar(
                            'Notification Scheduled',
                            'Alarm set for $formattedTime',
                            colorText: Colors.white,
                          );
                        });
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),

                const SizedBox(height: 20),
                _buildSelectdate(context, dateController),
                const SizedBox(height: 20),
                // Test Notification Button

                // Save and Delete Buttons
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          await _controller.deleteActivities(widget.fishId);
                          Get.off(() => const Navigation());
                          Get.snackbar(
                              'Success', 'Scheduled deleted successfully!',
                              colorText: Colors.white);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 131, 128, 128),
                                Color(0xFF141414),
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
                              fishSize.value,
                              foodType.text,
                              fishTemperature.text,
                              dateController.text);
                          Get.back(closeOverlays: true);
                          Get.snackbar('Success',
                              'Scheduled activities saved successfully!',
                              colorText: Colors.white);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFF0000),
                                Color.fromARGB(255, 73, 1, 1),
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
                const SizedBox(height: 20),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget buildInputField(
      TextEditingController controller, String label, bool isEdit) {
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
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white70, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextFormField(
            enabled: isEdit,
            controller: controller,
            cursorColor: const Color.fromARGB(255, 219, 21, 7),
            style: TextStyle(color: isEdit ? Colors.white : Colors.grey),
            decoration: const InputDecoration(
              hintStyle: TextStyle(color: Colors.white54),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectdate(
      BuildContext context, TextEditingController dateController) {
    return Column(
      children: [
        const Align(
          alignment: Alignment.topLeft,
          child: Text(
            'Change Water',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: dateController,
          style: const TextStyle(color: Colors.white),
          readOnly: true,
          decoration: InputDecoration(
            hintText: 'Select dates',
            hintStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            filled: true,
            fillColor: const Color(0xFF1E1E1E),
            suffixIcon: const Icon(
              Icons.calendar_today,
              color: Colors.white,
            ),
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
          onTap: () async {
            // When tapped, open the date picker
            await _selectDate(context, dateController);
          },
        ),
      ],
    );
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController dateController) async {
    DateTime today = DateTime.now();
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      setState(() {
        dateController.text = "${selectedDate.toLocal()}".split(' ')[0];

        // Schedule a notification for the selected water change date
        DateTime scheduledTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          9, // You can set a specific time, e.g., 9:00 AM
        );

        if (scheduledTime.isBefore(DateTime.now())) {
          scheduledTime = scheduledTime.add(const Duration(days: 1));
        }

        _notificationService.scheduleAlarm(
          999, // Unique ID for water change notification
          'Change Water Reminder',
          'It\'s time to change the water for your fish tank!',
          scheduledTime,
        );

        Get.snackbar(
          'Notification Scheduled',
          'Water change reminder set for ${DateFormat('yyyy-MM-dd').format(scheduledTime)} at 9:00 AM',
          colorText: Colors.white,
        );
      });
    }
  }

  Future<void> initFishData() async {
    await _controller.getSpecificFishData(widget.fishId);
    final fish = _controller.specificFishData;
    setState(() {
      fishSize.value = fish['size'] ?? 'Loading...';
      fishTemperature.text = fish['waterTemperature'] ?? 'Loading...';
      foodType.text = fish['foodType'] ?? 'Loading...';
      fishType.text = fish['fishType'] ?? 'Loading...';
      dateController.text = fish['changeWater'] ?? 'Loading...';
    });
  }

  Widget _buildDropdDownSize(String label) {
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
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white70, width: 1),
          ),
          child: DropdownButton<String>(
            value: fishSize.value.isEmpty
                ? null
                : fishSize.value, // Set to null if empty
            dropdownColor: const Color(0xFF1E1E1E),
            isExpanded: true,
            hint: const Text(
              'Select size',
              style: TextStyle(color: Colors.white),
            ),
            style: TextStyle(
              color: isEdit.value ? Colors.white : Colors.grey,
            ),
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            items:
                ["Small: 0 - 5 cm", "Medium: 6 - 15 cm", "Large: 16 cm above"]
                    .map((size) => DropdownMenuItem<String>(
                          value: size,
                          child: Text(size),
                        ))
                    .toList(),
            onChanged: isEdit.value
                ? (value) {
                    fishSize.value =
                        value!; // Update fishSize value when changed
                  }
                : (value) {}, // Disabled if not in edit mode
          ),
        ),
      ],
    );
  }
}
