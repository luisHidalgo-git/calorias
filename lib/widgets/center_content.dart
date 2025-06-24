import 'package:flutter/material.dart';
import '../models/fitness_data.dart';
import '../utils/color_utils.dart';

class CenterContent extends StatelessWidget {
  final FitnessData fitnessData;
  final double watchSize;

  const CenterContent({
    Key? key,
    required this.fitnessData,
    required this.watchSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accentColor = ColorUtils.getAccentColor(fitnessData.calories);
    final motivationalText = ColorUtils.getMotivationalText(
      fitnessData.calories,
    );

    return Center(
      child: Container(
        width: watchSize * 0.6,
        height: watchSize * 0.6,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Texto motivacional
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: watchSize * 0.03,
                vertical: watchSize * 0.01,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(watchSize * 0.02),
                color: accentColor.withOpacity(0.15),
                border: Border.all(
                  color: accentColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                motivationalText,
                style: TextStyle(
                  fontSize: watchSize * 0.025,
                  color: accentColor,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            SizedBox(height: watchSize * 0.04),

            // Contador principal de calorías
            Container(
              padding: EdgeInsets.all(watchSize * 0.04),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withOpacity(0.1),
                border: Border.all(
                  color: accentColor.withOpacity(0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: accentColor,
                    size: watchSize * 0.08,
                  ),
                  SizedBox(height: watchSize * 0.01),
                  Text(
                    '${fitnessData.calories.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: watchSize * 0.12,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                      shadows: [
                        Shadow(
                          color: accentColor.withOpacity(0.6),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'CALORÍAS',
                    style: TextStyle(
                      fontSize: watchSize * 0.025,
                      color: accentColor.withOpacity(0.8),
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: watchSize * 0.04),

            // Ritmo cardíaco
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: watchSize * 0.03,
                vertical: watchSize * 0.015,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(watchSize * 0.02),
                color: Colors.red.withOpacity(0.1),
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: watchSize * 0.04,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '${fitnessData.heartRate}',
                    style: TextStyle(
                      fontSize: watchSize * 0.04,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'bpm',
                    style: TextStyle(
                      fontSize: watchSize * 0.025,
                      color: Colors.red.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
