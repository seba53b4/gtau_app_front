import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../utils/common_utils.dart';

class WebSocketService {
  late WebSocketChannel _webSocketChannel;
  bool _isConnected = false;

  WebSocketService(
      {required Function(dynamic) onMessage,
      required Function() onDone,
      required Function(dynamic) onError}) {
    final String socketUrl =
        dotenv.get('ZONE_WEBSOCKET_URL', fallback: 'NOT_FOUND');
    _webSocketChannel = WebSocketChannel.connect(Uri.parse(socketUrl));
    openConn(onDone: onDone, onMessage: onMessage, onError: onError);
  }

  void openConn(
      {required Function(dynamic) onMessage,
      required Function() onDone,
      required Function(dynamic) onError}) async {
    await _webSocketChannel.ready;
    _webSocketChannel.stream.listen(
      (event) {
        if (!_isConnected) {
          _isConnected = true;
          printOnDebug('WebSocket Connected!');
        }
        onMessage(event);
      },
      onDone: () {
        _isConnected = false;
        onDone();
      },
      onError: (error) {
        _isConnected = false;
      },
      cancelOnError: true,
    );

    await Future.delayed(const Duration(seconds: 5));
    if (_webSocketChannel.closeCode == null) {
      _isConnected = true;
    } else {}
  }

  Future<void> waitForWebSocketConnection() async {
    int retries = 0;
    while (!_isConnected && retries < 10) {
      await Future.delayed(const Duration(seconds: 1));
      retries++;
    }
  }

  void initWebSocket(
      {required Function(dynamic) onMessage,
      required Function() onDone,
      required Function(dynamic) onError}) {
    if (!_isConnected) {
      printOnDebug('WebSocket connection is not fully open yet.');
      return;
    }

    _webSocketChannel.stream.listen(
      (event) {
        onMessage(event);
      },
      onDone: () {
        printOnDebug(
            'WebSocket connection closed with code: ${_webSocketChannel.closeCode}');
        onDone();
      },
      onError: (error) {
        printOnDebug('WebSocket Error: $error');
        onError(error);
      },
      cancelOnError: true,
    );
  }

  void sendMessage(String message) {
    if (_isConnected) {
      _webSocketChannel.sink.add(message);
    } else {
      printOnDebug(
          'WebSocket connection is not fully open yet. Unable to send message.');
    }
  }

  void closeWebSocket() {
    _webSocketChannel.sink.close();
  }
}
