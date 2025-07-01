import 'package:flutter/material.dart';
import '../models/device_connection_model.dart';
import '../utils/device_utils.dart' as DeviceUtils;
import 'adaptive_text.dart';

class ActivityMessageModal extends StatefulWidget {
  final ActivityMessage activityMessage;

  const ActivityMessageModal({
    super.key,
    required this.activityMessage,
  });

  @override
  _ActivityMessageModalState createState() => _ActivityMessageModalState();
}

class _ActivityMessageModalState extends State<ActivityMessageModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();

    // Auto-dismiss después de 3 segundos
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final deviceType = DeviceUtils.DeviceUtils.getDeviceType(
      screenSize.width,
      screenSize.height,
    );
    final isWearable = deviceType == DeviceUtils.DeviceType.wearable;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: screenSize.width * (isWearable ? 0.08 : 0.1),
                ),
                padding: EdgeInsets.all(
                  screenSize.width * (isWearable ? 0.05 : 0.06),
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(isWearable ? 16 : 20),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icono del dispositivo emisor
                    Container(
                      padding: EdgeInsets.all(
                        screenSize.width * (isWearable ? 0.03 : 0.04),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getDeviceIcon(),
                        color: Colors.blue.shade400,
                        size: screenSize.width * (isWearable ? 0.06 : 0.08),
                      ),
                    ),

                    SizedBox(height: screenSize.height * 0.02),

                    // Información del dispositivo emisor
                    AdaptiveText(
                      'Mensaje de ${widget.activityMessage.senderDeviceName}',
                      fontSize: screenSize.width * (isWearable ? 0.04 : 0.05),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: screenSize.height * 0.01),

                    AdaptiveText(
                      widget.activityMessage.senderDeviceType.name.toUpperCase(),
                      fontSize: screenSize.width * (isWearable ? 0.025 : 0.03),
                      color: Colors.blue.shade400,
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: screenSize.height * 0.02),

                    // Mensaje de actividad
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenSize.width * (isWearable ? 0.03 : 0.04),
                        vertical: screenSize.height * (isWearable ? 0.01 : 0.015),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.3),
                        ),
                      ),
                      child: AdaptiveText(
                        widget.activityMessage.activityDescription,
                        fontSize: screenSize.width * (isWearable ? 0.035 : 0.045),
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade300,
                        textAlign: TextAlign.center,
                      ),
                    ),

                    SizedBox(height: screenSize.height * 0.015),

                    // Datos de actividad
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildDataChip(
                          icon: Icons.local_fire_department,
                          value: '${widget.activityMessage.calories.toStringAsFixed(0)}',
                          unit: 'cal',
                          color: Colors.orange,
                          screenSize: screenSize,
                          isWearable: isWearable,
                        ),
                        _buildDataChip(
                          icon: Icons.favorite,
                          value: '${widget.activityMessage.heartRate}',
                          unit: 'BPM',
                          color: Colors.red,
                          screenSize: screenSize,
                          isWearable: isWearable,
                        ),
                      ],
                    ),

                    SizedBox(height: screenSize.height * 0.015),

                    // Timestamp
                    AdaptiveText(
                      _formatTimestamp(widget.activityMessage.timestamp),
                      fontSize: screenSize.width * (isWearable ? 0.025 : 0.03),
                      color: Colors.grey.shade400,
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: screenSize.height * 0.02),

                    // Botón de cerrar
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: AdaptiveText(
                        'Cerrar',
                        fontSize: screenSize.width * (isWearable ? 0.03 : 0.035),
                        color: Colors.blue.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDataChip({
    required IconData icon,
    required String value,
    required String unit,
    required Color color,
    required Size screenSize,
    required bool isWearable,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.width * (isWearable ? 0.025 : 0.03),
        vertical: screenSize.height * (isWearable ? 0.008 : 0.01),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: screenSize.width * (isWearable ? 0.03 : 0.04),
          ),
          SizedBox(width: 4),
          AdaptiveText(
            value,
            fontSize: screenSize.width * (isWearable ? 0.03 : 0.035),
            fontWeight: FontWeight.bold,
            color: color,
          ),
          SizedBox(width: 2),
          AdaptiveText(
            unit,
            fontSize: screenSize.width * (isWearable ? 0.025 : 0.03),
            color: color.withOpacity(0.8),
          ),
        ],
      ),
    );
  }

  IconData _getDeviceIcon() {
    switch (widget.activityMessage.senderDeviceType) {
      case DeviceConnectionType.smartwatch:
        return Icons.watch;
      case DeviceConnectionType.phone:
        return Icons.phone_android;
      case DeviceConnectionType.unknown:
      default:
        return Icons.device_unknown;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Hace ${difference.inSeconds} segundos';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} minutos';
    } else {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}