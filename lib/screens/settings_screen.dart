import 'package:flutter/material.dart';
import 'dart:async';
import '../models/wearable_settings.dart';
import '../services/settings_service.dart';
import '../utils/device_utils.dart' as DeviceUtils;
import '../widgets/adaptive_text.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';
import '../widgets/connection_status.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  final SettingsService _settingsService = SettingsService();
  WearableSettings _settings = WearableSettings();
  StreamSubscription? _settingsSubscription;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isConnected = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _loadSettings();
    _checkConnection();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _settingsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    await _settingsService.loadSettings();

    _settingsSubscription = _settingsService.settingsStream.listen((settings) {
      if (mounted) {
        setState(() {
          _settings = settings;
          _isLoading = false;
        });
      }
    });

    _fadeController.forward();
  }

  Future<void> _checkConnection() async {
    final connected = await _settingsService.testConnection();
    if (mounted) {
      setState(() {
        _isConnected = connected;
      });
    }
  }

  Future<void> _saveSettings(WearableSettings newSettings) async {
    setState(() {
      _isSaving = true;
    });

    try {
      await _settingsService.saveSettings(newSettings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Configuración aplicada al wearable'),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Text('Error al aplicar configuración'),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _resetSettings() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: Text(
          'Restablecer Configuración',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Estás seguro de que quieres restablecer toda la configuración a los valores por defecto?',
          style: TextStyle(color: Colors.grey.shade300),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Restablecer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _settingsService.resetToDefaults();
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

    if (isWearable) {
      return _buildWearableView(screenSize);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingView(screenSize)
            : FadeTransition(
                opacity: _fadeAnimation,
                child: _buildPhoneView(screenSize),
              ),
      ),
    );
  }

  Widget _buildWearableView(Size screenSize) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(screenSize.width * 0.1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.smartphone,
                  size: screenSize.width * 0.2,
                  color: Colors.blue.shade300,
                ),
                SizedBox(height: screenSize.height * 0.05),
                AdaptiveText(
                  'Configuración',
                  fontSize: screenSize.width * 0.08,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenSize.height * 0.03),
                AdaptiveText(
                  'Usa tu teléfono para configurar este dispositivo',
                  fontSize: screenSize.width * 0.045,
                  color: Colors.grey.shade400,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenSize.height * 0.05),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade300.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.shade300.withOpacity(0.3),
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.blue.shade300,
                      size: screenSize.width * 0.08,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView(Size screenSize) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade300),
          ),
          SizedBox(height: 20),
          AdaptiveText(
            'Cargando configuración...',
            fontSize: screenSize.width * 0.045,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneView(Size screenSize) {
    return Column(
      children: [
        _buildHeader(screenSize),
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(screenSize.width * 0.05),
            children: [
              ConnectionStatus(
                isConnected: _isConnected,
                onRefresh: _checkConnection,
              ),

              SizedBox(height: 20),

              _buildActivitySection(screenSize),
              SizedBox(height: 20),

              _buildAlertsSection(screenSize),
              SizedBox(height: 20),

              _buildDisplaySection(screenSize),
              SizedBox(height: 20),

              _buildDataSection(screenSize),
              SizedBox(height: 20),

              _buildActionsSection(screenSize),
              SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(Size screenSize) {
    return Container(
      padding: EdgeInsets.all(screenSize.width * 0.05),
      decoration: BoxDecoration(
        color: Colors.grey.shade900.withOpacity(0.5),
        border: Border(bottom: BorderSide(color: Colors.grey.shade700)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade300.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade300.withOpacity(0.3)),
            ),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.arrow_back,
                color: Colors.blue.shade300,
                size: 24,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdaptiveText(
                  'Configuración del Wearable',
                  fontSize: screenSize.width * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                AdaptiveText(
                  'Personaliza tu dispositivo',
                  fontSize: screenSize.width * 0.04,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
          if (_isSaving)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade300),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActivitySection(Size screenSize) {
    return SettingsSection(
      title: 'Actividad y Metas',
      icon: Icons.fitness_center,
      children: [
        // Meta de calorías con slider directo
        Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.local_fire_department,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AdaptiveText(
                          'Meta diaria de calorías',
                          fontSize: screenSize.width * 0.04,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                        AdaptiveText(
                          '${_settings.dailyCaloriesGoal.toInt()} calorías',
                          fontSize: screenSize.width * 0.045,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.orange,
                  inactiveTrackColor: Colors.orange.withOpacity(0.3),
                  thumbColor: Colors.orange,
                  overlayColor: Colors.orange.withOpacity(0.2),
                  valueIndicatorColor: Colors.orange,
                  valueIndicatorTextStyle: TextStyle(color: Colors.white),
                ),
                child: Slider(
                  value: _settings.dailyCaloriesGoal,
                  min: 100,
                  max: 1000,
                  divisions: 18,
                  label: '${_settings.dailyCaloriesGoal.toInt()} cal',
                  onChanged: (value) {
                    final newSettings = _settings.copyWith(
                      dailyCaloriesGoal: value,
                    );
                    setState(() {
                      _settings = newSettings;
                    });
                    _saveSettings(newSettings);
                  },
                ),
              ),
            ],
          ),
        ),

        Divider(color: Colors.grey.shade800.withOpacity(0.3), height: 1),

        // Ritmo cardíaco máximo con slider directo
        Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.favorite, color: Colors.pink),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AdaptiveText(
                          'Ritmo cardíaco máximo',
                          fontSize: screenSize.width * 0.04,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                        AdaptiveText(
                          '${_settings.maxHeartRate} BPM',
                          fontSize: screenSize.width * 0.045,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.pink,
                  inactiveTrackColor: Colors.pink.withOpacity(0.3),
                  thumbColor: Colors.pink,
                  overlayColor: Colors.pink.withOpacity(0.2),
                  valueIndicatorColor: Colors.pink,
                  valueIndicatorTextStyle: TextStyle(color: Colors.white),
                ),
                child: Slider(
                  value: _settings.maxHeartRate.toDouble(),
                  min: 100,
                  max: 200,
                  divisions: 20,
                  label: '${_settings.maxHeartRate} BPM',
                  onChanged: (value) {
                    final newSettings = _settings.copyWith(
                      maxHeartRate: value.toInt(),
                    );
                    setState(() {
                      _settings = newSettings;
                    });
                    _saveSettings(newSettings);
                  },
                ),
              ),
            ],
          ),
        ),

        Divider(color: Colors.grey.shade800.withOpacity(0.3), height: 1),

        // Frecuencia de lectura con slider directo
        Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.timer, color: Colors.blue),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AdaptiveText(
                          'Frecuencia de lectura',
                          fontSize: screenSize.width * 0.04,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                        AdaptiveText(
                          'Cada ${_settings.readingFrequency} segundos',
                          fontSize: screenSize.width * 0.045,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.blue,
                  inactiveTrackColor: Colors.blue.withOpacity(0.3),
                  thumbColor: Colors.blue,
                  overlayColor: Colors.blue.withOpacity(0.2),
                  valueIndicatorColor: Colors.blue,
                  valueIndicatorTextStyle: TextStyle(color: Colors.white),
                ),
                child: Slider(
                  value: _settings.readingFrequency.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: '${_settings.readingFrequency}s',
                  onChanged: (value) {
                    final newSettings = _settings.copyWith(
                      readingFrequency: value.toInt(),
                    );
                    setState(() {
                      _settings = newSettings;
                    });
                    _saveSettings(newSettings);
                  },
                ),
              ),
            ],
          ),
        ),

        Divider(color: Colors.grey.shade800.withOpacity(0.3), height: 1),

        SettingsTile(
          title: 'Reinicio automático',
          subtitle: 'Reiniciar al alcanzar la meta',
          leading: Icon(Icons.refresh, color: Colors.green),
          trailing: Switch(
            value: _settings.autoReset,
            onChanged: (value) {
              final newSettings = _settings.copyWith(autoReset: value);
              setState(() {
                _settings = newSettings;
              });
              _saveSettings(newSettings);
            },
            activeColor: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildAlertsSection(Size screenSize) {
    return SettingsSection(
      title: 'Alertas y Notificaciones',
      icon: Icons.notifications,
      children: [
        SettingsTile(
          title: 'Notificaciones',
          subtitle: 'Habilitar todas las notificaciones',
          leading: Icon(Icons.notifications_active, color: Colors.blue),
          trailing: Switch(
            value: _settings.enableNotifications,
            onChanged: (value) {
              final newSettings = _settings.copyWith(
                enableNotifications: value,
              );
              setState(() {
                _settings = newSettings;
              });
              _saveSettings(newSettings);
            },
            activeColor: Colors.blue,
          ),
        ),
        SettingsTile(
          title: 'Alerta de meta alcanzada',
          subtitle: 'Notificar cuando se alcance la meta',
          leading: Icon(Icons.celebration, color: Colors.orange),
          trailing: Switch(
            value: _settings.goalReachedAlert,
            onChanged: _settings.enableNotifications
                ? (value) {
                    final newSettings = _settings.copyWith(
                      goalReachedAlert: value,
                    );
                    setState(() {
                      _settings = newSettings;
                    });
                    _saveSettings(newSettings);
                  }
                : null,
            activeColor: Colors.orange,
          ),
        ),
        SettingsTile(
          title: 'Alerta de inactividad',
          subtitle: 'Después de ${_settings.inactivityThreshold} minutos',
          leading: Icon(Icons.warning, color: Colors.red),
          trailing: Switch(
            value: _settings.inactivityAlert,
            onChanged: _settings.enableNotifications
                ? (value) {
                    final newSettings = _settings.copyWith(
                      inactivityAlert: value,
                    );
                    setState(() {
                      _settings = newSettings;
                    });
                    _saveSettings(newSettings);
                  }
                : null,
            activeColor: Colors.red,
          ),
          onTap: _settings.enableNotifications && _settings.inactivityAlert
              ? () => _showInactivityThresholdDialog()
              : null,
        ),
        SettingsTile(
          title: 'Alerta de ritmo cardíaco',
          subtitle: 'Máximo ${_settings.maxHeartRate} BPM',
          leading: Icon(Icons.favorite, color: Colors.pink),
          trailing: Switch(
            value: _settings.heartRateAlert,
            onChanged: _settings.enableNotifications
                ? (value) {
                    final newSettings = _settings.copyWith(
                      heartRateAlert: value,
                    );
                    setState(() {
                      _settings = newSettings;
                    });
                    _saveSettings(newSettings);
                  }
                : null,
            activeColor: Colors.pink,
          ),
        ),
      ],
    );
  }

  Widget _buildDisplaySection(Size screenSize) {
    return SettingsSection(
      title: 'Pantalla y Visualización',
      icon: Icons.display_settings,
      children: [
        SettingsTile(
          title: 'Pantalla siempre encendida',
          subtitle: 'Mantener pantalla activa',
          leading: Icon(Icons.lightbulb, color: Colors.yellow),
          trailing: Switch(
            value: _settings.alwaysOnDisplay,
            onChanged: (value) {
              final newSettings = _settings.copyWith(alwaysOnDisplay: value);
              setState(() {
                _settings = newSettings;
              });
              _saveSettings(newSettings);
            },
            activeColor: Colors.yellow,
          ),
        ),
        SettingsTile(
          title: 'Brillo de pantalla',
          subtitle: '${(_settings.screenBrightness * 100).toInt()}%',
          leading: Icon(Icons.brightness_6, color: Colors.amber),
          onTap: () => _showBrightnessDialog(),
        ),
        SettingsTile(
          title: 'Modo nocturno',
          subtitle: 'Reducir brillo automáticamente',
          leading: Icon(Icons.nightlight, color: Colors.indigo),
          trailing: Switch(
            value: _settings.nightMode,
            onChanged: (value) {
              final newSettings = _settings.copyWith(nightMode: value);
              setState(() {
                _settings = newSettings;
              });
              _saveSettings(newSettings);
            },
            activeColor: Colors.indigo,
          ),
        ),
        SettingsTile(
          title: 'Formato de hora',
          subtitle: _settings.timeFormat == '24h' ? '24 horas' : '12 horas',
          leading: Icon(Icons.access_time, color: Colors.cyan),
          onTap: () => _showTimeFormatDialog(),
        ),
      ],
    );
  }

  Widget _buildDataSection(Size screenSize) {
    return SettingsSection(
      title: 'Datos y Privacidad',
      icon: Icons.storage,
      children: [
        SettingsTile(
          title: 'Sincronización en la nube',
          subtitle: 'Respaldar datos automáticamente',
          leading: Icon(Icons.cloud_sync, color: Colors.blue),
          trailing: Switch(
            value: _settings.syncToCloud,
            onChanged: (value) {
              final newSettings = _settings.copyWith(syncToCloud: value);
              setState(() {
                _settings = newSettings;
              });
              _saveSettings(newSettings);
            },
            activeColor: Colors.blue,
          ),
        ),
        SettingsTile(
          title: 'Compartir datos',
          subtitle: 'Permitir análisis anónimo',
          leading: Icon(Icons.share, color: Colors.green),
          trailing: Switch(
            value: _settings.shareData,
            onChanged: (value) {
              final newSettings = _settings.copyWith(shareData: value);
              setState(() {
                _settings = newSettings;
              });
              _saveSettings(newSettings);
            },
            activeColor: Colors.green,
          ),
        ),
        SettingsTile(
          title: 'Retención de datos',
          subtitle: '${_settings.dataRetentionDays} días',
          leading: Icon(Icons.history, color: Colors.purple),
          onTap: () => _showDataRetentionDialog(),
        ),
      ],
    );
  }

  Widget _buildActionsSection(Size screenSize) {
    return SettingsSection(
      title: 'Acciones',
      icon: Icons.settings,
      children: [
        SettingsTile(
          title: 'Probar conexión',
          subtitle: 'Verificar comunicación con wearable',
          leading: Icon(Icons.wifi_find, color: Colors.blue),
          onTap: _checkConnection,
        ),
        SettingsTile(
          title: 'Restablecer configuración',
          subtitle: 'Volver a valores por defecto',
          leading: Icon(Icons.restore, color: Colors.red),
          onTap: _resetSettings,
        ),
      ],
    );
  }

  // Diálogos simplificados para configuraciones específicas
  void _showInactivityThresholdDialog() {
    int tempThreshold = _settings.inactivityThreshold;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: Text(
          'Umbral de Inactividad',
          style: TextStyle(color: Colors.white),
        ),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$tempThreshold minutos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 20),
              Slider(
                value: tempThreshold.toDouble(),
                min: 5,
                max: 120,
                divisions: 23,
                activeColor: Colors.red,
                onChanged: (value) {
                  setState(() {
                    tempThreshold = value.toInt();
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              final newSettings = _settings.copyWith(
                inactivityThreshold: tempThreshold,
              );
              this.setState(() {
                _settings = newSettings;
              });
              _saveSettings(newSettings);
              Navigator.pop(context);
            },
            child: Text('Guardar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showBrightnessDialog() {
    double tempBrightness = _settings.screenBrightness;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: Text(
          'Brillo de Pantalla',
          style: TextStyle(color: Colors.white),
        ),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(tempBrightness * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              SizedBox(height: 20),
              Slider(
                value: tempBrightness,
                min: 0.1,
                max: 1.0,
                divisions: 9,
                activeColor: Colors.amber,
                onChanged: (value) {
                  setState(() {
                    tempBrightness = value;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              final newSettings = _settings.copyWith(
                screenBrightness: tempBrightness,
              );
              this.setState(() {
                _settings = newSettings;
              });
              _saveSettings(newSettings);
              Navigator.pop(context);
            },
            child: Text('Guardar', style: TextStyle(color: Colors.amber)),
          ),
        ],
      ),
    );
  }

  void _showTimeFormatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: Text('Formato de Hora', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('24 horas', style: TextStyle(color: Colors.white)),
              leading: Radio<String>(
                value: '24h',
                groupValue: _settings.timeFormat,
                onChanged: (value) {
                  final newSettings = _settings.copyWith(timeFormat: value);
                  setState(() {
                    _settings = newSettings;
                  });
                  _saveSettings(newSettings);
                  Navigator.pop(context);
                },
                activeColor: Colors.cyan,
              ),
            ),
            ListTile(
              title: Text(
                '12 horas (AM/PM)',
                style: TextStyle(color: Colors.white),
              ),
              leading: Radio<String>(
                value: '12h',
                groupValue: _settings.timeFormat,
                onChanged: (value) {
                  final newSettings = _settings.copyWith(timeFormat: value);
                  setState(() {
                    _settings = newSettings;
                  });
                  _saveSettings(newSettings);
                  Navigator.pop(context);
                },
                activeColor: Colors.cyan,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDataRetentionDialog() {
    int tempDays = _settings.dataRetentionDays;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: Text(
          'Retención de Datos',
          style: TextStyle(color: Colors.white),
        ),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$tempDays días',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              SizedBox(height: 20),
              Slider(
                value: tempDays.toDouble(),
                min: 7,
                max: 365,
                divisions: 51,
                activeColor: Colors.purple,
                onChanged: (value) {
                  setState(() {
                    tempDays = value.toInt();
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              final newSettings = _settings.copyWith(
                dataRetentionDays: tempDays,
              );
              this.setState(() {
                _settings = newSettings;
              });
              _saveSettings(newSettings);
              Navigator.pop(context);
            },
            child: Text('Guardar', style: TextStyle(color: Colors.purple)),
          ),
        ],
      ),
    );
  }
}