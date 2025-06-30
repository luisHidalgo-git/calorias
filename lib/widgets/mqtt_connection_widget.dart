import 'package:flutter/material.dart';
import 'dart:async';
import '../services/mqtt_communication_service.dart';
import '../models/device_connection_model.dart';
import '../utils/device_utils.dart' as DeviceUtils;
import 'adaptive_text.dart';

class MqttConnectionWidget extends StatefulWidget {
  final bool isCompact;

  const MqttConnectionWidget({
    super.key,
    this.isCompact = false,
  });

  @override
  _MqttConnectionWidgetState createState() => _MqttConnectionWidgetState();
}

class _MqttConnectionWidgetState extends State<MqttConnectionWidget>
    with TickerProviderStateMixin {
  final MqttCommunicationService _mqttService = MqttCommunicationService();
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  StreamSubscription? _connectionSubscription;
  StreamSubscription? _devicesSubscription;
  
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  List<DeviceConnectionModel> _discoveredDevices = [];

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _initializeMqtt();
    _setupStreams();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _connectionSubscription?.cancel();
    _devicesSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeMqtt() async {
    await _mqttService.initialize();
  }

  void _setupStreams() {
    _connectionSubscription = _mqttService.connectionStatusStream.listen((status) {
      if (mounted) {
        setState(() {
          _connectionStatus = status;
        });
        _updateAnimations();
      }
    });

    _devicesSubscription = _mqttService.devicesStream.listen((devices) {
      if (mounted) {
        setState(() {
          _discoveredDevices = devices;
        });
      }
    });
  }

  void _updateAnimations() {
    switch (_connectionStatus) {
      case ConnectionStatus.connected:
        _pulseController.repeat(reverse: true);
        _rotationController.stop();
        break;
      case ConnectionStatus.connecting:
        _pulseController.stop();
        _rotationController.repeat();
        break;
      case ConnectionStatus.disconnected:
      case ConnectionStatus.error:
        _pulseController.stop();
        _rotationController.stop();
        break;
    }
  }

  Future<void> _toggleConnection() async {
    if (_connectionStatus == ConnectionStatus.connected) {
      await _mqttService.disconnect();
    } else if (_connectionStatus == ConnectionStatus.disconnected || 
               _connectionStatus == ConnectionStatus.error) {
      await _mqttService.connect();
    }
  }

  Color _getStatusColor() {
    switch (_connectionStatus) {
      case ConnectionStatus.connected:
        return Colors.green;
      case ConnectionStatus.connecting:
        return Colors.orange;
      case ConnectionStatus.disconnected:
        return Colors.grey;
      case ConnectionStatus.error:
        return Colors.red;
    }
  }

  IconData _getStatusIcon() {
    switch (_connectionStatus) {
      case ConnectionStatus.connected:
        return Icons.wifi;
      case ConnectionStatus.connecting:
        return Icons.wifi_find;
      case ConnectionStatus.disconnected:
        return Icons.wifi_off;
      case ConnectionStatus.error:
        return Icons.wifi_off;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final deviceType = DeviceUtils.DeviceUtils.getDeviceType(screenSize.width, screenSize.height);
    final isWearable = deviceType == DeviceUtils.DeviceType.wearable;

    if (widget.isCompact) {
      return _buildCompactWidget(screenSize, isWearable);
    } else {
      return _buildFullWidget(screenSize, isWearable);
    }
  }

  Widget _buildCompactWidget(Size screenSize, bool isWearable) {
    return GestureDetector(
      onTap: _toggleConnection,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseAnimation, _rotationAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _connectionStatus == ConnectionStatus.connected 
                ? _pulseAnimation.value 
                : 1.0,
            child: Transform.rotate(
              angle: _connectionStatus == ConnectionStatus.connecting 
                  ? _rotationAnimation.value * 2 * 3.14159 
                  : 0.0,
              child: Container(
                padding: EdgeInsets.all(isWearable ? 8 : 12),
                decoration: BoxDecoration(
                  color: _getStatusColor().withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _getStatusColor().withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: _connectionStatus == ConnectionStatus.connected
                      ? [
                          BoxShadow(
                            color: _getStatusColor().withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  _getStatusIcon(),
                  color: _getStatusColor(),
                  size: isWearable ? 16 : 20,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFullWidget(Size screenSize, bool isWearable) {
    return Container(
      padding: EdgeInsets.all(isWearable ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900.withOpacity(0.3),
        borderRadius: BorderRadius.circular(isWearable ? 12 : 16),
        border: Border.all(
          color: _getStatusColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildConnectionHeader(screenSize, isWearable),
          if (!isWearable) ...[
            SizedBox(height: 16),
            _buildDeviceInfo(screenSize),
            if (_discoveredDevices.isNotEmpty) ...[
              SizedBox(height: 16),
              _buildDiscoveredDevices(screenSize),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildConnectionHeader(Size screenSize, bool isWearable) {
    return Row(
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([_pulseAnimation, _rotationAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _connectionStatus == ConnectionStatus.connected 
                  ? _pulseAnimation.value 
                  : 1.0,
              child: Transform.rotate(
                angle: _connectionStatus == ConnectionStatus.connecting 
                    ? _rotationAnimation.value * 2 * 3.14159 
                    : 0.0,
                child: Container(
                  padding: EdgeInsets.all(isWearable ? 8 : 12),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _getStatusColor().withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    _getStatusIcon(),
                    color: _getStatusColor(),
                    size: isWearable ? 16 : 20,
                  ),
                ),
              ),
            );
          },
        ),
        SizedBox(width: isWearable ? 8 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdaptiveText(
                'Conexión MQTT',
                fontSize: screenSize.width * (isWearable ? 0.035 : 0.04),
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              AdaptiveText(
                _connectionStatus.name.toUpperCase(),
                fontSize: screenSize.width * (isWearable ? 0.025 : 0.03),
                color: _getStatusColor(),
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _connectionStatus != ConnectionStatus.connecting 
                ? _toggleConnection 
                : null,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isWearable ? 8 : 12,
                vertical: isWearable ? 4 : 6,
              ),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getStatusColor().withOpacity(0.3),
                ),
              ),
              child: AdaptiveText(
                _connectionStatus == ConnectionStatus.connected 
                    ? 'Desconectar'
                    : 'Conectar',
                fontSize: screenSize.width * (isWearable ? 0.025 : 0.03),
                color: _getStatusColor(),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceInfo(Size screenSize) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade800.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdaptiveText(
            'Información del Dispositivo',
            fontSize: screenSize.width * 0.035,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          SizedBox(height: 8),
          _buildInfoRow('ID:', _mqttService.deviceId ?? 'No disponible', screenSize),
          _buildInfoRow('Nombre:', _mqttService.deviceName ?? 'No disponible', screenSize),
          _buildInfoRow('Tipo:', _mqttService.deviceType?.name ?? 'No disponible', screenSize),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Size screenSize) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          AdaptiveText(
            label,
            fontSize: screenSize.width * 0.03,
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w500,
          ),
          SizedBox(width: 8),
          Expanded(
            child: AdaptiveText(
              value,
              fontSize: screenSize.width * 0.03,
              color: Colors.white,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoveredDevices(Size screenSize) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade800.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdaptiveText(
            'Dispositivos Descubiertos (${_discoveredDevices.length})',
            fontSize: screenSize.width * 0.035,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          SizedBox(height: 8),
          ..._discoveredDevices.map((device) => _buildDeviceItem(device, screenSize)),
        ],
      ),
    );
  }

  Widget _buildDeviceItem(DeviceConnectionModel device, Size screenSize) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: device.isConnected 
            ? Colors.green.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: device.isConnected 
              ? Colors.green.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            device.deviceType == DeviceConnectionType.smartwatch 
                ? Icons.watch 
                : Icons.phone_android,
            color: device.isConnected ? Colors.green : Colors.grey,
            size: 16,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdaptiveText(
                  device.deviceName,
                  fontSize: screenSize.width * 0.03,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  overflow: TextOverflow.ellipsis,
                ),
                AdaptiveText(
                  '${device.deviceTypeText} • ${device.lastSeenText}',
                  fontSize: screenSize.width * 0.025,
                  color: Colors.grey.shade400,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: device.isConnected 
                  ? Colors.green.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: AdaptiveText(
              device.statusText,
              fontSize: screenSize.width * 0.025,
              color: device.isConnected ? Colors.green : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}