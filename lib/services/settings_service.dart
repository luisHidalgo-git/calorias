import 'dart:async';
import 'dart:convert';
import '../models/wearable_settings.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  WearableSettings _settings = WearableSettings();
  final StreamController<WearableSettings> _settingsController =
      StreamController<WearableSettings>.broadcast();
  final StreamController<Map<String, dynamic>> _configUpdateController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<WearableSettings> get settingsStream => _settingsController.stream;
  Stream<Map<String, dynamic>> get configUpdateStream =>
      _configUpdateController.stream;
  WearableSettings get currentSettings => _settings;

  // Simular persistencia de datos (en una app real usarías SharedPreferences o similar)
  final Map<String, dynamic> _storage = {};

  Future<void> loadSettings() async {
    // Simular carga desde almacenamiento local
    await Future.delayed(Duration(milliseconds: 500));

    if (_storage.containsKey('wearable_settings')) {
      try {
        final jsonData = jsonDecode(_storage['wearable_settings']);
        _settings = WearableSettings.fromJson(jsonData);
      } catch (e) {
        // Si hay error, usar configuración por defecto
        _settings = WearableSettings();
      }
    }

    _settingsController.add(_settings);

    // Notificar cambios de configuración
    _configUpdateController.add({
      'dailyCaloriesGoal': _settings.dailyCaloriesGoal,
      'maxHeartRate': _settings.maxHeartRate,
      'readingFrequency': _settings.readingFrequency,
    });
  }

  Future<void> saveSettings(WearableSettings settings) async {
    final oldSettings = _settings;
    _settings = settings;

    // Simular guardado en almacenamiento local
    _storage['wearable_settings'] = jsonEncode(settings.toJson());

    // Simular sincronización con wearable
    await _syncToWearable(settings);

    _settingsController.add(_settings);

    // Notificar cambios específicos que afectan el funcionamiento
    final configChanges = <String, dynamic>{};

    if (oldSettings.dailyCaloriesGoal != settings.dailyCaloriesGoal) {
      configChanges['dailyCaloriesGoal'] = settings.dailyCaloriesGoal;
    }

    if (oldSettings.maxHeartRate != settings.maxHeartRate) {
      configChanges['maxHeartRate'] = settings.maxHeartRate;
    }

    if (oldSettings.readingFrequency != settings.readingFrequency) {
      configChanges['readingFrequency'] = settings.readingFrequency;
    }

    if (configChanges.isNotEmpty) {
      _configUpdateController.add(configChanges);
    }
  }

  Future<void> _syncToWearable(WearableSettings settings) async {
    // Simular sincronización con dispositivo wearable
    await Future.delayed(Duration(milliseconds: 1000));

    // En una implementación real, aquí enviarías los datos via Bluetooth
    // o conexión WiFi al dispositivo wearable
    print('Configuración sincronizada con wearable: ${settings.toJson()}');
  }

  Future<void> resetToDefaults() async {
    _settings = WearableSettings();
    await saveSettings(_settings);
  }

  Future<bool> testConnection() async {
    // Simular prueba de conexión con wearable
    await Future.delayed(Duration(milliseconds: 2000));

    // Simular éxito/fallo aleatorio para demostración
    return DateTime.now().millisecond % 2 == 0;
  }

  void dispose() {
    _settingsController.close();
    _configUpdateController.close();
  }
}
