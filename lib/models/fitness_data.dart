class FitnessData {
  double _calories = 0.0;
  int _heartRate = 72;

  final double dailyCaloriesGoal = 300.0;

  double get calories => _calories;
  int get heartRate => _heartRate;

  void addCalories(double amount) {
    _calories += amount;
    _heartRate = (72 + (_calories / 8).round().clamp(0, 40)).clamp(60, 160);
  }

  void reset() {
    _calories = 0.0;
    _heartRate = 72;
  }

  // Método para obtener el nivel de intensidad basado en calorías
  int get intensityLevel {
    if (_calories < 50) return 1;
    if (_calories < 100) return 2;
    if (_calories < 200) return 3;
    if (_calories < 250) return 4;
    return 5;
  }
}