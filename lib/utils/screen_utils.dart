import 'package:flutter/material.dart';

class ScreenUtils {
  // Detectar si la pantalla es redonda basándose en la relación de aspecto
  static bool isRoundScreen(Size screenSize) {
    final aspectRatio = screenSize.width / screenSize.height;
    return (aspectRatio > 0.9 && aspectRatio < 1.1);
  }

  // Obtener dimensiones adaptativas para diferentes tipos de pantalla
  static double getAdaptiveSize(
    Size screenSize,
    double baseSize, {
    double roundMultiplier = 0.9,
  }) {
    return isRoundScreen(screenSize) ? baseSize * roundMultiplier : baseSize;
  }

  // Obtener padding adaptativo
  static EdgeInsets getAdaptivePadding(
    Size screenSize,
    EdgeInsets basePadding, {
    double roundMultiplier = 0.8,
  }) {
    if (isRoundScreen(screenSize)) {
      return EdgeInsets.only(
        left: basePadding.left * roundMultiplier,
        right: basePadding.right * roundMultiplier,
        top: basePadding.top * roundMultiplier,
        bottom: basePadding.bottom * roundMultiplier,
      );
    }
    return basePadding;
  }

  // Obtener margen adaptativo para contenedores
  static EdgeInsets getAdaptiveMargin(Size screenSize, EdgeInsets baseMargin) {
    if (isRoundScreen(screenSize)) {
      return EdgeInsets.all(screenSize.width * 0.08);
    }
    return baseMargin;
  }
}
