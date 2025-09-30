import 'package:flutter/material.dart';
import 'package:twitch_question_wheel/providers/app_preferences.dart';
import 'package:twitch_question_wheel/screens/wheel_screen.dart';
import 'package:provider/provider.dart';
import 'package:logging/logging.dart';

final _logger = Logger('WheelScreen');
void main() async {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print(
        '${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
  });

  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await AppPreferences.factory();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => preferences),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  final useTwitchMock =
      const bool.fromEnvironment('USE_TWITCH_MOCK', defaultValue: false);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: WheelScreen(useMock: useTwitchMock));
  }
}
