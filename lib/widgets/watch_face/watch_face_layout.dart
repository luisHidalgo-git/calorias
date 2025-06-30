import 'package:flutter/material.dart';
import '../../models/fitness_data.dart';
import '../../models/daily_calories.dart';
import '../../utils/device_utils.dart';
import 'watch_face_animations.dart';
import 'wearable_layout.dart';
import 'phone_layout.dart';

class WatchFaceLayout extends StatelessWidget {
  final bool isWearable;
  final Size screenSize;
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

  const WatchFaceLayout({
    super.key,
    required this.isWearable,
    required this.screenSize,
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
  });

  @override
  Widget build(BuildContext context) {
    final layoutConfig = DeviceUtils.getLayoutConfig(
      isWearable ? DeviceType.wearable : DeviceType.phone,
    );

    if (isWearable) {
      return WearableLayout(
        screenSize: screenSize,
        layoutConfig: layoutConfig,
        fitnessData: fitnessData,
        notifications: notifications,
        animations: animations,
        accentColor: accentColor,
        progressColor: progressColor,
        onNavigateToTable: onNavigateToTable,
        onShowNotifications: onShowNotifications,
        onShowCaloriesAdjustment: onShowCaloriesAdjustment,
        onShowHeartRateAdjustment: onShowHeartRateAdjustment,
      );
    } else {
      return PhoneLayout(
        screenSize: screenSize,
        layoutConfig: layoutConfig,
        fitnessData: fitnessData,
        notifications: notifications,
        animations: animations,
        accentColor: accentColor,
        progressColor: progressColor,
        onNavigateToTable: onNavigateToTable,
        onNavigateToSettings: onNavigateToSettings,
        onShowNotifications: onShowNotifications,
        onShowCaloriesAdjustment: onShowCaloriesAdjustment,
        onShowHeartRateAdjustment: onShowHeartRateAdjustment,
      );
    }
  }
}