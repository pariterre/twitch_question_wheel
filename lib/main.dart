import 'package:flutter/material.dart';
import 'package:pomodoro_wheel/screens/wheel_screen.dart';
import 'package:twitch_manager/twitch_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: TwitchAuthenticationScreen.route,
      routes: {
        TwitchAuthenticationScreen.route: (ctx) => TwitchAuthenticationScreen(
              onFinishedConnexion: (twitchManager) {
                Navigator.of(ctx).pushReplacementNamed(WheelScreen.route,
                    arguments: twitchManager);
              },
              mockOptions: const TwitchMockOptions(
                  isActive: false,
                  messagesFollowers: ['!spin'],
                  messagesModerators: ['!spin']),
              appInfo: TwitchAppInfo(
                appName: 'QuestionWheel',
                twitchAppId: 'bobffcezcrakzkqv62h78i04vxkx72',
                redirectAddress:
                    'https://twitchauthentication.pariterre.net:3000',
                authenticationServiceAddress:
                    'wss://twitchauthentication.pariterre.net:3002',
                scope: [
                  TwitchScope.chatRead,
                  TwitchScope.chatEdit,
                  TwitchScope.chatters,
                  TwitchScope.readFollowers,
                  TwitchScope.readSubscribers,
                ],
                useAuthenticationService: true,
              ),
            ),
        WheelScreen.route: (ctx) =>
            const WheelScreen(questionsPath: 'assets/questions.json'),
      },
    );
  }
}
