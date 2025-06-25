class DailyCalories {
  final DateTime date;
  final double calories;
  final List<CalorieEntry> entries;

  DailyCalories({
    required this.date,
    required this.calories,
    required this.entries,
  });

  String get formattedDate {
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  bool get goalReached => calories >= 300.0;
}

class CalorieEntry {
  final DateTime timestamp;
  final double calories;
  final String description;

  CalorieEntry({
    required this.timestamp,
    required this.calories,
    required this.description,
  });

  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}