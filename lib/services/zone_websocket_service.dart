import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/html.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ZoneWebSocketService {
  late WebSocketChannel _channel;

  ZoneWebSocketService() {
    final String socketUrl =
        dotenv.get('ZONE_WEBSOCKET_URL', fallback: 'NOT_FOUND');
    print('websocket url: ' + socketUrl);
    _channel = kIsWeb
        ? HtmlWebSocketChannel.connect(socketUrl)
        : IOWebSocketChannel.connect(socketUrl);
  }

  void initWebSocket(Function(dynamic) onMessage, Function() onDone,
      Function(dynamic) onError) {
    _channel.stream.listen(
      onMessage,
      onDone: onDone,
      onError: onError,
      cancelOnError: true,
    );
  }

  void sendMessage(String message) {
    _channel.sink.add(jsonEncode({'message': message}));
  }

  void closeWebSocket() {
    _channel.sink.close();
  }
}
