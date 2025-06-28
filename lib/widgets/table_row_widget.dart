import 'package:flutter/material.dart';
import '../models/daily_calories.dart';
import '../utils/color_utils.dart';
import '../utils/screen_utils.dart';
import 'adaptive_text.dart';

class TableRowWidget extends StatelessWidget {
  final DailyCalories record;
  final bool isToday;

  const TableRowWidget({
    super.key,
    required this.record,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isRound = ScreenUtils.isRoundScreen(screenSize);
    final progressColor = ColorUtils.getProgressColor(record.calories);

    return Container(
      margin: EdgeInsets.only(bottom: screenSize.height * 0.008),
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.width * (isRound ? 0.025 : 0.03),
        vertical: screenSize.height * (isRound ? 0.01 : 0.012),
      ),
      decoration: BoxDecoration(
        color: isToday
            ? progressColor.withOpacity(0.1)
            : Colors.grey.shade900.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isToday
              ? progressColor.withOpacity(0.4)
              : Colors.grey.shade800,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdaptiveText(
                  record.formattedDate,
                  fontSize: screenSize.width * 0.032,
                  fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
                  color: isToday ? progressColor : Colors.grey.shade300,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isToday)
                  AdaptiveText(
                    'Hoy',
                    fontSize: screenSize.width * 0.024,
                    color: progressColor.withOpacity(0.8),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                AdaptiveText(
                  '${record.calories.toInt()}',
                  fontSize: screenSize.width * 0.035,
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Container(
                  width: screenSize.width * (isRound ? 0.1 : 0.12),
                  height: 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: progressColor.withOpacity(0.2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (record.calories / 300.0).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: progressColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Icon(
              record.goalReached
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: record.goalReached
                  ? Colors.green.shade400
                  : Colors.grey.shade600,
              size: screenSize.width * (isRound ? 0.04 : 0.045),
            ),
          ),
        ],
      ),
    );
  }
}