import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

class TwitchConnector {
  final Socket _socket;
  static const ircServerAddress = 'irc.chat.twitch.tv';
  static const ircPort = 6667;
  static const regexpMessage = r'^:(.*)!.*@.*PRIVMSG.*#.*:(.*)$';

  final String username;
  final String channelName;
  final String oauthKey;
  Function(String sender, String message)? messageCallback;

  TwitchConnector(
    this._socket, {
    required this.username,
    required this.channelName,
    required this.oauthKey,
  }) {
    _send('PASS $oauthKey');
    _send('NICK $username');
    _send('JOIN #$channelName');

    _socket.listen(_messageReceived);
  }

  static Future<TwitchConnector> fromJsonConfig(String credentialsPath) async {
    final data = jsonDecode(await rootBundle.loadString(credentialsPath));

    final socket = await Socket.connect(ircServerAddress, ircPort);

    return TwitchConnector(
      socket,
      username: data['username'],
      channelName: data['channelName'],
      oauthKey: data['oauthKey'],
    );
  }

  void send(String message) {
    _send('PRIVMSG #$channelName :$message');
  }

  void _send(String command) {
    _socket.write('$command\n');
  }

  void disconnect() {
    _send('PART $channelName');
    _socket.close();
  }

  void _messageReceived(Uint8List data) {
    var response = String.fromCharCodes(data);
    // Remove the line returns
    if (response[response.length - 1] == '\n') {
      response = response.substring(0, response.length - 1);
    }
    if (response[response.length - 1] == '\r') {
      response = response.substring(0, response.length - 1);
    }

    if (response == "PING :tmi.twitch.tv") {
      // Keep connexion alive
      _send("PONG :tmi.twitch.tv");
      return;
    }

    if (messageCallback == null) return;
    final re = RegExp(regexpMessage);
    final match = re.firstMatch(response);
    if (match == null || match.groupCount != 2) return;

    final sender = match.group(1)!;
    final message = match.group(2)!;
    messageCallback!(sender, message);
  }
}
