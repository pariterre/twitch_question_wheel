import 'dart:convert';
import 'dart:js_interop';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pomodoro_wheel/models/questions.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;

const _preferencesFilename = 'preferences.json';

class AppPreferences with ChangeNotifier {
  Color _backgroundColor;
  Color get backgroundColor => _backgroundColor;
  set backgrondColor(Color value) {
    _backgroundColor = value;
    notifyListeners();
  }

  Questions _questions;
  Questions get questions => _questions;
  void addQuestion(String category, String question) {
    _questions.addQuestion(category, question);
    notifyListeners();
  }

  ///
  /// Save the current preferences to a file
  void _save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_preferencesFilename, jsonEncode(serialize()));
    notifyListeners();
  }

  Future<void> exportPreferences() async {
    const encoder = JsonEncoder.withIndent('\t');
    final text = encoder.convert(serialize(skipBinaryFiles: true));

    // prepare
    final bytes = utf8.encode(text);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = _preferencesFilename;
    html.document.body!.children.add(anchor);

    // download
    anchor.click();

    // cleanup
    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  Future<void> loadPreferences() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    final loadedPreferences =
        json.decode(utf8.decode(result.files.first.bytes!));

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
