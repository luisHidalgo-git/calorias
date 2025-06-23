import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../models/fitness_data.dart';
import '../widgets/progress_ring.dart';
import '../widgets/center_content.dart';
import '../widgets/control_buttons.dart';
import '../widgets/time_display.dart';
import '../utils/color_utils.dart';

class WatchFaceScreen extends StatefulWidget {
  @override
  _WatchFaceScreenState createState() => _WatchFaceScreenState();
}

class _WatchFaceScreenState extends State<WatchFaceScreen>
    with TickerProviderStateMixin {
  FitnessData fitnessData = FitnessData();

  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _progressController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _addCalories() {
    HapticFeedback.lightImpact();
    setState(() {
      fitnessData.addCalories(5.0);
    });

    _progressController.forward();
    Future.delayed(Duration(milliseconds: 800), () {
      _progressController.reset();
    });
  }

  void _resetData() {
    HapticFeedback.mediumImpact();
    setState(() {
      fitnessData.reset();
    });

    _progressController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final watchSize = math.min(screenSize.width, screenSize.height);
    final backgroundColor = ColorUtils.getBackgroundColor(fitnessData.heartRate);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Background gradient based on heart rate
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.8,
                  colors: [backgroundColor, Colors.black],
                ),
              ),
            ),

            // Main watch face
            Center(
              child: Container(
                width: watchSize * 0.95,
                height: watchSize * 0.95,
                child: Stack(
                  children: [
                    // Outer ring - Calories progress
                    ProgressRing(
                      progress: fitnessData.calories / fitnessData.dailyCaloriesGoal,
                      color: Colors.orange,
                      strokeWidth: 8,
                      radius: watchSize * 0.45,
                      animation: _progressAnimation,
                    ),

                    // Inner ring - Heart rate indicator
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: ProgressRing(
                            progress: 1.0,
                            color: Colors.red.withOpacity(0.6),
                            strokeWidth: 3,
                            radius: watchSize * 0.31,
                            animation: _progressAnimation,
                          ),
                        );
                      },
                    ),

                    // Center content
                    CenterContent(
                      fitnessData: fitnessData,
                      watchSize: watchSize,
                    ),

                    // Control buttons
                    ControlButtons(
                      watchSize: watchSize,
                      onAdd: _addCalories,
                      onReset: _resetData,
                    ),

                    // Time display
                    TimeDisplay(watchSize: watchSize),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}