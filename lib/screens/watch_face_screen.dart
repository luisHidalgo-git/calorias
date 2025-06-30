import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import '../models/fitness_data.dart';
import '../services/calorie_service.dart';
import '../services/settings_service.dart';
import '../utils/color_utils.dart';
import '../utils/device_utils.dart';
import '../widgets/watch_face/watch_face_layout.dart';
import '../widgets/watch_face/watch_face_animations.dart';
import '../widgets/watch_face/watch_face_navigation.dart';
import '../widgets/watch_face/watch_face_interactions.dart';
import '../models/daily_calories.dart';

class WatchFaceScreen extends StatefulWidget {
  const WatchFaceScreen({super.key});

  @override
  _WatchFaceScreenState createState() => _WatchFaceScreenState();
}

class _WatchFaceScreenState extends State<WatchFaceScreen>
    with TickerProviderStateMixin {
  // Core data
  FitnessData fitnessData = FitnessData();
  final CalorieService _calorieService = CalorieService();
  final SettingsService _settingsService = SettingsService();

  // State management
  Timer? _activityTimer;
  List<CalorieEntry> _notifications = [];
  StreamSubscription? _newEntrySubscription;
  StreamSubscription? _configUpdateSubscription;
  int _currentReadingFrequency = 3;

  // Animation controllers
  late WatchFaceAnimations _animations;

  @override
  void initState() {
    super.initState();
    _animations = WatchFaceAnimations(this);
    _setupStreams();
    _loadInitialSettings();
    _startAutomaticActivity();
  }

  @override
  void dispose() {
    _animations.dispose();
    _activityTimer?.cancel();
    _newEntrySubscription?.cancel();
    _configUpdateSubscription?.cancel();
    super.dispose();
  }

  void _setupStreams() {
    _newEntrySubscription = _calorieService.newEntryStream.listen((entry) {
      if (mounted) {
        setState(() {
          _notifications.add(entry);
        });
      }
    });

    _configUpdateSubscription = _settingsService.configUpdateStream.listen((
      config,
    ) {
      if (mounted) {
        _applyConfigurationChanges(config);
      }
    });
  }

  Future<void> _loadInitialSettings() async {
    await _settingsService.loadSettings();
    final settings = _settingsService.currentSettings;

    fitnessData.applySettings({
      'dailyCaloriesGoal': settings.dailyCaloriesGoal,
      'maxHeartRate': settings.maxHeartRate,
    });

    _currentReadingFrequency = settings.readingFrequency;

    if (mounted) {
      setState(() {});
    }
  }

  void _applyConfigurationChanges(Map<String, dynamic> config) {
    fitnessData.applySettings(config);

    if (config.containsKey('readingFrequency')) {
      final newFrequency = config['readingFrequency'] as int;
      if (newFrequency != _currentReadingFrequency) {
        _currentReadingFrequency = newFrequency;
        _restartActivityTimer();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.update, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Frecuencia actualizada: cada $_currentReadingFrequency segundos',
                ),
              ],
            ),
            backgroundColor: Colors.blue.shade700,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }

    setState(() {});
  }

  void _restartActivityTimer() {
    _activityTimer?.cancel();
    _startAutomaticActivity();
  }

  void _startAutomaticActivity() {
    _activityTimer = Timer.periodic(
      Duration(seconds: _currentReadingFrequency),
      (timer) {
        if (mounted) {
          final wasGoalReached = fitnessData.goalReached;

          setState(() {
            double increment = 1.0 + (math.Random().nextDouble() * 2.0);
            fitnessData.addCalories(increment);

            if (!wasGoalReached && fitnessData.calories == 0.0) {
              _showGoalReachedAnimation();
              _calorieService.resetDailyProgress();
            } else {
              _calorieService.addCalories(increment, fitnessData);
            }
          });

          _animations.triggerBackgroundPulse();
        }
      },
    );
  }

  void _showGoalReachedAnimation() {
    _animations.triggerGoalReached();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.celebration, color: Colors.orange),
              SizedBox(width: 8),
              Text('¡Meta alcanzada! Reiniciando...'),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final deviceType = DeviceUtils.getDeviceType(
      screenSize.width,
      screenSize.height,
    );
    final isWearable = deviceType == DeviceType.wearable;

    final backgroundColor = ColorUtils.getBackgroundColor(fitnessData.calories);
    final progressColor = ColorUtils.getProgressColor(fitnessData.calories);
    final accentColor = ColorUtils.getAccentColor(fitnessData.calories);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animations.backgroundAnimation,
          builder: (context, child) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    Color.lerp(
                      backgroundColor,
                      accentColor,
                      _animations.backgroundAnimation.value * 0.08,
                    )!,
                    backgroundColor.withOpacity(0.6),
                    Colors.black,
                  ],
                  stops: [0.0, 0.7, 1.0],
                ),
              ),
              child: WatchFaceLayout(
                isWearable: isWearable,
                screenSize: screenSize,
                fitnessData: fitnessData,
                notifications: _notifications,
                animations: _animations,
                accentColor: accentColor,
                progressColor: progressColor,
                onNavigateToTable: () =>
                    WatchFaceNavigation.navigateToTable(context),
                onNavigateToSettings: () =>
                    WatchFaceNavigation.navigateToSettings(context),
                onShowNotifications: () =>
                    WatchFaceNavigation.showNotificationsPanel(
                      context,
                      _notifications,
                      () {
                        setState(() {
                          _notifications.clear();
                        });
                      },
                    ),
                onShowCaloriesAdjustment: () =>
                    WatchFaceInteractions.showCaloriesAdjustment(
                      context,
                      fitnessData,
                      (newValue) {
                        setState(() {
                          fitnessData.setCalories(newValue);
                          _calorieService.updateCurrentCalories(
                            newValue,
                            fitnessData,
                          );
                        });
                      },
                    ),
                onShowHeartRateAdjustment: () =>
                    WatchFaceInteractions.showHeartRateAdjustment(
                      context,
                      fitnessData,
                      (newValue) {
                        setState(() {
                          fitnessData.setHeartRate(newValue.toInt());
                          _calorieService.updateCurrentCalories(
                            fitnessData.calories,
                            fitnessData,
                          );
                        });
                      },
                    ),
              ),
            );
          },
        ),
      ),
    );
  }
}
