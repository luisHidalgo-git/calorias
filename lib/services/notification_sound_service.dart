import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationSoundService {
  static final NotificationSoundService _instance = NotificationSoundService._internal();
  factory NotificationSoundService() => _instance;
  NotificationSoundService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  bool _isInitialized = false;
  bool _soundEnabled = true;

  /// Inicializa el servicio de sonidos de notificación
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Configuración para Android
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // Configuración para iOS
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _notificationsPlugin.initialize(initializationSettings);

      // Crear canal de notificación para Android
      if (Platform.isAndroid) {
        await _createNotificationChannel();
      }

      // Solicitar permisos
      await _requestPermissions();

      _isInitialized = true;
      print('✅ NotificationSoundService initialized successfully');
    } catch (e) {
      print('❌ Error initializing NotificationSoundService: $e');
    }
  }

  /// Crea el canal de notificación para Android
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'calorie_notifications',
      'Notificaciones de Calorías',
      description: 'Notificaciones de actividad física y calorías quemadas',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Solicita los permisos necesarios
  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      final androidInfo = await _getAndroidVersion();
      
      if (androidInfo >= 33) {
        await Permission.notification.request();
      }
    } else if (Platform.isIOS) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  /// Reproduce sonido de notificación para nueva actividad
  Future<void> playActivityNotificationSound() async {
    if (!_soundEnabled) return;

    try {
      // Reproducir sonido usando audioplayers (más confiable)
      await _playSystemSound();
      
      // También mostrar notificación local si está disponible
      await _showLocalNotification(
        title: '🔥 Nueva Actividad',
        body: 'Se han registrado nuevas calorías quemadas',
      );
      
      print('🔊 Activity notification sound played');
    } catch (e) {
      print('❌ Error playing activity notification sound: $e');
      // Fallback: usar sonido del sistema
      await _playFallbackSound();
    }
  }

  /// Reproduce sonido para mensajes MQTT
  Future<void> playMqttMessageSound() async {
    if (!_soundEnabled) return;

    try {
      await _playSystemSound();
      print('🔊 MQTT message sound played');
    } catch (e) {
      print('❌ Error playing MQTT message sound: $e');
      await _playFallbackSound();
    }
  }

  /// Reproduce sonido para meta alcanzada
  Future<void> playGoalReachedSound() async {
    if (!_soundEnabled) return;

    try {
      // Sonido más largo para celebración
      await _playSystemSound();
      await Future.delayed(Duration(milliseconds: 200));
      await _playSystemSound();
      
      await _showLocalNotification(
        title: '🎉 ¡Meta Alcanzada!',
        body: 'Has completado tu objetivo diario de calorías',
      );
      
      print('🔊 Goal reached sound played');
    } catch (e) {
      print('❌ Error playing goal reached sound: $e');
      await _playFallbackSound();
    }
  }

  /// Reproduce el sonido del sistema
  Future<void> _playSystemSound() async {
    try {
      // Usar sonido de notificación del sistema
      await _audioPlayer.play(AssetSource('sounds/notification.mp3'));
    } catch (e) {
      // Si no hay archivo de sonido, usar vibración del sistema
      await HapticFeedback.mediumImpact();
      print('🔊 Using haptic feedback as sound fallback');
    }
  }

  /// Sonido de respaldo usando vibración
  Future<void> _playFallbackSound() async {
    try {
      await HapticFeedback.mediumImpact();
      await Future.delayed(Duration(milliseconds: 100));
      await HapticFeedback.lightImpact();
    } catch (e) {
      print('❌ Even fallback sound failed: $e');
    }
  }

  /// Muestra una notificación local
  Future<void> _showLocalNotification({
    required String title,
    required String body,
  }) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'calorie_notifications',
        'Notificaciones de Calorías',
        channelDescription: 'Notificaciones de actividad física',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _notificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        platformChannelSpecifics,
      );
    } catch (e) {
      print('❌ Error showing local notification: $e');
    }
  }

  /// Habilita o deshabilita los sonidos
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    print('🔊 Notification sounds ${enabled ? 'enabled' : 'disabled'}');
  }

  /// Verifica si los sonidos están habilitados
  bool get isSoundEnabled => _soundEnabled;

  /// Obtiene la versión de Android
  Future<int> _getAndroidVersion() async {
    if (Platform.isAndroid) {
      // Esto es una aproximación, en una implementación real usarías device_info_plus
      return 33; // Asumimos Android 13+ para este ejemplo
    }
    return 0;
  }

  /// Limpia los recursos
  void dispose() {
    _audioPlayer.dispose();
  }
}