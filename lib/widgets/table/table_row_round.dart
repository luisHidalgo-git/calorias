import 'package:flutter/material.dart';
import '../../models/daily_calories.dart';
import '../../utils/color_utils.dart';
import '../adaptive_text.dart';

class TableRowRound extends StatelessWidget {
  final DailyCalories record;
  final bool isToday;
  final Size screenSize;

  const TableRowRound({
    super.key,
    required this.record,
    required this.isToday,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final progressColor = ColorUtils.getProgressColor(record.calories);

    return Container(
      margin: EdgeInsets.only(bottom: screenSize.height * 0.008),
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.width * 0.035,
        vertical: screenSize.height * 0.015,
      ),
      decoration: BoxDecoration(
        color: isToday
            ? progressColor.withOpacity(0.15)
            : Colors.grey.shade900.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isToday
              ? progressColor.withOpacity(0.5)
              : Colors.grey.shade800,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          _buildDateAndStatus(progressColor),
          SizedBox(height: screenSize.height * 0.012),
          _buildCaloriesAndProgress(progressColor),
        ],
      ),
    );
  }

  Widget _buildDateAndStatus(Color progressColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdaptiveText(
                record.formattedDate,
                fontSize: screenSize.width * 0.04,
                fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                color: isToday ? progressColor : Colors.grey.shade200,
                overflow: TextOverflow.ellipsis,
              ),
              if (isToday) ...[
                SizedBox(height: 1),
                AdaptiveText(
                  'Hoy',
                  fontSize: screenSize.width * 0.028,
                  color: progressColor.withOpacity(0.8),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        
        SizedBox(width: screenSize.width * 0.025),
        
        Container(
          padding: EdgeInsets.all(screenSize.width * 0.018),
          decoration: BoxDecoration(
            color: record.goalReached
                ? Colors.green.withOpacity(0.2)
                : Colors.grey.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: record.goalReached
                  ? Colors.green.withOpacity(0.4)
                  : Colors.grey.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(
            record.goalReached
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: record.goalReached
                ? Colors.green.shade400
                : Colors.grey.shade500,
            size: screenSize.width * 0.045,
          ),
        ),
      ],
    );
  }

  Widget _buildCaloriesAndProgress(Color progressColor) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.width * 0.022,
            vertical: screenSize.height * 0.006,
          ),
          decoration: BoxDecoration(
            color: progressColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: progressColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: AdaptiveText(
            '${record.calories.toInt()} cal',
            fontSize: screenSize.width * 0.038,
            fontWeight: FontWeight.bold,
            color: progressColor,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        
        SizedBox(width: screenSize.width * 0.02),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 3.5,
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
                      boxShadow: [
                        BoxShadow(
                          color: progressColor.withOpacity(0.4),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 3),
              AdaptiveText(
                '${((record.calories / 300.0) * 100).toStringAsFixed(0)}% objetivo',
                fontSize: screenSize.width * 0.026,
                color: progressColor.withOpacity(0.8),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}