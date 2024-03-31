import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:pomodoro_wheel/models/questions.dart';
import 'package:pomodoro_wheel/providers/app_preferences.dart';
import 'package:pomodoro_wheel/widgets/my_drawer.dart';
import 'package:twitch_manager/twitch_manager.dart';

class WheelScreen extends StatefulWidget {
  const WheelScreen({super.key, required this.useMock});

  final bool useMock;
  static const route = "/wheel-screen";

  @override
  State<WheelScreen> createState() => _WheelScreenState();
}

class _WheelScreenState extends State<WheelScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TwitchManager? _twitchManager;

  @override
  void initState() {
    super.initState();

    if (_twitchManager == null || !_twitchManager!.isConnected) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _getTwitchManagerDialog());
    }
  }

  Future<void> _getTwitchManagerDialog() async {
    _twitchManager = await showDialog<TwitchManager?>(
        barrierDismissible: false,
        context: context,
        builder: (context) => TwitchAuthenticationDialog(
              isMockActive: widget.useMock,
              onConnexionEstablished: (twitchManager) =>
                  Navigator.of(context).pop(twitchManager),
              appInfo: TwitchAppInfo(
                appName: 'QuestionWheel',
                twitchAppId: 'bobffcezcrakzkqv62h78i04vxkx72',
                redirectUri: 'twitchauthentication.pariterre.net',
                scope: [
                  TwitchScope.chatRead,
                  TwitchScope.chatEdit,
                  TwitchScope.chatters,
                  TwitchScope.readFollowers,
                  TwitchScope.readModerator,
                ],
              ),
              debugPanelOptions: TwitchDebugPanelOptions(
                chatters: [
                  TwitchChatterMock(displayName: 'Streamer', isModerator: true),
                  TwitchChatterMock(
                      displayName: 'Moderator 1', isModerator: true),
                  TwitchChatterMock(displayName: 'Viewer 1'),
                ],
                chatMessages: const ['!spin'],
              ),
            ));
    if (!mounted) return;

    if (_twitchManager == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Connexion à Twitch échouée, veuillez réessayer plus tard.')));
      return;
    }
    _twitchManager!.onHasDisconnected.startListening(() => WidgetsBinding
        .instance
        .addPostFrameCallback((_) => _getTwitchManagerDialog()));
    setState(() {});
  }

  final _selected = StreamController<int>();
  final _spinDuration = const Duration(seconds: 4);
  DateTime _spinStartingTime = DateTime.now();

  String? _currentQuestion;
  final _questionDuration = const Duration(seconds: 10);

  @override
  void dispose() {
    _selected.close();
    super.dispose();
  }

  void _spinIfTwichAsks(String sender, String message, Questions questions) {
    if (message != '!spin') return;
    if (!_spinWheel(questions)) return;

    _twitchManager?.chat.send('Et ça toooourneee!!!');
  }

  bool _spinWheel(Questions questions) {
    if (DateTime.now().subtract(_spinDuration).compareTo(_spinStartingTime) <
        0) {
      // Not enough time from the last spin then don't rotate
      return false;
    }

    _spinStartingTime = DateTime.now();
    final nextCategoryIndex = questions.pickNextCategoryIndex();
    final nextQuestion =
        questions.categories[nextCategoryIndex].pickNextQuestion();

    _selected.add(nextCategoryIndex);
    Future.delayed(_spinDuration, () {
      _askQuestion(nextQuestion);
    });
    setState(() {});
    return true;
  }

  void _askQuestion(String nextQuestion) {
    if (!mounted) return;

    _currentQuestion = nextQuestion;
    _twitchManager!.chat.send(_currentQuestion!);
    Future.delayed(_questionDuration, _removeQuestion);
    setState(() {});
  }

  void _removeQuestion() {
    if (!mounted) return;

    _currentQuestion = null;
    setState(() {});
  }

  Widget _buildWheel(Questions questions, double wheelSize) {
    final preferences = AppPreferences.of(context);

    if (_twitchManager == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (questions.notHasEnoughQuestions) {
      return const Center(child: Text('Svp ajouter des questions'));
    }
    return GestureDetector(
      onTap: _currentQuestion == null
          ? () => _spinWheel(questions)
          : _removeQuestion,
      child: RotatedBox(
        quarterTurns: 1,
        child: Container(
          decoration: BoxDecoration(color: preferences.backgroundColor),
          child: Center(
            child: Container(
              height: wheelSize,
              width: wheelSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border:
                    Border.all(color: preferences.wheelBorderColor, width: 20),
              ),
              child: FortuneWheel(
                indicators: const [
                  FortuneIndicator(
                      alignment: Alignment.topCenter,
                      child: TriangleIndicator(color: Colors.red))
                ],
                duration: _spinDuration,
                selected: _selected.stream,
                rotationCount: _spinDuration.inSeconds * 2,
                animateFirst: false,
                items: questions.categories
                    .asMap()
                    .keys
                    .map<FortuneItem>((index) => FortuneItem(
                          style: FortuneItemStyle(
                              borderColor: Colors.grey[900]!,
                              borderWidth: 2,
                              color: preferences.wheelFillingColor(index)),
                          child: Text(
                            questions.categories[index].name,
                            maxLines: 1,
                            style: TextStyle(fontSize: wheelSize / 25),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final preferences = AppPreferences.of(context);

    final windowSize = MediaQuery.of(context).size;
    final wheelSize = min(windowSize.height, windowSize.width) * 0.95;

    final questions = preferences.questions;
    final wheel = _buildWheel(questions, wheelSize);

    _twitchManager?.chat.onMessageReceived(
        (sender, message) => _spinIfTwichAsks(sender, message, questions));

    return Scaffold(
      key: _scaffoldKey,
      body: TwitchDebugOverlay(
        manager: _twitchManager,
        child: Stack(
          alignment: Alignment.center,
          children: [
            wheel,
            if (_currentQuestion != null)
              Positioned(
                bottom: wheelSize / 2,
                child: Container(
                  decoration:
                      BoxDecoration(color: preferences.wheelQuestionColor),
                  width: wheelSize * 6 / 5,
                  height: wheelSize / 5,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AutoSizeText(
                        _currentQuestion!,
                        maxLines: 2,
                        style: TextStyle(
                            color: Colors.white, fontSize: wheelSize / 20),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
                left: 12,
                top: 12,
                child: InkWell(
                  borderRadius: BorderRadius.circular(25),
                  onTap: () {
                    _scaffoldKey.currentState!.openDrawer();
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.menu,
                      color: Colors.black,
                    ),
                  ),
                )),
          ],
        ),
      ),
      drawer: MyDrawer(twitchManager: _twitchManager),
    );
  }
}
