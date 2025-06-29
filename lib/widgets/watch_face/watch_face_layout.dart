import 'package:flutter/material.dart';
import '../../models/fitness_data.dart';
import '../../models/daily_calories.dart';
import '../../utils/color_utils.dart';
import 'phone_layout.dart';
import 'wearable_layout.dart';

class WatchFaceLayout extends StatelessWidget {
  final FitnessData fitnessData;
  final List<CalorieEntry> notifications;
  final Animation<double> pulseAnimation;
  final Animation<double> backgroundAnimation;
  final Animation<double> goalReachedAnimation;
  final VoidCallback onNavigateToTable;
  final VoidCallback onNavigateToSettings;
  final VoidCallback onShowNotifications;
  final VoidCallback onShowCaloriesAdjustment;
  final VoidCallback onShowHeartRateAdjustment;
  final Color Function() getHeartRateColor;
  final bool isWearable;

  const WatchFaceLayout({
    super.key,
    required this.fitnessData,
    required this.notifications,
    required this.pulseAnimation,
    required this.backgroundAnimation,
    required this.goalReachedAnimation,
    required this.onNavigateToTable,
    required this.onNavigateToSettings,
    required this.onShowNotifications,
    required this.onShowCaloriesAdjustment,
    required this.onShowHeartRateAdjustment,
    required this.getHeartRateColor,
    required this.isWearable,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ColorUtils.getBackgroundColor(fitnessData.calories);
    final progressColor = ColorUtils.getProgressColor(fitnessData.calories);
    final accentColor = ColorUtils.getAccentColor(fitnessData.calories);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: backgroundAnimation,
          builder: (context, child) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    Color.lerp(
                      backgroundColor,
                      accentColor,
                      backgroundAnimation.value * 0.08,
                    )!,
                    backgroundColor.withOpacity(0.6),
                    Colors.black,
                  ],
                  stops: [0.0, 0.7, 1.0],
                ),
              ),
              child: isWearable
                  ? WearableLayout(
                      fitnessData: fitnessData,
                      notifications: notifications,
                      pulseAnimation: pulseAnimation,
                      goalReachedAnimation: goalReachedAnimation,
                      onNavigateToTable: onNavigateToTable,
                      onShowNotifications: onShowNotifications,
                      accentColor: accentColor,
                      progressColor: progressColor,
                    )
                  : PhoneLayout(
                      fitnessData: fitnessData,
                      notifications: notifications,
                      pulseAnimation: pulseAnimation,
                      goalReachedAnimation: goalReachedAnimation,
                      onNavigateToTable: onNavigateToTable,
                      onNavigateToSettings: onNavigateToSettings,
                      onShowNotifications: onShowNotifications,
                      onShowCaloriesAdjustment: onShowCaloriesAdjustment,
                      onShowHeartRateAdjustment: onShowHeartRateAdjustment,
                      getHeartRateColor: getHeartRateColor,
                      accentColor: accentColor,
                      progressColor: progressColor,
                    ),
            );
          },
        ),
      ),
    );
  }
}