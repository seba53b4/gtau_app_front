import 'package:gtau_app_front/models/scheduled/response_websocket_zone_load.dart';

class WebSocketResponseShapeLoad {
  String? type;
  StatusProcess status;
  bool result;
  String? message;
  String entityType;
  List<String>? errorIds;
  String? detail;

  WebSocketResponseShapeLoad({
    this.type,
    required this.status,
    required this.result,
    this.message,
    this.detail,
    this.errorIds,
    required this.entityType,
  });

  factory WebSocketResponseShapeLoad.fromJson(Map<String, dynamic> json) {
    return WebSocketResponseShapeLoad(
      type: json['type'],
      status: _parseStatus(json['status']),
      result: json['result'],
      message: json['message'],
      entityType: json['entityType'],
      errorIds: json['errorIds'] != null
          ? (json['errorIds'] as List)
              .map((dynamic id) => id.toString())
              .toList()
          : null,
      detail: json['detail'],
    );
  }

  static StatusProcess _parseStatus(String status) {
    switch (status) {
      case 'STARTING':
        return StatusProcess.STARTING;
      case 'RUNNING':
        return StatusProcess.RUNNING;
      case 'STOPPED':
        return StatusProcess.STOPPED;
      case 'FINISHED':
        return StatusProcess.FINISHED;
      case 'INFO':
        return StatusProcess.INFO;
      case 'ERROR':
        return StatusProcess.ERROR;
      default:
        throw ArgumentError('Invalid status: $status');
    }
  }
}
