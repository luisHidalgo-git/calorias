import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

void main() {
  runApp(SmartwatchCalorieApp());
}

class SmartwatchCalorieApp extends StatelessWidget {
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
      home: WatchFaceScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WatchFaceScreen extends StatefulWidget {
  @override
  _WatchFaceScreenState createState() => _WatchFaceScreenState();
}

class _WatchFaceScreenState extends State<WatchFaceScreen>
    with TickerProviderStateMixin {
  int steps = 0;
  double calories = 0.0;
  double distance = 0.0; // in km
  int heartRate = 72;

  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;

  final int dailyStepsGoal = 10000;
  final double dailyCaloriesGoal = 400.0;

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

  void _addSteps() {
    HapticFeedback.lightImpact();
    setState(() {
      steps += 10;
      calories = steps * 0.04;
      distance = steps * 0.0008; // Approximate: 0.8m per step
      heartRate = 72 + (steps / 100).round().clamp(0, 50);
    });

    _progressController.forward();
    Future.delayed(Duration(milliseconds: 800), () {
      _progressController.reset();
    });
  }

  void _resetData() {
    HapticFeedback.mediumImpact();
    setState(() {
      steps = 0;
      calories = 0.0;
      distance = 0.0;
      heartRate = 72;
    });

    _progressController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final watchSize = math.min(screenSize.width, screenSize.height);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.8,
                  colors: [Colors.grey[900]!, Colors.black],
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
                    // Outer ring - Steps progress
                    _buildProgressRing(
                      progress: steps / dailyStepsGoal,
                      color: Colors.blue,
                      strokeWidth: 8,
                      radius: watchSize * 0.45,
                    ),

                    // Middle ring - Calories progress
                    _buildProgressRing(
                      progress: calories / dailyCaloriesGoal,
                      color: Colors.green,
                      strokeWidth: 6,
                      radius: watchSize * 0.38,
                    ),

                    // Inner ring - Heart rate indicator
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: _buildProgressRing(
                            progress: 1.0,
                            color: Colors.red.withOpacity(0.6),
                            strokeWidth: 3,
                            radius: watchSize * 0.31,
                          ),
                        );
                      },
                    ),

                    // Center content
                    Center(
                      child: Container(
                        width: watchSize * 0.6,
                        height: watchSize * 0.6,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Steps counter
                            Text(
                              '$steps',
                              style: TextStyle(
                                fontSize: watchSize * 0.08,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'PASOS',
                              style: TextStyle(
                                fontSize: watchSize * 0.025,
                                color: Colors.blue,
                                letterSpacing: 1.2,
                              ),
                            ),

                            SizedBox(height: watchSize * 0.02),

                            // Calories
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.local_fire_department,
                                  color: Colors.orange,
                                  size: watchSize * 0.04,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '${calories.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: watchSize * 0.04,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                ),
                                Text(
                                  ' kcal',
                                  style: TextStyle(
                                    fontSize: watchSize * 0.025,
                                    color: Colors.green.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: watchSize * 0.015),

                            // Distance and Heart Rate
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Distance
                                Column(
                                  children: [
                                    Text(
                                      '${distance.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: watchSize * 0.03,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'km',
                                      style: TextStyle(
                                        fontSize: watchSize * 0.02,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),

                                // Heart Rate
                                Column(
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.favorite,
                                          color: Colors.red,
                                          size: watchSize * 0.025,
                                        ),
                                        SizedBox(width: 2),
                                        Text(
                                          '$heartRate',
                                          style: TextStyle(
                                            fontSize: watchSize * 0.03,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'bpm',
                                      style: TextStyle(
                                        fontSize: watchSize * 0.02,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Touch areas for interaction
                    Positioned(
                      bottom: watchSize * 0.1,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Add steps button
                          GestureDetector(
                            onTap: _addSteps,
                            child: Container(
                              width: watchSize * 0.12,
                              height: watchSize * 0.12,
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.blue,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.add,
                                color: Colors.blue,
                                size: watchSize * 0.06,
                              ),
                            ),
                          ),

                          // Reset button
                          GestureDetector(
                            onTap: _resetData,
                            child: Container(
                              width: watchSize * 0.12,
                              height: watchSize * 0.12,
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.red, width: 2),
                              ),
                              child: Icon(
                                Icons.refresh,
                                color: Colors.red,
                                size: watchSize * 0.06,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Time display (top)
                    Positioned(
                      top: watchSize * 0.08,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: StreamBuilder(
                          stream: Stream.periodic(Duration(seconds: 1)),
                          builder: (context, snapshot) {
                            final now = DateTime.now();
                            return Text(
                              '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: watchSize * 0.05,
                                fontWeight: FontWeight.w300,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressRing({
    required double progress,
    required Color color,
    required double strokeWidth,
    required double radius,
  }) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        final animatedProgress = progress * _progressAnimation.value;

        return Center(
          child: SizedBox(
            width: radius * 2,
            height: radius * 2,
            child: CustomPaint(
              painter: ProgressRingPainter(
                progress: animatedProgress,
                color: color,
                strokeWidth: strokeWidth,
              ),
            ),
          ),
        );
      },
    );
  }
}

class ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // Start from top
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
