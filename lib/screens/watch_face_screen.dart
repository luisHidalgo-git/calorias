import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import '../models/fitness_data.dart';
import '../widgets/progress_ring.dart';
import '../widgets/center_content.dart';
import '../widgets/time_display.dart';
import '../utils/color_utils.dart';

class WatchFaceScreen extends StatefulWidget {
  const WatchFaceScreen({super.key});

  @override
  _WatchFaceScreenState createState() => _WatchFaceScreenState();
}

class _WatchFaceScreenState extends State<WatchFaceScreen>
    with TickerProviderStateMixin {
  FitnessData fitnessData = FitnessData();
  Timer? _activityTimer;

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

    _startAutomaticActivity();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _backgroundController.dispose();
    _activityTimer?.cancel();
    super.dispose();
  }

  void _startAutomaticActivity() {
    _activityTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          double increment = 1.0 + (math.Random().nextDouble() * 2.0);
          fitnessData.addCalories(increment);
        });

        _backgroundController.forward().then((_) {
          _backgroundController.reverse();
        });
      }
    });
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
              child: Padding(
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
            );
          },
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
          fontSize:
              watchSize * 0.045, // Mismo tamaño que getActivityDescription
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
            fontSize: watchSize * 0.04, // Aumentado de 0.025 a 0.04
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
          fontSize:
              watchSize *
              0.045, // Aumentado de 0.02 a 0.045 (casi el tamaño de la hora)
          color: accentColor.withOpacity(0.9),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
