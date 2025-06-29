import 'package:sensors_plus/sensors_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:math' as math;

class SensorService {
  static final SensorService _instance = SensorService._internal();
  factory SensorService() => _instance;
  SensorService._internal();

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;

  bool _isInitialized = false;
  bool _isTracking = false;

  // Datos del acelerómetro
  double _lastX = 0.0;
  double _lastY = 0.0;
  double _lastZ = 0.0;

  // Contador de pasos básico
  int _stepCount = 0;
  double _lastMagnitude = 0.0;
  bool _isStepDetected = false;

  // Variable de instancia para el tiempo del último paso
  int _lastStepTime = 0;

  // Callbacks
  Function(int steps)? _onStepDetected;
  Function(double calories)? _onCaloriesCalculated;

  /// Inicializa el servicio de sensores
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Verificar permisos
      final sensorsPermission = await Permission.sensors.status;
      final activityPermission = await Permission.activityRecognition.status;

      if (!sensorsPermission.isGranted && !activityPermission.isGranted) {
        debugPrint('Permisos de sensores no concedidos');
        return false;
      }

      _isInitialized = true;
      debugPrint('Servicio de sensores inicializado correctamente');
      return true;
    } catch (e) {
      debugPrint('Error al inicializar sensores: $e');
      return false;
    }
  }

  /// Inicia el seguimiento de actividad
  Future<void> startTracking({
    Function(int steps)? onStepDetected,
    Function(double calories)? onCaloriesCalculated,
  }) async {
    if (!_isInitialized || _isTracking) return;

    _onStepDetected = onStepDetected;
    _onCaloriesCalculated = onCaloriesCalculated;

    try {
      // Suscribirse al acelerómetro
      _accelerometerSubscription = accelerometerEventStream(
        samplingPeriod: const Duration(milliseconds: 100),
      ).listen(_onAccelerometerEvent);

      // Suscribirse al giroscopio (opcional, para mejorar detección)
      _gyroscopeSubscription = gyroscopeEventStream(
        samplingPeriod: const Duration(milliseconds: 100),
      ).listen(_onGyroscopeEvent);

      _isTracking = true;
      debugPrint('Seguimiento de sensores iniciado');
    } catch (e) {
      debugPrint('Error al iniciar seguimiento de sensores: $e');
    }
  }

  /// Detiene el seguimiento de actividad
  Future<void> stopTracking() async {
    if (!_isTracking) return;

    await _accelerometerSubscription?.cancel();
    await _gyroscopeSubscription?.cancel();

    _accelerometerSubscription = null;
    _gyroscopeSubscription = null;
    _isTracking = false;

    debugPrint('Seguimiento de sensores detenido');
  }

  /// Maneja eventos del acelerómetro
  void _onAccelerometerEvent(AccelerometerEvent event) {
    // Calcular la magnitud del vector de aceleración
    final magnitude = math.sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );

    // Detectar pasos usando un algoritmo simple de detección de picos
    _detectStep(magnitude);

    // Actualizar valores anteriores
    _lastX = event.x;
    _lastY = event.y;
    _lastZ = event.z;
    _lastMagnitude = magnitude;
  }

  /// Maneja eventos del giroscopio
  void _onGyroscopeEvent(GyroscopeEvent event) {
    // Por ahora solo registramos los datos
    // Se puede usar para mejorar la detección de actividad
    debugPrint(
      'Giroscopio: x=${event.x.toStringAsFixed(2)}, '
      'y=${event.y.toStringAsFixed(2)}, '
      'z=${event.z.toStringAsFixed(2)}',
    );
  }

  /// Algoritmo simple de detección de pasos
  void _detectStep(double magnitude) {
    const double threshold = 12.0; // Umbral para detectar un paso
    const double minTimeBetweenSteps = 300; // Mínimo tiempo entre pasos (ms)

    final currentTime = DateTime.now().millisecondsSinceEpoch;

    // Detectar pico en la magnitud
    if (magnitude > threshold &&
        !_isStepDetected &&
        (currentTime - _lastStepTime) > minTimeBetweenSteps) {
      _stepCount++;
      _isStepDetected = true;
      _lastStepTime = currentTime;

      // Calcular calorías aproximadas (muy básico)
      final calories = _calculateCalories(_stepCount);

      // Notificar callbacks
      _onStepDetected?.call(_stepCount);
      _onCaloriesCalculated?.call(calories);

      debugPrint(
        'Paso detectado! Total: $_stepCount, Calorías: ${calories.toStringAsFixed(1)}',
      );

      // Reset flag después de un breve período
      Future.delayed(const Duration(milliseconds: 200), () {
        _isStepDetected = false;
      });
    }
  }

  /// Calcula calorías aproximadas basadas en pasos
  double _calculateCalories(int steps) {
    // Fórmula muy básica: aproximadamente 0.04 calorías por paso
    // En una implementación real, esto dependería del peso, altura, edad, etc.
    return steps * 0.04;
  }

  /// Simula actividad para pruebas (cuando no hay sensores reales)
  void simulateActivity() {
    if (!_isInitialized) return;

    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_isTracking) {
        timer.cancel();
        return;
      }

      // Simular detección de pasos
      _stepCount++;
      final calories = _calculateCalories(_stepCount);

      _onStepDetected?.call(_stepCount);
      _onCaloriesCalculated?.call(calories);

      debugPrint(
        'Actividad simulada - Pasos: $_stepCount, Calorías: ${calories.toStringAsFixed(1)}',
      );
    });
  }

  /// Resetea los contadores
  void resetCounters() {
    _stepCount = 0;
    debugPrint('Contadores reseteados');
  }

  /// Getters
  bool get isInitialized => _isInitialized;
  bool get isTracking => _isTracking;
  int get stepCount => _stepCount;

  /// Verifica si los sensores están disponibles
  Future<bool> areSensorsAvailable() async {
    try {
      // Intentar acceder a los sensores
      final accelerometerStream = accelerometerEventStream();
      final subscription = accelerometerStream.listen(null);
      await subscription.cancel();
      return true;
    } catch (e) {
      debugPrint('Sensores no disponibles: $e');
      return false;
    }
  }

  /// Limpia recursos
  void dispose() {
    stopTracking();
    _onStepDetected = null;
    _onCaloriesCalculated = null;
  }
}
