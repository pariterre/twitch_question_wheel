import 'package:flutter/material.dart';
import 'package:twitch_manager/twitch_manager.dart';

import '/screens/wheel_screen.dart';
import '/screens/twitch_authentication_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(initialRoute: TwitchAuthenticationScreen.route, routes: {
      TwitchAuthenticationScreen.route: (ctx) =>
          const TwitchAuthenticationScreen(
            nextRoute: WheelScreen.route,
            appId: 'mcysoxq3vitdjwcqn71f8opz11cyex',
            scope: [
              TwitchScope.chatRead,
              TwitchScope.chatEdit,
              TwitchScope.chatters,
              TwitchScope.readFollowers,
              TwitchScope.readSubscribers,
            ],
            moderatorName: 'BotBleuet',
            streamerName: 'pariterre',
          ),
      WheelScreen.route: (ctx) =>
          const WheelScreen(questionsPath: 'assets/questions.json'),
    });
  }
}
