import 'package:flutter/material.dart';
import '../../models/fitness_data.dart';
import '../../models/daily_calories.dart';
import '../../utils/device_utils.dart';
import '../../utils/color_utils.dart';
import '../progress_ring.dart';
import '../adaptive_text.dart';
import '../mqtt_connection_widget.dart';
import 'watch_face_animations.dart';

class PhoneLayout extends StatelessWidget {
  final Size screenSize;
  final LayoutConfig layoutConfig;
  final FitnessData fitnessData;
  final List<CalorieEntry> notifications;
  final WatchFaceAnimations animations;
  final Color accentColor;
  final Color progressColor;
  final VoidCallback onNavigateToTable;
  final VoidCallback onNavigateToSettings;
  final VoidCallback onShowNotifications;
  final VoidCallback onShowCaloriesAdjustment;
  final VoidCallback onShowHeartRateAdjustment;
  final VoidCallback? onSendActivityMessage; // Nuevo callback

  const PhoneLayout({
    super.key,
    required this.screenSize,
    required this.layoutConfig,
    required this.fitnessData,
    required this.notifications,
    required this.animations,
    required this.accentColor,
    required this.progressColor,
    required this.onNavigateToTable,
    required this.onNavigateToSettings,
    required this.onShowNotifications,
    required this.onShowCaloriesAdjustment,
    required this.onShowHeartRateAdjustment,
    this.onSendActivityMessage, // Nuevo parámetro opcional
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(screenSize.width * 0.04),
      child: Column(
        children: [
          _buildPhoneHeader(),
          SizedBox(height: screenSize.height * 0.02),
          _buildPhoneTimeSection(),
          SizedBox(height: screenSize.height * 0.025),
          Expanded(child: _buildPhoneProgressSection()),
          SizedBox(height: screenSize.height * 0.02),
          _buildPhoneStatsSection(),
          SizedBox(height: screenSize.height * 0.02),
          // Widget de conexión MQTT completo para teléfonos
          MqttConnectionWidget(isCompact: false),
        ],
      ),
    );
  }

  Widget _buildPhoneHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: onNavigateToTable,
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: accentColor.withOpacity(0.3)),
            ),
            child: Icon(
              Icons.table_chart_outlined,
              color: accentColor,
              size: 20,
            ),
          ),
        ),
        AdaptiveText(
          'CalorieWatch',
          fontSize: screenSize.width * 0.055,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        Row(
          children: [
            GestureDetector(
              onTap: onNavigateToSettings,
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: Icon(
                  Icons.settings,
                  color: Colors.grey.shade300,
                  size: 20,
                ),
              ),
            ),
            SizedBox(width: 6),
            GestureDetector(
              onTap: onShowNotifications,
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: notifications.isNotEmpty
                      ? Colors.red.withOpacity(0.15)
                      : Colors.grey.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: notifications.isNotEmpty
                        ? Colors.red.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.3),
                  ),
                ),
                child: Stack(
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      color: notifications.isNotEmpty ? Colors.red : Colors.grey,
                      size: 20,
                    ),
                    if (notifications.isNotEmpty)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${notifications.length}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhoneTimeSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          StreamBuilder(
            stream: Stream.periodic(Duration(seconds: 1)),
            builder: (context, snapshot) {
              final now = DateTime.now();
              return AdaptiveText(
                '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                fontSize: screenSize.width * 0.14,
                fontWeight: FontWeight.w300,
                color: accentColor,
                style: TextStyle(letterSpacing: 4.0),
              );
            },
          ),
          SizedBox(height: 10),
          AdaptiveText(
            ColorUtils.getMotivationalText(fitnessData.calories),
            fontSize: screenSize.width * 0.05,
            color: accentColor.withOpacity(0.8),
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneProgressSection() {
    final progressSize = screenSize.width * 0.8;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([
            animations.pulseAnimation,
            animations.goalReachedAnimation,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: animations.pulseAnimation.value * animations.goalReachedAnimation.value,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onLongPress: onShowCaloriesAdjustment,
                  borderRadius: BorderRadius.circular(progressSize / 2),
                  child: Container(
                    width: progressSize,
                    height: progressSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                    child: Stack(
                      children: [
                        ProgressRing(
                          progress: fitnessData.calories / fitnessData.dailyCaloriesGoal,
                          color: progressColor,
                          strokeWidth: 18,
                          radius: progressSize * 0.4,
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                color: accentColor,
                                size: progressSize * 0.14,
                              ),
                              SizedBox(height: 12),
                              AdaptiveText(
                                fitnessData.calories.toStringAsFixed(0),
                                fontSize: progressSize * 0.18,
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                              ),
                              AdaptiveText(
                                'CALORÍAS',
                                fontSize: progressSize * 0.045,
                                color: accentColor.withOpacity(0.8),
                                style: TextStyle(letterSpacing: 2.0),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        SizedBox(height: screenSize.height * 0.03),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onLongPress: onShowHeartRateAdjustment,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 28, vertical: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: _getHeartRateColor().withOpacity(0.15),
                border: Border.all(color: _getHeartRateColor().withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite,
                    color: _getHeartRateColor(),
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  AdaptiveText(
                    '${fitnessData.heartRate} BPM',
                    fontSize: screenSize.width * 0.06,
                    fontWeight: FontWeight.w600,
                    color: _getHeartRateColor(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneStatsSection() {
    final progress = fitnessData.calories / fitnessData.dailyCaloriesGoal;

    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: progressColor.withOpacity(0.2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: progressColor,
                boxShadow: [
                  BoxShadow(
                    color: progressColor.withOpacity(0.4),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AdaptiveText(
              '${(progress * 100).toStringAsFixed(0)}% OBJETIVO',
              fontSize: screenSize.width * 0.045,
              color: progressColor.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
            AdaptiveText(
              '${fitnessData.dailyCaloriesGoal.toInt()} cal meta',
              fontSize: screenSize.width * 0.045,
              color: accentColor.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
        SizedBox(height: 16),
        // Hacer clickeable la descripción de actividad
        GestureDetector(
          onTap: onSendActivityMessage,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: accentColor.withOpacity(0.1),
              border: Border.all(color: accentColor.withOpacity(0.3)),
              // Agregar efecto visual para indicar que es clickeable
              boxShadow: onSendActivityMessage != null ? [
                BoxShadow(
                  color: accentColor.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ] : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (onSendActivityMessage != null) ...[
                  Icon(
                    Icons.send,
                    color: accentColor.withOpacity(0.7),
                    size: screenSize.width * 0.05,
                  ),
                  SizedBox(width: 8),
                ],
                Flexible(
                  child: AdaptiveText(
                    ColorUtils.getActivityDescription(fitnessData.calories),
                    fontSize: screenSize.width * 0.05,
                    color: accentColor.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getHeartRateColor() {
    if (fitnessData.heartRate < 80) {
      return Colors.green.shade400;
    } else if (fitnessData.heartRate < 100) {
      return Colors.orange.shade400;
    } else {
      return Colors.red.shade400;
    }
  }
}