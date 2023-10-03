import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:pomodoro_wheel/providers/app_preferences.dart';

void _pickColorDialog(context,
    {required Color currentColor,
    required Function(Color) onColorChanged}) async {
  await showDialog<Color>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Pick a color!'),
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: currentColor,
          onColorChanged: onColorChanged,
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

class PreferencesDialog extends StatelessWidget {
  const PreferencesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final preferences = AppPreferences.of(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Preferences')),
      body: ListView(
        children: [
          const SizedBox(height: 12),
          ListTile(
            title: const Text('Couleur de fond'),
            trailing: Container(
              width: 50,
              height: 50,
              color: AppPreferences.of(context).backgroundColor,
            ),
            onTap: () async {
              _pickColorDialog(context,
                  currentColor: preferences.backgroundColor,
                  onColorChanged: (color) =>
                      preferences.backgrondColor = color);
            },
          ),
        ],
      ),
    );
  }
}
