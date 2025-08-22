import 'package:flutter/material.dart';
import 'package:menstrual_abnormality/main.dart';

class ThemeSwitch extends StatelessWidget {
  const ThemeSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return IconButton(
      icon: Icon(
        isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
        color: isDarkMode ? Colors.amber : Colors.indigo,
      ),
      onPressed: () {
        MyApp.of(context)?.toggleTheme();
      },
      tooltip: 'Toggle theme',
    );
  }
}