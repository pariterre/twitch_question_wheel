import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:twitch_manager/twitch_manager.dart';

class WheelScreen extends StatefulWidget {
  const WheelScreen({super.key, required this.questionsPath});

  static const route = "/wheel-screen";

  final String questionsPath;

  @override
  State<WheelScreen> createState() => _WheelScreenState();
}

class _WheelScreenState extends State<WheelScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TwitchManager? twitchManager;

  StreamController<int> selected = StreamController<int>();
  final _spinDuration = const Duration(seconds: 3);
  DateTime _spinStartingTime = DateTime.now();

  late Future<Map<String, List<String>>> _questions;
  String? _currentQuestion;
  final _questionDuration = const Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    _questions = _loadQuestions();
  }

  Future<Map<String, List<String>>> _loadQuestions() async {
    final data = jsonDecode(await rootBundle.loadString(widget.questionsPath));
    return data.map<String, List<String>>((String key, value) {
      return MapEntry(key, (value as List).map<String>((e) => e).toList());
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    twitchManager ??=
        ModalRoute.of(context)!.settings.arguments as TwitchManager;
  }

  @override
  void dispose() {
    selected.close();
    super.dispose();
  }

  void _spinIfTwichAsks(
      String sender, String message, Map<String, List<String>> questions) {
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

  bool _spinWheel(Map<String, List<String>> questions) {
    if (DateTime.now().subtract(_spinDuration).compareTo(_spinStartingTime) <
        0) {
      // Not enough time from the last spin then don't rotate
      return false;
    }

    _spinStartingTime = DateTime.now();
    final nextCategoryIndex = Fortune.randomInt(0, questions.length);
    final nextCategory = questions.keys.toList()[nextCategoryIndex];
    final categoryQuestions = questions[nextCategory]!;
    final nextQuestion =
        categoryQuestions[Fortune.randomInt(0, categoryQuestions.length)];

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

  Widget _buildWheel(Map<String, List<String>> questions, Color backgroundColor,
      double wheelSize) {
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
                items: questions.keys
                    .toList()
                    .asMap()
                    .entries
                    .map<FortuneItem>((e) => FortuneItem(
                          style: FortuneItemStyle(
                              borderColor: Colors.black,
                              borderWidth: 5,
                              color: _getFillColor(Colors.blue, e.key)),
                          child: Text(
                            e.value,
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
    const backgroundColor = Color.fromARGB(255, 0, 255, 0);
    final windowSize = MediaQuery.of(context).size;
    final wheelSize = min(windowSize.height, windowSize.width) * 0.95;

    return Scaffold(
      key: _scaffoldKey,
      body: FutureBuilder(
          future: _questions,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final questions = snapshot.data!;
            final wheel = _buildWheel(questions, backgroundColor, wheelSize);
            twitchManager!.irc.messageCallback = (sender, message) =>
                _spinIfTwichAsks(sender, message, questions);

            return Stack(
              alignment: Alignment.center,
              children: [
                wheel,
                if (_currentQuestion != null)
                  Positioned(
                    bottom: wheelSize / 2,
                    child: Container(
                      decoration:
                          BoxDecoration(color: Colors.blue.withAlpha(250)),
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
                if (twitchManager != null)
                  TwitchDebugPanel(manager: twitchManager!),
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
            );
          }),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const ListTile(
              title: Text('Éditeur de questions (À VENIR)'),
            ),
            ListTile(
              title: const Text('Déconnexion de Twitch'),
              onTap: () async {
                final navigator = Navigator.of(context);
                await twitchManager!.disconnect();
                navigator
                    .pushReplacementNamed(TwitchAuthenticationScreen.route);
              },
            ),
          ],
        ),
      ),
    );
  }
}
