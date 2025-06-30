import 'dart:convert';

enum DeviceConnectionType { smartwatch, phone, unknown }

enum ConnectionStatus { disconnected, connecting, connected, error }

class DeviceConnectionModel {
  final String deviceId;
  final String deviceName;
  final DeviceConnectionType deviceType;
  final ConnectionStatus status;
  final DateTime? lastConnected;
  final DateTime? lastSeen;
  final Map<String, dynamic>? lastData;
  final String? errorMessage;

  DeviceConnectionModel({
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    this.status = ConnectionStatus.disconnected,
    this.lastConnected,
    this.lastSeen,
    this.lastData,
    this.errorMessage,
  });

  DeviceConnectionModel copyWith({
    String? deviceId,
    String? deviceName,
    DeviceConnectionType? deviceType,
    ConnectionStatus? status,
    DateTime? lastConnected,
    DateTime? lastSeen,
    Map<String, dynamic>? lastData,
    String? errorMessage,
  }) {
    return DeviceConnectionModel(
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      deviceType: deviceType ?? this.deviceType,
      status: status ?? this.status,
      lastConnected: lastConnected ?? this.lastConnected,
      lastSeen: lastSeen ?? this.lastSeen,
      lastData: lastData ?? this.lastData,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'deviceType': deviceType.name,
      'status': status.name,
      'lastConnected': lastConnected?.toIso8601String(),
      'lastSeen': lastSeen?.toIso8601String(),
      'lastData': lastData,
      'errorMessage': errorMessage,
    };
  }

  factory DeviceConnectionModel.fromJson(Map<String, dynamic> json) {
    return DeviceConnectionModel(
      deviceId: json['deviceId'] ?? '',
      deviceName: json['deviceName'] ?? '',
      deviceType: DeviceConnectionType.values.firstWhere(
        (e) => e.name == json['deviceType'],
        orElse: () => DeviceConnectionType.unknown,
      ),
      status: ConnectionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ConnectionStatus.disconnected,
      ),
      lastConnected: json['lastConnected'] != null
          ? DateTime.parse(json['lastConnected'])
          : null,
      lastSeen: json['lastSeen'] != null
          ? DateTime.parse(json['lastSeen'])
          : null,
      lastData: json['lastData'],
      errorMessage: json['errorMessage'],
    );
  }

  String get statusText {
    switch (status) {
      case ConnectionStatus.disconnected:
        return 'Desconectado';
      case ConnectionStatus.connecting:
        return 'Conectando...';
      case ConnectionStatus.connected:
        return 'Conectado';
      case ConnectionStatus.error:
        return 'Error de conexión';
    }
  }

  String get deviceTypeText {
    switch (deviceType) {
      case DeviceConnectionType.smartwatch:
        return 'Smartwatch';
      case DeviceConnectionType.phone:
        return 'Teléfono';
      case DeviceConnectionType.unknown:
        return 'Dispositivo desconocido';
    }
  }

  String get lastSeenText {
    if (lastSeen == null) return 'Nunca visto';
    
    final now = DateTime.now();
    final difference = now.difference(lastSeen!);
    
    if (difference.inSeconds < 60) {
      return 'Hace ${difference.inSeconds}s';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else {
      return 'Hace ${difference.inDays}d';
    }
  }

  bool get isConnected => status == ConnectionStatus.connected;
  bool get isConnecting => status == ConnectionStatus.connecting;
  bool get hasError => status == ConnectionStatus.error;
}

class MqttCommunicationMessage {
  final String type;
  final String deviceId;
  final String deviceName;
  final DeviceConnectionType deviceType;
  final DateTime timestamp;
  final Map<String, dynamic> data;

  MqttCommunicationMessage({
    required this.type,
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    required this.timestamp,
    required this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'deviceId': deviceId,
      'deviceName': deviceName,
      'deviceType': deviceType.name,
      'timestamp': timestamp.toIso8601String(),
      'data': data,
    };
  }

  factory MqttCommunicationMessage.fromJson(Map<String, dynamic> json) {
    return MqttCommunicationMessage(
      type: json['type'] ?? '',
      deviceId: json['deviceId'] ?? '',
      deviceName: json['deviceName'] ?? '',
      deviceType: DeviceConnectionType.values.firstWhere(
        (e) => e.name == json['deviceType'],
        orElse: () => DeviceConnectionType.unknown,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      data: json['data'] ?? {},
    );
  }

  String toJsonString() => jsonEncode(toJson());

  static MqttCommunicationMessage fromJsonString(String jsonString) {
    return MqttCommunicationMessage.fromJson(jsonDecode(jsonString));
  }
}