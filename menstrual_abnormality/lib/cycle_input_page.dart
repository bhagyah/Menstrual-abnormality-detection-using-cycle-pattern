import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:http/http.dart' as http; // For standard deviation calculation

class CycleInputPage extends StatefulWidget {
  const CycleInputPage({super.key});

  @override
  State<CycleInputPage> createState() => _CycleInputPageState();
}

class _CycleInputPageState extends State<CycleInputPage> {
  // Controllers for text inputs
  final ageController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();
  final trackingDurationController = TextEditingController();
  final cycleLengthController = TextEditingController();
  final periodLengthController = TextEditingController();
  final intermenstrualEpisodesController = TextEditingController();
  final patternDisruptionController = TextEditingController();

  // Variables for form fields
  List<DateTime> cycleStartDates = []; // Store multiple cycle start dates
  double painScore = 0;
  String flowIntensity = 'Light';
  String lifeStage = 'Reproductive';
  bool irregularCycle = false;

  // Validation flags
  String? ageError, bmiError, trackingDurationError, cycleLengthError, periodLengthError, intermenstrualError;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      final dobString = data['dob'] as String?;
      int? age;

      if (dobString != null && dobString.isNotEmpty) {
        try {
          final parts = dobString.split('/'); // ["27", "8", "2000"]
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);

          final dob = DateTime(year, month, day);
          final today = DateTime.now();

          age = today.year - dob.year;
          // Adjust if birthday hasn't occurred yet this year
          if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
            age--;
          }

        } catch (e) {
          age = null;
        }
      }

      setState(() {
        ageController.text = age?.toString() ?? '';
        weightController.text = data['weight']?.toString() ?? '';
        heightController.text = data['height']?.toString() ?? '';
      });
    }
  }

  @override
  void dispose() {
    ageController.dispose();
    weightController.dispose();
    heightController.dispose();
    trackingDurationController.dispose();
    cycleLengthController.dispose();
    periodLengthController.dispose();
    intermenstrualEpisodesController.dispose();
    patternDisruptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Cycle Data'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Age
            TextFormField(
              controller: ageController,
              decoration: InputDecoration(
                labelText: 'Age (years)',
                hintText: 'e.g., 30',
                errorText: ageError,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            // Weight
            TextFormField(
              controller: weightController,
              decoration: InputDecoration(
                labelText: 'Weight (kg)',
                hintText: 'e.g., 60',
                errorText: bmiError,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            // Height
            TextFormField(
              controller: heightController,
              decoration: InputDecoration(
                labelText: 'Height (cm)',
                hintText: 'e.g., 165',
                errorText: bmiError,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            // Life Stage
            DropdownButtonFormField<String>(
              value: lifeStage,
              items: ['Puberty', 'Reproductive', 'Perimenopausal']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => lifeStage = v!),
              decoration: const InputDecoration(labelText: 'Life Stage'),
            ),
            const SizedBox(height: 16),
            // Tracking Duration
            TextFormField(
              controller: trackingDurationController,
              decoration: InputDecoration(
                labelText: 'Tracking Duration (months)',
                hintText: 'e.g., 12',
                errorText: trackingDurationError,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            // Cycle Start Dates
            ListTile(
              title: const Text('Cycle Start Dates'),
              subtitle: Text(
                cycleStartDates.isEmpty
                    ? 'Select the first days of your last few periods'
                    : cycleStartDates.map((d) => d.toLocal().toString().split(' ')[0]).join(', '),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => cycleStartDates.add(picked));
                }
              },
            ),
            const SizedBox(height: 16),
            // Cycle Length (optional, computed from dates)
            TextFormField(
              controller: cycleLengthController,
              decoration: InputDecoration(
                labelText: 'Average Cycle Length (days)',
                hintText: 'e.g., 28 (or computed from dates)',
                errorText: cycleLengthError,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            // Period Length
            TextFormField(
              controller: periodLengthController,
              decoration: InputDecoration(
                labelText: 'Average Bleeding Days',
                hintText: 'e.g., 5',
                errorText: periodLengthError,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            // Pain Score (adjusted to 0–3 scale)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pain Score (0 = no pain, 3 = severe pain)'),
                Slider(
                  value: painScore,
                  min: 0,
                  max: 3,
                  divisions: 3,
                  label: painScore.round().toString(),
                  onChanged: (v) => setState(() => painScore = v),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Flow Intensity (mapped to Bleeding Volume Score)
            DropdownButtonFormField<String>(
              value: flowIntensity,
              items: ['Light', 'Moderate', 'Heavy', 'Very Heavy']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => flowIntensity = v!),
              decoration: const InputDecoration(labelText: 'Bleeding Volume'),
            ),
            const SizedBox(height: 16),
            // Intermenstrual Episodes
            TextFormField(
              controller: intermenstrualEpisodesController,
              decoration: InputDecoration(
                labelText: 'Intermenstrual Bleeding Episodes',
                hintText: 'e.g., 0 (bleeding between periods)',
                errorText: intermenstrualError,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            // Pattern Disruption Score
            TextFormField(
              controller: patternDisruptionController,
              decoration: const InputDecoration(
                labelText: 'Pattern Disruption Score (5–100)',
                hintText: 'e.g., 20 (higher = more irregular)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            // Irregular Cycle (used to infer Duration Abnormality Flag)
            CheckboxListTile(
              value: irregularCycle,
              onChanged: (v) => setState(() => irregularCycle = v!),
              title: const Text('Irregular Cycle'),
              subtitle: const Text('Mark if your cycle is irregular'),
            ),
            const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () async {
            if (_validateInputs()) {
              final cycleData = _saveCycleData();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sending cycle data to server...')),
              );

              try {
                // Replace with your Flask server URL
                final url = Uri.parse('http://127.0.0.1:5000/predict');

                final response = await http.post(
                  url,
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode(cycleData),
                );

                if (response.statusCode == 200) {
                  final result = jsonDecode(response.body);

                  // 🔹 Save to Firestore
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await FirebaseFirestore.instance
                        .collection("users")
                        .doc(user.uid)
                        .collection("cycle_predictions")
                        .add({
                      "input": cycleData,
                      "prediction": result,
                      "timestamp": FieldValue.serverTimestamp(),
                    });
                  }

                  // Show result in an AlertDialog
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Prediction Result'),
                      content: Text(
                          'Predicted Cycle Length: ${result['residual']}\n' 'Actual Cycle Length: ${result['actual_cycle_length']}\n' 'Residual: ${result['predicted_cycle_length']}\n' 'Anomaly: ${result['is_anomaly']}\n' 'Irregularities: ${result['message']}'
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Error response from server
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Server error: ${response.statusCode}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error sending data: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please correct input errors')),
              );
            }
          },
          child: const Text('Submit'),
        ),
          ],
        ),
      ),
    );
  }

  bool _validateInputs() {
    setState(() {
      ageError = null;
      bmiError = null;
      trackingDurationError = null;
      cycleLengthError = null;
      periodLengthError = null;
      intermenstrualError = null;

      // Age validation
      final age = double.tryParse(ageController.text);
      if (age == null || age < 13 || age > 54) {
        ageError = 'Age must be between 13 and 54';
      }

      // BMI validation
      final weight = double.tryParse(weightController.text);
      final height = double.tryParse(heightController.text);
      if (weight == null || height == null || weight < 30 || weight > 150 || height < 100 || height > 250) {
        bmiError = 'Enter valid weight (30–150 kg) and height (100–250 cm)';
      } else {
        final bmi = weight / pow(height / 100, 2);
        if (bmi < 15 || bmi > 40) {
          bmiError = 'BMI must be between 15 and 40';
        }
      }

      // Tracking Duration validation
      final trackingDuration = double.tryParse(trackingDurationController.text);
      if (trackingDuration == null || trackingDuration < 1 || trackingDuration > 24) {
        trackingDurationError = 'Tracking duration must be 1–24 months';
      }

      // Cycle Length validation
      final cycleLength = double.tryParse(cycleLengthController.text);
      if (cycleLength != null && (cycleLength < 10 || cycleLength > 70)) {
        cycleLengthError = 'Cycle length must be 10–70 days';
      }

      // Period Length validation
      final periodLength = double.tryParse(periodLengthController.text);
      if (periodLength == null || periodLength < 0 || periodLength > 10) {
        periodLengthError = 'Bleeding days must be 0–10';
      }

      // Intermenstrual Episodes validation
      final intermenstrualEpisodes = int.tryParse(intermenstrualEpisodesController.text);
      if (intermenstrualEpisodes == null || intermenstrualEpisodes < 0 || intermenstrualEpisodes > 5) {
        intermenstrualError = 'Episodes must be 0–5';
      }
    });

    return ageError == null &&
        bmiError == null &&
        trackingDurationError == null &&
        cycleLengthError == null &&
        periodLengthError == null &&
        intermenstrualError == null;
  }

  Map<String, dynamic> _saveCycleData() {
    // Calculate BMI
    final weight = double.parse(weightController.text);
    final height = double.parse(heightController.text);
    final bmi = weight / pow(height / 100, 2);

    // Calculate cycle length and variation from dates
    double avgCycleLength = 0;
    double cycleVariation = 0;
    double cycleVariationCoefficient = 0;
    if (cycleStartDates.length >= 2) {
      cycleStartDates.sort(); // Ensure dates are in order
      List<double> cycleLengths = [];
      for (int i = 1; i < cycleStartDates.length; i++) {
        cycleLengths.add(cycleStartDates[i].difference(cycleStartDates[i - 1]).inDays.toDouble());
      }
      avgCycleLength = cycleLengths.reduce((a, b) => a + b) / cycleLengths.length;
      if (cycleLengths.length > 1) {
        final mean = avgCycleLength;
        final variance = cycleLengths.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) / (cycleLengths.length - 1);
        cycleVariation = sqrt(variance);
        cycleVariationCoefficient = (cycleVariation / mean) * 100;
      }
    } else if (cycleLengthController.text.isNotEmpty) {
      avgCycleLength = double.parse(cycleLengthController.text);
    }

    // Map Flow Intensity to Bleeding Volume Score
    final flowMap = {'Light': 1, 'Moderate': 2, 'Heavy': 3, 'Very Heavy': 4};
    final bleedingVolumeScore = flowMap[flowIntensity]!;

    // Duration Abnormality Flag
    final durationAbnormalityFlag = avgCycleLength != 0 && (avgCycleLength < 21 || avgCycleLength > 35) ? 1 : 0;

    // Pattern Disruption Score (use input or estimate)
    final patternDisruptionScore = patternDisruptionController.text.isNotEmpty
        ? double.parse(patternDisruptionController.text)
        : (cycleVariationCoefficient > 50 || irregularCycle ? 50 : 20); // Heuristic

    return {
      'age': double.parse(ageController.text),
      'bmi': bmi,
      'life_stage': lifeStage,
      'tracking_duration_months': double.parse(trackingDurationController.text),
      'pain_score': (painScore * 3).round(),
      'avg_cycle_length': avgCycleLength,
      'cycle_length_variation': cycleVariation,
      'avg_bleeding_days': double.parse(periodLengthController.text),
      'bleeding_volume_score': bleedingVolumeScore,
      'intermenstrual_episodes': int.parse(intermenstrualEpisodesController.text),
      'cycle_variation_coeff': cycleVariationCoefficient,
      'pattern_disruption_score': patternDisruptionScore,
      'duration_abnormality_flag': durationAbnormalityFlag,
    };

  }
}