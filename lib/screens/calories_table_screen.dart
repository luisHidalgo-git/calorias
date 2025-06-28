import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import '../models/daily_calories.dart';
import '../services/calorie_service.dart';
import '../utils/color_utils.dart';
import '../utils/screen_utils.dart';
import '../widgets/adaptive_container.dart';
import '../widgets/adaptive_text.dart';
import '../widgets/stats_card.dart';
import '../widgets/table_row_widget.dart';
import '../widgets/watch_button.dart';

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
    final isRound = ScreenUtils.isRoundScreen(screenSize);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: AdaptiveContainer(
            padding: EdgeInsets.all(screenSize.width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(screenSize, isRound),
                SizedBox(height: screenSize.height * 0.025),
                _buildStatsCards(screenSize),
                SizedBox(height: screenSize.height * 0.025),
                _buildTableHeader(screenSize, isRound),
                SizedBox(height: screenSize.height * 0.015),
                Expanded(child: _buildTable(screenSize)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Size screenSize, bool isRound) {
    final watchSize = ScreenUtils.getAdaptiveSize(
      screenSize,
      math.min(screenSize.width, screenSize.height) * 0.7,
    );

    if (isRound) {
      return Column(
        children: [
          // Botón centrado para pantallas redondas
          Center(
            child: WatchButton(
              onTap: () => Navigator.pop(context),
              icon: Icons.arrow_back,
              color: Colors.blue.shade300,
              size: watchSize,
            ),
          ),
          SizedBox(height: screenSize.height * 0.02),
          // Títulos centrados
          Center(
            child: Column(
              children: [
                AdaptiveText(
                  'Historial de Calorías',
                  fontSize: screenSize.width * 0.055,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenSize.height * 0.005),
                AdaptiveText(
                  'Seguimiento diario de actividad',
                  fontSize: screenSize.width * 0.032,
                  color: Colors.grey.shade400,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      // Layout horizontal para pantallas cuadradas
      return Row(
        children: [
          WatchButton(
            onTap: () => Navigator.pop(context),
            icon: Icons.arrow_back,
            color: Colors.blue.shade300,
            size: watchSize,
          ),
          SizedBox(width: screenSize.width * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdaptiveText(
                  'Historial de Calorías',
                  fontSize: screenSize.width * 0.055,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  overflow: TextOverflow.ellipsis,
                ),
                AdaptiveText(
                  'Seguimiento diario de actividad',
                  fontSize: screenSize.width * 0.032,
                  color: Colors.grey.shade400,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      );
    }
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

  Widget _buildTableHeader(Size screenSize, bool isRound) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.width * (isRound ? 0.025 : 0.03),
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
            child: AdaptiveText(
              'Fecha',
              fontSize: screenSize.width * 0.032,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade300,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 3,
            child: AdaptiveText(
              'Calorías',
              fontSize: screenSize.width * 0.032,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade300,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: AdaptiveText(
              'Estado',
              fontSize: screenSize.width * 0.032,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade300,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(Size screenSize) {
    if (_records.isEmpty) {
      return _buildEmptyState(screenSize);
    }

    return ListView.builder(
      itemCount: _records.length,
      itemBuilder: (context, index) {
        final record = _records[index];
        final isToday = _isToday(record.date);
        return TableRowWidget(record: record, isToday: isToday);
      },
    );
  }

  Widget _buildEmptyState(Size screenSize) {
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
          AdaptiveText(
            'No hay datos disponibles',
            fontSize: screenSize.width * 0.035,
            color: Colors.grey.shade500,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenSize.height * 0.01),
          AdaptiveText(
            'Comienza a hacer ejercicio para ver tu progreso',
            fontSize: screenSize.width * 0.028,
            color: Colors.grey.shade600,
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
