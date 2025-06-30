import 'package:flutter/material.dart';
import '../../models/daily_calories.dart';
import '../stats_card.dart';

class StatsSection extends StatelessWidget {
  final List<DailyCalories> records;
  final Size screenSize;

  const StatsSection({
    super.key,
    required this.records,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    final totalCalories = records.fold<double>(
      0,
      (sum, record) => sum + record.calories,
    );
    final avgCalories = records.isNotEmpty
        ? totalCalories / records.length
        : 0;
    final goalsReached = records.where((record) => record.goalReached).length;

    return Row(
      children: [
        Expanded(
          child: StatsCard(
            title: 'Total',
            value: '${totalCalories.toInt()}',
            unit: 'cal',
            color: Colors.blue,
          ),
        ),
        SizedBox(width: screenSize.width * 0.02),
        Expanded(
          child: StatsCard(
            title: 'Promedio',
            value: '${avgCalories.toInt()}',
            unit: 'cal/día',
            color: Colors.green,
          ),
        ),
        SizedBox(width: screenSize.width * 0.02),
        Expanded(
          child: StatsCard(
            title: 'Metas',
            value: '$goalsReached',
            unit: 'días',
            color: Colors.orange,
          ),
        ),
      ],
    );
  }
}