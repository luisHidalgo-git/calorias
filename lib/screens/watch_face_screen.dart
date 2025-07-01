import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import '../models/fitness_data.dart';
import '../models/device_connection_model.dart';
import '../services/calorie_service.dart';
import '../services/settings_service.dart';
import '../services/mqtt_communication_service.dart';
import '../utils/color_utils.dart';
import '../utils/device_utils.dart' as DeviceUtils;
import '../widgets/watch_face/watch_face_layout.dart';
import '../widgets/watch_face/watch_face_animations.dart';
import '../widgets/watch_face/watch_face_navigation.dart';
import '../widgets/watch_face/watch_face_interactions.dart';
import '../widgets/activity_message_modal.dart';
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
  final MqttCommunicationService _mqttService = MqttCommunicationService();

  // State management
  Timer? _activityTimer;
  List<CalorieEntry> _notifications = [];
  StreamSubscription? _newEntrySubscription;
  StreamSubscription? _configUpdateSubscription;
  StreamSubscription? _mqttMessageSubscription;
  StreamSubscription? _activityMessageSubscription;
  StreamSubscription? _connectionStatusSubscription;
  int _currentReadingFrequency = 3;

  // Animation controllers
  late WatchFaceAnimations _animations;

  @override
  void initState() {
    super.initState();
    _animations = WatchFaceAnimations(this);
    _setupStreams();
    _loadInitialSettings();
    _initializeMqtt();
    _startAutomaticActivity();
  }

  @override
  void dispose() {
    _animations.dispose();
    _activityTimer?.cancel();
    _newEntrySubscription?.cancel();
    _configUpdateSubscription?.cancel();
    _mqttMessageSubscription?.cancel();
    _activityMessageSubscription?.cancel();
    _connectionStatusSubscription?.cancel();
    _mqttService.dispose();
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

  Future<void> _initializeMqtt() async {
    print('🚀 Initializing MQTT service...');
    await _mqttService.initialize();

    // Escuchar estado de conexión
    _connectionStatusSubscription = _mqttService.connectionStatusStream.listen((
      status,
    ) {
      if (mounted) {
        print('📡 MQTT Connection status changed: ${status.name}');
        // Mostrar notificación de estado si es necesario
        if (status == ConnectionStatus.connected) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.wifi, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Conectado a MQTT'),
                ],
              ),
              backgroundColor: Colors.green.shade700,
              duration: Duration(seconds: 2),
            ),
          );
        } else if (status == ConnectionStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.wifi_off, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Error de conexión MQTT'),
                ],
              ),
              backgroundColor: Colors.red.shade700,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    });

    // Escuchar mensajes MQTT
    _mqttMessageSubscription = _mqttService.messageStream.listen((message) {
      if (mounted) {
        _handleMqttMessage(message);
      }
    });

    // Escuchar mensajes de actividad
    _activityMessageSubscription = _mqttService.activityMessageStream.listen((
      activityMessage,
    ) {
      if (mounted) {
        print(
          '🏃 Received activity message: ${activityMessage.activityDescription}',
        );
        _showActivityMessageModal(activityMessage);
      }
    });
  }

  void _handleMqttMessage(dynamic message) {
    try {
      print('📨 Handling MQTT message: ${message.type}');

      // Procesar mensajes de sincronización de datos
      if (message.type == 'calorie_sync' || message.type == 'data') {
        final calories = message.data['calories']?.toDouble() ?? 0.0;
        final heartRate = message.data['heartRate']?.toInt() ?? 72;

        print(
          '📊 Syncing data: ${calories.toStringAsFixed(0)} cal, $heartRate BPM',
        );

        setState(() {
          fitnessData.setCalories(calories);
          fitnessData.setHeartRate(heartRate);
        });

        _calorieService.updateCurrentCalories(calories, fitnessData);
      } else if (message.type == 'settings_sync') {
        // Sincronizar configuraciones
        final newGoal = message.data['dailyCaloriesGoal']?.toDouble();
        final newMaxHR = message.data['maxHeartRate']?.toInt();

        if (newGoal != null) {
          fitnessData.updateCaloriesGoal(newGoal);
        }
        if (newMaxHR != null) {
          fitnessData.updateMaxHeartRate(newMaxHR);
        }

        setState(() {});
      }
    } catch (e) {
      print('❌ Error handling MQTT message: $e');
    }
  }

  void _showActivityMessageModal(ActivityMessage activityMessage) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (context) =>
          ActivityMessageModal(activityMessage: activityMessage),
    );
  }

  Future<void> _sendActivityMessage() async {
    if (!_mqttService.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.red),
              SizedBox(width: 8),
              Text('No hay conexión MQTT disponible'),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      final activityDescription = ColorUtils.getActivityDescription(
        fitnessData.calories,
      );

      print('📤 Sending activity message: $activityDescription');

      await _mqttService.sendActivityMessage(
        activityDescription: activityDescription,
        calories: fitnessData.calories,
        heartRate: fitnessData.heartRate,
      );

      // Mostrar confirmación
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.send, color: Colors.green),
              SizedBox(width: 8),
              Expanded(child: Text('Mensaje enviado: $activityDescription')),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('❌ Error sending activity message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text('Error al enviar mensaje'),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          duration: Duration(seconds: 2),
        ),
      );
    }
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

    // Enviar cambios por MQTT
    _sendDataToMqtt();

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

          // Enviar datos actualizados por MQTT
          _sendDataToMqtt();
        }
      },
    );
  }

  void _sendDataToMqtt() {
    if (_mqttService.isConnected) {
      _mqttService.sendData({
        'type': 'calorie_sync',
        'calories': fitnessData.calories,
        'heartRate': fitnessData.heartRate,
        'dailyCaloriesGoal': fitnessData.dailyCaloriesGoal,
        'maxHeartRate': fitnessData.maxHeartRate,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
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
    final deviceType = DeviceUtils.DeviceUtils.getDeviceType(
      screenSize.width,
      screenSize.height,
    );
    final isWearable = deviceType == DeviceUtils.DeviceType.wearable;

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
                        _sendDataToMqtt();
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
                        _sendDataToMqtt();
                      },
                    ),
                onSendActivityMessage: _mqttService.isConnected
                    ? _sendActivityMessage
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }
}
