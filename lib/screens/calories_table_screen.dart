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
            padding: EdgeInsets.all(screenSize.width * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(screenSize),
                SizedBox(height: screenSize.height * 0.03),
                _buildStatsCards(screenSize),
                SizedBox(height: screenSize.height * 0.03),
                _buildTableHeader(screenSize),
                SizedBox(height: screenSize.height * 0.02),
                Expanded(child: _buildTable(screenSize)),
                SizedBox(height: screenSize.height * 0.02),
                _buildBackButton(screenSize),
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
        Container(
          padding: EdgeInsets.all(screenSize.width * 0.03),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Icon(
            Icons.analytics_outlined,
            color: Colors.blue.shade300,
            size: screenSize.width * 0.08,
          ),
        ),
        SizedBox(width: screenSize.width * 0.04),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Historial de Calorías',
                style: TextStyle(
                  fontSize: screenSize.width * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Seguimiento diario de actividad',
                style: TextStyle(
                  fontSize: screenSize.width * 0.035,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards(Size screenSize) {
    final totalCalories = _records.fold<double>(0, (sum, record) => sum + record.calories);
    final avgCalories = _records.isNotEmpty ? totalCalories / _records.length : 0;
    final goalsReached = _records.where((record) => record.goalReached).length;

    return Row(
      children: [
        Expanded(child: _buildStatCard('Total', '${totalCalories.toInt()}', 'cal', Colors.blue, screenSize)),
        SizedBox(width: screenSize.width * 0.03),
        Expanded(child: _buildStatCard('Promedio', '${avgCalories.toInt()}', 'cal/día', Colors.green, screenSize)),
        SizedBox(width: screenSize.width * 0.03),
        Expanded(child: _buildStatCard('Metas', '$goalsReached', 'días', Colors.orange, screenSize)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String unit, Color color, Size screenSize) {
    return Container(
      padding: EdgeInsets.all(screenSize.width * 0.04),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: screenSize.width * 0.03,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: screenSize.width * 0.045,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: screenSize.width * 0.025,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(Size screenSize) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.width * 0.04,
        vertical: screenSize.height * 0.015,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Fecha',
              style: TextStyle(
                fontSize: screenSize.width * 0.035,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade300,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Calorías',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenSize.width * 0.035,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade300,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Estado',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenSize.width * 0.035,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade300,
              ),
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
              size: screenSize.width * 0.15,
              color: Colors.grey.shade600,
            ),
            SizedBox(height: screenSize.height * 0.02),
            Text(
              'No hay datos disponibles',
              style: TextStyle(
                fontSize: screenSize.width * 0.04,
                color: Colors.grey.shade500,
              ),
            ),
            Text(
              'Comienza a hacer ejercicio para ver tu progreso',
              style: TextStyle(
                fontSize: screenSize.width * 0.03,
                color: Colors.grey.shade600,
              ),
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
      margin: EdgeInsets.only(bottom: screenSize.height * 0.01),
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.width * 0.04,
        vertical: screenSize.height * 0.015,
      ),
      decoration: BoxDecoration(
        color: isToday ? progressColor.withOpacity(0.1) : Colors.grey.shade900.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isToday ? progressColor.withOpacity(0.4) : Colors.grey.shade800,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.formattedDate,
                  style: TextStyle(
                    fontSize: screenSize.width * 0.035,
                    fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
                    color: isToday ? progressColor : Colors.grey.shade300,
                  ),
                ),
                if (isToday)
                  Text(
                    'Hoy',
                    style: TextStyle(
                      fontSize: screenSize.width * 0.025,
                      color: progressColor.withOpacity(0.8),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  '${record.calories.toInt()}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenSize.width * 0.04,
                    fontWeight: FontWeight.bold,
                    color: progressColor,
                  ),
                ),
                Container(
                  width: screenSize.width * 0.15,
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
            flex: 1,
            child: Icon(
              record.goalReached ? Icons.check_circle : Icons.radio_button_unchecked,
              color: record.goalReached ? Colors.green.shade400 : Colors.grey.shade600,
              size: screenSize.width * 0.05,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(Size screenSize) {
    return Center(
      child: Container(
        width: screenSize.width * 0.4,
        child: ElevatedButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, size: screenSize.width * 0.045),
          label: Text(
            'Volver',
            style: TextStyle(fontSize: screenSize.width * 0.035),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.015),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
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