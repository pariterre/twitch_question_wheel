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
  const WheelScreen({super.key});

  static const route = "/wheel-screen";

  @override
  State<WheelScreen> createState() => _WheelScreenState();
}

class _WheelScreenState extends State<WheelScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late TwitchManager? twitchManager =
      ModalRoute.of(context)!.settings.arguments as TwitchManager;

  StreamController<int> selected = StreamController<int>();
  final _spinDuration = const Duration(seconds: 3);
  DateTime _spinStartingTime = DateTime.now();

  String? _currentQuestion;
  final _questionDuration = const Duration(seconds: 10);

  @override
  void dispose() {
    selected.close();
    super.dispose();
  }

  void _spinIfTwichAsks(String sender, String message, Questions questions) {
    if (message != '!spin') return;
    if (!_spinWheel(questions)) return;

    twitchManager!.irc.send('Et ça toooourneee!!!');
  }

  Color _getFillColor(Color color, int index) {
    final opacity = index % 2 == 0 ? 0.6 : 0.3;

    return Color.alphaBlend(
      color.withOpacity(opacity),
      Colors.black,
    );
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

    selected.add(nextCategoryIndex);
    Future.delayed(_spinDuration, () => _askQuestion(nextQuestion));
    setState(() {});
    return true;
  }

  void _askQuestion(String nextQuestion) {
    if (!mounted) return;

    _currentQuestion = nextQuestion;
    twitchManager!.irc.send(_currentQuestion!);
    Future.delayed(_questionDuration, _removeQuestion);
    setState(() {});
  }

  void _removeQuestion() {
    if (!mounted) return;

    _currentQuestion = null;
    setState(() {});
  }

  Widget _buildWheel(
      Questions questions, Color backgroundColor, double wheelSize) {
    if (questions.length == 0) {
      return const Center(child: Text('Svp ajouter des questions'));
    }
    return GestureDetector(
      onTap: _currentQuestion == null
          ? () => _spinWheel(questions)
          : _removeQuestion,
      child: RotatedBox(
        quarterTurns: 1,
        child: Container(
          decoration: BoxDecoration(color: backgroundColor),
          child: Center(
            child: SizedBox(
              height: wheelSize,
              width: wheelSize,
              child: FortuneWheel(
                indicators: const [
                  FortuneIndicator(
                      alignment: Alignment.topCenter,
                      child: TriangleIndicator(color: Colors.red))
                ],
                duration: _spinDuration,
                selected: selected.stream,
                rotationCount: _spinDuration.inSeconds * 2,
                animateFirst: false,
                items: questions.categories
                    .asMap()
                    .keys
                    .map<FortuneItem>((index) => FortuneItem(
                          style: FortuneItemStyle(
                              borderColor: Colors.black,
                              borderWidth: 5,
                              color: _getFillColor(Colors.blue, index)),
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
    final wheel =
        _buildWheel(questions, preferences.backgroundColor, wheelSize);

    twitchManager!.irc.messageCallback =
        (sender, message) => _spinIfTwichAsks(sender, message, questions);

    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        alignment: Alignment.center,
        children: [
          wheel,
          if (_currentQuestion != null)
            Positioned(
              bottom: wheelSize / 2,
              child: Container(
                decoration: BoxDecoration(color: Colors.blue.withAlpha(250)),
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
          if (twitchManager != null) TwitchDebugPanel(manager: twitchManager!),
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
      drawer: MyDrawer(twitchManager: twitchManager),
    );
  }
}
