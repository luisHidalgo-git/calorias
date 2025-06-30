import 'package:flutter/material.dart';
import '../../models/fitness_data.dart';
import '../../utils/color_utils.dart';
import '../value_adjustment_dialog.dart';

class WatchFaceInteractions {
  static void showCaloriesAdjustment(
    BuildContext context,
    FitnessData fitnessData,
    Function(double) onValueChanged,
  ) {
    showDialog(
      context: context,
      builder: (context) => ValueAdjustmentDialog(
        title: 'Ajustar Calorías',
        currentValue: fitnessData.calories,
        maxValue: fitnessData.dailyCaloriesGoal,
        unit: 'cal',
        icon: Icons.local_fire_department,
        color: ColorUtils.getProgressColor(fitnessData.calories),
        onValueChanged: onValueChanged,
      ),
    );
  }

  static void showHeartRateAdjustment(
    BuildContext context,
    FitnessData fitnessData,
    Function(double) onValueChanged,
  ) {
    showDialog(
      context: context,
      builder: (context) => ValueAdjustmentDialog(
        title: 'Ajustar Ritmo Cardíaco',
        currentValue: fitnessData.heartRate.toDouble(),
        maxValue: fitnessData.maxHeartRate.toDouble(),
        unit: 'BPM',
        icon: Icons.favorite,
        color: _getHeartRateColor(fitnessData),
        onValueChanged: onValueChanged,
      ),
    );
  }

  static Color _getHeartRateColor(FitnessData fitnessData) {
    if (fitnessData.heartRate < 80) {
      return Colors.green.shade400;
    } else if (fitnessData.heartRate < 100) {
      return Colors.orange.shade400;
    } else {
      return Colors.red.shade400;
    }
  }
}