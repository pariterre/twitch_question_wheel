import 'package:flutter/material.dart';

import 'screens/wheel_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final questions = {
      'Vie professionnelle': ['Q1', 'Q2'],
      'Vie personnelle': ['Q3', 'Q4'],
      'Méthode pomodoro': ['Q5'],
      'Anecdote': ['Q6', 'Q7', 'Q8'],
      'Bonne bouffe': ['Q9'],
      'Voyage': ['Q10', 'Q11'],
    };

    return MaterialApp(
      home: WheelScreen(
        questions: questions,
      ),
    );
  }
}
