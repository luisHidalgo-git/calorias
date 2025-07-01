class BluetoothDeviceModel {
  final String name;
  final String address;
  final bool isConnected;
  final int signalStrength;
  final DateTime? lastConnected;
  final String deviceType; // 'phone', 'smartwatch', 'unknown'

  BluetoothDeviceModel({
    required this.name,
    required this.address,
    this.isConnected = false,
    this.signalStrength = 0,
    this.lastConnected,
    this.deviceType = 'unknown',
  });

  BluetoothDeviceModel copyWith({
    String? name,
    String? address,
    bool? isConnected,
    int? signalStrength,
    DateTime? lastConnected,
    String? deviceType,
  }) {
    return BluetoothDeviceModel(
      name: name ?? this.name,
      address: address ?? this.address,
      isConnected: isConnected ?? this.isConnected,
      signalStrength: signalStrength ?? this.signalStrength,
      lastConnected: lastConnected ?? this.lastConnected,
      deviceType: deviceType ?? this.deviceType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'isConnected': isConnected,
      'signalStrength': signalStrength,
      'lastConnected': lastConnected?.toIso8601String(),
      'deviceType': deviceType,
    };
  }

  factory BluetoothDeviceModel.fromJson(Map<String, dynamic> json) {
    return BluetoothDeviceModel(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      isConnected: json['isConnected'] ?? false,
      signalStrength: json['signalStrength'] ?? 0,
      lastConnected: json['lastConnected'] != null 
          ? DateTime.parse(json['lastConnected'])
          : null,
      deviceType: json['deviceType'] ?? 'unknown',
    );
  }

  String get displayName {
    if (name.isNotEmpty) return name;
    return 'Dispositivo ${address.substring(address.length - 5)}';
  }

  String get connectionStatus {
    if (isConnected) return 'Conectado';
    if (lastConnected != null) {
      final diff = DateTime.now().difference(lastConnected!);
      if (diff.inMinutes < 60) {
        return 'Desconectado hace ${diff.inMinutes}m';
      } else if (diff.inHours < 24) {
        return 'Desconectado hace ${diff.inHours}h';
      } else {
        return 'Desconectado hace ${diff.inDays}d';
      }
    }
    return 'Nunca conectado';
  }
}