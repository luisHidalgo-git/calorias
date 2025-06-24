class FitnessData {
  double _calories = 0.0;
  int _heartRate = 72;

  final double dailyCaloriesGoal = 300.0;

  double get calories => _calories;
  int get heartRate => _heartRate;

  void addCalories(double amount) {
    _calories += amount;
    // Ritmo cardíaco más realista basado en la actividad
    _heartRate = _calculateHeartRate();
  }

  int _calculateHeartRate() {
    // Cálculo más realista del ritmo cardíaco
    double baseRate = 72.0;
    double activityMultiplier = (_calories / dailyCaloriesGoal).clamp(0.0, 1.0);

    // El ritmo cardíaco aumenta gradualmente con la actividad
    double targetRate = baseRate + (activityMultiplier * 50); // Máximo 122 bpm

    return targetRate.round().clamp(60, 160);
  }

  // Método para obtener el nivel de intensidad basado en calorías
  int get intensityLevel {
    if (_calories < 50) return 1;
    if (_calories < 100) return 2;
    if (_calories < 150) return 3;
    if (_calories < 200) return 4;
    return 5;
  }

  // Método para obtener el porcentaje de progreso
  double get progressPercentage {
    return (_calories / dailyCaloriesGoal).clamp(0.0, 1.0);
  }

  // Método para verificar si se alcanzó la meta
  bool get goalReached {
    return _calories >= dailyCaloriesGoal;
  }
}
