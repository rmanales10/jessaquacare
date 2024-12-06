import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gwapo/add_fish/fish_add_controller.dart';
import 'package:gwapo/notification/notification_service.dart';
import 'package:intl/intl.dart';

class FishAdd extends StatefulWidget {
  const FishAdd({super.key});

  @override
  State<FishAdd> createState() => _FishAddState();
}

class _FishAddState extends State<FishAdd> {
  final FishAddController controller = Get.put(FishAddController());
  final NotificationService _notificationService = NotificationService();
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
                "Add Fish Activity",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  children: [
                    buildInputField("Type of Fish",
                        controller.fishTypeController, TextInputType.text),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Size',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    _buildDropdDownSize(controller),
                    const SizedBox(height: 16),
                    buildInputField("Type of Food",
                        controller.foodTypeController, TextInputType.text),
                    const SizedBox(height: 16),
                    buildInputField(
                        "Water Temperature (°C)",
                        controller.waterTemperatureController,
                        TextInputType.number),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Feed Times",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Obx(() {
                      return Column(
                        children: controller.feedTimes.map((time) {
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
                                    child: Text(
                                      time,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                GestureDetector(
                                  onTap: () {
                                    controller.removeFeedTime(time);
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
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    }),
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

                          String formattedTime =
                              DateFormat('hh:mm a').format(scheduledTime);

                          setState(() {
                            controller.addFeedTime(
                                formattedTime); // Add the feed time to the list

                            // Schedule the notification for the added feed time
                            _notificationService.scheduleAlarm(
                              controller.feedTimes
                                  .length, // Unique ID for each notification
                              'Feed Fish', // Notification title
                              'It\'s time to feed your ${controller.fishTypeController.text} fish!', // Notification body
                              scheduledTime, // Scheduled time
                            );
                          });

                          Get.snackbar(
                            'Notification Scheduled',
                            'Alarm set for $formattedTime',
                            colorText: Colors.white,
                          );
                        }
                      },
                      child: Align(
                        alignment: Alignment.topLeft,
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
                    ),
                    const SizedBox(height: 16),
                    _buildSelectdate(context, controller.dateController),
                    const SizedBox(height: 20),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => controller.pickImageAndProcess(),
                      child: buildImageUploadBox(controller),
                    ),
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: () => controller.isSaving.value
                          ? null
                          : controller.saveActivity(),
                      child: buildSaveButton(controller),
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

  Widget buildInputField(
      String label, TextEditingController controller, TextInputType inputType) {
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
          keyboardType: inputType,
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

  Widget _buildDropdDownSize(FishAddController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white70, width: 1),
      ),
      child: DropdownButton<String>(
        value: controller.selectedSize,
        dropdownColor: const Color(0xFF1E1E1E),
        isExpanded: true,
        hint: const Text(
          'Select size',
          style: TextStyle(color: Colors.white),
        ),
        style: const TextStyle(color: Colors.white),
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
        items: ["Small: 0 - 5 cm", "Medium: 6 - 15 cm", "Large: 16 cm above"]
            .map((size) => DropdownMenuItem(
                  value: size,
                  child: Text(size),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            controller.selectedSize = value!;
          });
        },
      ),
    );
  }

  Widget buildImageUploadBox(FishAddController controller) {
    return Obx(() {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: controller.base64Image.value == null
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate,
                        color: Colors.white70, size: 32),
                    SizedBox(height: 8),
                    Text("Click To Upload Photo",
                        style: TextStyle(color: Colors.white70)),
                  ],
                ),
              )
            : Image.memory(
                base64Decode(controller.base64Image.value!),
                fit: BoxFit.cover,
              ),
      );
    });
  }

  Widget buildSaveButton(FishAddController controller) {
    return Obx(() {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          gradient: const LinearGradient(
            colors: [Color(0xFFFF0000), Color.fromARGB(255, 73, 1, 1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Text(
            controller.isSaving.value ? "Saving..." : "Save",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    });
  }
}
