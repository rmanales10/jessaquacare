import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Example notifications
    final List<String> notifications = [
      "Time to Feed! - Gold Fish",
      "Change Your Water Now! - Gold Fish",
      "Time to Feed! - Gold Fish",
      "Time to Feed! - Gold Fish",
      "Time to Feed! - Gold Fish",
      "Time to Feed! - Gold Fish",
      "Time to Feed! - Gold Fish",
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Notification",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            return Row(
              children: [
                // Image of the fish
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    width: 50,
                    height: 50,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.red, width: 1),
                      image: const DecorationImage(
                        image: AssetImage(
                            "assets/fishes.png"), // Update path if necessary
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Notification text
                Expanded(
                  child: Text(
                    notifications[index],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
