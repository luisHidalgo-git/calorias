import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Inicializa el servicio de notificaciones
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Verificar permisos de notificación
      final permissionStatus = await Permission.notification.status;
      if (!permissionStatus.isGranted) {
        debugPrint('Permisos de notificación no concedidos');
        return false;
      }

      // Configuración para Android
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      // Configuración para iOS
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Configuración general
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Inicializar
      final result = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _isInitialized = result ?? false;

      if (_isInitialized) {
        debugPrint('Servicio de notificaciones inicializado correctamente');
        await _createNotificationChannels();
      } else {
        debugPrint('Error al inicializar el servicio de notificaciones');
      }

      return _isInitialized;
    } catch (e) {
      debugPrint('Error al inicializar notificaciones: $e');
      return false;
    }
  }

  /// Crea los canales de notificación para Android
  Future<void> _createNotificationChannels() async {
    // Canal para notificaciones de progreso
    const progressChannel = AndroidNotificationChannel(
      'progress_channel',
      'Progreso de Actividad',
      description:
          'Notificaciones sobre el progreso de calorías y actividad física',
      importance: Importance.defaultImportance,
      enableVibration: true,
    );

    // Canal para logros
    const achievementChannel = AndroidNotificationChannel(
      'achievement_channel',
      'Logros y Metas',
      description: 'Notificaciones cuando alcances tus metas diarias',
      importance: Importance.high,
      enableVibration: true,
      enableLights: true,
    );

    // Canal para recordatorios
    const reminderChannel = AndroidNotificationChannel(
      'reminder_channel',
      'Recordatorios',
      description: 'Recordatorios para mantenerte activo',
      importance: Importance.defaultImportance,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(progressChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(achievementChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(reminderChannel);
  }

  /// Maneja cuando se toca una notificación
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notificación tocada: ${response.payload}');
    // Aquí puedes agregar lógica para navegar a pantallas específicas
  }

  /// Muestra una notificación de progreso
  Future<void> showProgressNotification({
    required double calories,
    required double goal,
  }) async {
    if (!_isInitialized) return;

    final percentage = ((calories / goal) * 100).round();

    // Crear notificación con progreso usando la versión compatible
    const androidDetails = AndroidNotificationDetails(
      'progress_channel',
      'Progreso de Actividad',
      channelDescription: 'Notificaciones sobre el progreso de calorías',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      showProgress: true,
      maxProgress: 100,
      progress: 0, // Se establecerá dinámicamente
      onlyAlertOnce: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
    );

    // Crear nueva instancia con el progreso actualizado
    final updatedAndroidDetails = AndroidNotificationDetails(
      'progress_channel',
      'Progreso de Actividad',
      channelDescription: 'Notificaciones sobre el progreso de calorías',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      showProgress: true,
      maxProgress: 100,
      progress: percentage,
      onlyAlertOnce: true,
    );

    final details = NotificationDetails(
      android: updatedAndroidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      1, // ID único para notificaciones de progreso
      'Progreso de Calorías',
      'Has quemado ${calories.toInt()} de ${goal.toInt()} calorías ($percentage%)',
      details,
      payload: 'progress:$calories:$goal',
    );
  }

  /// Muestra una notificación de logro
  Future<void> showAchievementNotification({
    required String title,
    required String message,
  }) async {
    if (!_isInitialized) return;

    const androidDetails = AndroidNotificationDetails(
      'achievement_channel',
      'Logros y Metas',
      channelDescription: 'Notificaciones de logros alcanzados',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      enableLights: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      2, // ID único para notificaciones de logros
      title,
      message,
      details,
      payload: 'achievement:$title',
    );
  }

  /// Muestra una notificación de recordatorio
  Future<void> showReminderNotification({required String message}) async {
    if (!_isInitialized) return;

    const androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Recordatorios',
      channelDescription: 'Recordatorios para mantenerte activo',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      3, // ID único para recordatorios
      'Mantente Activo',
      message,
      details,
      payload: 'reminder',
    );
  }

  /// Cancela todas las notificaciones
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Cancela una notificación específica
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Verifica si las notificaciones están habilitadas
  Future<bool> areNotificationsEnabled() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }
}
