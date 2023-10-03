import 'package:flutter/material.dart';
import 'package:pomodoro_wheel/screens/preferences_dialog.dart';
import 'package:twitch_manager/twitch_manager.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key, required this.twitchManager});

  final TwitchManager? twitchManager;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          const ListTile(
            title: Text('Éditeur de questions (À VENIR)'),
          ),
          ListTile(
            title: const Text('Préférences'),
            onTap: () => showDialog(
                context: context,
                builder: (context) =>
                    const AlertDialog(content: PreferencesDialog())),
          ),
          ListTile(
            title: const Text('Déconnexion de Twitch'),
            onTap: () async {
              final navigator = Navigator.of(context);
              await twitchManager!.disconnect();
              navigator.pushReplacementNamed(TwitchAuthenticationScreen.route);
            },
          ),
        ],
      ),
    );
  }
}
