import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/fitness_data.dart';
import '../../models/daily_calories.dart';
import '../../widgets/progress_ring.dart';
import '../../widgets/center_content.dart';
import '../../widgets/time_display.dart';
import '../../widgets/notification_icon.dart';
import '../../widgets/watch_button.dart';
import '../../widgets/adaptive_text.dart';
import '../../widgets/branded_logo.dart';
import '../../utils/color_utils.dart';
import '../../utils/screen_utils.dart';

class WearableLayout extends StatelessWidget {
  final FitnessData fitnessData;
  final List<CalorieEntry> notifications;
  final Animation<double> pulseAnimation;
  final Animation<double> goalReachedAnimation;
  final VoidCallback onNavigateToTable;
  final VoidCallback onShowNotifications;
  final Color accentColor;
  final Color progressColor;

  const WearableLayout({
    super.key,
    required this.fitnessData,
    required this.notifications,
    required this.pulseAnimation,
    required this.goalReachedAnimation,
    required this.onNavigateToTable,
    required this.onShowNotifications,
    required this.accentColor,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
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
            top: screenSize.height * 0.02,
            left: screenSize.width * 0.05,
            child: WatchButton(
              onTap: onNavigateToTable,
              icon: Icons.table_chart_outlined,
              color: accentColor,
              size: watchSize,
            ),
          ),
          Positioned(
            top: screenSize.height * 0.02,
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
                      pulseAnimation,
                      goalReachedAnimation,
                    ]),
                    builder: (context, child) {
                      return Transform.scale(
                        scale: pulseAnimation.value * goalReachedAnimation.value,
                        child: SizedBox(
                          width: watchSize,
                          height: watchSize,
                          child: Stack(
                            children: [
                              ProgressRing(
                                progress: fitnessData.calories / fitnessData.dailyCaloriesGoal,
                                color: progressColor,
                                strokeWidth: isRound ? 13 : 14,
                                radius: watchSize * 0.4,
                              ),
                              CenterContent(
                                fitnessData: fitnessData,
                                watchSize: watchSize,
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

  Widget _buildMotivationalText(double watchSize, Color accentColor, bool isRound) {
    final motivationalText = ColorUtils.getMotivationalText(fitnessData.calories);

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

  Widget _buildActivityDescription(double watchSize, Color accentColor, bool isRound) {
    final description = ColorUtils.getActivityDescription(fitnessData.calories);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: watchSize * 0.03,
        vertical: watchSize * (isRound ? 0.009 : 0.01),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(watchSize * 0.015),
        color: accentColor.withOpacity(0.12),
        border: Border.all(color: accentColor.withOpacity(0.3), width: 1),
      ),
      child: AdaptiveText(
        description,
        fontSize: watchSize * (isRound ? 0.042 : 0.045),
        color: accentColor.withOpacity(0.9),
        fontWeight: FontWeight.w500,
      ),
    );
  }
}