import 'package:flutter/material.dart';
import 'dart:math' as math;

class DeviceUtils {
  // Detecta si el dispositivo es redondo basándose en la relación de aspecto
  static bool isRoundDevice(Size screenSize) {
    final aspectRatio = screenSize.width / screenSize.height;
    // Si la relación de aspecto está muy cerca de 1:1, consideramos que es redondo
    return (aspectRatio >= 0.95 && aspectRatio <= 1.05);
  }

  // Obtiene un factor de escala muy sutil
  static double getScaleFactor(Size screenSize) {
    if (isRoundDevice(screenSize)) {
      return 0.9; // Ligeramente más pequeño para redondos
    }
    return 1.0; // Tamaño normal para cuadrados
  }

  // Obtiene el padding mínimo necesario
  static EdgeInsets getDevicePadding(Size screenSize) {
    if (isRoundDevice(screenSize)) {
      // Para dispositivos redondos, un poco más de padding
      return EdgeInsets.symmetric(
        horizontal: screenSize.width * 0.06,
        vertical: screenSize.height * 0.04,
      );
    } else {
      // Para dispositivos cuadrados, padding original
      return EdgeInsets.symmetric(
        horizontal: screenSize.width * 0.05,
        vertical: screenSize.height * 0.02,
      );
    }
  }

  // Obtiene el tamaño del anillo de progreso
  static double getProgressRingSize(Size screenSize) {
    final baseSize = math.min(screenSize.width, screenSize.height) * 0.7;
    
    if (isRoundDevice(screenSize)) {
      return baseSize * 0.85; // Ligeramente más pequeño para redondos
    }
    return baseSize; // Tamaño original para cuadrados
  }

  // Obtiene la posición de los elementos de esquina
  static EdgeInsets getCornerElementsInsets(Size screenSize) {
    if (isRoundDevice(screenSize)) {
      // En dispositivos redondos, alejar un poco más de los bordes
      return EdgeInsets.only(
        top: screenSize.height * 0.03,
        left: screenSize.width * 0.08,
        right: screenSize.width * 0.08,
      );
    } else {
      // En dispositivos cuadrados, posición original
      return EdgeInsets.only(
        top: screenSize.height * 0.02,
        left: screenSize.width * 0.05,
        right: screenSize.width * 0.05,
      );
    }
  }
}