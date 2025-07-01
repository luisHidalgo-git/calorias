class WearableSettings {
  // Configuraciones de actividad
  double dailyCaloriesGoal;
  int readingFrequency; // en segundos
  bool autoReset;
  
  // Configuraciones de alertas
  bool enableNotifications;
  bool goalReachedAlert;
  bool inactivityAlert;
  int inactivityThreshold; // en minutos
  bool heartRateAlert;
  int maxHeartRate;
  
  // Configuraciones de pantalla
  bool alwaysOnDisplay;
  double screenBrightness;
  bool nightMode;
  String timeFormat; // '12h' o '24h'
  
  // Configuraciones de datos
  bool syncToCloud;
  bool shareData;
  int dataRetentionDays;
  
  WearableSettings({
    this.dailyCaloriesGoal = 300.0,
    this.readingFrequency = 3,
    this.autoReset = true,
    this.enableNotifications = true,
    this.goalReachedAlert = true,
    this.inactivityAlert = true,
    this.inactivityThreshold = 30,
    this.heartRateAlert = false,
    this.maxHeartRate = 150,
    this.alwaysOnDisplay = false,
    this.screenBrightness = 0.8,
    this.nightMode = false,
    this.timeFormat = '24h',
    this.syncToCloud = true,
    this.shareData = false,
    this.dataRetentionDays = 30,
  });

  Map<String, dynamic> toJson() {
    return {
      'dailyCaloriesGoal': dailyCaloriesGoal,
      'readingFrequency': readingFrequency,
      'autoReset': autoReset,
      'enableNotifications': enableNotifications,
      'goalReachedAlert': goalReachedAlert,
      'inactivityAlert': inactivityAlert,
      'inactivityThreshold': inactivityThreshold,
      'heartRateAlert': heartRateAlert,
      'maxHeartRate': maxHeartRate,
      'alwaysOnDisplay': alwaysOnDisplay,
      'screenBrightness': screenBrightness,
      'nightMode': nightMode,
      'timeFormat': timeFormat,
      'syncToCloud': syncToCloud,
      'shareData': shareData,
      'dataRetentionDays': dataRetentionDays,
    };
  }

  factory WearableSettings.fromJson(Map<String, dynamic> json) {
    return WearableSettings(
      dailyCaloriesGoal: json['dailyCaloriesGoal']?.toDouble() ?? 300.0,
      readingFrequency: json['readingFrequency'] ?? 3,
      autoReset: json['autoReset'] ?? true,
      enableNotifications: json['enableNotifications'] ?? true,
      goalReachedAlert: json['goalReachedAlert'] ?? true,
      inactivityAlert: json['inactivityAlert'] ?? true,
      inactivityThreshold: json['inactivityThreshold'] ?? 30,
      heartRateAlert: json['heartRateAlert'] ?? false,
      maxHeartRate: json['maxHeartRate'] ?? 150,
      alwaysOnDisplay: json['alwaysOnDisplay'] ?? false,
      screenBrightness: json['screenBrightness']?.toDouble() ?? 0.8,
      nightMode: json['nightMode'] ?? false,
      timeFormat: json['timeFormat'] ?? '24h',
      syncToCloud: json['syncToCloud'] ?? true,
      shareData: json['shareData'] ?? false,
      dataRetentionDays: json['dataRetentionDays'] ?? 30,
    );
  }

  WearableSettings copyWith({
    double? dailyCaloriesGoal,
    int? readingFrequency,
    bool? autoReset,
    bool? enableNotifications,
    bool? goalReachedAlert,
    bool? inactivityAlert,
    int? inactivityThreshold,
    bool? heartRateAlert,
    int? maxHeartRate,
    bool? alwaysOnDisplay,
    double? screenBrightness,
    bool? nightMode,
    String? timeFormat,
    bool? syncToCloud,
    bool? shareData,
    int? dataRetentionDays,
  }) {
    return WearableSettings(
      dailyCaloriesGoal: dailyCaloriesGoal ?? this.dailyCaloriesGoal,
      readingFrequency: readingFrequency ?? this.readingFrequency,
      autoReset: autoReset ?? this.autoReset,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      goalReachedAlert: goalReachedAlert ?? this.goalReachedAlert,
      inactivityAlert: inactivityAlert ?? this.inactivityAlert,
      inactivityThreshold: inactivityThreshold ?? this.inactivityThreshold,
      heartRateAlert: heartRateAlert ?? this.heartRateAlert,
      maxHeartRate: maxHeartRate ?? this.maxHeartRate,
      alwaysOnDisplay: alwaysOnDisplay ?? this.alwaysOnDisplay,
      screenBrightness: screenBrightness ?? this.screenBrightness,
      nightMode: nightMode ?? this.nightMode,
      timeFormat: timeFormat ?? this.timeFormat,
      syncToCloud: syncToCloud ?? this.syncToCloud,
      shareData: shareData ?? this.shareData,
      dataRetentionDays: dataRetentionDays ?? this.dataRetentionDays,
    );
  }
}