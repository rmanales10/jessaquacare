import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gwapo/add_fish/fish_add.dart';

import 'package:gwapo/home/home.dart';
import 'package:gwapo/profile/profile.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _currentIndex = 0;
  List<Widget> body = const [HomePage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body[_currentIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => FishAdd()),
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            border: Border.all(color: Colors.white, width: 1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black12,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        currentIndex: _currentIndex,
        onTap: (int newIndex) {
          setState(() {
            _currentIndex = newIndex;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 20), // Adjust spacing here
              child: Icon(Icons.home_outlined),
            ),
            label: '',
          ),
          // BottomNavigationBarItem(
          //   icon: Padding(
          //     padding: const EdgeInsets.symmetric(
          //         horizontal: 20), // Adjust spacing here
          //     child: GestureDetector(
          //       onTap: () {
          //         Navigator.pushNamed(context, '/add');
          //       },
          //       child: Container(
          //         width: 56,
          //         height: 56,
          //         decoration: BoxDecoration(
          //           color: Colors.white.withOpacity(0.2),
          //           border: Border.all(color: Colors.white, width: 1),
          //           shape: BoxShape.circle,
          //         ),
          //         child: const Icon(Icons.add, color: Colors.white),
          //       ),
          //     ),
          //   ),
          //   label: '',
          // ),
          BottomNavigationBarItem(
            icon: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 20), // Adjust spacing here
              child: Icon(Icons.person_outlined),
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}
