import 'package:flutter/material.dart';

import '/models/twitch_connector.dart';
import '/screens/wheel_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final connector =
      await TwitchConnector.fromJsonConfig('assets/credentials.json');
  runApp(MyApp(connector: connector));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.connector});

  final TwitchConnector connector;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WheelScreen(
        questionsPath: 'assets/questions.json',
        connector: connector,
      ),
    );
  }
}
