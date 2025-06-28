import 'package:flutter/material.dart';
import '../models/fitness_data.dart';
import '../utils/color_utils.dart';

class CenterContent extends StatelessWidget {
  final FitnessData fitnessData;
  final double watchSize;
  final bool isRound;

  const CenterContent({
    super.key,
    required this.fitnessData,
    required this.watchSize,
    this.isRound = false,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = ColorUtils.getAccentColor(fitnessData.calories);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Contador principal de calorías
          Container(
            width: watchSize * (isRound ? 0.34 : 0.35),
            height: watchSize * (isRound ? 0.34 : 0.35),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withOpacity(0.12),
              border: Border.all(color: accentColor.withOpacity(0.4), width: 2),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: accentColor,
                  size: watchSize * (isRound ? 0.048 : 0.05),
                ),
                SizedBox(height: watchSize * 0.005),
                Text(
                  fitnessData.calories.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: watchSize * (isRound ? 0.085 : 0.09),
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
                    fontSize: watchSize * (isRound ? 0.017 : 0.018),
                    color: accentColor.withOpacity(0.8),
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: watchSize * (isRound ? 0.018 : 0.02)),

          // Ritmo cardíaco - optimizado para ambos tipos de pantalla
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: watchSize * (isRound ? 0.028 : 0.03),
              vertical: watchSize * (isRound ? 0.014 : 0.015),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(watchSize * 0.015),
              color: _getHeartRateColor().withOpacity(0.12),
              border: Border.all(
                color: _getHeartRateColor().withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              '♥ ${fitnessData.heartRate}',
              style: TextStyle(
                fontSize: watchSize * (isRound ? 0.034 : 0.035),
                fontWeight: FontWeight.w600,
                color: _getHeartRateColor(),
              ),
            ),
          ),
        ],
      ),
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
