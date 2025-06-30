import 'package:flutter/material.dart';

class WatchFaceAnimations {
  final TickerProvider _vsync;
  
  late AnimationController _pulseController;
  late AnimationController _backgroundController;
  late AnimationController _goalReachedController;
  
  late Animation<double> _pulseAnimation;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _goalReachedAnimation;

  WatchFaceAnimations(this._vsync) {
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: _vsync,
    )..repeat(reverse: true);

    _backgroundController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: _vsync,
    );

    _goalReachedController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: _vsync,
    );

    _pulseAnimation = Tween<double>(begin: 0.99, end: 1.01).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );

    _goalReachedAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _goalReachedController, curve: Curves.elasticOut),
    );
  }

  // Getters for animations
  Animation<double> get pulseAnimation => _pulseAnimation;
  Animation<double> get backgroundAnimation => _backgroundAnimation;
  Animation<double> get goalReachedAnimation => _goalReachedAnimation;

  // Animation triggers
  void triggerBackgroundPulse() {
    _backgroundController.forward().then((_) {
      _backgroundController.reverse();
    });
  }

  void triggerGoalReached() {
    _goalReachedController.forward().then((_) {
      _goalReachedController.reverse();
    });
  }

  void dispose() {
    _pulseController.dispose();
    _backgroundController.dispose();
    _goalReachedController.dispose();
  }
}