import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';

class WheelScreen extends StatefulWidget {
  const WheelScreen({super.key, required this.questions});

  final Map<String, List<String>> questions;

  @override
  State<WheelScreen> createState() => _WheelScreenState();
}

class _WheelScreenState extends State<WheelScreen> {
  StreamController<int> selected = StreamController<int>();
  final _spinDuration = const Duration(seconds: 3);
  DateTime _spinStartingTime = DateTime.now();
  String? _question;
  final _questionDuration = const Duration(seconds: 10);

  @override
  void initState() {
    super.initState();

    // Initialize with a random value
    selected.add(
      Fortune.randomInt(0, widget.questions.length),
    );
  }

  @override
  void dispose() {
    selected.close();
    super.dispose();
  }

  Color _getFillColor(Color color, int index) {
    final opacity = index % 2 == 0 ? 0.6 : 0.3;

    return Color.alphaBlend(
      color.withOpacity(opacity),
      Colors.black,
    );
  }

  void _spinWheel() {
    if (DateTime.now().subtract(_spinDuration).compareTo(_spinStartingTime) <
        0) {
      // Not enough time from the last spin then don't rotate
      return;
    }

    _spinStartingTime = DateTime.now();
    final nextCategoryIndex = Fortune.randomInt(0, widget.questions.length);
    final nextCategory = widget.questions.keys.toList()[nextCategoryIndex];
    selected.add(nextCategoryIndex);
    Future.delayed(_spinDuration, () => _bringQuestion(nextCategory));
    setState(() {});
  }

  void _bringQuestion(String nextCategory) {
    final questions = widget.questions[nextCategory]!;
    _question = questions[Fortune.randomInt(0, questions.length)];
    Future.delayed(_questionDuration, _removeQuestion);
    setState(() {});
  }

  void _removeQuestion() {
    _question = null;
    setState(() {});
  }

  Widget _buildWheel(Color backgroundColor, double wheelSize) =>
      GestureDetector(
        onTap: _question == null ? _spinWheel : _removeQuestion,
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
                        child: TriangleIndicator(
                          color: Colors.red,
                        ))
                  ],
                  duration: _spinDuration,
                  selected: selected.stream,
                  rotationCount: _spinDuration.inSeconds * 2,
                  items: widget.questions.keys
                      .toList()
                      .asMap()
                      .entries
                      .map<FortuneItem>((e) => FortuneItem(
                            style: FortuneItemStyle(
                                color: _getFillColor(Colors.blue, e.key)),
                            child: AutoSizeText(e.value,
                                maxLines: 1,
                                style: TextStyle(fontSize: wheelSize / 20)),
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color.fromARGB(255, 0, 255, 0);
    final windowSize = MediaQuery.of(context).size;
    final wheelSize = min(windowSize.height, windowSize.width) * 0.95;

    final wheel = _buildWheel(backgroundColor, wheelSize);
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          wheel,
          if (_question != null)
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
                      _question!,
                      maxLines: 2,
                      style: TextStyle(
                          color: Colors.white, fontSize: wheelSize / 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
