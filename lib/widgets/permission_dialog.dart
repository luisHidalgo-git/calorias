import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/permission_service.dart';
import '../utils/screen_utils.dart';
import 'adaptive_text.dart';
import 'adaptive_container.dart';

class PermissionDialog extends StatefulWidget {
  final VoidCallback? onPermissionsGranted;
  final VoidCallback? onPermissionsDenied;

  const PermissionDialog({
    super.key,
    this.onPermissionsGranted,
    this.onPermissionsDenied,
  });

  @override
  _PermissionDialogState createState() => _PermissionDialogState();
}

class _PermissionDialogState extends State<PermissionDialog> {
  final PermissionService _permissionService = PermissionService();
  bool _isRequesting = false;
  Map<Permission, PermissionStatus> _permissionStatuses = {};

  @override
  void initState() {
    super.initState();
    _checkCurrentPermissions();
  }

  Future<void> _checkCurrentPermissions() async {
    final statuses = await _permissionService.getAllPermissionsStatus();
    if (mounted) {
      setState(() {
        _permissionStatuses = statuses;
      });
    }
  }

  Future<void> _requestPermissions() async {
    if (_isRequesting) return;

    setState(() {
      _isRequesting = true;
    });

    try {
      final results = await _permissionService.requestAllPermissions();
      
      if (mounted) {
        setState(() {
          _permissionStatuses = results;
          _isRequesting = false;
        });

        // Verificar si los permisos críticos fueron concedidos
        final canFunction = await _permissionService.canAppFunction();
        
        if (canFunction) {
          widget.onPermissionsGranted?.call();
          Navigator.of(context).pop(true);
        } else {
          widget.onPermissionsDenied?.call();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRequesting = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al solicitar permisos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isRound = ScreenUtils.isRoundScreen(screenSize);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: AdaptiveContainer(
        padding: EdgeInsets.all(screenSize.width * (isRound ? 0.06 : 0.05)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: screenSize.height * (isRound ? 0.7 : 0.8),
            maxWidth: screenSize.width * (isRound ? 0.85 : 0.9),
          ),
          decoration: BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(isRound ? 20 : 16),
            border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 20,
                spreadRadius: 4,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(screenSize.width * (isRound ? 0.05 : 0.04)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(screenSize, isRound),
                SizedBox(height: screenSize.height * 0.02),
                Flexible(
                  child: _buildPermissionsList(screenSize, isRound),
                ),
                SizedBox(height: screenSize.height * 0.02),
                _buildButtons(screenSize, isRound),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Size screenSize, bool isRound) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(screenSize.width * (isRound ? 0.04 : 0.05)),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.security,
            color: Colors.blue.shade400,
            size: screenSize.width * (isRound ? 0.08 : 0.1),
          ),
        ),
        SizedBox(height: screenSize.height * 0.015),
        AdaptiveText(
          'Permisos Necesarios',
          fontSize: screenSize.width * (isRound ? 0.045 : 0.05),
          fontWeight: FontWeight.bold,
          color: Colors.white,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: screenSize.height * 0.01),
        AdaptiveText(
          'Para funcionar correctamente, la aplicación necesita acceso a los siguientes permisos:',
          fontSize: screenSize.width * (isRound ? 0.028 : 0.032),
          color: Colors.grey.shade400,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPermissionsList(Size screenSize, bool isRound) {
    final requiredPermissions = [
      Permission.sensors,
      Permission.activityRecognition,
      Permission.notification,
    ];

    return ListView.separated(
      shrinkWrap: true,
      itemCount: requiredPermissions.length,
      separatorBuilder: (context, index) => 
          SizedBox(height: screenSize.height * 0.01),
      itemBuilder: (context, index) {
        final permission = requiredPermissions[index];
        final status = _permissionStatuses[permission];
        
        return _buildPermissionItem(
          permission, 
          status, 
          screenSize, 
          isRound
        );
      },
    );
  }

  Widget _buildPermissionItem(
    Permission permission,
    PermissionStatus? status,
    Size screenSize,
    bool isRound,
  ) {
    final isGranted = status?.isGranted ?? false;
    final isDenied = status?.isDenied ?? false;
    final isPermanentlyDenied = status?.isPermanentlyDenied ?? false;

    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (isGranted) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'Concedido';
    } else if (isPermanentlyDenied) {
      statusColor = Colors.red;
      statusIcon = Icons.block;
      statusText = 'Denegado';
    } else if (isDenied) {
      statusColor = Colors.orange;
      statusIcon = Icons.warning;
      statusText = 'Pendiente';
    } else {
      statusColor = Colors.grey;
      statusIcon = Icons.help_outline;
      statusText = 'Desconocido';
    }

    return Container(
      padding: EdgeInsets.all(screenSize.width * (isRound ? 0.03 : 0.035)),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(isRound ? 10 : 12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(screenSize.width * (isRound ? 0.02 : 0.025)),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getPermissionIcon(permission),
              color: statusColor,
              size: screenSize.width * (isRound ? 0.04 : 0.045),
            ),
          ),
          SizedBox(width: screenSize.width * (isRound ? 0.03 : 0.035)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdaptiveText(
                  _getPermissionTitle(permission),
                  fontSize: screenSize.width * (isRound ? 0.032 : 0.036),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2),
                AdaptiveText(
                  _permissionService.getPermissionDescription(permission),
                  fontSize: screenSize.width * (isRound ? 0.025 : 0.028),
                  color: Colors.grey.shade400,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            children: [
              Icon(
                statusIcon,
                color: statusColor,
                size: screenSize.width * (isRound ? 0.035 : 0.04),
              ),
              SizedBox(height: 2),
              AdaptiveText(
                statusText,
                fontSize: screenSize.width * (isRound ? 0.022 : 0.025),
                color: statusColor,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(Size screenSize, bool isRound) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () {
              widget.onPermissionsDenied?.call();
              Navigator.of(context).pop(false);
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                vertical: screenSize.height * (isRound ? 0.015 : 0.018),
              ),
              backgroundColor: Colors.grey.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: AdaptiveText(
              'Cancelar',
              fontSize: screenSize.width * (isRound ? 0.032 : 0.036),
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: screenSize.width * 0.03),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _isRequesting ? null : _requestPermissions,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                vertical: screenSize.height * (isRound ? 0.015 : 0.018),
              ),
              backgroundColor: Colors.blue.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isRequesting
                ? SizedBox(
                    width: screenSize.width * 0.04,
                    height: screenSize.width * 0.04,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : AdaptiveText(
                    'Conceder Permisos',
                    fontSize: screenSize.width * (isRound ? 0.032 : 0.036),
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
          ),
        ),
      ],
    );
  }

  IconData _getPermissionIcon(Permission permission) {
    switch (permission) {
      case Permission.sensors:
        return Icons.sensors;
      case Permission.activityRecognition:
        return Icons.directions_run;
      case Permission.notification:
        return Icons.notifications;
      case Permission.location:
        return Icons.location_on;
      default:
        return Icons.security;
    }
  }

  String _getPermissionTitle(Permission permission) {
    switch (permission) {
      case Permission.sensors:
        return 'Sensores de Movimiento';
      case Permission.activityRecognition:
        return 'Reconocimiento de Actividad';
      case Permission.notification:
        return 'Notificaciones';
      case Permission.location:
        return 'Ubicación';
      default:
        return 'Permiso Desconocido';
    }
  }
}