class FitnessData {
  double _calories = 0.0;
  int _heartRate = 72;
  double _dailyCaloriesGoal = 300.0; // Hacer modificable
  int _maxHeartRate = 150; // Hacer modificable

  double get calories => _calories;
  int get heartRate => _heartRate;
  double get dailyCaloriesGoal => _dailyCaloriesGoal;
  int get maxHeartRate => _maxHeartRate;

  // Métodos para actualizar configuraciones
  void updateCaloriesGoal(double newGoal) {
    _dailyCaloriesGoal = newGoal;
  }

  void updateMaxHeartRate(int newMaxHR) {
    _maxHeartRate = newMaxHR;
  }

  void addCalories(double amount) {
    _calories += amount;

    // Si alcanza o supera el 100% del objetivo, reiniciar
    if (_calories >= _dailyCaloriesGoal) {
      _resetGoal();
    } else {
      // Ritmo cardíaco más realista basado en la actividad
      _heartRate = _calculateHeartRate();
    }
  }

  void _resetGoal() {
    // Reiniciar calorías a 0
    _calories = 0.0;
    // Reiniciar ritmo cardíaco a valor base
    _heartRate = 72;
  }

  int _calculateHeartRate() {
    // Cálculo más realista del ritmo cardíaco
    double baseRate = 72.0;
    double activityMultiplier = (_calories / _dailyCaloriesGoal).clamp(
      0.0,
      1.0,
    );

    // El ritmo cardíaco aumenta gradualmente con la actividad
    double targetRate = baseRate + (activityMultiplier * 50); // Máximo 122 bpm

    return targetRate.round().clamp(60, _maxHeartRate);
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
    return (_calories / _dailyCaloriesGoal).clamp(0.0, 1.0);
  }

  // Método para verificar si se alcanzó la meta
  bool get goalReached {
    return _calories >= _dailyCaloriesGoal;
  }

  // Método para aplicar configuraciones desde settings
  void applySettings(Map<String, dynamic> settings) {
    if (settings.containsKey('dailyCaloriesGoal')) {
      _dailyCaloriesGoal = settings['dailyCaloriesGoal'].toDouble();
    }
    if (settings.containsKey('maxHeartRate')) {
      _maxHeartRate = settings['maxHeartRate'];
    }
  }
}
