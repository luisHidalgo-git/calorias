class FitnessData {
  double _calories = 0.0;
  double _distance = 0.0;
  int _heartRate = 72;

  final double dailyCaloriesGoal = 400.0;

  double get calories => _calories;
  double get distance => _distance;
  int get heartRate => _heartRate;

  void addCalories(double amount) {
    _calories += amount;
    _distance = _calories * 0.02; // Approximate: 0.02km per 5 calories
    _heartRate = (72 + (_calories / 5).round().clamp(0, 50)).clamp(60, 180);
  }

  void reset() {
    _calories = 0.0;
    _distance = 0.0;
    _heartRate = 72;
  }
}