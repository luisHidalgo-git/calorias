import 'package:flutter/material.dart';
import 'dart:async';
import '../models/daily_calories.dart';
import '../services/calorie_service.dart';
import '../utils/device_utils.dart' as DeviceUtils;
import '../widgets/adaptive_container.dart';
import '../widgets/stats/stats_section.dart';
import '../widgets/table/table_header.dart';
import '../widgets/table/table_list.dart';
import '../widgets/headers/wearable_header.dart';
import '../widgets/headers/phone_header.dart';

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
    final deviceType = DeviceUtils.DeviceUtils.getDeviceType(screenSize.width, screenSize.height);
    final isWearable = deviceType == DeviceUtils.DeviceType.wearable;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: isWearable 
              ? _buildWearableLayout(screenSize)
              : _buildPhoneLayout(screenSize),
        ),
      ),
    );
  }

  Widget _buildWearableLayout(Size screenSize) {
    final isRound = _isRoundScreen(screenSize);
    
    return AdaptiveContainer(
      padding: EdgeInsets.all(screenSize.width * (isRound ? 0.02 : 0.04)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WearableHeader(
            screenSize: screenSize,
            isRound: isRound,
            onBack: () => Navigator.pop(context),
          ),
          SizedBox(height: screenSize.height * (isRound ? 0.008 : 0.025)),
          StatsSection(records: _records, screenSize: screenSize),
          SizedBox(height: screenSize.height * (isRound ? 0.008 : 0.025)),
          if (!isRound) ...[
            TableHeader(screenSize: screenSize, isRound: isRound),
            SizedBox(height: screenSize.height * 0.015),
          ],
          Expanded(
            child: TableList(
              records: _records,
              screenSize: screenSize,
              isRound: isRound,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneLayout(Size screenSize) {
    return Padding(
      padding: EdgeInsets.all(screenSize.width * 0.05),
      child: Column(
        children: [
          PhoneHeader(
            screenSize: screenSize,
            onBack: () => Navigator.pop(context),
          ),
          SizedBox(height: screenSize.height * 0.03),
          _buildPhoneStatsSection(screenSize),
          SizedBox(height: screenSize.height * 0.03),
          Expanded(child: _buildPhoneTableSection(screenSize)),
        ],
      ),
    );
  }

  Widget _buildPhoneStatsSection(Size screenSize) {
    final totalCalories = _records.fold<double>(0, (sum, record) => sum + record.calories);
    final avgCalories = _records.isNotEmpty ? totalCalories / _records.length : 0;
    final goalsReached = _records.where((record) => record.goalReached).length;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade900.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estadísticas Generales',
            style: TextStyle(
              fontSize: screenSize.width * 0.05,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPhoneStatCard(
                  'Total',
                  '${totalCalories.toInt()}',
                  'cal',
                  Colors.blue,
                  screenSize,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildPhoneStatCard(
                  'Promedio',
                  '${avgCalories.toInt()}',
                  'cal/día',
                  Colors.green,
                  screenSize,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildPhoneStatCard(
                  'Metas',
                  '$goalsReached',
                  'días',
                  Colors.orange,
                  screenSize,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneStatCard(String title, String value, String unit, Color color, Size screenSize) {
    return Container(
      padding: EdgeInsets.all(16),
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
              fontSize: screenSize.width * 0.035,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
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
              fontSize: screenSize.width * 0.03,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneTableSection(Size screenSize) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Fecha',
                    style: TextStyle(
                      fontSize: screenSize.width * 0.04,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade300,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Calorías',
                    style: TextStyle(
                      fontSize: screenSize.width * 0.04,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade300,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Estado',
                    style: TextStyle(
                      fontSize: screenSize.width * 0.04,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade300,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TableList(
              records: _records,
              screenSize: screenSize,
              isRound: false,
            ),
          ),
        ],
      ),
    );
  }

  bool _isRoundScreen(Size screenSize) {
    final aspectRatio = screenSize.width / screenSize.height;
    return (aspectRatio > 0.9 && aspectRatio < 1.1);
  }
}