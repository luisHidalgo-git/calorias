import 'package:flutter/material.dart';
import '../utils/screen_utils.dart';
import '../utils/device_utils.dart';
import '../utils/color_utils.dart';

class SplashScreen extends StatefulWidget {
  final Widget child;

  const SplashScreen({
    super.key,
    required this.child,
  });

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
    final deviceType = DeviceUtils.getDeviceType(screenSize.width, screenSize.height);
    final isWearable = deviceType == DeviceType.wearable;

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
              child: CustomPaint(
                painter: SplashBackgroundPainter(),
              ),
            ),

            // Contenido principal adaptativo
            Center(
              child: isWearable 
                  ? _buildWearableContent(screenSize)
                  : _buildPhoneContent(screenSize),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWearableContent(Size screenSize) {
    final isRound = ScreenUtils.isRoundScreen(screenSize);
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo principal personalizado
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
                          Color(0xFF3B82F6),
                          Color(0xFF1E40AF),
                          Color(0xFF1E3A8A),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF3B82F6).withOpacity(0.5),
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
                              Color(0xFF60A5FA),
                            ),
                            backgroundColor: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        
                        // Logo personalizado en el centro
                        Center(
                          child: CustomPaint(
                            size: Size(
                              screenSize.width * (isRound ? 0.15 : 0.17),
                              screenSize.width * (isRound ? 0.15 : 0.17),
                            ),
                            painter: CustomLogoPainter(),
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
                    'CalorieWatch',
                    style: TextStyle(
                      fontSize: screenSize.width * (isRound ? 0.08 : 0.09),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2.0,
                      shadows: [
                        Shadow(
                          color: Color(0xFF3B82F6).withOpacity(0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.01),
                  Text(
                    'Fitness Tracker',
                    style: TextStyle(
                      fontSize: screenSize.width * (isRound ? 0.04 : 0.045),
                      color: Color(0xFF60A5FA),
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
                        Color(0xFF60A5FA),
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
    );
  }

  Widget _buildPhoneContent(Size screenSize) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo principal más grande para teléfonos
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
                    width: screenSize.width * 0.5,
                    height: screenSize.width * 0.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Color(0xFF3B82F6),
                          Color(0xFF1E40AF),
                          Color(0xFF1E3A8A),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF3B82F6).withOpacity(0.5),
                          blurRadius: 40,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Anillo de progreso animado
                        Positioned.fill(
                          child: CircularProgressIndicator(
                            value: _rotateAnimation.value,
                            strokeWidth: 6,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF60A5FA),
                            ),
                            backgroundColor: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        
                        // Logo personalizado en el centro
                        Center(
                          child: CustomPaint(
                            size: Size(
                              screenSize.width * 0.25,
                              screenSize.width * 0.25,
                            ),
                            painter: CustomLogoPainter(),
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

        SizedBox(height: screenSize.height * 0.06),

        // Título de la aplicación más grande
        AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Column(
                children: [
                  Text(
                    'CalorieWatch',
                    style: TextStyle(
                      fontSize: screenSize.width * 0.12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 3.0,
                      shadows: [
                        Shadow(
                          color: Color(0xFF3B82F6).withOpacity(0.5),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  Text(
                    'Fitness Tracker',
                    style: TextStyle(
                      fontSize: screenSize.width * 0.06,
                      color: Color(0xFF60A5FA),
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.01),
                  Text(
                    'Monitorea tu actividad diaria',
                    style: TextStyle(
                      fontSize: screenSize.width * 0.04,
                      color: Colors.white.withOpacity(0.7),
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        SizedBox(height: screenSize.height * 0.08),

        // Indicador de carga más prominente
        AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value * 0.8,
              child: Column(
                children: [
                  Container(
                    width: screenSize.width * 0.6,
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF60A5FA),
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.03),
                  Text(
                    'Iniciando aplicación...',
                    style: TextStyle(
                      fontSize: screenSize.width * 0.045,
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
    );
  }
}

class CustomLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Círculo exterior
    paint.color = Color(0xFF1F2937);
    canvas.drawCircle(center, radius * 0.9, paint);

    // Borde del círculo
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Color(0xFF60A5FA);
    canvas.drawCircle(center, radius * 0.9, paint);

    // Anillo de progreso
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = Color(0xFF3B82F6)
      ..strokeCap = StrokeCap.round;
    
    final rect = Rect.fromCircle(center: center, radius: radius * 0.7);
    canvas.drawArc(rect, -1.57, 4.71, false, paint);

    // Círculo central
    paint
      ..style = PaintingStyle.fill
      ..color = Color(0xFF374151);
    canvas.drawCircle(center, radius * 0.5, paint);

    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Color(0xFF60A5FA);
    canvas.drawCircle(center, radius * 0.5, paint);

    // Ícono de fuego personalizado
    paint
      ..style = PaintingStyle.fill
      ..color = Color(0xFFFF6B35);

    final flamePath = Path();
    final flameCenter = center;
    final flameRadius = radius * 0.25;
    
    // Forma de llama simplificada
    flamePath.moveTo(flameCenter.dx, flameCenter.dy + flameRadius);
    flamePath.quadraticBezierTo(
      flameCenter.dx - flameRadius * 0.8, flameCenter.dy,
      flameCenter.dx, flameCenter.dy - flameRadius * 0.8,
    );
    flamePath.quadraticBezierTo(
      flameCenter.dx + flameRadius * 0.8, flameCenter.dy,
      flameCenter.dx, flameCenter.dy + flameRadius,
    );
    
    canvas.drawPath(flamePath, paint);

    // Puntos decorativos
    paint
      ..style = PaintingStyle.fill
      ..color = Color(0xFF60A5FA);
    
    final dotRadius = 2.0;
    canvas.drawCircle(Offset(center.dx, center.dy - radius * 0.8), dotRadius, paint);
    canvas.drawCircle(Offset(center.dx, center.dy + radius * 0.8), dotRadius, paint);
    canvas.drawCircle(Offset(center.dx - radius * 0.8, center.dy), dotRadius, paint);
    canvas.drawCircle(Offset(center.dx + radius * 0.8, center.dy), dotRadius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SplashBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF3B82F6).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Círculos decorativos
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.15),
      30,
      paint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.25),
      20,
      paint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.75),
      25,
      paint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.8),
      15,
      paint,
    );

    // Líneas decorativas
    final linePaint = Paint()
      ..color = Color(0xFF3B82F6).withOpacity(0.15)
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