import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gwapo/profile/profile_settings.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 100),
            const Text(
              "Profile",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Personal",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 30),
            ListTile(
              title: const Text(
                "Profile",
                style: TextStyle(color: Colors.white),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_outlined,
                  color: Colors.white),
              onTap: () => Get.to(() => ProfileSettingsPage()),
            ),
            const Divider(color: Colors.white54),
            ListTile(
              title: const Text(
                "About",
                style: TextStyle(color: Colors.white),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_outlined,
                  color: Colors.white),
              onTap: () {
                Navigator.pushNamed(context, '/about');
              },
            ),
            const Divider(color: Colors.white54),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                _showLogoutConfirmationDialog(context);
              },
              child: const Text(
                "Logout",
                style: TextStyle(
                    color: Color(0xFFFF0000),
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showLogoutConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss the dialog
            },
            child: const Text("Cancel", style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () async {
              // Perform logout operation
              try {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pop(); // Dismiss the dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("You have logged out successfully!")),
                );
                // Navigate to SignIn screen or any other screen
                Navigator.pushReplacementNamed(context, '/signin');
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: ${e.toString()}")),
                );
              }
            },
            child: const Text("Logout",
                style: TextStyle(color: Color(0xFFFF0000))),
          ),
        ],
      );
    },
  );
}
