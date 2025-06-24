import 'package:flutter/material.dart';

class ColorUtils {
  // Colores más realistas basados en niveles de actividad física
  static Color getBackgroundColor(double calories) {
    if (calories < 50) {
      // Muy poca actividad - gris azulado (sedentario)
      return Color(0xFF1A1A2E);
    } else if (calories < 100) {
      // Actividad ligera - azul oscuro
      return Color(0xFF16213E);
    } else if (calories < 150) {
      // Actividad moderada - verde oscuro
      return Color(0xFF0F3460);
    } else if (calories < 200) {
      // Buena actividad - verde medio
      return Color(0xFF1B4332);
    } else if (calories < 250) {
      // Excelente actividad - verde vibrante
      return Color(0xFF2D6A4F);
    } else {
      // Meta alcanzada - dorado/verde brillante
      return Color(0xFF40916C);
    }
  }

  static Color getAccentColor(double calories) {
    if (calories < 50) {
      // Sedentario - gris claro
      return Color(0xFF9CA3AF);
    } else if (calories < 100) {
      // Ligero - azul suave
      return Color(0xFF60A5FA);
    } else if (calories < 150) {
      // Moderado - amarillo suave
      return Color(0xFFFBBF24);
    } else if (calories < 200) {
      // Bueno - verde claro
      return Color(0xFF34D399);
    } else if (calories < 250) {
      // Excelente - verde brillante
      return Color(0xFF10B981);
    } else {
      // Meta - dorado brillante
      return Color(0xFFF59E0B);
    }
  }

  static Color getProgressColor(double calories) {
    if (calories < 50) {
      // Sedentario - gris
      return Color(0xFF6B7280);
    } else if (calories < 100) {
      // Ligero - azul
      return Color(0xFF3B82F6);
    } else if (calories < 150) {
      // Moderado - amarillo/naranja
      return Color(0xFFF97316);
    } else if (calories < 200) {
      // Bueno - verde
      return Color(0xFF22C55E);
    } else if (calories < 250) {
      // Excelente - verde intenso
      return Color(0xFF16A34A);
    } else {
      // Meta - dorado
      return Color(0xFFEAB308);
    }
  }

  static String getMotivationalText(double calories) {
    if (calories < 50) {
      return "Sedentario";
    } else if (calories < 100) {
      return "Ligero";
    } else if (calories < 150) {
      return "Moderado";
    } else if (calories < 200) {
      return "Activo";
    } else if (calories < 250) {
      return "Muy Activo";
    } else {
      return "¡META!";
    }
  }

  // Nuevo método para obtener descripción del nivel
  static String getActivityDescription(double calories) {
    if (calories < 50) {
      return "Necesitas moverte más";
    } else if (calories < 100) {
      return "Actividad básica";
    } else if (calories < 150) {
      return "Buen progreso";
    } else if (calories < 200) {
      return "Excelente trabajo";
    } else if (calories < 250) {
      return "Nivel excepcional";
    } else {
      return "¡Objetivo cumplido!";
    }
  }

  // Método para obtener el color del texto según el nivel
  static Color getTextColor(double calories) {
    if (calories < 50) {
      return Color(0xFFD1D5DB);
    } else if (calories < 100) {
      return Color(0xFFDBEAFE);
    } else if (calories < 150) {
      return Color(0xFFFEF3C7);
    } else if (calories < 200) {
      return Color(0xFFD1FAE5);
    } else if (calories < 250) {
      return Color(0xFFDCFCE7);
    } else {
      return Color(0xFFFEF3C7);
    }
  }
}