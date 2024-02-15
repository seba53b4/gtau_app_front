import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:gtau_app_front/models/enums/element_type.dart';

import '../models/scheduled/response_websocket_shape_load.dart';
import '../models/scheduled/response_websocket_zone_load.dart';
import '../services/websocket_service.dart';

enum SocketConnectionStatus { connecting, connected, disconnected }

class ShapeLoadViewModel extends ChangeNotifier {
  late WebSocketService _socketService;
  static const String proccesIsAlreadyRunning = "Process is already running";
  static const String processType = "ENTITIES_CHARGE";
  SocketConnectionStatus _connectionStatus = SocketConnectionStatus.connecting;

  SocketConnectionStatus get connectionStatus => _connectionStatus;

  String? _token = '';

  bool? _result;

  bool? get result => _result;

  String? _message;

  String? get message => _message;

  bool _error = false;

  bool get error => _error;

  bool _warning = false;

  bool get warning => _warning;

  bool _connected = false;

  bool get connected => _connected;

  bool _processAlreadyRunning = false;

  bool get processAlreadyRunning => _processAlreadyRunning;

  bool _isRetrying = false;

  bool get isRetrying => _isRetrying;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  double _percent = 0.0;

  double get percent => _percent;

  bool _processing = false;

  bool get processing => _processing;

  int _blockMaxSize = 8;
  int _lastBlock = 8;

  int _elementsProcessed = 0;

  List<dynamic> _linesData = [];

  ElementType? _elementType;

  ElementType? get elementType => _elementType;

  List<dynamic> _linesError = [];

  List<dynamic> get linesError => _linesError;

  List<dynamic>? _linesProcess = [];

  void initWS() {
    _socketService = WebSocketService(
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

  void sendMessage({
    required ElementType elementType,
  }) {
    Map<String, Object?> message = {
      'type': processType,
      'token': _token,
    };

    _linesProcess = _getSublist(_linesData, _elementsProcessed);
    message['entityType'] = _elementType!.pluralName;

    switch (_elementType!.type) {
      case 'T':
        message['linesTramos'] = _linesProcess;
        break;
      case 'R':
        message['linesRegistros'] = _linesProcess;
        break;
      case 'C':
        message['linesCaptaciones'] = _linesProcess;
        break;
      case 'P':
        message['linesParcelas'] = _linesProcess;
        break;
    }

    _socketService.sendMessage(jsonEncode(message));
  }

  void initializeProcessShapeLoad({
    String? token,
    required String entityType,
    List<dynamic>? linesTramos,
    List<dynamic>? linesRegistros,
    List<dynamic>? linesCaptaciones,
    List<dynamic>? linesParcelas,
  }) {
    _token = token ?? _token;

    _linesData =
    (linesTramos ?? linesRegistros ?? linesCaptaciones ?? linesParcelas)!;

    if (linesTramos != null) {
      _elementType = ElementType.section;
    } else if (linesRegistros != null) {
      _elementType = ElementType.register;
    } else if (linesCaptaciones != null) {
      _elementType = ElementType.catchment;
    } else if (linesParcelas != null) {
      _elementType = ElementType.lot;
      _blockMaxSize = 1;
      _lastBlock = 1;
    }
    _processing = true;
    notifyListeners();
    sendMessage(elementType: _elementType!);
  }

  List<dynamic>? _getSublist(List<dynamic>? lines, int startIndex) {
    if (lines == null || startIndex < 0 || startIndex >= lines.length) {
      return null;
    }

    int endIndex = startIndex + _blockMaxSize;
    if (endIndex > lines.length) {
      endIndex = lines.length;
      _lastBlock = endIndex - startIndex;
    }

    List<dynamic> sublist = lines.sublist(startIndex, endIndex);

    return sublist;
  }

  double calculatePercentLoad() {
    double result;
    if (_elementsProcessed < _linesData.length) {
      result = ((_elementsProcessed + 1) / _linesData.length);
    } else {
      result = 1.0;
    }
    return double.parse(result.toStringAsFixed(2));
  }

  // Future<void> retryProcess(
  //     {String? token,
  //     required String type,
  //     required String operation,
  //     required int id}) async {
  //   _token = token ?? _token;
  //   {
  //     _isRetrying = true;
  //     notifyListeners();
  //     await Future.delayed(const Duration(seconds: 1));
  //     sendMessage(type: type, operation: operation, id: id);
  //     _isRetrying = false;
  //     notifyListeners();
  //   }
  // }

  Future<void> waitForWebSocketConnection() async {
    _connected = false;
    notifyListeners();
    await _socketService.waitForWebSocketConnection();
    _connectionStatus = SocketConnectionStatus.connected;
    _connected = true;
    notifyListeners();
  }

  void _handleWebSocketMessage(String message) {
    WebSocketResponseShapeLoad webSocketResponseShapeLoad =
    WebSocketResponseShapeLoad.fromJson(json.decode(message));

    switch (webSocketResponseShapeLoad.status) {
      case StatusProcess.STARTING:
        _isLoading = true;
        _warning = false;
        _processAlreadyRunning = false;
        break;
      case StatusProcess.ERROR:
      //int prevProcessed = _elementsProcessed;
        if (_linesData.length - _elementsProcessed < _blockMaxSize) {
          _elementsProcessed += _lastBlock;
        } else {
          _elementsProcessed += _blockMaxSize;
        }

        _linesError.addAll(webSocketResponseShapeLoad.errorIds!);

        _percent = calculatePercentLoad();
        if (_elementsProcessed < _linesData.length) {
          sendMessage(elementType: _elementType!);
        }

        if (_elementsProcessed == _linesData.length) {
          _processing = false;
          _result = true;
          closeWebSocket();
        }

        break;
      case StatusProcess.INFO:
        break;
      case StatusProcess.RUNNING:
        _processAlreadyRunning = true;
        _warning = true;
        _isLoading = false;
        break;
      case StatusProcess.STOPPED:
        _warning = true;
        _isLoading = false;
        break;
      case StatusProcess.FINISHED:
        if (webSocketResponseShapeLoad.result) {
          if (_linesData.length - _elementsProcessed < _blockMaxSize) {
            _elementsProcessed += _lastBlock;
          } else {
            _elementsProcessed += _blockMaxSize;
          }
          _percent = calculatePercentLoad();
          if (_elementsProcessed < _linesData.length) {
            sendMessage(elementType: _elementType!);
          }

          if (_elementsProcessed == _linesData.length) {
            _processing = false;
            _result = true;
            closeWebSocket();
          }
        } else {
          _result = false;
          _processing = false;
          closeWebSocket();
        }

        break;
      default:
        break;
    }
    notifyListeners();
  }

  void closeWebSocket() {
    _socketService.closeWebSocket();
  }

  void reset() {
    _result = null;
    _message = null;
    _error = false;
    _token = null;
    _percent = 0.0;
    _connected = false;
    _processing = false;
    _warning = false;
    _elementsProcessed = 0;
    _linesData.clear();
    _elementType = null;
    _connectionStatus = SocketConnectionStatus.disconnected;
  }
}
