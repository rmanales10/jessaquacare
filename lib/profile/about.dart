import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80),
            // Back Button
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            const SizedBox(height: 50),
            // Centered Fishes Image
            Center(
              child: Image.asset(
                'assets/fishes.png', // Replace with your asset path
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 50),
            // About Title
            const Text(
              "About",
              style: TextStyle(
                color: Color(0xFFFF0000),
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 16),
            // About Description
            const Text(
              "AquaCare is designed for dedicated fish caretakers. We provide tools to help you monitor, feed, and nurture the fish under your care.\n\nWith AquaCare, giving the best care to your aquatic companions is simple and efficient. Together, let's ensure every fish thrives!",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
