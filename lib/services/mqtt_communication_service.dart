import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';
import '../models/device_connection_model.dart';
import '../utils/device_utils.dart';

class MqttCommunicationService {
  static final MqttCommunicationService _instance = MqttCommunicationService._internal();
  factory MqttCommunicationService() => _instance;
  MqttCommunicationService._internal();

  // Configuración MQTT
  static const String _mqttHost = 'test.mosquitto.org';
  static const int _mqttPort = 1883;
  static const String _baseTopic = 'calorias/bidireccional';
  static const String _discoveryTopic = '$_baseTopic/discovery';
  static const String _dataTopic = '$_baseTopic/data';
  static const String _statusTopic = '$_baseTopic/status';

  MqttServerClient? _client;
  String? _deviceId;
  String? _deviceName;
  DeviceType? _deviceType;
  Timer? _heartbeatTimer;
  Timer? _discoveryTimer;

  // Streams para comunicar el estado
  final StreamController<ConnectionStatus> _connectionStatusController = 
      StreamController<ConnectionStatus>.broadcast();
  final StreamController<List<DeviceConnectionModel>> _devicesController = 
      StreamController<List<DeviceConnectionModel>>.broadcast();
  final StreamController<MqttMessage> _messageController = 
      StreamController<MqttMessage>.broadcast();

  // Estado interno
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  final Map<String, DeviceConnectionModel> _discoveredDevices = {};
  DeviceConnectionModel? _connectedDevice;

  // Getters públicos
  Stream<ConnectionStatus> get connectionStatusStream => _connectionStatusController.stream;
  Stream<List<DeviceConnectionModel>> get devicesStream => _devicesController.stream;
  Stream<MqttMessage> get messageStream => _messageController.stream;
  
  ConnectionStatus get connectionStatus => _connectionStatus;
  List<DeviceConnectionModel> get discoveredDevices => _discoveredDevices.values.toList();
  DeviceConnectionModel? get connectedDevice => _connectedDevice;
  bool get isConnected => _connectionStatus == ConnectionStatus.connected;
  String? get deviceId => _deviceId;
  String? get deviceName => _deviceName;
  DeviceType? get deviceType => _deviceType;

  Future<void> initialize() async {
    try {
      await _initializeDeviceInfo();
      print('MQTT Service initialized - Device: $_deviceName ($_deviceType)');
    } catch (e) {
      print('Error initializing MQTT service: $e');
    }
  }

  Future<void> _initializeDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    final uuid = Uuid();
    
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _deviceName = androidInfo.model;
        _deviceId = androidInfo.id;
        
        // Determinar tipo de dispositivo basado en el tamaño de pantalla
        // En una implementación real, podrías usar otras características
        _deviceType = _determineDeviceType();
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        _deviceName = iosInfo.name;
        _deviceId = iosInfo.identifierForVendor ?? uuid.v4();
        _deviceType = _determineDeviceType();
      } else {
        // Para otros platforms o emuladores
        _deviceName = Platform.operatingSystem;
        _deviceId = uuid.v4();
        _deviceType = _determineDeviceType();
      }
    } catch (e) {
      // Fallback para emuladores o casos donde no se puede obtener info
      _deviceName = 'Dispositivo ${Platform.operatingSystem}';
      _deviceId = uuid.v4();
      _deviceType = _determineDeviceType();
    }
  }

  DeviceType _determineDeviceType() {
    // En una implementación real, podrías usar características del dispositivo
    // Por ahora, usamos una lógica simple basada en el nombre o configuración
    if (_deviceName?.toLowerCase().contains('watch') == true) {
      return DeviceType.smartwatch;
    }
    
    // Para propósitos de demostración, alternamos entre tipos
    // En producción, esto debería ser más sofisticado
    return DeviceType.phone;
  }

  Future<bool> connect() async {
    if (_connectionStatus == ConnectionStatus.connecting || 
        _connectionStatus == ConnectionStatus.connected) {
      return _connectionStatus == ConnectionStatus.connected;
    }

    try {
      _updateConnectionStatus(ConnectionStatus.connecting);

      // Crear cliente MQTT
      _client = MqttServerClient(_mqttHost, _deviceId!);
      _client!.port = _mqttPort;
      _client!.keepAlivePeriod = 30;
      _client!.autoReconnect = true;
      _client!.resubscribeOnAutoReconnect = true;
      _client!.logging(on: true);

      // Configurar callbacks
      _client!.onConnected = _onConnected;
      _client!.onDisconnected = _onDisconnected;
      _client!.onSubscribed = _onSubscribed;
      _client!.onAutoReconnect = _onAutoReconnect;

      // Conectar
      final connMessage = MqttConnectMessage()
          .withClientIdentifier(_deviceId!)
          .withWillTopic('$_statusTopic/$_deviceId/offline')
          .withWillMessage('{"status": "offline", "timestamp": "${DateTime.now().toIso8601String()}"}')
          .withWillQos(MqttQos.atLeastOnce)
          .startClean()
          .withWillRetain();

      _client!.connectionMessage = connMessage;

      await _client!.connect();

      if (_client!.connectionStatus!.state == MqttConnectionState.connected) {
        _setupSubscriptions();
        _startHeartbeat();
        _startDiscovery();
        _updateConnectionStatus(ConnectionStatus.connected);
        return true;
      } else {
        _updateConnectionStatus(ConnectionStatus.error);
        return false;
      }
    } catch (e) {
      print('Error connecting to MQTT: $e');
      _updateConnectionStatus(ConnectionStatus.error);
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      _heartbeatTimer?.cancel();
      _discoveryTimer?.cancel();
      
      if (_client?.connectionStatus?.state == MqttConnectionState.connected) {
        // Enviar mensaje de desconexión
        await _publishStatus('offline');
        _client!.disconnect();
      }
      
      _updateConnectionStatus(ConnectionStatus.disconnected);
      _discoveredDevices.clear();
      _connectedDevice = null;
      _devicesController.add([]);
    } catch (e) {
      print('Error disconnecting from MQTT: $e');
    }
  }

  void _setupSubscriptions() {
    if (_client?.connectionStatus?.state != MqttConnectionState.connected) return;

    // Suscribirse a todos los topics relevantes
    _client!.subscribe(_discoveryTopic, MqttQos.atLeastOnce);
    _client!.subscribe('$_dataTopic/+', MqttQos.atLeastOnce);
    _client!.subscribe('$_statusTopic/+/+', MqttQos.atLeastOnce);

    // Configurar listener para mensajes
    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      for (final message in messages) {
        _handleIncomingMessage(message);
      }
    });
  }

  void _handleIncomingMessage(MqttReceivedMessage<MqttMessage> receivedMessage) {
    try {
      final topic = receivedMessage.topic;
      final payload = MqttPublishPayload.bytesToStringAsString(
        receivedMessage.payload.message,
      );

      print('Received message on topic: $topic');
      print('Payload: $payload');

      if (topic == _discoveryTopic) {
        _handleDiscoveryMessage(payload);
      } else if (topic.startsWith(_dataTopic)) {
        _handleDataMessage(topic, payload);
      } else if (topic.startsWith(_statusTopic)) {
        _handleStatusMessage(topic, payload);
      }
    } catch (e) {
      print('Error handling incoming message: $e');
    }
  }

  void _handleDiscoveryMessage(String payload) {
    try {
      final data = jsonDecode(payload);
      final deviceId = data['deviceId'];
      
      // No procesar nuestros propios mensajes
      if (deviceId == _deviceId) return;

      final device = DeviceConnectionModel(
        deviceId: deviceId,
        deviceName: data['deviceName'] ?? 'Dispositivo desconocido',
        deviceType: DeviceType.values.firstWhere(
          (e) => e.name == data['deviceType'],
          orElse: () => DeviceType.unknown,
        ),
        status: ConnectionStatus.disconnected,
        lastSeen: DateTime.now(),
      );

      _discoveredDevices[deviceId] = device;
      _devicesController.add(discoveredDevices);

      // Responder al discovery si somos un dispositivo compatible
      if (_shouldRespondToDiscovery(device.deviceType)) {
        _publishDiscoveryResponse();
      }
    } catch (e) {
      print('Error handling discovery message: $e');
    }
  }

  void _handleDataMessage(String topic, String payload) {
    try {
      final message = MqttMessage.fromJsonString(payload);
      
      // No procesar nuestros propios mensajes
      if (message.deviceId == _deviceId) return;

      // Actualizar último mensaje del dispositivo
      if (_discoveredDevices.containsKey(message.deviceId)) {
        _discoveredDevices[message.deviceId] = _discoveredDevices[message.deviceId]!.copyWith(
          lastSeen: DateTime.now(),
          lastData: message.data,
        );
        _devicesController.add(discoveredDevices);
      }

      _messageController.add(message);
    } catch (e) {
      print('Error handling data message: $e');
    }
  }

  void _handleStatusMessage(String topic, String payload) {
    try {
      final data = jsonDecode(payload);
      final deviceId = topic.split('/')[2]; // Extract device ID from topic
      final status = data['status'];
      
      // No procesar nuestros propios mensajes
      if (deviceId == _deviceId) return;

      if (_discoveredDevices.containsKey(deviceId)) {
        ConnectionStatus connectionStatus;
        switch (status) {
          case 'online':
            connectionStatus = ConnectionStatus.connected;
            break;
          case 'offline':
            connectionStatus = ConnectionStatus.disconnected;
            break;
          default:
            connectionStatus = ConnectionStatus.disconnected;
        }

        _discoveredDevices[deviceId] = _discoveredDevices[deviceId]!.copyWith(
          status: connectionStatus,
          lastSeen: DateTime.now(),
        );
        _devicesController.add(discoveredDevices);
      }
    } catch (e) {
      print('Error handling status message: $e');
    }
  }

  bool _shouldRespondToDiscovery(DeviceType discoveredDeviceType) {
    // Responder si somos dispositivos complementarios
    return (_deviceType == DeviceType.smartwatch && discoveredDeviceType == DeviceType.phone) ||
           (_deviceType == DeviceType.phone && discoveredDeviceType == DeviceType.smartwatch);
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
  }

  Future<void> startDiscovery() async {
    if (_client?.connectionStatus?.state != MqttConnectionState.connected) return;

    final message = {
      'deviceId': _deviceId,
      'deviceName': _deviceName,
      'deviceType': _deviceType!.name,
      'timestamp': DateTime.now().toIso8601String(),
      'discovery': true,
    };

    await _publishMessage(_discoveryTopic, jsonEncode(message));
  }

  Future<void> sendData(Map<String, dynamic> data) async {
    if (_client?.connectionStatus?.state != MqttConnectionState.connected) return;

    final message = MqttMessage(
      type: 'data',
      deviceId: _deviceId!,
      deviceName: _deviceName!,
      deviceType: _deviceType!,
      timestamp: DateTime.now(),
      data: data,
    );

    await _publishMessage('$_dataTopic/$_deviceId', message.toJsonString());
  }

  Future<void> _publishStatus(String status) async {
    final message = {
      'status': status,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await _publishMessage('$_statusTopic/$_deviceId/$status', jsonEncode(message));
  }

  Future<void> _publishMessage(String topic, String message) async {
    if (_client?.connectionStatus?.state != MqttConnectionState.connected) return;

    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      _publishStatus('online');
    });
  }

  void _startDiscovery() {
    _discoveryTimer?.cancel();
    _discoveryTimer = Timer.periodic(Duration(seconds: 60), (timer) {
      startDiscovery();
    });
    
    // Enviar discovery inicial
    startDiscovery();
  }

  void _updateConnectionStatus(ConnectionStatus status) {
    _connectionStatus = status;
    _connectionStatusController.add(status);
  }

  // Callbacks MQTT
  void _onConnected() {
    print('MQTT Connected');
    _publishStatus('online');
  }

  void _onDisconnected() {
    print('MQTT Disconnected');
    _updateConnectionStatus(ConnectionStatus.disconnected);
  }

  void _onSubscribed(String topic) {
    print('Subscribed to topic: $topic');
  }

  void _onAutoReconnect() {
    print('MQTT Auto reconnecting...');
    _updateConnectionStatus(ConnectionStatus.connecting);
  }

  void dispose() {
    _heartbeatTimer?.cancel();
    _discoveryTimer?.cancel();
    _connectionStatusController.close();
    _devicesController.close();
    _messageController.close();
    disconnect();
  }
}