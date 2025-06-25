import 'dart:async';
import '../models/daily_calories.dart';
import '../models/fitness_data.dart';

class CalorieService {
  static final CalorieService _instance = CalorieService._internal();
  factory CalorieService() => _instance;
  CalorieService._internal();

  final List<DailyCalories> _dailyRecords = [];
  final List<CalorieEntry> _todayEntries = [];
  final StreamController<List<DailyCalories>> _recordsController = 
      StreamController<List<DailyCalories>>.broadcast();
  final StreamController<CalorieEntry> _newEntryController = 
      StreamController<CalorieEntry>.broadcast();

  Stream<List<DailyCalories>> get recordsStream => _recordsController.stream;
  Stream<CalorieEntry> get newEntryStream => _newEntryController.stream;

  List<DailyCalories> get dailyRecords => List.unmodifiable(_dailyRecords);

  void addCalories(double amount, FitnessData fitnessData) {
    final now = DateTime.now();
    final entry = CalorieEntry(
      timestamp: now,
      calories: amount,
      description: _getActivityDescription(amount, fitnessData.intensityLevel),
    );

    _todayEntries.add(entry);
    _newEntryController.add(entry);

    // Actualizar o crear registro del día actual
    _updateTodayRecord(fitnessData.calories);
    
    // Generar datos históricos si es la primera vez
    if (_dailyRecords.length <= 1) {
      _generateHistoricalData();
    }
  }

  void _updateTodayRecord(double totalCalories) {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    // Buscar si ya existe un registro para hoy
    final existingIndex = _dailyRecords.indexWhere(
      (record) => _isSameDay(record.date, todayStart)
    );

    final todayRecord = DailyCalories(
      date: todayStart,
      calories: totalCalories,
      entries: List.from(_todayEntries),
    );

    if (existingIndex >= 0) {
      _dailyRecords[existingIndex] = todayRecord;
    } else {
      _dailyRecords.insert(0, todayRecord);
    }

    _recordsController.add(_dailyRecords);
  }

  void _generateHistoricalData() {
    final today = DateTime.now();
    
    // Generar datos para los últimos 7 días
    for (int i = 1; i <= 7; i++) {
      final date = DateTime(today.year, today.month, today.day - i);
      final calories = 150.0 + (i * 25.0) + (i % 3 * 50.0); // Datos variados
      
      final entries = _generateEntriesForDay(calories, i);
      
      _dailyRecords.add(DailyCalories(
        date: date,
        calories: calories,
        entries: entries,
      ));
    }

    _recordsController.add(_dailyRecords);
  }

  List<CalorieEntry> _generateEntriesForDay(double totalCalories, int dayOffset) {
    final date = DateTime.now().subtract(Duration(days: dayOffset));
    final entries = <CalorieEntry>[];
    
    // Simular actividades del día
    final activities = [
      'Caminata matutina',
      'Ejercicio en casa',
      'Subir escaleras',
      'Actividad ligera',
      'Caminata vespertina',
    ];

    double remaining = totalCalories;
    for (int i = 0; i < activities.length && remaining > 0; i++) {
      final amount = (remaining / (activities.length - i)) * (0.8 + (i % 3) * 0.4);
      final finalAmount = amount.clamp(10.0, remaining);
      
      entries.add(CalorieEntry(
        timestamp: DateTime(date.year, date.month, date.day, 8 + i * 2, 30),
        calories: finalAmount,
        description: activities[i],
      ));
      
      remaining -= finalAmount;
    }

    return entries;
  }

  String _getActivityDescription(double calories, int intensity) {
    if (calories < 2) return 'Actividad mínima';
    if (calories < 5) return 'Movimiento ligero';
    if (calories < 10) return 'Actividad moderada';
    return 'Actividad intensa';
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  void dispose() {
    _recordsController.close();
    _newEntryController.close();
  }
}