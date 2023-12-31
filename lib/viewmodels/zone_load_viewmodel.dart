import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/scheduled/response_websocket.dart';
import '../services/zone_websocket_service.dart';

enum SocketConnectionStatus { connecting, connected, disconnected }

class ZoneLoadViewModel extends ChangeNotifier {
  late ZoneWebSocketService _socketService;
  SocketConnectionStatus _connectionStatus = SocketConnectionStatus.connecting;
  String? _token = '';

  ZoneLoadViewModel() {
    _socketService = ZoneWebSocketService();
    _initWebSocket();
  }

  SocketConnectionStatus get connectionStatus => _connectionStatus;

  void _initWebSocket() {
    _socketService.initWebSocket(
      onMessage: (message) {
        _handleWebSocketMessage(message);
      },
      onDone: () {
        _connectionStatus = SocketConnectionStatus.disconnected;
        notifyListeners();
      },
      onError: (error) {
        print('Error: $error');
      },
    );

    _connectionStatus = SocketConnectionStatus.connected;
    notifyListeners();
  }

  void sendMessage(
      {String? token,
      required String type,
      required String operation,
      required int id}) {
    _token = token ?? _token;

    final message = {
      'type': type,
      'operation': operation,
      'id': id,
      'token': _token
    };

    _socketService.sendMessage(jsonEncode(message));
  }

  Future<void> waitForWebSocketConnection() async {
    return await _socketService.waitForWebSocketConnection();
  }

  void _handleWebSocketMessage(String message) {
    WebSocketResponse webSocketResponse =
        WebSocketResponse.fromJson(json.decode(message));

    if (webSocketResponse.status == StatusProcess.ERROR) {
      print('Received an error message: ${webSocketResponse.message}');
    } else if (webSocketResponse.status == StatusProcess.INFO) {
      print('Received an info message: ${webSocketResponse.message}');
    } else if (webSocketResponse.status == StatusProcess.FINISHED) {
      if (webSocketResponse.result) {
        print('Task finished successfully.');
      } else {
        print('Task finished with an error: ${webSocketResponse.message}');
      }
    }
  }

  void closeWebSocket() {
    _socketService.closeWebSocket();
  }

  @override
  void dispose() {
    _socketService.closeWebSocket();
    super.dispose();
  }
}
