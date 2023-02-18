import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:irc/client.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen(
      {super.key, required this.credentialsPath, required this.nextRoute});

  final String credentialsPath;
  final String nextRoute;

  static const route = '/connect-screen';

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  late final String nickname;
  late final String channelName;
  late final String oauthKey;
  late final String ircServerAddress;
  late final int ircPort;

  Future<bool> _readCredentials() async {
    final data =
        jsonDecode(await rootBundle.loadString(widget.credentialsPath));
    nickname = data['nickname'];
    channelName = data['channelName'];
    oauthKey = data['oauthKey'];
    ircServerAddress = data['ircServerAddress'];
    ircPort = data['ircPort'];
    return true;
  }

  void _connect(BuildContext context) {
    // self._irc_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    // self._irc_socket.connect((self._config.irc_server_address, self._config.irc_port))
    // self._connexion_initialized = True
    // self._irc_send_data(f"PASS {self._config.oauth_key}")
    // self._irc_send_data(f"NICK {self._config.nickname}")
    // self._irc_send_data(f"JOIN #{self._config.channel_name}")

    final client = Client(Configuration(
      nickname: nickname,
      host: ircServerAddress,
      port: ircPort,
    ));
    client.connect();

    Navigator.of(context).pushReplacementNamed(widget.nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: _readCredentials(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Nom d\'utilisation: $nickname'),
                  Text('Nom de la chaîne : $channelName'),
                  Text('Clé OAUTH : $oauthKey'),
                  Text('Serveur IRC : $ircServerAddress'),
                  Text('Numéro de port : $ircPort'),
                  ElevatedButton(
                      onPressed: (() => _connect(context)),
                      child: const Text('Connecter')),
                ],
              ),
            );
          }),
    );
  }
}
