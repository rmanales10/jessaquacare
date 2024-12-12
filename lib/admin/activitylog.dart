import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ActivityLogScreenState createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  String searchQuery = "";
  String filterType = "All"; // Filters: All, Online, Offline

  // Function to show logout confirmation dialog
  Future<void> _showLogoutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          elevation: 10,
          shadowColor: Colors.white,
          title: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                        _logout(); // Implement logout action here
                      },
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // Simulated logout action (add actual logout logic)
  void _logout() {
    log('Logged out');
    Get.off('/');
    Get.snackbar('Success', 'Logged out success!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        toolbarHeight: 80,
        title: const Padding(
          padding: EdgeInsets.only(top: 30),
          child: Text(
            'Activity Log',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 50, top: 30),
            child: IconButton(
              icon: const Icon(Icons.exit_to_app, color: Colors.white),
              onPressed: _showLogoutDialog,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 50),
        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Search by email...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Data Table with Firestore Integration
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No activity logs found."));
                  }

                  // Filter data based on search query and filter type
                  final filteredData = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final email = data['email']?.toString().toLowerCase() ?? '';
                    final status = data['status']?.toString() ?? '';
                    return (filterType == "All" || status == filterType) &&
                        email.contains(searchQuery.toLowerCase());
                  }).toList();

                  // Summary Data: Dynamically calculate users in different statuses
                  final totalUsers = snapshot.data!.docs.length;
                  final onlineUsers = snapshot.data!.docs
                      .where((doc) =>
                          (doc.data() as Map<String, dynamic>)['status'] ==
                          "online")
                      .length;
                  final offlineUsers = snapshot.data!.docs
                      .where((doc) =>
                          (doc.data() as Map<String, dynamic>)['status'] !=
                          "online")
                      .length;

                  return Column(
                    children: [
                      // Summary Row with dynamic updates
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSummaryCard(
                            title: "Total Users",
                            count: totalUsers,
                            color: Colors.blueGrey.withOpacity(0.3),
                            onTap: () {
                              setState(() {
                                filterType = "All";
                              });
                            },
                          ),
                          _buildSummaryCard(
                            title: "Online Users",
                            count: onlineUsers,
                            color: Colors.green.withOpacity(0.2),
                            onTap: () {
                              setState(() {
                                filterType = "online";
                              });
                            },
                          ),
                          _buildSummaryCard(
                            title: "Offline Users",
                            count: offlineUsers,
                            color: Colors.red.withOpacity(0.2),
                            onTap: () {
                              setState(() {
                                filterType = "offline";
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Data Table with Firestore Integration
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: DataTable(
                              columnSpacing: 24.0,
                              columns: const [
                                DataColumn(label: Text("ID")),
                                DataColumn(label: Text("Email")),
                                DataColumn(label: Text("IP Address")),
                                DataColumn(label: Text("Sign-Up Date")),
                                DataColumn(label: Text("Sign-Up Time")),
                                DataColumn(label: Text("Status")),
                              ],
                              rows: filteredData.map((doc) {
                                final data = doc.data() as Map<String, dynamic>;

                                // Format Timestamp fields
                                final signUpDate =
                                    data['signUpDate'] is Timestamp
                                        ? DateFormat('yyyy-MM-dd').format(
                                            (data['signUpDate'] as Timestamp)
                                                .toDate())
                                        : 'N/A';

                                final signUpTime =
                                    data['signUpTime'] is Timestamp
                                        ? DateFormat('HH:mm:ss').format(
                                            (data['signUpTime'] as Timestamp)
                                                .toDate())
                                        : 'N/A';

                                return DataRow(cells: [
                                  DataCell(Text(doc.id)),
                                  DataCell(
                                      Text(data['email']?.toString() ?? 'N/A')),
                                  DataCell(Text(
                                      data['ipAddress']?.toString() ?? 'N/A')),
                                  DataCell(Text(signUpDate)),
                                  DataCell(Text(signUpTime)),
                                  DataCell(Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 4.0),
                                    decoration: BoxDecoration(
                                      color: data['status'] == "Online"
                                          ? Colors.green.withOpacity(0.2)
                                          : Colors.red.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    child: Text(
                                      data['status']?.toString() ?? 'N/A',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  )),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required int count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "$count",
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
