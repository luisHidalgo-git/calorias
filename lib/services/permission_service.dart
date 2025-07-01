import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = 
      FlutterLocalNotificationsPlugin();

  /// Inicializa el servicio de notificaciones
  Future<void> initialize() async {
    // Configuración para Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuración para iOS
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  /// Solicita permisos de notificaciones
  Future<bool> requestNotificationPermissions() async {
    if (Platform.isAndroid) {
      return await _requestAndroidNotificationPermissions();
    } else if (Platform.isIOS) {
      return await _requestIOSNotificationPermissions();
    }
    return false;
  }

  /// Solicita permisos específicos de Android
  Future<bool> _requestAndroidNotificationPermissions() async {
    // Para Android 13+ (API 33+)
    if (Platform.isAndroid) {
      final androidInfo = await _getAndroidVersion();
      
      if (androidInfo >= 33) {
        // Android 13+ requiere permiso POST_NOTIFICATIONS
        final status = await Permission.notification.request();
        
        if (status.isGranted) {
          print('✅ Permisos de notificación concedidos');
          return true;
        } else if (status.isDenied) {
          print('❌ Permisos de notificación denegados');
          return false;
        } else if (status.isPermanentlyDenied) {
          print('⚠️ Permisos de notificación denegados permanentemente');
          await _showPermissionDialog();
          return false;
        }
      } else {
        // Para versiones anteriores de Android, las notificaciones están habilitadas por defecto
        print('✅ Notificaciones habilitadas (Android < 13)');
        return true;
      }
    }
    
    return false;
  }

  /// Solicita permisos específicos de iOS
  Future<bool> _requestIOSNotificationPermissions() async {
    final bool? result = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    
    if (result == true) {
      print('✅ Permisos de notificación iOS concedidos');
      return true;
    } else {
      print('❌ Permisos de notificación iOS denegados');
      return false;
    }
  }

  /// Verifica si los permisos de notificación están concedidos
  Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      final androidInfo = await _getAndroidVersion();
      
      if (androidInfo >= 33) {
        final status = await Permission.notification.status;
        return status.isGranted;
      } else {
        // Para versiones anteriores, verificar si las notificaciones están habilitadas
        return await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.areNotificationsEnabled() ?? false;
      }
    } else if (Platform.isIOS) {
      final bool? result = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: false,
            badge: false,
            sound: false,
          );
      return result ?? false;
    }
    
    return false;
  }

  /// Solicita permisos adicionales para wearables
  Future<Map<String, bool>> requestWearablePermissions() async {
    final Map<String, bool> results = {};
    
    // Permisos para sensores corporales
    final bodySensorsStatus = await Permission.sensors.request();
    results['body_sensors'] = bodySensorsStatus.isGranted;
    
    // Permisos para reconocimiento de actividad
    final activityRecognitionStatus = await Permission.activityRecognition.request();
    results['activity_recognition'] = activityRecognitionStatus.isGranted;
    
    // Permisos para notificaciones
    final notificationStatus = await requestNotificationPermissions();
    results['notifications'] = notificationStatus;
    
    print('📊 Estado de permisos wearable: $results');
    return results;
  }

  /// Verifica el estado de todos los permisos
  Future<Map<String, PermissionStatus>> checkAllPermissions() async {
    final Map<String, PermissionStatus> permissions = {};
    
    permissions['notifications'] = await Permission.notification.status;
    permissions['body_sensors'] = await Permission.sensors.status;
    permissions['activity_recognition'] = await Permission.activityRecognition.status;
    
    return permissions;
  }

  /// Abre la configuración de la aplicación
  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  /// Obtiene la versión de Android
  Future<int> _getAndroidVersion() async {
    if (Platform.isAndroid) {
      // Esto es una aproximación, en una implementación real usarías device_info_plus
      return 33; // Asumimos Android 13+ para este ejemplo
    }
    return 0;
  }

  /// Muestra un diálogo explicando por qué se necesitan los permisos
  Future<void> _showPermissionDialog() async {
    // Este método sería implementado en la UI para mostrar un diálogo
    print('⚠️ Se debe mostrar diálogo explicativo de permisos');
  }

  /// Crea un canal de notificación para Android
  Future<void> createNotificationChannel() async {
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'smartwatch_calories_channel',
        'Smartwatch Calories',
        description: 'Notificaciones de seguimiento de calorías y actividad física',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      );

      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
      
      print('📱 Canal de notificación creado: ${channel.id}');
    }
  }

  /// Muestra una notificación de prueba
  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'smartwatch_calories_channel',
      'Smartwatch Calories',
      channelDescription: 'Notificaciones de seguimiento de calorías',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
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
      0,
      '🔥 Smartwatch Calories',
      'Permisos de notificación configurados correctamente',
      platformChannelSpecifics,
    );
  }

  /// Programa una notificación de recordatorio
  Future<void> scheduleActivityReminder() async {
    await _notificationsPlugin.periodicallyShow(
      1,
      '⏰ Recordatorio de Actividad',
      '¡Es hora de moverte! Mantén tu objetivo de calorías.',
      RepeatInterval.hourly,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'smartwatch_calories_channel',
          'Smartwatch Calories',
          channelDescription: 'Recordatorios de actividad',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// Cancela todas las notificaciones programadas
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    print('🚫 Todas las notificaciones canceladas');
  }
}