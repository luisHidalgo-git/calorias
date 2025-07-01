import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/fitness_data.dart';
import '../../models/daily_calories.dart';
import '../../utils/device_utils.dart';
import '../../utils/screen_utils.dart';
import '../../utils/color_utils.dart';
import '../progress_ring.dart';
import '../time_display.dart';
import '../notification_icon.dart';
import '../watch_button.dart';
import '../adaptive_text.dart';
import '../branded_logo.dart';
import '../mqtt_connection_widget.dart';
import 'watch_face_animations.dart';
import 'interactive_center_content.dart';

class WearableLayout extends StatelessWidget {
  final Size screenSize;
  final LayoutConfig layoutConfig;
  final FitnessData fitnessData;
  final List<CalorieEntry> notifications;
  final WatchFaceAnimations animations;
  final Color accentColor;
  final Color progressColor;
  final VoidCallback onNavigateToTable;
  final VoidCallback onShowNotifications;
  final VoidCallback onShowCaloriesAdjustment;
  final VoidCallback onShowHeartRateAdjustment;
  final VoidCallback? onSendActivityMessage;
  final VoidCallback? onRequestCaloriesData; // Nuevo callback

  const WearableLayout({
    super.key,
    required this.screenSize,
    required this.layoutConfig,
    required this.fitnessData,
    required this.notifications,
    required this.animations,
    required this.accentColor,
    required this.progressColor,
    required this.onNavigateToTable,
    required this.onShowNotifications,
    required this.onShowCaloriesAdjustment,
    required this.onShowHeartRateAdjustment,
    this.onSendActivityMessage,
    this.onRequestCaloriesData, // Nuevo parámetro opcional
  });

  @override
  Widget build(BuildContext context) {
    final isRound = ScreenUtils.isRoundScreen(screenSize);
    final watchSize = isRound
        ? math.min(screenSize.width, screenSize.height) * 0.68
        : math.min(screenSize.width, screenSize.height) * 0.7;

    return Stack(
      children: [
        // Logo de marca sutil en la esquina
        Positioned(
          bottom: screenSize.height * 0.02,
          right: screenSize.width * 0.02,
          child: Opacity(
            opacity: 0.3,
            child: BrandedLogo(size: screenSize.width * 0.08, animated: false),
          ),
        ),

        // Widget de conexión MQTT - MOVIDO MÁS A LA DERECHA EN PANTALLAS REDONDAS
        Positioned(
          top: screenSize.height * 0.02,
          left:
              screenSize.width *
              (isRound
                  ? 0.15
                  : 0.02), // Movido aún más a la derecha en pantallas redondas
          child: MqttConnectionWidget(isCompact: true),
        ),

        // Botón para solicitar datos (solo en wearables)
        if (onRequestCaloriesData != null && isRound) ...[
          Positioned(
            bottom: screenSize.height * 0.15,
            left: screenSize.width * 0.15,
            child: WatchButton(
              onTap: onRequestCaloriesData!,
              icon: Icons.sync,
              color: Colors.blue.shade300,
              size: watchSize * 0.8,
            ),
          ),
        ] else if (onRequestCaloriesData != null && !isRound) ...[
          Positioned(
            bottom: screenSize.height * 0.08,
            left: screenSize.width * 0.05,
            child: WatchButton(
              onTap: onRequestCaloriesData!,
              icon: Icons.sync,
              color: Colors.blue.shade300,
              size: watchSize * 0.8,
            ),
          ),
        ],

        // Botones posicionados de manera adaptativa
        if (isRound) ...[
          Positioned(
            top: screenSize.height * 0.18,
            left: screenSize.width * 0.18,
            child: WatchButton(
              onTap: onNavigateToTable,
              icon: Icons.table_chart_outlined,
              color: accentColor,
              size: watchSize,
            ),
          ),
          Positioned(
            top: screenSize.height * 0.18,
            right: screenSize.width * 0.18,
            child: NotificationIcon(
              notifications: notifications,
              onTap: onShowNotifications,
            ),
          ),
        ] else ...[
          Positioned(
            top: screenSize.height * 0.08,
            left: screenSize.width * 0.05,
            child: WatchButton(
              onTap: onNavigateToTable,
              icon: Icons.table_chart_outlined,
              color: accentColor,
              size: watchSize,
            ),
          ),
          Positioned(
            top: screenSize.height * 0.08,
            right: screenSize.width * 0.05,
            child: NotificationIcon(
              notifications: notifications,
              onTap: onShowNotifications,
            ),
          ),
        ],

        // Contenido principal adaptativo
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isRound
                ? screenSize.width * 0.06
                : screenSize.width * 0.05,
            vertical: isRound
                ? screenSize.height * 0.03
                : screenSize.height * 0.02,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (isRound) SizedBox(height: screenSize.height * 0.05),

              TimeDisplay(watchSize: watchSize, accentColor: accentColor),
              _buildMotivationalText(watchSize, accentColor, isRound),

              Flexible(
                flex: 3,
                child: Center(
                  child: AnimatedBuilder(
                    animation: Listenable.merge([
                      animations.pulseAnimation,
                      animations.goalReachedAnimation,
                    ]),
                    builder: (context, child) {
                      return Transform.scale(
                        scale:
                            animations.pulseAnimation.value *
                            animations.goalReachedAnimation.value,
                        child: SizedBox(
                          width: watchSize,
                          height: watchSize,
                          child: Stack(
                            children: [
                              ProgressRing(
                                progress:
                                    fitnessData.calories /
                                    fitnessData.dailyCaloriesGoal,
                                color: progressColor,
                                strokeWidth: isRound ? 13 : 14,
                                radius: watchSize * 0.4,
                              ),
                              InteractiveCenterContent(
                                fitnessData: fitnessData,
                                watchSize: watchSize,
                                isRound: isRound,
                                accentColor: accentColor,
                                onShowCaloriesAdjustment:
                                    onShowCaloriesAdjustment,
                                onShowHeartRateAdjustment:
                                    onShowHeartRateAdjustment,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              Column(
                children: [
                  _buildProgressIndicator(watchSize, progressColor, isRound),
                  SizedBox(
                    height: isRound
                        ? screenSize.height * 0.008
                        : screenSize.height * 0.015,
                  ),
                  _buildActivityDescription(watchSize, accentColor, isRound),
                ],
              ),

              if (isRound) SizedBox(height: screenSize.height * 0.015),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMotivationalText(
    double watchSize,
    Color accentColor,
    bool isRound,
  ) {
    final motivationalText = ColorUtils.getMotivationalText(
      fitnessData.calories,
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: watchSize * 0.025,
        vertical: watchSize * (isRound ? 0.007 : 0.008),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(watchSize * 0.015),
        color: accentColor.withOpacity(0.15),
        border: Border.all(color: accentColor.withOpacity(0.4), width: 1),
      ),
      child: AdaptiveText(
        motivationalText,
        fontSize: watchSize * (isRound ? 0.042 : 0.045),
        color: accentColor,
        fontWeight: FontWeight.w600,
        style: TextStyle(letterSpacing: 0.8),
      ),
    );
  }

  Widget _buildProgressIndicator(double watchSize, Color color, bool isRound) {
    final progress = fitnessData.calories / fitnessData.dailyCaloriesGoal;

    return Column(
      children: [
        Container(
          width: watchSize * (isRound ? 0.38 : 0.4),
          height: isRound ? 3.5 : 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: color.withOpacity(0.2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: color,
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.4), blurRadius: 6),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: isRound ? 5 : 6),
        AdaptiveText(
          '${(progress * 100).toStringAsFixed(0)}% OBJETIVO',
          fontSize: watchSize * (isRound ? 0.037 : 0.04),
          color: color.withOpacity(0.9),
          fontWeight: FontWeight.w600,
          style: TextStyle(letterSpacing: 1.0),
        ),
      ],
    );
  }

  Widget _buildActivityDescription(
    double watchSize,
    Color accentColor,
    bool isRound,
  ) {
    final description = ColorUtils.getActivityDescription(fitnessData.calories);

    return GestureDetector(
      onTap: onSendActivityMessage, // Hacer clickeable
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: watchSize * 0.03,
          vertical: watchSize * (isRound ? 0.009 : 0.01),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(watchSize * 0.015),
          color: accentColor.withOpacity(0.12),
          border: Border.all(color: accentColor.withOpacity(0.3), width: 1),
          // Agregar efecto visual para indicar que es clickeable
          boxShadow: onSendActivityMessage != null
              ? [
                  BoxShadow(
                    color: accentColor.withOpacity(0.2),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onSendActivityMessage != null) ...[
              Icon(
                Icons.send,
                color: accentColor.withOpacity(0.7),
                size: watchSize * (isRound ? 0.035 : 0.038),
              ),
              SizedBox(width: watchSize * 0.01),
            ],
            Flexible(
              child: AdaptiveText(
                description,
                fontSize: watchSize * (isRound ? 0.042 : 0.045),
                color: accentColor.withOpacity(0.9),
                fontWeight: FontWeight.w500,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
