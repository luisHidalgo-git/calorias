import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/permission_service.dart';
import '../utils/device_utils.dart' as DeviceUtils;
import 'adaptive_text.dart';

class PermissionRequestDialog extends StatefulWidget {
  final VoidCallback? onPermissionsGranted;
  final VoidCallback? onPermissionsDenied;

  const PermissionRequestDialog({
    super.key,
    this.onPermissionsGranted,
    this.onPermissionsDenied,
  });

  @override
  _PermissionRequestDialogState createState() => _PermissionRequestDialogState();
}

class _PermissionRequestDialogState extends State<PermissionRequestDialog>
    with SingleTickerProviderStateMixin {
  final PermissionService _permissionService = PermissionService();
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _isLoading = false;
  Map<String, bool> _permissionResults = {};
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Inicializar el servicio de notificaciones
      await _permissionService.initialize();
      
      // Crear canal de notificación
      await _permissionService.createNotificationChannel();
      
      // Solicitar permisos
      final results = await _permissionService.requestWearablePermissions();
      
      setState(() {
        _permissionResults = results;
        _showResults = true;
        _isLoading = false;
      });

      // Verificar si todos los permisos fueron concedidos
      final allGranted = results.values.every((granted) => granted);
      
      if (allGranted) {
        // Mostrar notificación de prueba
        await _permissionService.showTestNotification();
        
        // Llamar callback de éxito
        widget.onPermissionsGranted?.call();
        
        // Cerrar diálogo después de un breve delay
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop(true);
          }
        });
      } else {
        widget.onPermissionsDenied?.call();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      print('❌ Error solicitando permisos: $e');
      widget.onPermissionsDenied?.call();
    }
  }

  Future<void> _openSettings() async {
    await openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final deviceType = DeviceUtils.DeviceUtils.getDeviceType(
      screenSize.width,
      screenSize.height,
    );
    final isWearable = deviceType == DeviceUtils.DeviceType.wearable;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: isWearable ? screenSize.width * 0.95 : screenSize.width * 0.85,
                padding: EdgeInsets.all(isWearable ? 16 : 24),
                decoration: BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.withOpacity(0.3), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(screenSize, isWearable),
                    SizedBox(height: isWearable ? 16 : 24),
                    
                    if (!_showResults) ...[
                      _buildPermissionExplanation(screenSize, isWearable),
                      SizedBox(height: isWearable ? 16 : 24),
                      _buildActionButtons(screenSize, isWearable),
                    ] else ...[
                      _buildPermissionResults(screenSize, isWearable),
                      SizedBox(height: isWearable ? 16 : 24),
                      _buildResultActions(screenSize, isWearable),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(Size screenSize, bool isWearable) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isWearable ? 8 : 12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.security,
            color: Colors.blue.shade300,
            size: isWearable ? 20 : 24,
          ),
        ),
        SizedBox(width: isWearable ? 12 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdaptiveText(
                'Permisos Necesarios',
                fontSize: screenSize.width * (isWearable ? 0.045 : 0.05),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              AdaptiveText(
                'Para el funcionamiento completo',
                fontSize: screenSize.width * (isWearable ? 0.03 : 0.035),
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
        if (!_showResults)
          GestureDetector(
            onTap: () => Navigator.of(context).pop(false),
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.close,
                color: Colors.grey.shade400,
                size: isWearable ? 16 : 20,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPermissionExplanation(Size screenSize, bool isWearable) {
    final permissions = [
      {
        'icon': Icons.notifications_active,
        'title': 'Notificaciones',
        'description': 'Para alertas de metas y recordatorios de actividad',
        'color': Colors.blue,
      },
      {
        'icon': Icons.sensors,
        'title': 'Sensores Corporales',
        'description': 'Para monitorear ritmo cardíaco y actividad física',
        'color': Colors.green,
      },
      {
        'icon': Icons.directions_run,
        'title': 'Reconocimiento de Actividad',
        'description': 'Para detectar automáticamente ejercicios y movimiento',
        'color': Colors.orange,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdaptiveText(
          'Esta aplicación necesita los siguientes permisos:',
          fontSize: screenSize.width * (isWearable ? 0.035 : 0.04),
          color: Colors.grey.shade300,
          fontWeight: FontWeight.w500,
        ),
        SizedBox(height: isWearable ? 12 : 16),
        
        ...permissions.map((permission) => Container(
          margin: EdgeInsets.only(bottom: isWearable ? 8 : 12),
          padding: EdgeInsets.all(isWearable ? 12 : 16),
          decoration: BoxDecoration(
            color: (permission['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (permission['color'] as Color).withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isWearable ? 6 : 8),
                decoration: BoxDecoration(
                  color: (permission['color'] as Color).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  permission['icon'] as IconData,
                  color: permission['color'] as Color,
                  size: isWearable ? 16 : 20,
                ),
              ),
              SizedBox(width: isWearable ? 8 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AdaptiveText(
                      permission['title'] as String,
                      fontSize: screenSize.width * (isWearable ? 0.032 : 0.038),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    SizedBox(height: 2),
                    AdaptiveText(
                      permission['description'] as String,
                      fontSize: screenSize.width * (isWearable ? 0.028 : 0.032),
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildActionButtons(Size screenSize, bool isWearable) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(false),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: isWearable ? 12 : 16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Center(
                child: AdaptiveText(
                  'Cancelar',
                  fontSize: screenSize.width * (isWearable ? 0.035 : 0.04),
                  color: Colors.grey.shade300,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: _isLoading ? null : _requestPermissions,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: isWearable ? 12 : 16),
              decoration: BoxDecoration(
                color: _isLoading 
                    ? Colors.grey.withOpacity(0.3)
                    : Colors.blue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isLoading 
                      ? Colors.grey.withOpacity(0.3)
                      : Colors.blue.withOpacity(0.3),
                ),
                boxShadow: !_isLoading ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ] : null,
              ),
              child: Center(
                child: _isLoading
                    ? SizedBox(
                        width: isWearable ? 16 : 20,
                        height: isWearable ? 16 : 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      )
                    : AdaptiveText(
                        'Conceder Permisos',
                        fontSize: screenSize.width * (isWearable ? 0.035 : 0.04),
                        color: Colors.blue.shade300,
                        fontWeight: FontWeight.bold,
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionResults(Size screenSize, bool isWearable) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdaptiveText(
          'Resultado de Permisos:',
          fontSize: screenSize.width * (isWearable ? 0.035 : 0.04),
          color: Colors.grey.shade300,
          fontWeight: FontWeight.w500,
        ),
        SizedBox(height: isWearable ? 12 : 16),
        
        ..._permissionResults.entries.map((entry) {
          final isGranted = entry.value;
          final permissionName = _getPermissionDisplayName(entry.key);
          
          return Container(
            margin: EdgeInsets.only(bottom: isWearable ? 6 : 8),
            padding: EdgeInsets.all(isWearable ? 10 : 12),
            decoration: BoxDecoration(
              color: isGranted 
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isGranted 
                    ? Colors.green.withOpacity(0.3)
                    : Colors.red.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isGranted ? Icons.check_circle : Icons.cancel,
                  color: isGranted ? Colors.green : Colors.red,
                  size: isWearable ? 16 : 20,
                ),
                SizedBox(width: isWearable ? 8 : 12),
                Expanded(
                  child: AdaptiveText(
                    permissionName,
                    fontSize: screenSize.width * (isWearable ? 0.032 : 0.036),
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                AdaptiveText(
                  isGranted ? 'Concedido' : 'Denegado',
                  fontSize: screenSize.width * (isWearable ? 0.028 : 0.032),
                  color: isGranted ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildResultActions(Size screenSize, bool isWearable) {
    final allGranted = _permissionResults.values.every((granted) => granted);
    
    if (allGranted) {
      return Container(
        padding: EdgeInsets.all(isWearable ? 12 : 16),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: isWearable ? 20 : 24,
            ),
            SizedBox(width: isWearable ? 8 : 12),
            Expanded(
              child: AdaptiveText(
                '¡Permisos configurados correctamente!',
                fontSize: screenSize.width * (isWearable ? 0.032 : 0.036),
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    } else {
      return Column(
        children: [
          Container(
            padding: EdgeInsets.all(isWearable ? 12 : 16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.orange,
                  size: isWearable ? 20 : 24,
                ),
                SizedBox(width: isWearable ? 8 : 12),
                Expanded(
                  child: AdaptiveText(
                    'Algunos permisos fueron denegados. Puedes habilitarlos en configuración.',
                    fontSize: screenSize.width * (isWearable ? 0.03 : 0.034),
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isWearable ? 12 : 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(false),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: isWearable ? 10 : 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    child: Center(
                      child: AdaptiveText(
                        'Continuar',
                        fontSize: screenSize.width * (isWearable ? 0.032 : 0.036),
                        color: Colors.grey.shade300,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: _openSettings,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: isWearable ? 10 : 12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Center(
                      child: AdaptiveText(
                        'Configuración',
                        fontSize: screenSize.width * (isWearable ? 0.032 : 0.036),
                        color: Colors.blue.shade300,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  String _getPermissionDisplayName(String key) {
    switch (key) {
      case 'notifications':
        return 'Notificaciones';
      case 'body_sensors':
        return 'Sensores Corporales';
      case 'activity_recognition':
        return 'Reconocimiento de Actividad';
      default:
        return key;
    }
  }
}