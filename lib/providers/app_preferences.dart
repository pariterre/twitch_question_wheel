import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pomodoro_wheel/models/file_picker_interface.dart';
import 'package:pomodoro_wheel/models/questions.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _preferencesFilename = 'preferences.json';

class AppPreferences with ChangeNotifier {
  Color _backgroundColor;
  Color get backgroundColor => _backgroundColor;
  set backgrondColor(Color value) {
    _backgroundColor = value;
    _save();
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
    final text = encoder.convert(serialize(skipBinaryFiles: true));

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
    final questions =
        Questions.fromSerialized(previousPreferences['questions'] ?? {});
    return AppPreferences._(
        backgroundColor: backgroundColor, questions: questions);
  }

  AppPreferences._({
    required Color backgroundColor,
    required Questions questions,
  })  : _backgroundColor = backgroundColor,
        _questions = questions;

  // INTERNAL METHODS
  ///

  ///
  /// Serialize all the values
  Map<String, dynamic> serialize({bool skipBinaryFiles = false}) => {
        'backgroundColor': _backgroundColor.value,
        'questions': _questions.serialize(),
      };

  ///
  /// Reset the app configuration to their original values
  void updateFromSerialized(map) async {
    _backgroundColor = Color(map['backgroundColor'] ?? 0x0000000);
    _questions = Questions.fromSerialized(map['questions'] ?? {});
  }
}
