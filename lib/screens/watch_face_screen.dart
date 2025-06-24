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
      duration: Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _backgroundController = AnimationController(
      duration: Duration(milliseconds: 3000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
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
          // Incremento más realista entre 1-3 calorías cada 3 segundos
          double increment = 1.0 + (math.Random().nextDouble() * 2.0);
          fitnessData.addCalories(increment);
        });

        // Animar el fondo cuando cambian las calorías
        _backgroundController.forward().then((_) {
          _backgroundController.reverse();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final watchSize = math.min(screenSize.width, screenSize.height);
    final backgroundColor = ColorUtils.getBackgroundColor(fitnessData.calories);
    final progressColor = ColorUtils.getProgressColor(fitnessData.calories);
    final accentColor = ColorUtils.getAccentColor(fitnessData.calories);

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  Color.lerp(
                    backgroundColor,
                    accentColor,
                    _backgroundAnimation.value * 0.2,
                  )!,
                  backgroundColor.withOpacity(0.9),
                  backgroundColor.withOpacity(0.6),
                  Colors.black,
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Efecto de partículas sutiles
                ...List.generate(
                  6,
                  (index) =>
                      _buildFloatingParticle(index, watchSize, accentColor),
                ),

                // Main watch face
                Center(
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: SizedBox(
                          width: watchSize * 0.85,
                          height: watchSize * 0.85,
                          child: Stack(
                            children: [
                              // Anillo principal de progreso
                              ProgressRing(
                                progress:
                                    fitnessData.calories /
                                    fitnessData.dailyCaloriesGoal,
                                color: progressColor,
                                strokeWidth: 16,
                                radius: watchSize * 0.4,
                              ),

                              // Anillo interior decorativo
                              ProgressRing(
                                progress: 1.0,
                                color: accentColor.withOpacity(0.15),
                                strokeWidth: 2,
                                radius: watchSize * 0.32,
                              ),

                              // Contenido central
                              CenterContent(
                                fitnessData: fitnessData,
                                watchSize: watchSize,
                              ),

                              // Display de tiempo
                              TimeDisplay(
                                watchSize: watchSize,
                                accentColor: accentColor,
                              ),

                              // Indicador de progreso en la parte inferior
                              Positioned(
                                bottom: watchSize * 0.12,
                                left: 0,
                                right: 0,
                                child: _buildProgressIndicator(
                                  watchSize,
                                  progressColor,
                                ),
                              ),

                              // Descripción del nivel de actividad
                              Positioned(
                                bottom: watchSize * 0.05,
                                left: 0,
                                right: 0,
                                child: _buildActivityDescription(
                                  watchSize,
                                  accentColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressIndicator(double watchSize, Color color) {
    final progress = fitnessData.calories / fitnessData.dailyCaloriesGoal;

    return Column(
      children: [
        Container(
          width: watchSize * 0.3,
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: color.withOpacity(0.2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.8), color],
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.6),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          '${(progress * 100).toStringAsFixed(0)}% META',
          style: TextStyle(
            fontSize: watchSize * 0.022,
            color: color.withOpacity(0.9),
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityDescription(double watchSize, Color accentColor) {
    final description = ColorUtils.getActivityDescription(fitnessData.calories);

    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: watchSize * 0.04,
          vertical: watchSize * 0.01,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(watchSize * 0.02),
          color: accentColor.withOpacity(0.1),
          border: Border.all(color: accentColor.withOpacity(0.3), width: 1),
        ),
        child: Text(
          description,
          style: TextStyle(
            fontSize: watchSize * 0.02,
            color: accentColor.withOpacity(0.8),
            fontWeight: FontWeight.w500,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingParticle(int index, double watchSize, Color color) {
    final random = math.Random(index);
    final size = 1.5 + random.nextDouble() * 3.0;
    final left = random.nextDouble() * watchSize;
    final top = random.nextDouble() * watchSize;

    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.1 + random.nextDouble() * 0.15),
          boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 3)],
        ),
      ),
    );
  }
}
