import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import '../models/fitness_data.dart';
import '../services/calorie_service.dart';
import '../services/settings_service.dart';
import '../widgets/progress_ring.dart';
import '../widgets/center_content.dart';
import '../widgets/time_display.dart';
import '../widgets/notification_icon.dart';
import '../widgets/notifications_panel.dart';
import '../widgets/watch_button.dart';
import '../widgets/adaptive_text.dart';
import '../widgets/branded_logo.dart';
import '../widgets/value_adjustment_dialog.dart';
import '../utils/color_utils.dart';
import '../utils/screen_utils.dart';
import '../utils/device_utils.dart';
import 'calories_table_screen.dart';
import 'settings_screen.dart';
import '../models/daily_calories.dart';

class WatchFaceScreen extends StatefulWidget {
  const WatchFaceScreen({super.key});

  @override
  _WatchFaceScreenState createState() => _WatchFaceScreenState();
}

class _WatchFaceScreenState extends State<WatchFaceScreen>
    with TickerProviderStateMixin {
  FitnessData fitnessData = FitnessData();
  final CalorieService _calorieService = CalorieService();
  final SettingsService _settingsService = SettingsService();
  Timer? _activityTimer;
  List<CalorieEntry> _notifications = [];
  StreamSubscription? _newEntrySubscription;
  StreamSubscription? _configUpdateSubscription;
  int _currentReadingFrequency = 3; // Frecuencia actual en segundos

  late AnimationController _pulseController;
  late AnimationController _backgroundController;
  late AnimationController _goalReachedController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _goalReachedAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _backgroundController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _goalReachedController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.99, end: 1.01).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );

    _goalReachedAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _goalReachedController, curve: Curves.elasticOut),
    );

    // Escuchar nuevas entradas de calorías para notificaciones
    _newEntrySubscription = _calorieService.newEntryStream.listen((entry) {
      if (mounted) {
        setState(() {
          _notifications.add(entry);
        });
      }
    });

    // Escuchar cambios de configuración
    _configUpdateSubscription = _settingsService.configUpdateStream.listen((
      config,
    ) {
      if (mounted) {
        _applyConfigurationChanges(config);
      }
    });

    // Cargar configuración inicial
    _loadInitialSettings();
    _startAutomaticActivity();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _backgroundController.dispose();
    _goalReachedController.dispose();
    _activityTimer?.cancel();
    _newEntrySubscription?.cancel();
    _configUpdateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialSettings() async {
    await _settingsService.loadSettings();
    final settings = _settingsService.currentSettings;

    // Aplicar configuración inicial
    fitnessData.applySettings({
      'dailyCaloriesGoal': settings.dailyCaloriesGoal,
      'maxHeartRate': settings.maxHeartRate,
    });

    _currentReadingFrequency = settings.readingFrequency;

    if (mounted) {
      setState(() {});
    }
  }

  void _applyConfigurationChanges(Map<String, dynamic> config) {
    print('Aplicando cambios de configuración: $config');

    // Aplicar cambios al modelo de datos
    fitnessData.applySettings(config);

    // Actualizar frecuencia de lectura si cambió
    if (config.containsKey('readingFrequency')) {
      final newFrequency = config['readingFrequency'] as int;
      if (newFrequency != _currentReadingFrequency) {
        _currentReadingFrequency = newFrequency;
        _restartActivityTimer();

        // Mostrar notificación de cambio
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.update, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Frecuencia actualizada: cada $_currentReadingFrequency segundos',
                ),
              ],
            ),
            backgroundColor: Colors.blue.shade700,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }

    // Mostrar notificación de cambios aplicados
    if (config.containsKey('dailyCaloriesGoal')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.local_fire_department, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                'Meta actualizada: ${config['dailyCaloriesGoal'].toInt()} calorías',
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade700,
          duration: Duration(seconds: 2),
        ),
      );
    }

    if (config.containsKey('maxHeartRate')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.favorite, color: Colors.pink),
              SizedBox(width: 8),
              Text('Ritmo cardíaco máximo: ${config['maxHeartRate']} BPM'),
            ],
          ),
          backgroundColor: Colors.pink.shade700,
          duration: Duration(seconds: 2),
        ),
      );
    }

    setState(() {});
  }

  void _restartActivityTimer() {
    _activityTimer?.cancel();
    _startAutomaticActivity();
  }

  void _startAutomaticActivity() {
    _activityTimer = Timer.periodic(
      Duration(seconds: _currentReadingFrequency),
      (timer) {
        if (mounted) {
          final previousCalories = fitnessData.calories;
          final wasGoalReached = fitnessData.goalReached;

          setState(() {
            double increment = 1.0 + (math.Random().nextDouble() * 2.0);
            fitnessData.addCalories(increment);

            // Si se alcanzó la meta, mostrar animación y reiniciar
            if (!wasGoalReached && fitnessData.calories == 0.0) {
              _showGoalReachedAnimation();
              _calorieService.resetDailyProgress();
            } else {
              // Notificar al servicio de calorías solo si no se reinició
              _calorieService.addCalories(increment, fitnessData);
            }
          });

          _backgroundController.forward().then((_) {
            _backgroundController.reverse();
          });
        }
      },
    );
  }

  void _showGoalReachedAnimation() {
    _goalReachedController.forward().then((_) {
      _goalReachedController.reverse();
    });

    // Mostrar notificación de meta alcanzada
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.celebration, color: Colors.orange),
              SizedBox(width: 8),
              Text('¡Meta alcanzada! Reiniciando...'),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _navigateToTable() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            CaloriesTableScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: 300),
      ),
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            SettingsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: 300),
      ),
    );
  }

  void _showNotificationsPanel() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (context) => NotificationsPanel(
        notifications: _notifications,
        onClear: () {
          setState(() {
            _notifications.clear();
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  // Métodos para ajustar valores con mantener presionado
  void _showCaloriesAdjustment() {
    showDialog(
      context: context,
      builder: (context) => ValueAdjustmentDialog(
        title: 'Ajustar Calorías',
        currentValue: fitnessData.calories,
        maxValue: fitnessData.dailyCaloriesGoal,
        unit: 'cal',
        icon: Icons.local_fire_department,
        color: ColorUtils.getProgressColor(fitnessData.calories),
        onValueChanged: (newValue) {
          setState(() {
            fitnessData.setCalories(newValue);
            _calorieService.updateCurrentCalories(newValue, fitnessData);
          });
        },
      ),
    );
  }

  void _showHeartRateAdjustment() {
    showDialog(
      context: context,
      builder: (context) => ValueAdjustmentDialog(
        title: 'Ajustar Ritmo Cardíaco',
        currentValue: fitnessData.heartRate.toDouble(),
        maxValue: fitnessData.maxHeartRate.toDouble(),
        unit: 'BPM',
        icon: Icons.favorite,
        color: _getHeartRateColor(),
        onValueChanged: (newValue) {
          setState(() {
            fitnessData.setHeartRate(newValue.toInt());
            _calorieService.updateCurrentCalories(
              fitnessData.calories,
              fitnessData,
            );
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final deviceType = DeviceUtils.getDeviceType(
      screenSize.width,
      screenSize.height,
    );
    final layoutConfig = DeviceUtils.getLayoutConfig(deviceType);
    final isWearable = deviceType == DeviceType.wearable;

    final backgroundColor = ColorUtils.getBackgroundColor(fitnessData.calories);
    final progressColor = ColorUtils.getProgressColor(fitnessData.calories);
    final accentColor = ColorUtils.getAccentColor(fitnessData.calories);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _backgroundAnimation,
          builder: (context, child) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    Color.lerp(
                      backgroundColor,
                      accentColor,
                      _backgroundAnimation.value * 0.08,
                    )!,
                    backgroundColor.withOpacity(0.6),
                    Colors.black,
                  ],
                  stops: [0.0, 0.7, 1.0],
                ),
              ),
              child: isWearable
                  ? _buildWearableLayout(
                      screenSize,
                      layoutConfig,
                      accentColor,
                      progressColor,
                    )
                  : _buildPhoneLayout(
                      screenSize,
                      layoutConfig,
                      accentColor,
                      progressColor,
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWearableLayout(
    Size screenSize,
    LayoutConfig config,
    Color accentColor,
    Color progressColor,
  ) {
    final isRound = ScreenUtils.isRoundScreen(screenSize);
    final watchSize = isRound
        ? math.min(screenSize.width, screenSize.height) * 0.68
        : math.min(screenSize.width, screenSize.height) * 0.7;

    return Stack(
      children: [
        // Logo de marca sutil en la esquina
        Positioned(
          bottom: screenSize.height * 0.02,
          right: screenSize.width * 0.02,
          child: Opacity(
            opacity: 0.3,
            child: BrandedLogo(size: screenSize.width * 0.08, animated: false),
          ),
        ),

        // Botones posicionados de manera adaptativa
        if (isRound) ...[
          Positioned(
            top: screenSize.height * 0.18,
            left: screenSize.width * 0.18,
            child: WatchButton(
              onTap: _navigateToTable,
              icon: Icons.table_chart_outlined,
              color: accentColor,
              size: watchSize,
            ),
          ),
          Positioned(
            top: screenSize.height * 0.18,
            right: screenSize.width * 0.18,
            child: NotificationIcon(
              notifications: _notifications,
              onTap: _showNotificationsPanel,
            ),
          ),
        ] else ...[
          Positioned(
            top: screenSize.height * 0.02,
            left: screenSize.width * 0.05,
            child: WatchButton(
              onTap: _navigateToTable,
              icon: Icons.table_chart_outlined,
              color: accentColor,
              size: watchSize,
            ),
          ),
          Positioned(
            top: screenSize.height * 0.02,
            right: screenSize.width * 0.05,
            child: NotificationIcon(
              notifications: _notifications,
              onTap: _showNotificationsPanel,
            ),
          ),
        ],

        // Contenido principal adaptativo
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isRound
                ? screenSize.width * 0.06
                : screenSize.width * 0.05,
            vertical: isRound
                ? screenSize.height * 0.03
                : screenSize.height * 0.02,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (isRound) SizedBox(height: screenSize.height * 0.05),

              TimeDisplay(watchSize: watchSize, accentColor: accentColor),
              _buildMotivationalText(watchSize, accentColor, isRound),

              Flexible(
                flex: 3,
                child: Center(
                  child: AnimatedBuilder(
                    animation: Listenable.merge([
                      _pulseAnimation,
                      _goalReachedAnimation,
                    ]),
                    builder: (context, child) {
                      return Transform.scale(
                        scale:
                            _pulseAnimation.value * _goalReachedAnimation.value,
                        child: SizedBox(
                          width: watchSize,
                          height: watchSize,
                          child: Stack(
                            children: [
                              ProgressRing(
                                progress:
                                    fitnessData.calories /
                                    fitnessData.dailyCaloriesGoal,
                                color: progressColor,
                                strokeWidth: isRound ? 13 : 14,
                                radius: watchSize * 0.4,
                              ),
                              // CenterContent con funcionalidad de mantener presionado
                              _buildInteractiveCenterContent(
                                fitnessData,
                                watchSize,
                                isRound,
                                accentColor,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              Column(
                children: [
                  _buildProgressIndicator(watchSize, progressColor, isRound),
                  SizedBox(
                    height: isRound
                        ? screenSize.height * 0.008
                        : screenSize.height * 0.015,
                  ),
                  _buildActivityDescription(watchSize, accentColor, isRound),
                ],
              ),

              if (isRound) SizedBox(height: screenSize.height * 0.015),
            ],
          ),
        ),
      ],
    );
  }

  // Widget para el contenido central interactivo - SIN TEXTOS DE AYUDA
  Widget _buildInteractiveCenterContent(
    FitnessData fitnessData,
    double watchSize,
    bool isRound,
    Color accentColor,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Contador principal de calorías - CLICKEABLE CON MANTENER PRESIONADO
          GestureDetector(
            onLongPress: _showCaloriesAdjustment,
            child: Container(
              width: watchSize * (isRound ? 0.34 : 0.35),
              height: watchSize * (isRound ? 0.34 : 0.35),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withOpacity(0.12),
                border: Border.all(
                  color: accentColor.withOpacity(0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: accentColor,
                    size: watchSize * (isRound ? 0.048 : 0.05),
                  ),
                  SizedBox(height: watchSize * 0.005),
                  AdaptiveText(
                    fitnessData.calories.toStringAsFixed(0),
                    fontSize: watchSize * (isRound ? 0.085 : 0.09),
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                    style: TextStyle(
                      shadows: [
                        Shadow(
                          color: accentColor.withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  AdaptiveText(
                    'CALORÍAS',
                    fontSize: watchSize * (isRound ? 0.017 : 0.018),
                    color: accentColor.withOpacity(0.8),
                    style: TextStyle(
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: watchSize * (isRound ? 0.018 : 0.02)),

          // Ritmo cardíaco - CLICKEABLE CON MANTENER PRESIONADO
          GestureDetector(
            onLongPress: _showHeartRateAdjustment,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: watchSize * (isRound ? 0.028 : 0.03),
                vertical: watchSize * (isRound ? 0.014 : 0.015),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(watchSize * 0.015),
                color: _getHeartRateColor().withOpacity(0.12),
                border: Border.all(
                  color: _getHeartRateColor().withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: AdaptiveText(
                '♥ ${fitnessData.heartRate}',
                fontSize: watchSize * (isRound ? 0.034 : 0.035),
                fontWeight: FontWeight.w600,
                color: _getHeartRateColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneLayout(
    Size screenSize,
    LayoutConfig config,
    Color accentColor,
    Color progressColor,
  ) {
    return Padding(
      padding: EdgeInsets.all(screenSize.width * 0.04),
      child: Column(
        children: [
          // Header con navegación y notificaciones
          _buildPhoneHeader(screenSize, accentColor),

          SizedBox(height: screenSize.height * 0.02),

          // Tiempo y estado
          _buildPhoneTimeSection(screenSize, accentColor),

          SizedBox(height: screenSize.height * 0.025),

          // Área principal del progreso
          Expanded(
            child: _buildPhoneProgressSection(
              screenSize,
              progressColor,
              accentColor,
            ),
          ),

          SizedBox(height: screenSize.height * 0.02),

          // Estadísticas inferiores
          _buildPhoneStatsSection(screenSize, progressColor, accentColor),
        ],
      ),
    );
  }

  Widget _buildPhoneHeader(Size screenSize, Color accentColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: _navigateToTable,
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: accentColor.withOpacity(0.3)),
            ),
            child: Icon(
              Icons.table_chart_outlined,
              color: accentColor,
              size: 20,
            ),
          ),
        ),

        AdaptiveText(
          'CalorieWatch',
          fontSize: screenSize.width * 0.055,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),

        Row(
          children: [
            GestureDetector(
              onTap: _navigateToSettings,
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: Icon(
                  Icons.settings,
                  color: Colors.grey.shade300,
                  size: 20,
                ),
              ),
            ),
            SizedBox(width: 6),
            GestureDetector(
              onTap: _showNotificationsPanel,
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _notifications.isNotEmpty
                      ? Colors.red.withOpacity(0.15)
                      : Colors.grey.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _notifications.isNotEmpty
                        ? Colors.red.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.3),
                  ),
                ),
                child: Stack(
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      color: _notifications.isNotEmpty
                          ? Colors.red
                          : Colors.grey,
                      size: 20,
                    ),
                    if (_notifications.isNotEmpty)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${_notifications.length}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhoneTimeSection(Size screenSize, Color accentColor) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          StreamBuilder(
            stream: Stream.periodic(Duration(seconds: 1)),
            builder: (context, snapshot) {
              final now = DateTime.now();
              return AdaptiveText(
                '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                fontSize: screenSize.width * 0.14,
                fontWeight: FontWeight.w300,
                color: accentColor,
                style: TextStyle(letterSpacing: 4.0),
              );
            },
          ),
          SizedBox(height: 10),
          AdaptiveText(
            ColorUtils.getMotivationalText(fitnessData.calories),
            fontSize: screenSize.width * 0.05,
            color: accentColor.withOpacity(0.8),
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneProgressSection(
    Size screenSize,
    Color progressColor,
    Color accentColor,
  ) {
    final progressSize = screenSize.width * 0.8;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Anillo de progreso grande - CLICKEABLE CON MANTENER PRESIONADO
        AnimatedBuilder(
          animation: Listenable.merge([_pulseAnimation, _goalReachedAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value * _goalReachedAnimation.value,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onLongPress: _showCaloriesAdjustment,
                  borderRadius: BorderRadius.circular(progressSize / 2),
                  child: Container(
                    width: progressSize,
                    height: progressSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                    child: Stack(
                      children: [
                        ProgressRing(
                          progress:
                              fitnessData.calories /
                              fitnessData.dailyCaloriesGoal,
                          color: progressColor,
                          strokeWidth: 18,
                          radius: progressSize * 0.4,
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                color: accentColor,
                                size: progressSize * 0.14,
                              ),
                              SizedBox(height: 12),
                              AdaptiveText(
                                fitnessData.calories.toStringAsFixed(0),
                                fontSize: progressSize * 0.18,
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                              ),
                              AdaptiveText(
                                'CALORÍAS',
                                fontSize: progressSize * 0.045,
                                color: accentColor.withOpacity(0.8),
                                style: TextStyle(letterSpacing: 2.0),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        SizedBox(height: screenSize.height * 0.03),

        // Ritmo cardíaco - CLICKEABLE CON MANTENER PRESIONADO
        Material(
          color: Colors.transparent,
          child: InkWell(
            onLongPress: _showHeartRateAdjustment,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 28, vertical: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: _getHeartRateColor().withOpacity(0.15),
                border: Border.all(
                  color: _getHeartRateColor().withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite, color: _getHeartRateColor(), size: 28),
                  SizedBox(width: 12),
                  AdaptiveText(
                    '${fitnessData.heartRate} BPM',
                    fontSize: screenSize.width * 0.06,
                    fontWeight: FontWeight.w600,
                    color: _getHeartRateColor(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneStatsSection(
    Size screenSize,
    Color progressColor,
    Color accentColor,
  ) {
    final progress = fitnessData.calories / fitnessData.dailyCaloriesGoal;

    return Column(
      children: [
        // Barra de progreso
        Container(
          width: double.infinity,
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: progressColor.withOpacity(0.2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: progressColor,
                boxShadow: [
                  BoxShadow(
                    color: progressColor.withOpacity(0.4),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        ),

        SizedBox(height: 14),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AdaptiveText(
              '${(progress * 100).toStringAsFixed(0)}% OBJETIVO',
              fontSize: screenSize.width * 0.045,
              color: progressColor.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
            AdaptiveText(
              '${fitnessData.dailyCaloriesGoal.toInt()} cal meta',
              fontSize: screenSize.width * 0.045,
              color: accentColor.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ],
        ),

        SizedBox(height: 16),

        // Descripción de actividad
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: accentColor.withOpacity(0.1),
            border: Border.all(color: accentColor.withOpacity(0.3)),
          ),
          child: Center(
            child: AdaptiveText(
              ColorUtils.getActivityDescription(fitnessData.calories),
              fontSize: screenSize.width * 0.05,
              color: accentColor.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMotivationalText(
    double watchSize,
    Color accentColor,
    bool isRound,
  ) {
    final motivationalText = ColorUtils.getMotivationalText(
      fitnessData.calories,
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: watchSize * 0.025,
        vertical: watchSize * (isRound ? 0.007 : 0.008),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(watchSize * 0.015),
        color: accentColor.withOpacity(0.15),
        border: Border.all(color: accentColor.withOpacity(0.4), width: 1),
      ),
      child: AdaptiveText(
        motivationalText,
        fontSize: watchSize * (isRound ? 0.042 : 0.045),
        color: accentColor,
        fontWeight: FontWeight.w600,
        style: TextStyle(letterSpacing: 0.8),
      ),
    );
  }

  Widget _buildProgressIndicator(double watchSize, Color color, bool isRound) {
    final progress = fitnessData.calories / fitnessData.dailyCaloriesGoal;

    return Column(
      children: [
        Container(
          width: watchSize * (isRound ? 0.38 : 0.4),
          height: isRound ? 3.5 : 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: color.withOpacity(0.2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: color,
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.4), blurRadius: 6),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: isRound ? 5 : 6),
        AdaptiveText(
          '${(progress * 100).toStringAsFixed(0)}% OBJETIVO',
          fontSize: watchSize * (isRound ? 0.037 : 0.04),
          color: color.withOpacity(0.9),
          fontWeight: FontWeight.w600,
          style: TextStyle(letterSpacing: 1.0),
        ),
      ],
    );
  }

  Widget _buildActivityDescription(
    double watchSize,
    Color accentColor,
    bool isRound,
  ) {
    final description = ColorUtils.getActivityDescription(fitnessData.calories);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: watchSize * 0.03,
        vertical: watchSize * (isRound ? 0.009 : 0.01),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(watchSize * 0.015),
        color: accentColor.withOpacity(0.12),
        border: Border.all(color: accentColor.withOpacity(0.3), width: 1),
      ),
      child: AdaptiveText(
        description,
        fontSize: watchSize * (isRound ? 0.042 : 0.045),
        color: accentColor.withOpacity(0.9),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Color _getHeartRateColor() {
    if (fitnessData.heartRate < 80) {
      return Colors.green.shade400;
    } else if (fitnessData.heartRate < 100) {
      return Colors.orange.shade400;
    } else {
      return Colors.red.shade400;
    }
  }
}
