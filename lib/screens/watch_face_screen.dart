import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import '../models/fitness_data.dart';
import '../services/calorie_service.dart';
import '../widgets/progress_ring.dart';
import '../widgets/center_content.dart';
import '../widgets/time_display.dart';
import '../widgets/notification_icon.dart';
import '../widgets/notifications_panel.dart';
import '../utils/color_utils.dart';
import 'calories_table_screen.dart';
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
  Timer? _activityTimer;
  List<CalorieEntry> _notifications = [];
  StreamSubscription? _newEntrySubscription;

  late AnimationController _pulseController;
  late AnimationController _backgroundController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _backgroundAnimation;

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

    _pulseAnimation = Tween<double>(begin: 0.99, end: 1.01).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );

    // Escuchar nuevas entradas de calorías para notificaciones
    _newEntrySubscription = _calorieService.newEntryStream.listen((entry) {
      if (mounted) {
        setState(() {
          _notifications.add(entry);
        });
      }
    });

    _startAutomaticActivity();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _backgroundController.dispose();
    _activityTimer?.cancel();
    _newEntrySubscription?.cancel();
    super.dispose();
  }

  void _startAutomaticActivity() {
    _activityTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          double increment = 1.0 + (math.Random().nextDouble() * 2.0);
          fitnessData.addCalories(increment);
          
          // Notificar al servicio de calorías
          _calorieService.addCalories(increment, fitnessData);
        });

        _backgroundController.forward().then((_) {
          _backgroundController.reverse();
        });
      }
    });
  }

  void _navigateToTable() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => CaloriesTableScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    final watchSize = math.min(screenWidth, screenHeight) * 0.7;

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
              child: Stack(
                children: [
                  // Botón de historial en la esquina superior izquierda
                  Positioned(
                    top: screenHeight * 0.02,
                    left: screenWidth * 0.05,
                    child: _buildHistorialButton(watchSize, accentColor),
                  ),

                  // Icono de notificaciones en la esquina superior derecha
                  Positioned(
                    top: screenHeight * 0.02,
                    right: screenWidth * 0.05,
                    child: NotificationIcon(
                      notifications: _notifications,
                      onTap: _showNotificationsPanel,
                    ),
                  ),

                  // Contenido principal
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHeight * 0.02,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Hora en la parte superior
                        TimeDisplay(watchSize: watchSize, accentColor: accentColor),

                        // Texto motivacional justo debajo de la hora
                        _buildMotivationalText(watchSize, accentColor),

                        // Área principal del reloj
                        Flexible(
                          flex: 3,
                          child: Center(
                            child: AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: SizedBox(
                                    width: watchSize,
                                    height: watchSize,
                                    child: Stack(
                                      children: [
                                        // Anillo principal de progreso
                                        ProgressRing(
                                          progress:
                                              fitnessData.calories /
                                              fitnessData.dailyCaloriesGoal,
                                          color: progressColor,
                                          strokeWidth: 14,
                                          radius: watchSize * 0.4,
                                        ),

                                        // Contenido central
                                        CenterContent(
                                          fitnessData: fitnessData,
                                          watchSize: watchSize,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        // Información inferior
                        Column(
                          children: [
                            _buildProgressIndicator(watchSize, progressColor),
                            SizedBox(height: screenHeight * 0.015),
                            _buildActivityDescription(watchSize, accentColor),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHistorialButton(double watchSize, Color accentColor) {
    return GestureDetector(
      onTap: _navigateToTable,
      child: Container(
        padding: EdgeInsets.all(watchSize * 0.025),
        decoration: BoxDecoration(
          color: accentColor.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(color: accentColor.withOpacity(0.4), width: 2),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(
          Icons.table_chart_outlined,
          color: accentColor,
          size: watchSize * 0.05,
        ),
      ),
    );
  }

  Widget _buildMotivationalText(double watchSize, Color accentColor) {
    final motivationalText = ColorUtils.getMotivationalText(
      fitnessData.calories,
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: watchSize * 0.025,
        vertical: watchSize * 0.008,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(watchSize * 0.015),
        color: accentColor.withOpacity(0.15),
        border: Border.all(color: accentColor.withOpacity(0.4), width: 1),
      ),
      child: Text(
        motivationalText,
        style: TextStyle(
          fontSize: watchSize * 0.045,
          color: accentColor,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(double watchSize, Color color) {
    final progress = fitnessData.calories / fitnessData.dailyCaloriesGoal;

    return Column(
      children: [
        Container(
          width: watchSize * 0.4,
          height: 4,
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
        SizedBox(height: 6),
        Text(
          '${(progress * 100).toStringAsFixed(0)}% OBJETIVO',
          style: TextStyle(
            fontSize: watchSize * 0.04,
            color: color.withOpacity(0.9),
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityDescription(double watchSize, Color accentColor) {
    final description = ColorUtils.getActivityDescription(fitnessData.calories);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: watchSize * 0.03,
        vertical: watchSize * 0.01,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(watchSize * 0.015),
        color: accentColor.withOpacity(0.12),
        border: Border.all(color: accentColor.withOpacity(0.3), width: 1),
      ),
      child: Text(
        description,
        style: TextStyle(
          fontSize: watchSize * 0.045,
          color: accentColor.withOpacity(0.9),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}