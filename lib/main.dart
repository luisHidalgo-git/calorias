import 'package:flutter/material.dart';
import 'screens/watch_face_screen.dart';
import 'widgets/splash_screen.dart';
import 'services/permission_service.dart';
import 'widgets/permission_request_dialog.dart';

void main() {
  runApp(SmartwatchCalorieApp());
}

class SmartwatchCalorieApp extends StatelessWidget {
  const SmartwatchCalorieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smartwatch Calories',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.dark(
          primary: Colors.blue,
          secondary: Colors.green,
          surface: Colors.grey[900]!,
        ),
      ),
      home: SplashScreen(
        child: PermissionAwareApp(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PermissionAwareApp extends StatefulWidget {
  const PermissionAwareApp({super.key});

  @override
  _PermissionAwareAppState createState() => _PermissionAwareAppState();
}

class _PermissionAwareAppState extends State<PermissionAwareApp> {
  final PermissionService _permissionService = PermissionService();
  bool _permissionsChecked = false;
  bool _permissionsGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    try {
      // Inicializar el servicio de permisos
      await _permissionService.initialize();
      
      // Verificar si las notificaciones están habilitadas
      final notificationsEnabled = await _permissionService.areNotificationsEnabled();
      
      setState(() {
        _permissionsChecked = true;
        _permissionsGranted = notificationsEnabled;
      });

      // Si los permisos no están concedidos, mostrar el diálogo
      if (!notificationsEnabled) {
        _showPermissionDialog();
      }
    } catch (e) {
      print('❌ Error verificando permisos: $e');
      setState(() {
        _permissionsChecked = true;
        _permissionsGranted = false;
      });
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PermissionRequestDialog(
        onPermissionsGranted: () {
          setState(() {
            _permissionsGranted = true;
          });
          print('✅ Permisos concedidos exitosamente');
        },
        onPermissionsDenied: () {
          print('⚠️ Algunos permisos fueron denegados');
          // La aplicación puede continuar funcionando con funcionalidad limitada
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_permissionsChecked) {
      // Mostrar pantalla de carga mientras se verifican los permisos
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade300),
              ),
              SizedBox(height: 20),
              Text(
                'Verificando permisos...',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Mostrar la aplicación principal
    return WatchFaceScreen();
  }
}