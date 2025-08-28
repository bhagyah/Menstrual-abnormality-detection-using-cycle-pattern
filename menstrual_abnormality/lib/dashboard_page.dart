import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'cycle_input_page.dart'; // <-- make sure this file exists

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool showGraph = false;

  Future<Map<String, dynamic>?> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc =
    await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    return doc.exists ? doc.data() : null;
  }

  Future<void> _showProfileDialog(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final data = await _getUserData();
    if (data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No user data found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final TextEditingController dobController =
    TextEditingController(text: data['dob']);
    final TextEditingController firstNameController =
    TextEditingController(text: data['firstName']);
    final TextEditingController lastNameController =
    TextEditingController(text: data['lastName']);
    final TextEditingController heightController =
    TextEditingController(text: data['height'].toString());
    final TextEditingController weightController =
    TextEditingController(text: data['weight'].toString());

    bool isEditing = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Profile'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: firstNameController,
                    decoration: const InputDecoration(labelText: 'First Name'),
                    readOnly: !isEditing,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: lastNameController,
                    decoration: const InputDecoration(labelText: 'Last Name'),
                    readOnly: !isEditing,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: dobController,
                    decoration:
                    const InputDecoration(labelText: 'Date of Birth'),
                    readOnly: true,
                    onTap: isEditing
                        ? () async {
                      final now = DateTime.now();
                      final firstDate = DateTime(now.year - 60, 1, 1);
                      final lastDate = DateTime(now.year - 8, 12, 31);
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: firstDate,
                        lastDate: lastDate,
                        initialDate: DateTime.tryParse(
                            data['dob'].split('/').reversed.join('-')) ??
                            DateTime(now.year - 20),
                      );
                      if (picked != null) {
                        dobController.text =
                        "${picked.day}/${picked.month}/${picked.year}";
                      }
                    }
                        : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: heightController,
                    decoration: const InputDecoration(labelText: 'Height (cm)'),
                    keyboardType: TextInputType.number,
                    readOnly: !isEditing,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: weightController,
                    decoration: const InputDecoration(labelText: 'Weight (kg)'),
                    keyboardType: TextInputType.number,
                    readOnly: !isEditing,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              if (!isEditing)
                TextButton(
                  onPressed: () => setState(() => isEditing = true),
                  child: const Text('Edit'),
                ),
              if (isEditing)
                TextButton(
                  onPressed: () async {
                    try {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .set({
                        'firstName': firstNameController.text.trim(),
                        'lastName': lastNameController.text.trim(),
                        'dob': dobController.text.trim(),
                        'height':
                        int.tryParse(heightController.text.trim()) ?? 0,
                        'weight':
                        int.tryParse(weightController.text.trim()) ?? 0,
                      }, SetOptions(merge: true));

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile updated successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error updating profile: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Save'),
                ),
            ],
          );
        });
      },
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _getPredictions() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cycle_predictions')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Dashboard"),
        centerTitle: true,
        backgroundColor: Colors.pink,
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.person),
            itemBuilder: (context) => [
              const PopupMenuItem<int>(value: 0, child: Text('Profile')),
              const PopupMenuItem<int>(value: 1, child: Text('Logout')),
            ],
            onSelected: (item) {
              switch (item) {
                case 0:
                  _showProfileDialog(context);
                  break;
                case 1:
                  FirebaseAuth.instance.signOut().then((_) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  });
                  break;
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "My Tracking",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
            const Divider(),

            // Predictions area
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _getPredictions(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No tracking data available"));
                  }

                  final docs = snapshot.data!.docs;

                  if (!showGraph) {
                    // Card view
                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data();
                        final ts = data['timestamp'];
                        DateTime? date;
                        if (ts is Timestamp) {
                          date = ts.toDate();
                        }
                        final message =
                            data['prediction']?['message'] ?? 'No message';

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 3,
                          child: ListTile(
                            leading: const Icon(Icons.event_note, color: Colors.pink),
                            title: Text(
                              "Message: ${data['prediction']?['message'] ?? 'No message'}",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Date: ${date != null ? "${date.day}/${date.month}/${date.year}" : "-"}"),
                                Text("Actual cycle length: ${data['prediction']?['actual_cycle_length'] ?? '-'}"),
                                Text("Predicted cycle length: ${data['prediction']?['residual'] ?? '-'}"),
                                Text("Deviation: ${data['prediction']?['predicted_cycle_length'] ?? '-'}"),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    // Graph view
                    final List<FlSpot> actualSpots = [];
                    final List<FlSpot> predictedSpots = [];

                    for (int i = 0; i < docs.length; i++) {
                      final data = docs[i].data();
                      final ts = data['timestamp'];
                      if (ts is Timestamp) {
                        final actual = (data['prediction']?['actual_cycle_length'] ?? 0).toDouble();
                        final predicted = (data['prediction']?['predicted_cycle_length'] ?? 0).toDouble();

                        actualSpots.add(FlSpot(i.toDouble(), actual));
                        predictedSpots.add(FlSpot(i.toDouble(), predicted));
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: LineChart(
                        LineChartData(
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true),
                            ),
                          ),
                          gridData: FlGridData(show: true),
                          borderData: FlBorderData(show: true),
                          lineBarsData: [
                            LineChartBarData(
                              spots: actualSpots,
                              isCurved: true,
                              color: Colors.pink,
                              barWidth: 3,
                              dotData: FlDotData(show: true),
                            ),
                            LineChartBarData(
                              spots: predictedSpots,
                              isCurved: true,
                              color: Colors.blue,
                              barWidth: 3,
                              dotData: FlDotData(show: true),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),

            // Switch between Card & Graph
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Card View"),
                  Switch(
                    value: showGraph,
                    activeColor: Colors.pink,
                    onChanged: (val) {
                      setState(() => showGraph = val);
                    },
                  ),
                  const Text("Graph View"),
                ],
              ),
            ),

            // Analyze Button
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CycleInputPage()),
                  );
                },
                child: const Text(
                  "Analyze",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
