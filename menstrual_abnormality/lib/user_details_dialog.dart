import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:menstrual_abnormality/dashboard_page.dart'; // your dashboard page

// Dialog Widget
class UserDetailsDialog extends StatefulWidget {
  final String userId;
  const UserDetailsDialog({super.key, required this.userId});

  @override
  State<UserDetailsDialog> createState() => _UserDetailsDialogState();
}

class _UserDetailsDialogState extends State<UserDetailsDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  Future<void> _pickDate() async {
    final now = DateTime.now();

    // 60 years ago, starting January
    final firstDate = DateTime(now.year - 60, 1, 1);

    // 8 years ago, ending December
    final lastDate = DateTime(now.year - 8, 12, 31);

    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDate: DateTime(now.year - 20, now.month, now.day), // default initial date
    );

    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }


  Future<void> _saveToFirestore() async {
    final userRef =
    FirebaseFirestore.instance.collection('users').doc(widget.userId);

    await userRef.set({
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'dob': _dobController.text.trim(),
      'height': int.tryParse(_heightController.text.trim()) ?? 0,
      'weight': int.tryParse(_weightController.text.trim()) ?? 0,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        "Enter Your Details",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                // Logo at the top
                Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Image.asset(
                  'assets/images/logo.png', // your logo path
                  height: 80,                // adjust height
                  fit: BoxFit.contain,
                ),
              ),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: "First Name",
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                val == null || val.isEmpty ? "Enter first name" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: "Last Name",
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                val == null || val.isEmpty ? "Enter last name" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dobController,
                readOnly: true,
                onTap: _pickDate,
                decoration: const InputDecoration(
                  labelText: "Date of Birth",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                validator: (val) =>
                val == null || val.isEmpty ? "Pick your DOB" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Height (cm)",
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return "Enter height";
                  final height = int.tryParse(val);
                  if (height == null) return "Enter a valid number";
                  if (height < 100 || height > 250) return "Height must be between 100 and 250 cm";
                  return null;
                },
              ),

              const SizedBox(height: 12),
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Weight (kg)",
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                val == null || val.isEmpty ? "Enter weight" : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: Colors.pink,
          ),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              try {
                await _saveToFirestore();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Details saved successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );

                Navigator.pop(context); // Close the dialog first

                // Navigate to dashboard after closing dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardPage()),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error saving details: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}

// Function to show the dialog anywhere
Future<void> showUserDetailsDialog(BuildContext context, String userId) {
  return showDialog(
    context: context,
    builder: (_) => UserDetailsDialog(userId: userId),
  );
}

// Optional page to automatically open dialog
class UserDetailsPage extends StatelessWidget {
  final String userId;
  const UserDetailsPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showUserDetailsDialog(context, userId);
    });

    return Scaffold(
      body: Center(child: Text('Enter your details')), // optional
    );
  }
}
