import 'package:flutter/material.dart';
import '../models/fitness_data.dart';
import '../utils/color_utils.dart';

class CenterContent extends StatelessWidget {
  final FitnessData fitnessData;
  final double watchSize;

  const CenterContent({
    super.key,
    required this.fitnessData,
    required this.watchSize,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = ColorUtils.getAccentColor(fitnessData.calories);
    final motivationalText = ColorUtils.getMotivationalText(
      fitnessData.calories,
    );

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Nivel de actividad
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: watchSize * 0.02,
              vertical: watchSize * 0.006,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(watchSize * 0.012),
              color: accentColor.withOpacity(0.12),
              border: Border.all(color: accentColor.withOpacity(0.3), width: 1),
            ),
            child: Text(
              motivationalText,
              style: TextStyle(
                fontSize: watchSize * 0.018,
                color: accentColor,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ),

          SizedBox(height: watchSize * 0.025),

          // Contador principal de calorías
          Container(
            padding: EdgeInsets.all(watchSize * 0.03),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withOpacity(0.08),
              border: Border.all(
                color: accentColor.withOpacity(0.35),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.25),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: accentColor,
                  size: watchSize * 0.05,
                ),
                SizedBox(height: watchSize * 0.005),
                Text(
                  fitnessData.calories.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: watchSize * 0.08,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                    shadows: [
                      Shadow(
                        color: accentColor.withOpacity(0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                Text(
                  'CALORÍAS',
                  style: TextStyle(
                    fontSize: watchSize * 0.016,
                    color: accentColor.withOpacity(0.8),
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: watchSize * 0.025),

          // Ritmo cardíaco
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: watchSize * 0.02,
              vertical: watchSize * 0.01,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(watchSize * 0.012),
              color: _getHeartRateColor().withOpacity(0.08),
              border: Border.all(
                color: _getHeartRateColor().withOpacity(0.25),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.favorite,
                  color: _getHeartRateColor(),
                  size: watchSize * 0.025,
                ),
                SizedBox(width: 4),
                Text(
                  '${fitnessData.heartRate}',
                  style: TextStyle(
                    fontSize: watchSize * 0.025,
                    fontWeight: FontWeight.w600,
                    color: _getHeartRateColor(),
                  ),
                ),
                SizedBox(width: 2),
                Text(
                  'bpm',
                  style: TextStyle(
                    fontSize: watchSize * 0.016,
                    color: _getHeartRateColor().withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getHeartRateColor() {
    if (fitnessData.heartRate < 80) {
      return Colors.green;
    } else if (fitnessData.heartRate < 100) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
