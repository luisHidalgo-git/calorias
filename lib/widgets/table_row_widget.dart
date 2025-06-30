import 'package:flutter/material.dart';
import '../models/daily_calories.dart';
import '../utils/screen_utils.dart';
import 'table/table_row_round.dart';
import 'table/table_row_square.dart';

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

    if (isRound) {
      return TableRowRound(
        record: record,
        isToday: isToday,
        screenSize: screenSize,
      );
    } else {
      return TableRowSquare(
        record: record,
        isToday: isToday,
        screenSize: screenSize,
      );
    }
  }
}