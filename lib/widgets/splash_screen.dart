import 'package:flutter/material.dart';
import '../utils/screen_utils.dart';
import '../utils/color_utils.dart';

class SplashScreen extends StatefulWidget {
  final Widget child;

  const SplashScreen({super.key, required this.child});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: Duration(milliseconds: 3000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeInOut),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(Duration(milliseconds: 300));
    _fadeController.forward();

    await Future.delayed(Duration(milliseconds: 500));
    _scaleController.forward();

    await Future.delayed(Duration(milliseconds: 800));
    _rotateController.forward();

    await Future.delayed(Duration(milliseconds: 2500));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => widget.child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isRound = ScreenUtils.isRoundScreen(screenSize);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
              Colors.black,
            ],
            stops: [0.0, 0.4, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Fondo decorativo
            Positioned.fill(
              child: CustomPaint(painter: SplashBackgroundPainter()),
            ),

            // Contenido principal
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo principal
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _fadeAnimation,
                      _scaleAnimation,
                      _rotateAnimation,
                    ]),
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Transform.rotate(
                          angle: _rotateAnimation.value * 0.1,
                          child: Opacity(
                            opacity: _fadeAnimation.value,
                            child: Container(
                              width: screenSize.width * (isRound ? 0.35 : 0.4),
                              height: screenSize.width * (isRound ? 0.35 : 0.4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    ColorUtils.getProgressColor(200),
                                    ColorUtils.getProgressColor(100),
                                    ColorUtils.getProgressColor(50),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: ColorUtils.getProgressColor(
                                      150,
                                    ).withOpacity(0.5),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // Anillo de progreso animado
                                  Positioned.fill(
                                    child: CircularProgressIndicator(
                                      value: _rotateAnimation.value,
                                      strokeWidth: 4,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        ColorUtils.getAccentColor(200),
                                      ),
                                      backgroundColor: Colors.white.withOpacity(
                                        0.2,
                                      ),
                                    ),
                                  ),

                                  // Ícono central
                                  Center(
                                    child: Icon(
                                      Icons.local_fire_department,
                                      size:
                                          screenSize.width *
                                          (isRound ? 0.12 : 0.14),
                                      color: Colors.white,
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

                  SizedBox(height: screenSize.height * 0.05),

                  // Título de la aplicación
                  AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: Column(
                          children: [
                            Text(
                              'Smartwatch',
                              style: TextStyle(
                                fontSize:
                                    screenSize.width * (isRound ? 0.08 : 0.09),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2.0,
                                shadows: [
                                  Shadow(
                                    color: ColorUtils.getAccentColor(
                                      150,
                                    ).withOpacity(0.5),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: screenSize.height * 0.01),
                            Text(
                              'Calories Tracker',
                              style: TextStyle(
                                fontSize:
                                    screenSize.width * (isRound ? 0.04 : 0.045),
                                color: ColorUtils.getAccentColor(150),
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  SizedBox(height: screenSize.height * 0.08),

                  // Indicador de carga
                  AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value * 0.7,
                        child: Column(
                          children: [
                            SizedBox(
                              width: screenSize.width * 0.15,
                              height: 2,
                              child: LinearProgressIndicator(
                                backgroundColor: Colors.white.withOpacity(0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  ColorUtils.getAccentColor(150),
                                ),
                              ),
                            ),
                            SizedBox(height: screenSize.height * 0.02),
                            Text(
                              'Iniciando...',
                              style: TextStyle(
                                fontSize: screenSize.width * 0.035,
                                color: Colors.white.withOpacity(0.8),
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SplashBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Círculos decorativos
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.15), 30, paint);

    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.25), 20, paint);

    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.75), 25, paint);

    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.8), 15, paint);

    // Líneas decorativas
    final linePaint = Paint()
      ..color = Colors.blue.withOpacity(0.15)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.3);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.25,
      size.width,
      size.height * 0.3,
    );
    canvas.drawPath(path, linePaint);

    final path2 = Path();
    path2.moveTo(0, size.height * 0.7);
    path2.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.65,
      size.width,
      size.height * 0.7,
    );
    canvas.drawPath(path2, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
