import 'package:flutter/material.dart';

class ColorUtils {
  // Colores más suaves y legibles
  static Color getBackgroundColor(double calories) {
    if (calories < 50) {
      // Muy poca actividad - gris azulado oscuro
      return Color(0xFF1A1A2E);
    } else if (calories < 100) {
      // Actividad ligera - azul oscuro
      return Color(0xFF16213E);
    } else if (calories < 150) {
      // Actividad moderada - azul medio
      return Color(0xFF0F3460);
    } else if (calories < 200) {
      // Buena actividad - verde azulado
      return Color(0xFF1B4332);
    } else if (calories < 250) {
      // Excelente actividad - verde oscuro
      return Color(0xFF2D6A4F);
    } else {
      // Meta alcanzada - verde medio
      return Color(0xFF40916C);
    }
  }

  static Color getAccentColor(double calories) {
    if (calories < 50) {
      // Sedentario - gris claro suave
      return Color(0xFFD1D5DB);
    } else if (calories < 100) {
      // Ligero - azul suave
      return Color(0xFF93C5FD);
    } else if (calories < 150) {
      // Moderado - azul claro
      return Color(0xFF60A5FA);
    } else if (calories < 200) {
      // Bueno - verde suave
      return Color(0xFF86EFAC);
    } else if (calories < 250) {
      // Excelente - verde claro
      return Color(0xFF6EE7B7);
    } else {
      // Meta - verde brillante suave
      return Color(0xFF34D399);
    }
  }

  static Color getProgressColor(double calories) {
    if (calories < 50) {
      // Sedentario - gris medio
      return Color(0xFF9CA3AF);
    } else if (calories < 100) {
      // Ligero - azul medio
      return Color(0xFF60A5FA);
    } else if (calories < 150) {
      // Moderado - azul
      return Color(0xFF3B82F6);
    } else if (calories < 200) {
      // Bueno - verde medio
      return Color(0xFF22C55E);
    } else if (calories < 250) {
      // Excelente - verde
      return Color(0xFF16A34A);
    } else {
      // Meta - verde brillante
      return Color(0xFF10B981);
    }
  }

  static String getMotivationalText(double calories) {
    if (calories < 50) {
      return "SEDENTARIO";
    } else if (calories < 100) {
      return "LIGERO";
    } else if (calories < 150) {
      return "MODERADO";
    } else if (calories < 200) {
      return "ACTIVO";
    } else if (calories < 250) {
      return "MUY ACTIVO";
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
      return Color(0xFFDDEAFE);
    } else if (calories < 200) {
      return Color(0xFFD1FAE5);
    } else if (calories < 250) {
      return Color(0xFFDCFCE7);
    } else {
      return Color(0xFFD1FAE5);
    }
  }
}