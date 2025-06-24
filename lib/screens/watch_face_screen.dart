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
    final watchSize = math.min(screenSize.width, screenSize.height) * 0.75;
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
                radius: 1.2,
                colors: [
                  Color.lerp(
                    backgroundColor,
                    accentColor,
                    _backgroundAnimation.value * 0.15,
                  )!,
                  backgroundColor.withOpacity(0.8),
                  Colors.black,
                ],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
            child: Column(
              children: [
                // Hora en la parte superior
                Container(
                  margin: EdgeInsets.only(top: 40),
                  child: TimeDisplay(
                    watchSize: watchSize,
                    accentColor: accentColor,
                  ),
                ),

                // Espacio flexible
                Expanded(
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
                                  strokeWidth: 12,
                                  radius: watchSize * 0.38,
                                ),

                                // Anillo interior decorativo
                                ProgressRing(
                                  progress: 1.0,
                                  color: accentColor.withOpacity(0.12),
                                  strokeWidth: 2,
                                  radius: watchSize * 0.3,
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
                Container(
                  margin: EdgeInsets.only(bottom: 30),
                  child: Column(
                    children: [
                      _buildProgressIndicator(watchSize, progressColor),
                      SizedBox(height: 12),
                      _buildActivityDescription(watchSize, accentColor),
                    ],
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
          width: watchSize * 0.25,
          height: 3,
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
                  BoxShadow(color: color.withOpacity(0.5), blurRadius: 4),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(
          '${(progress * 100).toStringAsFixed(0)}% META',
          style: TextStyle(
            fontSize: watchSize * 0.016,
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
        horizontal: watchSize * 0.025,
        vertical: watchSize * 0.006,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(watchSize * 0.012),
        color: accentColor.withOpacity(0.08),
        border: Border.all(color: accentColor.withOpacity(0.25), width: 1),
      ),
      child: Text(
        description,
        style: TextStyle(
          fontSize: watchSize * 0.014,
          color: accentColor.withOpacity(0.8),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
