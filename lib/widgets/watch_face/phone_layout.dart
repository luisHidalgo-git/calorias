import 'package:flutter/material.dart';
import '../../models/fitness_data.dart';
import '../../models/daily_calories.dart';
import '../../widgets/adaptive_text.dart';
import '../../widgets/progress_ring.dart';
import '../phone_components/phone_header.dart';
import '../phone_components/phone_time_section.dart';
import '../phone_components/phone_progress_section.dart';
import '../phone_components/phone_stats_section.dart';

class PhoneLayout extends StatelessWidget {
  final FitnessData fitnessData;
  final List<CalorieEntry> notifications;
  final Animation<double> pulseAnimation;
  final Animation<double> goalReachedAnimation;
  final VoidCallback onNavigateToTable;
  final VoidCallback onNavigateToSettings;
  final VoidCallback onShowNotifications;
  final VoidCallback onShowCaloriesAdjustment;
  final VoidCallback onShowHeartRateAdjustment;
  final Color Function() getHeartRateColor;
  final Color accentColor;
  final Color progressColor;

  const PhoneLayout({
    super.key,
    required this.fitnessData,
    required this.notifications,
    required this.pulseAnimation,
    required this.goalReachedAnimation,
    required this.onNavigateToTable,
    required this.onNavigateToSettings,
    required this.onShowNotifications,
    required this.onShowCaloriesAdjustment,
    required this.onShowHeartRateAdjustment,
    required this.getHeartRateColor,
    required this.accentColor,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.all(screenSize.width * 0.05),
      child: Column(
        children: [
          PhoneHeader(
            notifications: notifications,
            onNavigateToTable: onNavigateToTable,
            onNavigateToSettings: onNavigateToSettings,
            onShowNotifications: onShowNotifications,
            accentColor: accentColor,
          ),
          SizedBox(height: screenSize.height * 0.03),
          PhoneTimeSection(accentColor: accentColor),
          SizedBox(height: screenSize.height * 0.04),
          Expanded(
            child: PhoneProgressSection(
              fitnessData: fitnessData,
              pulseAnimation: pulseAnimation,
              goalReachedAnimation: goalReachedAnimation,
              onShowCaloriesAdjustment: onShowCaloriesAdjustment,
              onShowHeartRateAdjustment: onShowHeartRateAdjustment,
              getHeartRateColor: getHeartRateColor,
              accentColor: accentColor,
              progressColor: progressColor,
            ),
          ),
          SizedBox(height: screenSize.height * 0.03),
          PhoneStatsSection(
            fitnessData: fitnessData,
            accentColor: accentColor,
            progressColor: progressColor,
          ),
        ],
      ),
    );
  }
}