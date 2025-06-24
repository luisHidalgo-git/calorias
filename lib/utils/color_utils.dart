import 'package:flutter/material.dart';

class ColorUtils {
  // Colores basados en las calorías quemadas
  static Color getBackgroundColor(double calories) {
    if (calories < 50) {
      // Muy pocas calorías - azul oscuro relajante
      return Color(0xFF0D1B2A);
    } else if (calories < 100) {
      // Pocas calorías - azul medio
      return Color(0xFF1B263B);
    } else if (calories < 150) {
      // Calorías moderadas - púrpura
      return Color(0xFF2D1B69);
    } else if (calories < 200) {
      // Buenas calorías - naranja oscuro
      return Color(0xFF8B2635);
    } else if (calories < 250) {
      // Muchas calorías - rojo intenso
      return Color(0xFF9D0208);
    } else {
      // Meta alcanzada - dorado
      return Color(0xFF6F4E37);
    }
  }

  static Color getAccentColor(double calories) {
    if (calories < 50) {
      return Color(0xFF4CC9F0);
    } else if (calories < 100) {
      return Color(0xFF7209B7);
    } else if (calories < 150) {
      return Color(0xFF560BAD);
    } else if (calories < 200) {
      return Color(0xFFFF6B35);
    } else if (calories < 250) {
      return Color(0xFFFF0A54);
    } else {
      return Color(0xFFFFD60A);
    }
  }

  static Color getProgressColor(double calories) {
    if (calories < 50) {
      return Color(0xFF00B4D8);
    } else if (calories < 100) {
      return Color(0xFF9D4EDD);
    } else if (calories < 150) {
      return Color(0xFF7B2CBF);
    } else if (calories < 200) {
      return Color(0xFFFF8500);
    } else if (calories < 250) {
      return Color(0xFFFF006E);
    } else {
      return Color(0xFFFFBF00);
    }
  }

  static String getMotivationalText(double calories) {
    if (calories < 50) {
      return "¡Empezando!";
    } else if (calories < 100) {
      return "¡Buen ritmo!";
    } else if (calories < 150) {
      return "¡Excelente!";
    } else if (calories < 200) {
      return "¡Increíble!";
    } else if (calories < 250) {
      return "¡Casi ahí!";
    } else {
      return "¡META!";
    }
  }
}