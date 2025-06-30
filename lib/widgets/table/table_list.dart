import 'package:flutter/material.dart';
import '../../models/daily_calories.dart';
import '../table_row_widget.dart';

class TableList extends StatelessWidget {
  final List<DailyCalories> records;
  final Size screenSize;
  final bool isRound;

  const TableList({
    super.key,
    required this.records,
    required this.screenSize,
    required this.isRound,
  });

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      padding: isRound 
          ? EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.01,
            )
          : EdgeInsets.zero,
      child: ListView.builder(
        padding: isRound 
            ? EdgeInsets.only(
                top: screenSize.height * 0.005,
                bottom: screenSize.height * 0.08,
                left: screenSize.width * 0.01,
                right: screenSize.width * 0.01,
              )
            : EdgeInsets.zero,
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];
          final isToday = _isToday(record.date);
          return TableRowWidget(record: record, isToday: isToday);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center_outlined,
            size: screenSize.width * 0.12,
            color: Colors.grey.shade600,
          ),
          SizedBox(height: screenSize.height * 0.02),
          Text(
            'No hay datos disponibles',
            style: TextStyle(
              fontSize: screenSize.width * 0.035,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenSize.height * 0.01),
          Text(
            'Comienza a hacer ejercicio para ver tu progreso',
            style: TextStyle(
              fontSize: screenSize.width * 0.028,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}