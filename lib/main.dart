import 'package:flutter/material.dart';

import '/screens/connect_screen.dart';
import '/screens/wheel_screen.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: ConnectScreen.route,
      routes: {
        ConnectScreen.route: (ctx) => const ConnectScreen(
            credentialsPath: 'assets/credentials.json',
            nextRoute: WheelScreen.route),
        WheelScreen.route: (ctx) =>
            const WheelScreen(questionsPath: 'assets/questions.json'),
      },
    );
  }
}
