import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/wheel_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final data = jsonDecode(await rootBundle.loadString("assets/questions.json"));
  final questions = data.map<String, List<String>>((String key, value) {
    return MapEntry(key, (value as List).map<String>((e) => e).toList());
  });

  runApp(MyApp(questions: questions));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.questions});

  final Map<String, List<String>> questions;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WheelScreen(
        questions: questions,
      ),
    );
  }
}
