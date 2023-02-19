import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  late Socket client;
  late final Future<bool> _isReady = _readCredentials();

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

  @override
  void dispose() {
    super.dispose();
    _disconnect();
  }

  void _connect(BuildContext context) async {
    client = await Socket.connect(ircServerAddress, ircPort);
    debugPrint(
        'Connected to: ${client.remoteAddress.address}:${client.remotePort}');
    client.listen((Uint8List data) {
      final serverResponse = String.fromCharCodes(data);
      debugPrint('Server: $serverResponse');
    });

    debugPrint('Joining server...');
    client.write('PASS $oauthKey\n');
    client.write('NICK $nickname\n');
    client.write('JOIN #$channelName\n');

    debugPrint('Connexion established');
    //Navigator.of(context).pushReplacementNamed(widget.nextRoute);
  }

  void _send(String message) {
    final messageToSend = 'PRIVMSG #$channelName :$message\n';
    debugPrint('Sending message:\n$messageToSend');
    client.write(messageToSend);
  }

  void _disconnect() async {
    final message = 'PART $channelName';
    debugPrint('Sending message:\n$message');
    client.write(message);
    client.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: _isReady,
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
                  ElevatedButton(
                      onPressed: (() => _send("Coucou!")),
                      child: const Text('Send')),
                  ElevatedButton(
                      onPressed: (() => _disconnect()),
                      child: const Text('Quit')),
                ],
              ),
            );
          }),
    );
  }
}
