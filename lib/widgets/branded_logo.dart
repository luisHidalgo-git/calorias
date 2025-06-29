import 'package:flutter/material.dart';
import '../utils/color_utils.dart';
import '../utils/screen_utils.dart';

class BrandedLogo extends StatefulWidget {
  final double size;
  final bool animated;

  const BrandedLogo({
    super.key,
    required this.size,
    this.animated = false,
  });

  @override
  _BrandedLogoState createState() => _BrandedLogoState();
}

class _BrandedLogoState extends State<BrandedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    if (widget.animated) {
      _controller = AnimationController(
        duration: Duration(seconds: 3),
        vsync: this,
      );

      _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.linear),
      );

      _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );

      _controller.repeat();
    } else {
      _controller = AnimationController(
        duration: Duration.zero,
        vsync: this,
      );
      _rotationAnimation = AlwaysStoppedAnimation(0.0);
      _pulseAnimation = AlwaysStoppedAnimation(1.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isRound = ScreenUtils.isRoundScreen(screenSize);

    return AnimatedBuilder(
      animation: widget.animated ? _controller : _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 2 * 3.14159,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ColorUtils.getBackgroundColor(150),
                    ColorUtils.getBackgroundColor(100),
                    ColorUtils.getBackgroundColor(50),
                  ],
                  stops: [0.0, 0.7, 1.0],
                ),
                border: Border.all(
                  color: ColorUtils.getProgressColor(150),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ColorUtils.getProgressColor(150).withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Anillo de progreso decorativo
                  Positioned.fill(
                    child: CustomPaint(
                      painter: LogoRingPainter(
                        progress: 0.75,
                        color: ColorUtils.getProgressColor(200),
                      ),
                    ),
                  ),

                  // Ícono central
                  Center(
                    child: Container(
                      width: widget.size * 0.4,
                      height: widget.size * 0.4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ColorUtils.getAccentColor(150).withOpacity(0.2),
                        border: Border.all(
                          color: ColorUtils.getAccentColor(150),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.local_fire_department,
                        size: widget.size * 0.2,
                        color: ColorUtils.getAccentColor(200),
                      ),
                    ),
                  ),

                  // Puntos decorativos
                  Positioned(
                    top: widget.size * 0.1,
                    left: widget.size * 0.5 - 2,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ColorUtils.getAccentColor(150),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: widget.size * 0.1,
                    left: widget.size * 0.5 - 2,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ColorUtils.getAccentColor(150),
                      ),
                    ),
                  ),
                  Positioned(
                    left: widget.size * 0.1,
                    top: widget.size * 0.5 - 2,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ColorUtils.getAccentColor(150),
                      ),
                    ),
                  ),
                  Positioned(
                    right: widget.size * 0.1,
                    top: widget.size * 0.5 - 2,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ColorUtils.getAccentColor(150),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class LogoRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  LogoRingPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 20) / 2;

    // Anillo de fondo
    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Anillo de progreso
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * 3.14159 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(LogoRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}