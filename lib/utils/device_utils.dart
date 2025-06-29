class DeviceUtils {
  // Detectar si es un dispositivo tipo smartwatch
  static bool isWearableDevice(double screenWidth, double screenHeight) {
    // Smartwatches típicamente tienen pantallas pequeñas (< 400px)
    final minDimension = screenWidth < screenHeight ? screenWidth : screenHeight;
    return minDimension < 400;
  }

  // Detectar si es un teléfono
  static bool isPhoneDevice(double screenWidth, double screenHeight) {
    final minDimension = screenWidth < screenHeight ? screenWidth : screenHeight;
    final maxDimension = screenWidth > screenHeight ? screenWidth : screenHeight;
    
    // Teléfonos típicamente tienen relación de aspecto > 1.5 y pantalla > 400px
    return minDimension >= 400 && (maxDimension / minDimension) > 1.5;
  }

  // Detectar si es una tablet
  static bool isTabletDevice(double screenWidth, double screenHeight) {
    final minDimension = screenWidth < screenHeight ? screenWidth : screenHeight;
    final maxDimension = screenWidth > screenHeight ? screenWidth : screenHeight;
    
    // Tablets tienen pantallas grandes pero relación de aspecto menor
    return minDimension >= 600 && (maxDimension / minDimension) <= 1.5;
  }

  // Obtener tipo de dispositivo
  static DeviceType getDeviceType(double screenWidth, double screenHeight) {
    if (isWearableDevice(screenWidth, screenHeight)) {
      return DeviceType.wearable;
    } else if (isPhoneDevice(screenWidth, screenHeight)) {
      return DeviceType.phone;
    } else if (isTabletDevice(screenWidth, screenHeight)) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  // Obtener configuración de layout según dispositivo
  static LayoutConfig getLayoutConfig(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.wearable:
        return LayoutConfig(
          showSideButtons: true,
          compactLayout: true,
          circularDesign: true,
          fontSize: 0.9,
          padding: 0.8,
          iconSize: 0.9,
        );
      case DeviceType.phone:
        return LayoutConfig(
          showSideButtons: false,
          compactLayout: false,
          circularDesign: false,
          fontSize: 1.0,
          padding: 1.0,
          iconSize: 1.0,
        );
      case DeviceType.tablet:
        return LayoutConfig(
          showSideButtons: false,
          compactLayout: false,
          circularDesign: false,
          fontSize: 1.1,
          padding: 1.2,
          iconSize: 1.1,
        );
      case DeviceType.desktop:
        return LayoutConfig(
          showSideButtons: false,
          compactLayout: false,
          circularDesign: false,
          fontSize: 1.2,
          padding: 1.4,
          iconSize: 1.2,
        );
    }
  }
}

enum DeviceType {
  wearable,
  phone,
  tablet,
  desktop,
}

class LayoutConfig {
  final bool showSideButtons;
  final bool compactLayout;
  final bool circularDesign;
  final double fontSize;
  final double padding;
  final double iconSize;

  const LayoutConfig({
    required this.showSideButtons,
    required this.compactLayout,
    required this.circularDesign,
    required this.fontSize,
    required this.padding,
    required this.iconSize,
  });
}