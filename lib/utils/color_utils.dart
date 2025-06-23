import 'package:flutter/material.dart';

class ColorUtils {
  static Color getBackgroundColor(int heartRate) {
    if (heartRate < 80) {
      // Resting heart rate - cool blue/grey
      return Colors.grey[900]!;
    } else if (heartRate < 100) {
      // Light activity - subtle green
      return Colors.green[900]!.withOpacity(0.3);
    } else if (heartRate < 130) {
      // Moderate activity - orange
      return Colors.orange[900]!.withOpacity(0.3);
    } else {
      // High intensity - red
      return Colors.red[900]!.withOpacity(0.3);
    }
  }

  static Color getHeartRateColor(int heartRate) {
    if (heartRate < 80) {
      return Colors.blue;
    } else if (heartRate < 100) {
      return Colors.green;
    } else if (heartRate < 130) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}