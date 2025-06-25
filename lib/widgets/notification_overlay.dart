import 'package:flutter/material.dart';
import '../models/daily_calories.dart';

class NotificationOverlay extends StatefulWidget {
  final CalorieEntry entry;

  const NotificationOverlay({
    super.key,
    required this.entry,
  });

  @override
  _NotificationOverlayState createState() => _NotificationOverlayState();
}

class _NotificationOverlayState extends State<NotificationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();

    // Auto-dismiss después de 3 segundos
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: screenSize.width * 0.1),
                padding: EdgeInsets.all(screenSize.width * 0.06),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.withOpacity(0.4), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icono de fuego animado
                    Container(
                      padding: EdgeInsets.all(screenSize.width * 0.04),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.local_fire_department,
                        color: Colors.green.shade400,
                        size: screenSize.width * 0.08,
                      ),
                    ),

                    SizedBox(height: screenSize.height * 0.02),

                    // Título
                    Text(
                      '¡Calorías Quemadas!',
                      style: TextStyle(
                        fontSize: screenSize.width * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: screenSize.height * 0.01),

                    // Cantidad de calorías
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenSize.width * 0.04,
                        vertical: screenSize.height * 0.01,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Text(
                        '+${widget.entry.calories.toStringAsFixed(1)} cal',
                        style: TextStyle(
                          fontSize: screenSize.width * 0.045,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade300,
                        ),
                      ),
                    ),

                    SizedBox(height: screenSize.height * 0.015),

                    // Descripción de la actividad
                    Text(
                      widget.entry.description,
                      style: TextStyle(
                        fontSize: screenSize.width * 0.035,
                        color: Colors.grey.shade400,
                      ),
                    ),

                    SizedBox(height: screenSize.height * 0.01),

                    // Hora
                    Text(
                      widget.entry.formattedTime,
                      style: TextStyle(
                        fontSize: screenSize.width * 0.03,
                        color: Colors.grey.shade500,
                      ),
                    ),

                    SizedBox(height: screenSize.height * 0.02),

                    // Botón de cerrar
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Continuar',
                        style: TextStyle(
                          color: Colors.green.shade400,
                          fontSize: screenSize.width * 0.035,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}