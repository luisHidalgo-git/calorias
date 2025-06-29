import 'package:flutter/material.dart';
import '../../models/fitness_data.dart';
import '../../widgets/adaptive_text.dart';
import '../../utils/color_utils.dart';

class PhoneStatsSection extends StatelessWidget {
  final FitnessData fitnessData;
  final Color accentColor;
  final Color progressColor;

  const PhoneStatsSection({
    super.key,
    required this.fitnessData,
    required this.accentColor,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final progress = fitnessData.calories / fitnessData.dailyCaloriesGoal;

    return Column(
      children: [
        // Barra de progreso
        Container(
          width: double.infinity,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: progressColor.withOpacity(0.2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: progressColor,
                boxShadow: [
                  BoxShadow(
                    color: progressColor.withOpacity(0.4),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        ),

        SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AdaptiveText(
              '${(progress * 100).toStringAsFixed(0)}% OBJETIVO',
              fontSize: screenSize.width * 0.04,
              color: progressColor.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
            AdaptiveText(
              '${fitnessData.dailyCaloriesGoal.toInt()} cal meta',
              fontSize: screenSize.width * 0.04,
              color: accentColor.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ],
        ),

        SizedBox(height: 16),

        // Descripción de actividad
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: accentColor.withOpacity(0.1),
            border: Border.all(color: accentColor.withOpacity(0.3)),
          ),
          child: Center(
            child: AdaptiveText(
              ColorUtils.getActivityDescription(fitnessData.calories),
              fontSize: screenSize.width * 0.045,
              color: accentColor.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}