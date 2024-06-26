import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twitch_question_wheel/models/file_picker_interface.dart';
import 'package:twitch_question_wheel/models/questions.dart';

const _preferencesFilename = 'preferences.json';

class AppPreferences with ChangeNotifier {
  Color _backgroundColor;
  Color get backgroundColor => _backgroundColor;
  set backgroundColor(Color value) {
    _backgroundColor = value;
    _save();
  }

  Color _wheelBorderColor;
  Color get wheelBorderColor => _wheelBorderColor;
  set wheelBorderColor(Color value) {
    _wheelBorderColor = value;
    _save();
  }

  Color _wheelColorOdd;
  Color get wheelColorOdd => _wheelColorOdd;
  set wheelColorOdd(Color value) {
    _wheelColorOdd = value;
    _save();
  }

  Color _wheelColorEven;
  Color get wheelColorEven => _wheelColorEven;
  set wheelColorEven(Color value) {
    _wheelColorEven = value;
    _save();
  }

  Color _wheelQuestionColor;
  Color get wheelQuestionColor => _wheelQuestionColor;
  set wheelQuestionColor(Color value) {
    _wheelQuestionColor = value;
    _save();
  }

  Color wheelFillingColor(int index) {
    return index.isOdd ? _wheelColorOdd : _wheelColorEven;
  }

  Questions _questions;
  Questions get questions => _questions;
  void addCategory(String category) {
    _questions.addCategory(category);
    _save();
  }

  void editCategory(String oldCategory, String newCategory) {
    _questions.editCategory(oldCategory, newCategory);
    _save();
  }

  void deleteCategory(String category) {
    _questions.deleteCategory(category);
    _save();
  }

  void addQuestion(String category, String question) {
    _questions.addQuestion(category, question);
    _save();
  }

  void editQuestion(String category, String oldQuestion, String newQuestion) {
    _questions.editQuestion(category, oldQuestion, newQuestion);
    _save();
  }

  void deleteQuestion(String category, String question) {
    _questions.deleteQuestion(category, question);
    _save();
  }

  ///
  /// Save the current preferences to a file
  void _save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_preferencesFilename, jsonEncode(serialize()));
    notifyListeners();
  }

  ///
  /// Export the current preferences to a file
  Future<void> savePreferences(context) async {
    const encoder = JsonEncoder.withIndent('\t');
    final text = encoder.convert(serialize());

    await FilePickerInterface.instance.saveFile(
      context,
      data: text,
      filename: 'preferences.json',
    );
  }

  Future<void> loadPreferences(context) async {
    final result = await FilePickerInterface.instance.pickFile(context);
    if (result == null) return;

    final loadedPreferences = json.decode(utf8.decode(result));

    updateFromSerialized(loadedPreferences);
    _save();
  }

  // CONSTRUCTOR AND ACCESSORS
  ///
  /// Main accessor of the AppPreference
  static AppPreferences of(BuildContext context, {listen = true}) =>
      Provider.of<AppPreferences>(context, listen: listen);

  ///
  /// Main constructor of the AppPreferences. If [reload] is false, then the
  /// previously saved folder is ignored
  static Future<AppPreferences> factory({reload = true}) async {
    Future<String?> readPreferences() async {
      // Read the previously saved preference file if it exists
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_preferencesFilename);
    }

    final preferencesAsString = await readPreferences();
    Map<String, dynamic> previousPreferences = {};
    if (reload && preferencesAsString != null) {
      try {
        previousPreferences = jsonDecode(preferencesAsString);
      } catch (_) {
        // Do nothing
      }
    }

    // Call the real constructor
    final backgroundColor =
        Color(previousPreferences['backgroundColor'] ?? 0x00000000);
    final wheelBorderColor = Color(
        previousPreferences['wheelBorderColor'] ?? Colors.grey[700]!.value);
    final wheelColorOdd =
        Color(previousPreferences['wheelColorOdd'] ?? Colors.blue.value);
    final wheelColorEven =
        Color(previousPreferences['wheelColorEven'] ?? Colors.blue[800]!.value);
    final wheelQuestionColor =
        Color(previousPreferences['wheelQuestionColor'] ?? Colors.blue.value);

    final questions =
        Questions.fromSerialized(previousPreferences['questions'] ?? {});
    return AppPreferences._(
        backgroundColor: backgroundColor,
        wheelBorderColor: wheelBorderColor,
        wheelColorOdd: wheelColorOdd,
        wheelColorEven: wheelColorEven,
        wheelQuestionColor: wheelQuestionColor,
        questions: questions);
  }

  AppPreferences._({
    required Color backgroundColor,
    required Color wheelBorderColor,
    required Color wheelColorOdd,
    required Color wheelColorEven,
    required Color wheelQuestionColor,
    required Questions questions,
  })  : _backgroundColor = backgroundColor,
        _wheelBorderColor = wheelBorderColor,
        _wheelColorOdd = wheelColorOdd,
        _wheelColorEven = wheelColorEven,
        _wheelQuestionColor = wheelQuestionColor,
        _questions = questions;

  // INTERNAL METHODS
  ///

  ///
  /// Serialize all the values
  Map<String, dynamic> serialize() => {
        'backgroundColor': _backgroundColor.value,
        'wheelBorderColor': _wheelBorderColor.value,
        'wheelColorOdd': _wheelColorOdd.value,
        'wheelColorEven': _wheelColorEven.value,
        'wheelQuestionColor': _wheelQuestionColor.value,
        'questions': _questions.serialize(),
      };

  ///
  /// Reset the app configuration to their original values
  void updateFromSerialized(map) async {
    _backgroundColor = Color(map['backgroundColor'] ?? 0x0000000);
    _wheelBorderColor =
        Color(map['wheelBorderColor'] ?? Colors.grey[700]!.value);
    _wheelColorOdd = Color(map['wheelColorOdd'] ?? Colors.blue.value);
    _wheelColorEven = Color(map['wheelColorEven'] ?? Colors.blue[800]!.value);
    _wheelQuestionColor = Color(map['wheelQuestionColor'] ?? Colors.blue.value);
    _questions = Questions.fromSerialized(map['questions'] ?? {});
  }
}
