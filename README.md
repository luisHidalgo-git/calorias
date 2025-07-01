# Smartwatch Calories - Flutter App

Una aplicación Flutter para monitoreo de calorías diseñada para smartwatches y dispositivos móviles con comunicación MQTT entre dispositivos.

## Características

-   🔥 Seguimiento de calorías en tiempo real
-   ❤️ Monitoreo de ritmo cardíaco
-   📱 Interfaz adaptativa para smartwatches y teléfonos
-   🌐 Comunicación MQTT entre dispositivos
-   📊 Historial de actividad diaria
-   ⚙️ Configuración personalizable
-   🔔 Notificaciones y alertas

## Requisitos del Sistema

### Software Necesario

-   **Flutter SDK**: 3.8.1 o superior
-   **Dart SDK**: 3.8.1 o superior
-   **Android Studio** o **VS Code** con extensiones de Flutter
-   **Git** para control de versiones

### Para Desarrollo Android

-   **Android SDK**: API level 21 o superior
-   **Java JDK**: 11 o superior
-   **Gradle**: 8.12 (incluido en el proyecto)

### Para Desarrollo iOS

-   **Xcode**: 15.0 o superior (solo en macOS)
-   **iOS SDK**: 12.0 o superior
-   **CocoaPods**: Para gestión de dependencias

## Instalación y Configuración

### 1. Clonar el Repositorio

```bash
git clone https://github.com/luisHidalgo-git/calorias.git
cd calorias
```

### 2. Verificar Instalación de Flutter

```bash
flutter doctor
```

Asegúrate de que todos los componentes estén correctamente instalados.

### 3. Instalar Dependencias

```bash
flutter pub get
```

### 4. Configuración de Permisos

#### Android

Los permisos ya están configurados en `android/app/src/main/AndroidManifest.xml`:

-   `BODY_SENSORS` - Para sensores de actividad física
-   `ACTIVITY_RECOGNITION` - Para reconocimiento de actividad
-   `WAKE_LOCK` - Para mantener la pantalla activa
-   `INTERNET` - Para comunicación MQTT

#### iOS

Los permisos se solicitan automáticamente en tiempo de ejecución.

### 5. Generar Archivos Necesarios

Si faltan archivos de configuración, ejecuta:

```bash
# Para Android
flutter build apk --debug

# Para iOS (solo en macOS)
flutter build ios --debug
```

## Ejecución del Proyecto

### Desarrollo en Dispositivo/Emulador

```bash
# Listar dispositivos disponibles
flutter devices

# Ejecutar en dispositivo específico
flutter run -d <device-id>

# Ejecutar en modo debug (por defecto)
flutter run

# Ejecutar en modo release
flutter run --release
```

### Para Smartwatches Android

```bash
# Asegúrate de que el smartwatch esté conectado y en modo desarrollador
adb devices

# Ejecutar específicamente en el smartwatch
flutter run -d <smartwatch-device-id>
```

## Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada de la aplicación
├── models/                   # Modelos de datos
├── screens/                  # Pantallas principales
├── services/                 # Servicios (MQTT, permisos, etc.)
├── utils/                    # Utilidades y helpers
└── widgets/                  # Widgets reutilizables

android/                      # Configuración Android
ios/                         # Configuración iOS
assets/                      # Recursos (imágenes, iconos)
```

## Configuración MQTT

La aplicación utiliza un broker MQTT público para comunicación entre dispositivos:

-   **Broker**: `test.mosquitto.org`
-   **Puerto**: `1883`
-   **Topics**: `smartwatch/calories/v1/*`

### Configuración Personalizada

Para usar tu propio broker MQTT, modifica las constantes en:
`lib/services/mqtt_communication_service.dart`

```dart
static const String _mqttHost = 'tu-broker.com';
static const int _mqttPort = 1883;
```

## Funcionalidades Principales

### 1. Pantalla Principal (Watch Face)

-   Visualización de calorías en tiempo real
-   Anillo de progreso animado
-   Ritmo cardíaco
-   Hora actual

### 2. Historial de Calorías

-   Tabla de registros diarios
-   Estadísticas generales
-   Progreso hacia objetivos

### 3. Configuración

-   Meta diaria de calorías
-   Frecuencia de lectura
-   Configuración de alertas
-   Ajustes de pantalla

### 4. Comunicación MQTT

-   Sincronización entre dispositivos
-   Mensajes de actividad
-   Estado de conexión en tiempo real

## Desarrollo y Personalización

### Agregar Nuevas Funcionalidades

1. **Modelos**: Crear en `lib/models/`
2. **Servicios**: Implementar en `lib/services/`
3. **UI**: Agregar widgets en `lib/widgets/`
4. **Pantallas**: Crear en `lib/screens/`

### Temas y Estilos

Los colores y estilos se gestionan en:

-   `lib/utils/color_utils.dart` - Colores dinámicos
-   `lib/widgets/adaptive_text.dart` - Texto adaptativo

### Dispositivos Soportados

-   **Smartwatches**: Pantallas circulares y cuadradas
-   **Teléfonos**: Android e iOS
-   **Tablets**: Interfaz expandida

## Solución de Problemas

### Problemas Comunes

1. **Error de permisos en Android**:

    ```bash
    flutter clean
    flutter pub get
    flutter run
    ```

2. **Problemas de MQTT**:

    - Verificar conexión a internet
    - Comprobar firewall/proxy
    - Usar broker alternativo

3. **Errores de compilación iOS**:
    ```bash
    cd ios
    pod install
    cd ..
    flutter run
    ```

### Logs y Debugging

```bash
# Ver logs detallados
flutter run --verbose

# Logs específicos de MQTT
# Buscar en consola: "📡", "📤", "📥"
```

## Contribución

1. Fork del repositorio
2. Crear rama para nueva funcionalidad
3. Implementar cambios
4. Ejecutar tests: `flutter test`
5. Crear Pull Request

## Licencia

Este proyecto está bajo la licencia MIT. Ver archivo `LICENSE` para más detalles.

## Soporte

Para reportar bugs o solicitar funcionalidades, crear un issue en el repositorio.

---

**Nota**: Esta aplicación está optimizada para smartwatches con Wear OS y dispositivos Android/iOS. Para mejor experiencia, usar en dispositivos con pantallas pequeñas (< 400px).
.
