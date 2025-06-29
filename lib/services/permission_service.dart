import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  // Lista de permisos necesarios para la aplicación
  static const List<Permission> _requiredPermissions = [
    Permission.sensors,
    Permission.activityRecognition,
    Permission.notification,
  ];

  // Permisos adicionales para dispositivos específicos
  static const List<Permission> _optionalPermissions = [
    Permission.location,
    Permission.locationWhenInUse,
  ];

  /// Solicita todos los permisos necesarios
  Future<Map<Permission, PermissionStatus>> requestAllPermissions() async {
    final Map<Permission, PermissionStatus> results = {};

    // Solicitar permisos requeridos
    for (final permission in _requiredPermissions) {
      final status = await _requestSinglePermission(permission);
      results[permission] = status;
    }

    // Solicitar permisos opcionales (sin bloquear la app si se niegan)
    for (final permission in _optionalPermissions) {
      final status = await _requestSinglePermission(permission, isOptional: true);
      results[permission] = status;
    }

    return results;
  }

  /// Solicita un permiso específico
  Future<PermissionStatus> _requestSinglePermission(
    Permission permission, {
    bool isOptional = false,
  }) async {
    try {
      // Verificar si el permiso ya está concedido
      final currentStatus = await permission.status;
      
      if (currentStatus.isGranted) {
        debugPrint('Permiso ${permission.toString()} ya concedido');
        return currentStatus;
      }

      // Si el permiso fue negado permanentemente
      if (currentStatus.isPermanentlyDenied) {
        debugPrint('Permiso ${permission.toString()} negado permanentemente');
        if (!isOptional) {
          // Para permisos críticos, mostrar diálogo para ir a configuración
          await _showSettingsDialog(permission);
        }
        return currentStatus;
      }

      // Solicitar el permiso
      debugPrint('Solicitando permiso: ${permission.toString()}');
      final newStatus = await permission.request();
      
      debugPrint('Estado del permiso ${permission.toString()}: ${newStatus.toString()}');
      return newStatus;

    } catch (e) {
      debugPrint('Error al solicitar permiso ${permission.toString()}: $e');
      return PermissionStatus.denied;
    }
  }

  /// Verifica si todos los permisos críticos están concedidos
  Future<bool> areRequiredPermissionsGranted() async {
    for (final permission in _requiredPermissions) {
      final status = await permission.status;
      if (!status.isGranted) {
        return false;
      }
    }
    return true;
  }

  /// Verifica el estado de un permiso específico
  Future<PermissionStatus> checkPermissionStatus(Permission permission) async {
    return await permission.status;
  }

  /// Abre la configuración de la aplicación
  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }

  /// Muestra un diálogo para ir a configuración (implementación básica)
  Future<void> _showSettingsDialog(Permission permission) async {
    debugPrint('Se debería mostrar diálogo para configurar ${permission.toString()}');
    // Esta función se puede expandir para mostrar un diálogo real
    // Por ahora solo registra el evento
  }

  /// Obtiene una descripción amigable del permiso
  String getPermissionDescription(Permission permission) {
    switch (permission) {
      case Permission.sensors:
        return 'Acceso a sensores de movimiento para detectar actividad física';
      case Permission.activityRecognition:
        return 'Reconocimiento de actividad para contar pasos y calorías';
      case Permission.notification:
        return 'Mostrar notificaciones de progreso y logros';
      case Permission.location:
        return 'Ubicación para mejorar el seguimiento de actividades';
      case Permission.locationWhenInUse:
        return 'Ubicación durante el uso de la aplicación';
      default:
        return 'Permiso necesario para el funcionamiento de la aplicación';
    }
  }

  /// Obtiene el estado de todos los permisos
  Future<Map<Permission, PermissionStatus>> getAllPermissionsStatus() async {
    final Map<Permission, PermissionStatus> statuses = {};
    
    final allPermissions = [..._requiredPermissions, ..._optionalPermissions];
    
    for (final permission in allPermissions) {
      statuses[permission] = await permission.status;
    }
    
    return statuses;
  }

  /// Verifica si la aplicación puede funcionar con los permisos actuales
  Future<bool> canAppFunction() async {
    // Al menos necesitamos sensores o reconocimiento de actividad
    final sensorsStatus = await Permission.sensors.status;
    final activityStatus = await Permission.activityRecognition.status;
    
    return sensorsStatus.isGranted || activityStatus.isGranted;
  }
}