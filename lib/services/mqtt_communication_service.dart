import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';
import '../models/device_connection_model.dart';
import '../utils/device_utils.dart' as DeviceUtils;

class MqttCommunicationService {
  static final MqttCommunicationService _instance =
      MqttCommunicationService._internal();
  factory MqttCommunicationService() => _instance;
  MqttCommunicationService._internal();

  // Configuración MQTT - Usando broker público confiable
  static const String _mqttHost = 'broker.hivemq.com';
  static const int _mqttPort = 1883;
  static const String _baseTopic = 'smartwatch/calories/v1';
  static const String _discoveryTopic = '$_baseTopic/discovery';
  static const String _dataTopic = '$_baseTopic/data';
  static const String _statusTopic = '$_baseTopic/status';
  static const String _heartbeatTopic = '$_baseTopic/heartbeat';
  static const String _activityMessageTopic = '$_baseTopic/activity';

  MqttServerClient? _client;
  String? _deviceId;
  String? _deviceName;
  DeviceConnectionType? _deviceType;
  Timer? _heartbeatTimer;
  Timer? _discoveryTimer;
  Timer? _cleanupTimer;
  Timer? _reconnectTimer;

  // Streams para comunicar el estado
  final StreamController<ConnectionStatus> _connectionStatusController =
      StreamController<ConnectionStatus>.broadcast();
  final StreamController<List<DeviceConnectionModel>> _devicesController =
      StreamController<List<DeviceConnectionModel>>.broadcast();
  final StreamController<MqttCommunicationMessage> _messageController =
      StreamController<MqttCommunicationMessage>.broadcast();
  final StreamController<ActivityMessage> _activityMessageController =
      StreamController<ActivityMessage>.broadcast();

  // Estado interno
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  final Map<String, DeviceConnectionModel> _discoveredDevices = {};
  final Map<String, DateTime> _connectedDevices = {};
  DeviceConnectionModel? _connectedDevice;
  bool _isReconnecting = false;

  // Getters públicos
  Stream<ConnectionStatus> get connectionStatusStream =>
      _connectionStatusController.stream;
  Stream<List<DeviceConnectionModel>> get devicesStream =>
      _devicesController.stream;
  Stream<MqttCommunicationMessage> get messageStream =>
      _messageController.stream;
  Stream<ActivityMessage> get activityMessageStream =>
      _activityMessageController.stream;

  ConnectionStatus get connectionStatus => _connectionStatus;
  List<DeviceConnectionModel> get discoveredDevices =>
      _discoveredDevices.values.toList();
  DeviceConnectionModel? get connectedDevice => _connectedDevice;
  bool get isConnected => _connectionStatus == ConnectionStatus.connected;
  String? get deviceId => _deviceId;
  String? get deviceName => _deviceName;
  DeviceConnectionType? get deviceType => _deviceType;

  List<DeviceConnectionModel> get connectedDevices {
    final now = DateTime.now();
    final activeDevices = <DeviceConnectionModel>[];

    _connectedDevices.removeWhere((deviceId, lastSeen) {
      return now.difference(lastSeen).inMinutes > 2;
    });

    for (final deviceId in _connectedDevices.keys) {
      if (_discoveredDevices.containsKey(deviceId)) {
        final device = _discoveredDevices[deviceId]!.copyWith(
          status: ConnectionStatus.connected,
          lastSeen: _connectedDevices[deviceId],
        );
        activeDevices.add(device);
      }
    }

    return activeDevices;
  }

  Future<void> initialize() async {
    try {
      await _initializeDeviceInfo();
      _startCleanupTimer();
      print('🚀 MQTT Service initialized - Device: $_deviceName ($_deviceType)');

      // Auto-conectar al inicializar
      await connect();
    } catch (e) {
      print('❌ Error initializing MQTT service: $e');
    }
  }

  Future<void> _initializeDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    final uuid = Uuid();

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _deviceName = '${androidInfo.brand} ${androidInfo.model}';
        _deviceId = androidInfo.id;
        _deviceType = _determineDeviceType();
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _deviceName = '${iosInfo.name} (${iosInfo.model})';
        _deviceId = iosInfo.identifierForVendor ?? uuid.v4();
        _deviceType = _determineDeviceType();
      } else {
        _deviceName = 'Dispositivo ${Platform.operatingSystem}';
        _deviceId = uuid.v4();
        _deviceType = _determineDeviceType();
      }
    } catch (e) {
      _deviceName = 'Dispositivo ${Platform.operatingSystem}';
      _deviceId = uuid.v4();
      _deviceType = _determineDeviceType();
    }

    print('📱 Device initialized: $_deviceName (ID: $_deviceId, Type: $_deviceType)');
  }

  DeviceConnectionType _determineDeviceType() {
    if (_deviceName?.toLowerCase().contains('watch') == true) {
      return DeviceConnectionType.smartwatch;
    }
    return DeviceConnectionType.phone;
  }

  Future<bool> connect() async {
    if (_connectionStatus == ConnectionStatus.connecting ||
        _connectionStatus == ConnectionStatus.connected) {
      return _connectionStatus == ConnectionStatus.connected;
    }

    try {
      _updateConnectionStatus(ConnectionStatus.connecting);
      print('🔌 Connecting to MQTT broker: $_mqttHost:$_mqttPort');

      // Crear cliente con ID único más corto
      final clientId = 'sw_${_deviceId?.substring(0, 8) ?? 'unknown'}_${DateTime.now().millisecondsSinceEpoch % 10000}';
      _client = MqttServerClient(_mqttHost, clientId);
      _client!.port = _mqttPort;
      _client!.keepAlivePeriod = 30;
      _client!.autoReconnect = true;
      _client!.resubscribeOnAutoReconnect = true;
      _client!.logging(on: false); // Deshabilitar logging para reducir ruido

      // Configurar callbacks
      _client!.onConnected = _onConnected;
      _client!.onDisconnected = _onDisconnected;
      _client!.onSubscribed = _onSubscribed;
      _client!.onAutoReconnect = _onAutoReconnect;
      _client!.onAutoReconnected = _onAutoReconnected;

      // Mensaje de última voluntad
      final connMessage = MqttConnectMessage()
          .withClientIdentifier(clientId)
          .withWillTopic('$_statusTopic/$_deviceId')
          .withWillMessage(
            jsonEncode({
              'status': 'offline',
              'deviceId': _deviceId,
              'deviceName': _deviceName,
              'timestamp': DateTime.now().toIso8601String(),
            }),
          )
          .withWillQos(MqttQos.atLeastOnce)
          .withWillRetain()
          .startClean(); // Limpiar sesión anterior

      _client!.connectionMessage = connMessage;

      print('⏳ Attempting MQTT connection...');
      await _client!.connect();

      if (_client!.connectionStatus!.state == MqttConnectionState.connected) {
        print('✅ MQTT Connected successfully!');
        _setupSubscriptions();
        _startHeartbeat();
        _startDiscovery();
        _updateConnectionStatus(ConnectionStatus.connected);
        _isReconnecting = false;
        return true;
      } else {
        print('❌ MQTT Connection failed: ${_client!.connectionStatus}');
        _updateConnectionStatus(ConnectionStatus.error);
        return false;
      }
    } catch (e) {
      print('❌ Error connecting to MQTT: $e');
      _updateConnectionStatus(ConnectionStatus.error);
      _scheduleReconnect();
      return false;
    }
  }

  void _scheduleReconnect() {
    if (_isReconnecting) return;

    _isReconnecting = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: 10), () async {
      if (_connectionStatus != ConnectionStatus.connected) {
        print('🔄 Attempting to reconnect...');
        await connect();
      }
    });
  }

  Future<void> disconnect() async {
    try {
      _heartbeatTimer?.cancel();
      _discoveryTimer?.cancel();
      _reconnectTimer?.cancel();

      if (_client?.connectionStatus?.state == MqttConnectionState.connected) {
        await _publishStatus('offline');
        _client!.disconnect();
      }

      _updateConnectionStatus(ConnectionStatus.disconnected);
      _discoveredDevices.clear();
      _connectedDevices.clear();
      _connectedDevice = null;
      _devicesController.add([]);
      _isReconnecting = false;
    } catch (e) {
      print('❌ Error disconnecting from MQTT: $e');
    }
  }

  void _setupSubscriptions() {
    if (_client?.connectionStatus?.state != MqttConnectionState.connected)
      return;

    print('📡 Setting up MQTT subscriptions...');

    try {
      // Suscribirse a todos los topics relevantes
      _client!.subscribe(_discoveryTopic, MqttQos.atLeastOnce);
      _client!.subscribe('$_dataTopic/+', MqttQos.atLeastOnce);
      _client!.subscribe('$_statusTopic/+', MqttQos.atLeastOnce);
      _client!.subscribe('$_heartbeatTopic/+', MqttQos.atLeastOnce);
      _client!.subscribe(_activityMessageTopic, MqttQos.atLeastOnce);

      // Configurar listener para mensajes entrantes
      _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
        for (final message in messages) {
          _handleIncomingMessage(message);
        }
      });

      print('✅ MQTT subscriptions completed');
    } catch (e) {
      print('❌ Error setting up subscriptions: $e');
    }
  }

  void _handleIncomingMessage(
    MqttReceivedMessage<MqttMessage> receivedMessage,
  ) {
    try {
      final topic = receivedMessage.topic;

      String payload = '';
      if (receivedMessage.payload is MqttPublishMessage) {
        final publishMessage = receivedMessage.payload as MqttPublishMessage;
        payload = MqttPublishPayload.bytesToStringAsString(
          publishMessage.payload.message,
        );
      }

      print('📨 Received message on topic: $topic');
      print('📨 Payload: $payload');

      if (topic == _discoveryTopic) {
        _handleDiscoveryMessage(payload);
      } else if (topic.startsWith(_dataTopic)) {
        _handleDataMessage(topic, payload);
      } else if (topic.startsWith(_statusTopic)) {
        _handleStatusMessage(topic, payload);
      } else if (topic.startsWith(_heartbeatTopic)) {
        _handleHeartbeatMessage(topic, payload);
      } else if (topic == _activityMessageTopic) {
        _handleActivityMessage(payload);
      }
    } catch (e) {
      print('❌ Error handling incoming message: $e');
    }
  }

  void _handleDiscoveryMessage(String payload) {
    try {
      final data = jsonDecode(payload);
      final deviceId = data['deviceId'];

      if (deviceId == _deviceId) return; // Ignorar nuestros propios mensajes

      print('🔍 Discovery message from: $deviceId');

      final device = DeviceConnectionModel(
        deviceId: deviceId,
        deviceName: data['deviceName'] ?? 'Dispositivo desconocido',
        deviceType: DeviceConnectionType.values.firstWhere(
          (e) => e.name == data['deviceType'],
          orElse: () => DeviceConnectionType.unknown,
        ),
        status: ConnectionStatus.disconnected,
        lastSeen: DateTime.now(),
      );

      _discoveredDevices[deviceId] = device;
      _devicesController.add(discoveredDevices);

      // Responder al discovery si es apropiado
      if (_shouldRespondToDiscovery(device.deviceType)) {
        _publishDiscoveryResponse();
      }
    } catch (e) {
      print('❌ Error handling discovery message: $e');
    }
  }

  void _handleDataMessage(String topic, String payload) {
    try {
      final message = MqttCommunicationMessage.fromJsonString(payload);

      if (message.deviceId == _deviceId)
        return; // Ignorar nuestros propios mensajes

      print('📊 Data message from: ${message.deviceId}');

      if (_discoveredDevices.containsKey(message.deviceId)) {
        _discoveredDevices[message.deviceId] =
            _discoveredDevices[message.deviceId]!.copyWith(
              lastSeen: DateTime.now(),
              lastData: message.data,
            );
        _devicesController.add(discoveredDevices);
      }

      _connectedDevices[message.deviceId] = DateTime.now();
      _messageController.add(message);
    } catch (e) {
      print('❌ Error handling data message: $e');
    }
  }

  void _handleStatusMessage(String topic, String payload) {
    try {
      final data = jsonDecode(payload);
      final deviceId = topic.split('/').last;
      final status = data['status'];

      if (deviceId == _deviceId) return; // Ignorar nuestros propios mensajes

      print('📡 Status message from $deviceId: $status');

      if (_discoveredDevices.containsKey(deviceId)) {
        ConnectionStatus connectionStatus;
        switch (status) {
          case 'online':
            connectionStatus = ConnectionStatus.connected;
            _connectedDevices[deviceId] = DateTime.now();
            break;
          case 'offline':
            connectionStatus = ConnectionStatus.disconnected;
            _connectedDevices.remove(deviceId);
            break;
          default:
            connectionStatus = ConnectionStatus.disconnected;
            _connectedDevices.remove(deviceId);
        }

        _discoveredDevices[deviceId] = _discoveredDevices[deviceId]!.copyWith(
          status: connectionStatus,
          lastSeen: DateTime.now(),
        );
        _devicesController.add(discoveredDevices);
      }
    } catch (e) {
      print('❌ Error handling status message: $e');
    }
  }

  void _handleHeartbeatMessage(String topic, String payload) {
    try {
      final data = jsonDecode(payload);
      final deviceId = topic.split('/').last;

      if (deviceId == _deviceId) return; // Ignorar nuestros propios mensajes

      print('💓 Heartbeat from: $deviceId');

      _connectedDevices[deviceId] = DateTime.now();

      if (!_discoveredDevices.containsKey(deviceId)) {
        final device = DeviceConnectionModel(
          deviceId: deviceId,
          deviceName: data['deviceName'] ?? 'Dispositivo desconocido',
          deviceType: DeviceConnectionType.values.firstWhere(
            (e) => e.name == data['deviceType'],
            orElse: () => DeviceConnectionType.unknown,
          ),
          status: ConnectionStatus.connected,
          lastSeen: DateTime.now(),
        );
        _discoveredDevices[deviceId] = device;
      } else {
        _discoveredDevices[deviceId] = _discoveredDevices[deviceId]!.copyWith(
          status: ConnectionStatus.connected,
          lastSeen: DateTime.now(),
        );
      }

      _devicesController.add(discoveredDevices);
    } catch (e) {
      print('❌ Error handling heartbeat message: $e');
    }
  }

  void _handleActivityMessage(String payload) {
    try {
      final activityMessage = ActivityMessage.fromJsonString(payload);

      // No procesar nuestros propios mensajes
      if (activityMessage.senderDeviceId == _deviceId) return;

      print(
        '🏃 Activity message from ${activityMessage.senderDeviceName}: ${activityMessage.activityDescription}',
      );

      // Enviar al stream para que la UI lo maneje
      _activityMessageController.add(activityMessage);
    } catch (e) {
      print('❌ Error handling activity message: $e');
    }
  }

  bool _shouldRespondToDiscovery(DeviceConnectionType discoveredDeviceType) {
    return (_deviceType == DeviceConnectionType.smartwatch &&
            discoveredDeviceType == DeviceConnectionType.phone) ||
        (_deviceType == DeviceConnectionType.phone &&
            discoveredDeviceType == DeviceConnectionType.smartwatch);
  }

  Future<void> _publishDiscoveryResponse() async {
    final message = {
      'deviceId': _deviceId,
      'deviceName': _deviceName,
      'deviceType': _deviceType!.name,
      'timestamp': DateTime.now().toIso8601String(),
      'response': true,
    };

    await _publishMessage(_discoveryTopic, jsonEncode(message));
    print('📤 Discovery response sent');
  }

  Future<void> startDiscovery() async {
    if (_client?.connectionStatus?.state != MqttConnectionState.connected)
      return;

    final message = {
      'deviceId': _deviceId,
      'deviceName': _deviceName,
      'deviceType': _deviceType!.name,
      'timestamp': DateTime.now().toIso8601String(),
      'discovery': true,
    };

    await _publishMessage(_discoveryTopic, jsonEncode(message));
    print('📤 Discovery message sent');
  }

  Future<void> sendData(Map<String, dynamic> data) async {
    if (_client?.connectionStatus?.state != MqttConnectionState.connected) {
      print('❌ Cannot send data: MQTT not connected');
      return;
    }

    final message = MqttCommunicationMessage(
      type: 'data',
      deviceId: _deviceId!,
      deviceName: _deviceName!,
      deviceType: _deviceType!,
      timestamp: DateTime.now(),
      data: data,
    );

    await _publishMessage('$_dataTopic/$_deviceId', message.toJsonString());
    print('📤 Data sent: ${data.keys.join(', ')}');
  }

  Future<void> sendActivityMessage({
    required String activityDescription,
    required double calories,
    required int heartRate,
  }) async {
    if (_client?.connectionStatus?.state != MqttConnectionState.connected) {
      print('❌ Cannot send activity message: MQTT not connected');
      throw Exception('MQTT not connected');
    }

    final uuid = Uuid();
    final activityMessage = ActivityMessage(
      messageId: uuid.v4(),
      senderDeviceId: _deviceId!,
      senderDeviceName: _deviceName!,
      senderDeviceType: _deviceType!,
      activityDescription: activityDescription,
      calories: calories,
      heartRate: heartRate,
      timestamp: DateTime.now(),
    );

    await _publishMessage(
      _activityMessageTopic,
      activityMessage.toJsonString(),
    );
    print(
      '📤 Activity message sent: $activityDescription (${calories.toStringAsFixed(0)} cal, ${heartRate} BPM)',
    );
  }

  Future<void> _publishStatus(String status) async {
    final message = {
      'status': status,
      'deviceId': _deviceId,
      'deviceName': _deviceName,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await _publishMessage('$_statusTopic/$_deviceId', jsonEncode(message));
    print('📤 Status sent: $status');
  }

  Future<void> _publishHeartbeat() async {
    final message = {
      'deviceId': _deviceId,
      'deviceName': _deviceName,
      'deviceType': _deviceType!.name,
      'timestamp': DateTime.now().toIso8601String(),
      'status': 'alive',
    };

    await _publishMessage('$_heartbeatTopic/$_deviceId', jsonEncode(message));
    print('📤 Heartbeat sent');
  }

  Future<void> _publishMessage(String topic, String message) async {
    if (_client?.connectionStatus?.state != MqttConnectionState.connected) {
      print('❌ Cannot publish to $topic: MQTT not connected');
      return;
    }

    try {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      
      print('📤 Publishing to $topic: ${message.substring(0, message.length > 100 ? 100 : message.length)}${message.length > 100 ? '...' : ''}');
      
      _client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
      
      // Pequeña pausa para asegurar que el mensaje se envíe
      await Future.delayed(Duration(milliseconds: 100));
      
      print('✅ Message published successfully to $topic');
    } catch (e) {
      print('❌ Error publishing message to $topic: $e');
      rethrow;
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      _publishStatus('online');
      _publishHeartbeat();
    });
    
    // Enviar heartbeat inicial inmediatamente
    Future.delayed(Duration(seconds: 1), () {
      _publishStatus('online');
      _publishHeartbeat();
    });
  }

  void _startDiscovery() {
    _discoveryTimer?.cancel();
    _discoveryTimer = Timer.periodic(Duration(seconds: 45), (timer) {
      startDiscovery();
    });

    // Enviar discovery inicial inmediatamente
    Future.delayed(Duration(seconds: 3), () {
      startDiscovery();
    });
  }

  void _startCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      final now = DateTime.now();
      final devicesToRemove = <String>[];

      _connectedDevices.forEach((deviceId, lastSeen) {
        if (now.difference(lastSeen).inMinutes > 3) {
          devicesToRemove.add(deviceId);
        }
      });

      for (final deviceId in devicesToRemove) {
        _connectedDevices.remove(deviceId);
        if (_discoveredDevices.containsKey(deviceId)) {
          _discoveredDevices[deviceId] = _discoveredDevices[deviceId]!.copyWith(
            status: ConnectionStatus.disconnected,
          );
        }
      }

      if (devicesToRemove.isNotEmpty) {
        _devicesController.add(discoveredDevices);
        print('🧹 Cleaned up ${devicesToRemove.length} inactive devices');
      }
    });
  }

  void _updateConnectionStatus(ConnectionStatus status) {
    _connectionStatus = status;
    _connectionStatusController.add(status);
    print('🔄 Connection status: ${status.name}');
  }

  void _onConnected() {
    print('✅ MQTT Connected successfully');
    _publishStatus('online');
    _publishHeartbeat();
  }

  void _onDisconnected() {
    print('❌ MQTT Disconnected');
    _updateConnectionStatus(ConnectionStatus.disconnected);
    _connectedDevices.clear();

    // Intentar reconectar si no fue desconexión intencional
    if (!_isReconnecting) {
      _scheduleReconnect();
    }
  }

  void _onSubscribed(String topic) {
    print('✅ Subscribed to topic: $topic');
  }

  void _onAutoReconnect() {
    print('🔄 MQTT Auto reconnecting...');
    _updateConnectionStatus(ConnectionStatus.connecting);
  }

  void _onAutoReconnected() {
    print('✅ MQTT Auto reconnected successfully');
    _updateConnectionStatus(ConnectionStatus.connected);
    _setupSubscriptions();
    _startHeartbeat();
    _startDiscovery();
  }

  void dispose() {
    _heartbeatTimer?.cancel();
    _discoveryTimer?.cancel();
    _cleanupTimer?.cancel();
    _reconnectTimer?.cancel();
    _connectionStatusController.close();
    _devicesController.close();
    _messageController.close();
    _activityMessageController.close();
    disconnect();
  }
}