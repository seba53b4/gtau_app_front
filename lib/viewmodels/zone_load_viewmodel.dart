import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gtau_app_front/services/zone_websocket_service.dart';

import '../models/scheduled/response_websocket.dart';

enum SocketConnectionStatus { connecting, connected, disconnected }

class ZoneLoadViewModel extends ChangeNotifier {
  late ZoneWebSocketService _webSocketService;
  SocketConnectionStatus _connectionStatus = SocketConnectionStatus.connecting;

  ZoneLoadViewModel() {
    _webSocketService = ZoneWebSocketService();
    _initWebSocket();
  }

  SocketConnectionStatus get connectionStatus => _connectionStatus;

  void _initWebSocket() {
    _webSocketService.initWebSocket(
      (message) {
        _handleWebSocketMessage(message);
      },
      () {
        _connectionStatus = SocketConnectionStatus.disconnected;
        notifyListeners();
      },
      (error) {
        print('Error: $error');
      },
    );

    _connectionStatus = SocketConnectionStatus.connected;
    notifyListeners();
  }

  void sendMessage(String type, String operation, int id) {
    final message = {
      'type': type,
      'operation': operation,
      'id': id,
    };
    _webSocketService.sendMessage(message.toString());
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

  @override
  void dispose() {
    _webSocketService.closeWebSocket();
    super.dispose();
  }
}
