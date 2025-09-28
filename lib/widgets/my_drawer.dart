import 'package:flutter/material.dart';
import 'package:twitch_manager/twitch_app.dart';
import 'package:twitch_question_wheel/providers/app_preferences.dart';
import 'package:twitch_question_wheel/screens/edit_question_dialog.dart';
import 'package:twitch_question_wheel/widgets/custom_hue_ring_picker.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key, required this.twitchManager});

  final TwitchAppManager? twitchManager;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              _wheelThemeColorTileBuild(context),
              _backgroundColorTileBuild(context),
              _editQuestionsTileBuild(context),
              _savePreferencesTileBuild(context),
              _loadPreferencesTileBuild(context),
            ],
          ),
          ListTile(
            title: const Text('Déconnexion de Twitch'),
            onTap: () async {
              await twitchManager!.disconnect();

              if (!context.mounted) return;
              Navigator.of(context).pop();
            },
          ),
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
      onTap: () => _onTapPickBackgroundColor(context),
    );
  }

  ListTile _wheelThemeColorTileBuild(BuildContext context) {
    return ListTile(
      title: const Text('Couleur de la roue'),
      trailing: const MiniWheel(thumbnailRadius: 25),
      onTap: () => _onTapPickWheelThemeColor(context),
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
      title: const Text('Sauvegarder'),
      onTap: () => _onTapSavePreferences(context),
    );
  }

  Widget _loadPreferencesTileBuild(BuildContext context) {
    return ListTile(
      title: const Text('Charger'),
      onTap: () => _onTapLoadPreferences(context),
    );
  }

  void _onTapPickBackgroundColor(context) async {
    final preferences = AppPreferences.of(context, listen: false);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir la couleur du fond d\'écran'),
        content: SingleChildScrollView(
          child: CustomHueRingPicker(
            pickerColor: preferences.backgroundColor,
            onColorChanged: (color) => preferences.backgroundColor = color,
            enableAlpha: true,
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Terminer'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _onTapPickWheelThemeColor(context) async {
    const thumbnailRadius = 75.0;

    final preferences = AppPreferences.of(context, listen: false);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir la couleur du thème de la roue'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Première moitiée',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        CustomHueRingPicker(
                          pickerColor: preferences.wheelColorOdd,
                          colorPickerHeight: 200,
                          onColorChanged: (color) =>
                              preferences.wheelColorOdd = color,
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Texte première moitiée',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        CustomHueRingPicker(
                          pickerColor: preferences.wheelTextColorOdd,
                          colorPickerHeight: 200,
                          onColorChanged: (color) =>
                              preferences.wheelTextColorOdd = color,
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Seconde moitiée',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        CustomHueRingPicker(
                          pickerColor: preferences.wheelColorEven,
                          colorPickerHeight: 200,
                          onColorChanged: (color) =>
                              preferences.wheelColorEven = color,
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Texte seconde moitiée',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        CustomHueRingPicker(
                          pickerColor: preferences.wheelTextColorEven,
                          colorPickerHeight: 200,
                          onColorChanged: (color) =>
                              preferences.wheelTextColorEven = color,
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Marqueur',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        CustomHueRingPicker(
                          pickerColor: preferences.wheelColorMarker,
                          colorPickerHeight: 200,
                          onColorChanged: (color) =>
                              preferences.wheelColorMarker = color,
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bordure',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        CustomHueRingPicker(
                          pickerColor: preferences.wheelBorderColor,
                          colorPickerHeight: 200,
                          onColorChanged: (color) =>
                              preferences.wheelBorderColor = color,
                          enableAlpha: true,
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Question',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        CustomHueRingPicker(
                          pickerColor: preferences.wheelQuestionColor,
                          colorPickerHeight: 200,
                          onColorChanged: (color) =>
                              preferences.wheelQuestionColor = color,
                          enableAlpha: true,
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bordure question',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        CustomHueRingPicker(
                          pickerColor: preferences.wheelQuestionBorderColor,
                          colorPickerHeight: 200,
                          onColorChanged: (color) =>
                              preferences.wheelQuestionBorderColor = color,
                          enableAlpha: true,
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Text question',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        CustomHueRingPicker(
                          pickerColor: preferences.wheelQuestionTextColor,
                          colorPickerHeight: 200,
                          onColorChanged: (color) =>
                              preferences.wheelQuestionTextColor = color,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      children: [
                        Text('Résultat',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        const MiniWheel(thumbnailRadius: thumbnailRadius)
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Terminer'),
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
      builder: (context) => const EditQuestionDialog(),
    );
  }

  void _onTapSavePreferences(context) async {
    final preferences = AppPreferences.of(context, listen: false);
    final navigator = Navigator.of(context);
    await preferences.savePreferences(context);
    navigator.pop();
  }

  void _onTapLoadPreferences(context) async {
    final preferences = AppPreferences.of(context, listen: false);
    final navigator = Navigator.of(context);
    await preferences.loadPreferences(context);
    navigator.pop();
  }
}

class MiniWheel extends StatelessWidget {
  const MiniWheel({
    super.key,
    required this.thumbnailRadius,
  });

  final double thumbnailRadius;
  final borderRadiusFactor = 0.9;

  @override
  Widget build(BuildContext context) {
    final preferences = AppPreferences.of(context);

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 2 * thumbnailRadius,
          height: 2 * thumbnailRadius,
          decoration: BoxDecoration(
            color: preferences.wheelBorderColor,
            borderRadius: BorderRadius.circular(thumbnailRadius),
          ),
          child: Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    width: thumbnailRadius * borderRadiusFactor,
                    height: 2 * thumbnailRadius * borderRadiusFactor,
                    decoration: BoxDecoration(
                      color: preferences.wheelFillingColor(1),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(
                              thumbnailRadius * borderRadiusFactor),
                          bottomLeft: Radius.circular(
                              thumbnailRadius * borderRadiusFactor)),
                    )),
                Container(
                  width: thumbnailRadius * borderRadiusFactor,
                  height: 2 * thumbnailRadius * borderRadiusFactor,
                  decoration: BoxDecoration(
                    color: preferences.wheelFillingColor(2),
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(
                            thumbnailRadius * borderRadiusFactor),
                        bottomRight: Radius.circular(
                            thumbnailRadius * borderRadiusFactor)),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: thumbnailRadius / 2,
          top: thumbnailRadius / 3,
          child: Container(
            width: thumbnailRadius / 4,
            height: thumbnailRadius / 4,
            decoration: BoxDecoration(color: preferences.wheelTextColorOdd),
          ),
        ),
        Positioned(
          right: thumbnailRadius / 2,
          top: thumbnailRadius / 3,
          child: Container(
            width: thumbnailRadius / 4,
            height: thumbnailRadius / 4,
            decoration: BoxDecoration(color: preferences.wheelTextColorEven),
          ),
        ),
        Positioned(
          right: 0,
          child: Container(
            width: thumbnailRadius / 4,
            height: thumbnailRadius / 4,
            decoration: BoxDecoration(color: preferences.wheelColorMarker),
          ),
        ),
        Positioned(
          left: 0,
          child: Container(
            width: thumbnailRadius * 1.2 + thumbnailRadius / 10,
            height: thumbnailRadius / 2,
            decoration:
                BoxDecoration(color: preferences.wheelQuestionBorderColor),
          ),
        ),
        Positioned(
          left: thumbnailRadius / 10,
          child: Container(
            width: thumbnailRadius * 1.2 - thumbnailRadius / 10,
            height: thumbnailRadius / 2 - thumbnailRadius / 10,
            decoration: BoxDecoration(color: preferences.wheelQuestionColor),
          ),
        ),
        Positioned(
          left: thumbnailRadius / 4,
          child: Container(
            width: thumbnailRadius * 0.3,
            height: thumbnailRadius / 4,
            decoration:
                BoxDecoration(color: preferences.wheelQuestionTextColor),
          ),
        ),
      ],
    );
  }
}
