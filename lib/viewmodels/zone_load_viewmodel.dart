import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/scheduled/response_websocket.dart';
import '../services/zone_websocket_service.dart';

enum SocketConnectionStatus { connecting, connected, disconnected }

class ZoneLoadViewModel extends ChangeNotifier {
  late ZoneWebSocketService _socketService;

  SocketConnectionStatus _connectionStatus = SocketConnectionStatus.connecting;

  SocketConnectionStatus get connectionStatus => _connectionStatus;

  String? _token = '';

  bool _catchmentsResult = false;

  bool get catchmentsResult => _catchmentsResult;

  bool _registersResult = false;

  bool get registersResult => _registersResult;

  bool _sectionsResult = false;

  bool get sectionsResult => _sectionsResult;

  bool _isLoading = false;

  bool get isLoading => _isLoading;
  bool _isLoadingSections = false;

  bool get isLoadingSections => _isLoadingSections;

  bool _isLoadingCatchments = false;

  bool get isLoadingCatchments => _isLoadingCatchments;

  bool _isLoadingRegisters = false;

  bool get isLoadingRegisters => _isLoadingRegisters;

  bool? _result;

  bool? get result => _result;

  String? _message;

  String? get message => _message;

  bool _error = false;

  bool get error => _error;

  bool _warning = false;

  bool get warning => _warning;

  ZoneLoadViewModel() {
    _socketService = ZoneWebSocketService(
      onMessage: (message) {
        _handleWebSocketMessage(message);
      },
      onDone: () {
        _connectionStatus = SocketConnectionStatus.disconnected;
        notifyListeners();
      },
      onError: (error) {
        _connectionStatus = SocketConnectionStatus.disconnected;
        notifyListeners();
      },
    );
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
    await _socketService.waitForWebSocketConnection();
    _connectionStatus = SocketConnectionStatus.connected;
    notifyListeners();
  }

  void _handleWebSocketMessage(String message) {
    WebSocketResponse webSocketResponse =
        WebSocketResponse.fromJson(json.decode(message));

    switch (webSocketResponse.status) {
      case StatusProcess.STARTING:
        _isLoading = true;
        _isLoadingCatchments = true;
        _isLoadingRegisters = true;
        _isLoadingSections = true;
        break;
      case StatusProcess.ERROR:
        _message = webSocketResponse.message;
        _isLoading = false;
        _error = true;
        notifyListeners();
        break;
      case StatusProcess.INFO:
        if (webSocketResponse.tramosStatus != null && !_sectionsResult) {
          _sectionsResult = webSocketResponse.tramosStatus!.result;
          _isLoadingSections = false;
        }
        if (webSocketResponse.captacionesStatus != null && !_catchmentsResult) {
          _catchmentsResult = webSocketResponse.captacionesStatus!.result;
          _isLoadingCatchments = false;
        }
        if (webSocketResponse.registrosStatus != null && !_registersResult) {
          _registersResult = webSocketResponse.registrosStatus!.result;
          _isLoadingRegisters = false;
        }
        notifyListeners();
        break;
      case StatusProcess.RUNNING:
        _message =
            'Existe un proceso ejecutándose. Espere unos minutos y vuelva a intentar.';
        _warning = true;
        _isLoading = false;
        notifyListeners();
        break;
      case StatusProcess.STOPPED:
        _message =
            'Se está cancelando el proceso. Espere unos minutos y vuelva a intentar.';
        _warning = true;
        _isLoading = false;
        print('Process stopped');
        notifyListeners();
        break;
      case StatusProcess.FINISHED:
        if (webSocketResponse.result) {
          _result = true;
          print('Task finished successfully.');
        } else {
          _result = false;
          print('Task finished with an error: ${webSocketResponse.message}');
        }
        _isLoading = false;
        closeWebSocket();
        notifyListeners();
        break;
      default:
        break;
    }
  }

  void closeWebSocket() {
    _socketService.closeWebSocket();
  }

  void reset() {
    _socketService.closeWebSocket();
    _registersResult = false;
    _catchmentsResult = false;
    _sectionsResult = false;
    _isLoading = false;
    _result = false;
    _message = null;
    _error = false;
    _token = null;
    _warning = false;
    _isLoadingCatchments = false;
    _isLoadingRegisters = false;
    _isLoadingSections = false;
    super.dispose();
  }
}
