import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:pomodoro_wheel/providers/app_preferences.dart';

class PreferencesDialog extends StatelessWidget {
  const PreferencesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preferences')),
      body: ListView(
        children: [
          const SizedBox(height: 12),
          _backgroundColorTileBuild(context),
          _editQuestionsTileBuild(context),
          _savePreferencesTileBuild(context),
          _loadPreferencesTileBuild(context),
        ],
      ),
    );
  }

  ListTile _backgroundColorTileBuild(BuildContext context) {
    return ListTile(
      title: const Text('Couleur de fond'),
      trailing: Container(
        width: 50,
        height: 50,
        color: AppPreferences.of(context).backgroundColor,
      ),
      onTap: () => _onTapPickColor(context),
    );
  }

  ListTile _editQuestionsTileBuild(BuildContext context) {
    return ListTile(
      title: const Text('Éditer les questions'),
      onTap: () => _onTapEditQuestions(context),
    );
  }

  Widget _savePreferencesTileBuild(BuildContext context) {
    return ListTile(
      title: const Text('Sauvegarder les préférences'),
      onTap: () => _onTapSavePreferences(context),
    );
  }

  Widget _loadPreferencesTileBuild(BuildContext context) {
    return ListTile(
      title: const Text('Charger les préférences'),
      onTap: () => _onTapLoadPreferences(context),
    );
  }

  void _onTapPickColor(context) async {
    final preferences = AppPreferences.of(context, listen: false);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color!'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: preferences.backgroundColor,
            onColorChanged: (color) => preferences.backgrondColor = color,
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Confirm'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _onTapEditQuestions(context) async {
    //final preferences = AppPreferences.of(context, listen: false);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color!'),
        content: SingleChildScrollView(
          child: Container(),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Confirm'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _onTapSavePreferences(context) async {
    final preferences = AppPreferences.of(context, listen: false);
    final navigator = Navigator.of(context);
    await preferences.savePreferences();
    navigator.pop(); // pop the dialog
    navigator.pop(); // pop the drawer
  }

  void _onTapLoadPreferences(context) async {
    final preferences = AppPreferences.of(context, listen: false);
    final navigator = Navigator.of(context);
    await preferences.loadPreferences();
    navigator.pop(); // pop the dialog
    navigator.pop(); // pop the drawer
  }
}
