import 'package:flutter/material.dart';
import 'dart:async';
import '../models/daily_calories.dart';
import '../services/calorie_service.dart';
import '../utils/color_utils.dart';

class CaloriesTableScreen extends StatefulWidget {
  const CaloriesTableScreen({super.key});

  @override
  _CaloriesTableScreenState createState() => _CaloriesTableScreenState();
}

class _CaloriesTableScreenState extends State<CaloriesTableScreen>
    with TickerProviderStateMixin {
  final CalorieService _calorieService = CalorieService();
  List<DailyCalories> _records = [];
  StreamSubscription? _recordsSubscription;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _records = _calorieService.dailyRecords;

    _recordsSubscription = _calorieService.recordsStream.listen((records) {
      if (mounted) {
        setState(() {
          _records = records;
        });
      }
    });

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _recordsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: EdgeInsets.all(screenSize.width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(screenSize),
                SizedBox(height: screenSize.height * 0.025),
                _buildStatsCards(screenSize),
                SizedBox(height: screenSize.height * 0.025),
                _buildTableHeader(screenSize),
                SizedBox(height: screenSize.height * 0.015),
                Expanded(child: _buildTable(screenSize)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Size screenSize) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: EdgeInsets.all(screenSize.width * 0.025),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Icon(
              Icons.arrow_back,
              color: Colors.blue.shade300,
              size: screenSize.width * 0.07,
            ),
          ),
        ),
        SizedBox(width: screenSize.width * 0.03),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Historial de Calorías',
                style: TextStyle(
                  fontSize: screenSize.width * 0.055,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Seguimiento diario de actividad',
                style: TextStyle(
                  fontSize: screenSize.width * 0.032,
                  color: Colors.grey.shade400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards(Size screenSize) {
    final totalCalories = _records.fold<double>(
      0,
      (sum, record) => sum + record.calories,
    );
    final avgCalories = _records.isNotEmpty
        ? totalCalories / _records.length
        : 0;
    final goalsReached = _records.where((record) => record.goalReached).length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total',
            '${totalCalories.toInt()}',
            'cal',
            Colors.blue,
            screenSize,
          ),
        ),
        SizedBox(width: screenSize.width * 0.02),
        Expanded(
          child: _buildStatCard(
            'Promedio',
            '${avgCalories.toInt()}',
            'cal/día',
            Colors.green,
            screenSize,
          ),
        ),
        SizedBox(width: screenSize.width * 0.02),
        Expanded(
          child: _buildStatCard(
            'Metas',
            '$goalsReached',
            'días',
            Colors.orange,
            screenSize,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String unit,
    Color color,
    Size screenSize,
  ) {
    return Container(
      padding: EdgeInsets.all(screenSize.width * 0.03),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: screenSize.width * 0.028,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: screenSize.width * 0.04,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: screenSize.width * 0.022,
              color: color.withOpacity(0.7),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(Size screenSize) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.width * 0.03,
        vertical: screenSize.height * 0.012,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Fecha',
              style: TextStyle(
                fontSize: screenSize.width * 0.032,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade300,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Calorías',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenSize.width * 0.032,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade300,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Estado',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenSize.width * 0.032,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade300,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(Size screenSize) {
    if (_records.isEmpty) {
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

    return ListView.builder(
      itemCount: _records.length,
      itemBuilder: (context, index) {
        final record = _records[index];
        return _buildTableRow(record, screenSize, index);
      },
    );
  }

  Widget _buildTableRow(DailyCalories record, Size screenSize, int index) {
    final isToday = _isToday(record.date);
    final progressColor = ColorUtils.getProgressColor(record.calories);

    return Container(
      margin: EdgeInsets.only(bottom: screenSize.height * 0.008),
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.width * 0.03,
        vertical: screenSize.height * 0.012,
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
                Text(
                  record.formattedDate,
                  style: TextStyle(
                    fontSize: screenSize.width * 0.032,
                    fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
                    color: isToday ? progressColor : Colors.grey.shade300,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (isToday)
                  Text(
                    'Hoy',
                    style: TextStyle(
                      fontSize: screenSize.width * 0.024,
                      color: progressColor.withOpacity(0.8),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Text(
                  '${record.calories.toInt()}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenSize.width * 0.035,
                    fontWeight: FontWeight.bold,
                    color: progressColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Container(
                  width: screenSize.width * 0.12,
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
              size: screenSize.width * 0.045,
            ),
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
