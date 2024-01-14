enum StatusProcess {
  STARTING,
  RUNNING,
  STOPPED,
  FINISHED,
  INFO,
  ERROR,
}

class WebSocketResponse {
  String? type;
  StatusProcess status;
  bool result;
  String? message;
  ElementStatus? tramosStatus;
  ElementStatus? registrosStatus;
  ElementStatus? captacionesStatus;

  WebSocketResponse({
    this.type,
    required this.status,
    required this.result,
    this.message,
    this.tramosStatus,
    this.registrosStatus,
    this.captacionesStatus,
  });

  factory WebSocketResponse.fromJson(Map<String, dynamic> json) {
    return WebSocketResponse(
      type: json['type'],
      status: _parseStatus(json['status']),
      result: json['result'],
      message: json['message'],
      tramosStatus: json['tramosStatus'] != null
          ? ElementStatus.fromJson(json['tramosStatus'])
          : null,
      registrosStatus: json['registrosStatus'] != null
          ? ElementStatus.fromJson(json['registrosStatus'])
          : null,
      captacionesStatus: json['captacionesStatus'] != null
          ? ElementStatus.fromJson(json['captacionesStatus'])
          : null,
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

class ElementStatus {
  String entity;
  bool result;
  String? message;

  ElementStatus({
    required this.entity,
    required this.result,
    this.message,
  });

  factory ElementStatus.fromJson(Map<String, dynamic> json) {
    return ElementStatus(
      entity: json['entity'],
      result: json['result'],
      message: json['message'],
    );
  }
}
