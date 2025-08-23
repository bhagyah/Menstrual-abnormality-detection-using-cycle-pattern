import 'package:flutter/material.dart';

class CycleInputPage extends StatefulWidget {
  const CycleInputPage({super.key});

  @override
  State<CycleInputPage> createState() => _CycleInputPageState();
}

class _CycleInputPageState extends State<CycleInputPage> {
  DateTime? cycleStartDate;
  final cycleLengthController = TextEditingController();
  final periodLengthController = TextEditingController();
  double painScore = 0;
  String flowIntensity = 'Light';
  String mood = 'Happy';
  bool irregularCycle = false;
  bool pcosRisk = false;
  bool thyroidRisk = false;

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
          children: [
            // Cycle Start Date
            ListTile(
              title: const Text('Cycle Start Date'),
              subtitle: Text(
                cycleStartDate == null
                  ? 'Select the first day of your last period'
                  : cycleStartDate!.toLocal().toString().split(' ')[0],
              ),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => cycleStartDate = picked);
              },
            ),
            const SizedBox(height: 16),
            // Cycle Length
            TextFormField(
              controller: cycleLengthController,
              decoration: const InputDecoration(
                labelText: 'Cycle Length (days)',
                hintText: 'e.g., 28',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            // Period Length
            TextFormField(
              controller: periodLengthController,
              decoration: const InputDecoration(
                labelText: 'Period Length (days)',
                hintText: 'e.g., 5',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            // Pain Score
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pain Score (0 = no pain, 10 = severe pain)'),
                Slider(
                  value: painScore,
                  min: 0,
                  max: 10,
                  divisions: 10,
                  label: painScore.round().toString(),
                  onChanged: (v) => setState(() => painScore = v),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Flow Intensity
            DropdownButtonFormField<String>(
              value: flowIntensity,
              items: ['Light', 'Medium', 'Heavy']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => flowIntensity = v!),
              decoration: const InputDecoration(labelText: 'Flow Intensity'),
            ),
            const SizedBox(height: 16),
            // Mood
            DropdownButtonFormField<String>(
              value: mood,
              items: ['Happy', 'Neutral', 'Sad', 'Irritable', 'Anxious']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => mood = v!),
              decoration: const InputDecoration(labelText: 'Mood'),
            ),
            const SizedBox(height: 16),
            // Irregular Cycle
            CheckboxListTile(
              value: irregularCycle,
              onChanged: (v) => setState(() => irregularCycle = v!),
              title: const Text('Irregular Cycle'),
              subtitle: const Text('Mark if your cycle is irregular'),
            ),
            // PCOS Risk
            CheckboxListTile(
              value: pcosRisk,
              onChanged: (v) => setState(() => pcosRisk = v!),
              title: const Text('PCOS Risk'),
              subtitle: const Text('Indicate if you have PCOS diagnosis or symptoms'),
            ),
            // Thyroid Risk
            CheckboxListTile(
              value: thyroidRisk,
              onChanged: (v) => setState(() => thyroidRisk = v!),
              title: const Text('Thyroid Risk'),
              subtitle: const Text('Indicate if you have thyroid disorder diagnosis or symptoms'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _saveCycleData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cycle data saved!')),
                );
                // Optionally navigate or reset form
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveCycleData() {
    print('Cycle Start Date: $cycleStartDate');
    print('Cycle Length: ${cycleLengthController.text}');
    print('Period Length: ${periodLengthController.text}');
    print('Pain Score: $painScore');
    print('Flow Intensity: $flowIntensity');
    print('Mood: $mood');
    print('Irregular Cycle: $irregularCycle');
    print('PCOS Risk: $pcosRisk');
    print('Thyroid Risk: $thyroidRisk');
    // TODO: Replace with actual save logic (e.g., database, API)
  }
}