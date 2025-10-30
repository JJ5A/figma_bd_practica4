# Guía de Archivos del Proyecto - Hotel Booking App

## 📁 Estructura y Función de cada Archivo

### 🔧 Archivos de Configuración Raíz

#### `pubspec.yaml`
**Función**: Archivo de configuración principal de Flutter
- Define las dependencias del proyecto (table_calendar, sqflite, etc.)
- Especifica assets (imágenes, fuentes)
- Configura versiones de Dart y Flutter
- Administra metadatos del proyecto

#### `analysis_options.yaml`
**Función**: Configuración de análisis estático de código
- Define reglas de linting
- Configura warnings y errores
- Establece estándares de código

#### `README.md`
**Función**: Documentación principal del proyecto
- Instrucciones de instalación
- Descripción del proyecto
- Guía de uso

### 📱 Archivos Principales de la App (`lib/`)

#### `main.dart`
**Función**: Punto de entrada de la aplicación
```dart
void main() => runApp(MyApp());
```
- Inicializa la aplicación Flutter
- Configura el tema principal
- Define la ruta inicial (Splash Screen)
- Configura MaterialApp

#### `Splash_screen.dart`
**Función**: Pantalla de bienvenida/carga inicial
- Muestra logo y branding
- Transición automática al login después de 3 segundos
- Animaciones de entrada
- Primera impresión de la app

#### `login.dart`
**Función**: Pantalla de autenticación de usuarios
- Formulario de login con email/password
- Validación de campos
- Navegación a la pantalla principal
- UI de bienvenida

#### `home_page.dart`
**Función**: Pantalla principal de la aplicación
- **Dashboard central** con:
  - Barra de búsqueda de lugares
  - Lista de categorías (Casas, Camp, Villa, Hotel)
  - Sección "Popular" con lugares destacados
  - Sección "Nearby" con lugares cercanos
  - **Botones "Agregar"** para crear contenido dinámicamente
- Navegación a favoritos y perfil
- Gestión de estado de lugares y búsqueda

#### `detail.dart`
**Función**: Pantalla de detalles de un lugar específico
- Muestra información completa del lugar seleccionado
- Galería de imágenes
- Características (Features): WiFi, camas, comida
- Descripción detallada
- **Botón "Book Now"** que lleva al formulario de reserva
- Navegación al mapa
- Botón de favoritos

#### `favorites_page.dart`
**Función**: Pantalla de lugares favoritos del usuario
- Lista de todos los lugares marcados como favoritos
- Funcionalidad para remover de favoritos
- Navegación a detalles de cada lugar
- Pull-to-refresh para actualizar

#### `calendar_screen.dart`
**Función**: Pantalla de gestión de reservaciones con calendario
- **Calendario interactivo** con Table Calendar
- Vista de reservas por fecha
- **Botones para confirmar/cancelar reservas**
- Estados visuales de reservaciones
- Filtros por mes/semana
- Detalles completos de cada reserva

#### `map.dart`
**Función**: Pantalla de mapa y ubicación
- Muestra ubicación del lugar
- Información básica superpuesta
- Navegación de regreso
- Integración con servicios de mapas

### 🗃️ Modelos de Datos (`lib/models/`)

#### `place.dart`
**Función**: Modelo de datos para lugares/hoteles
```dart
class Place {
  final int? id;
  final String title;
  final String subtitle;
  final String imageAsset;
  final String price;
  final double rating;
  final PlaceType type; // popular, nearby
  final String description;
  final List<String> features;
  final bool isFavorite;
}
```
- Define estructura de un lugar
- Enum `PlaceType` (popular, nearby)
- Métodos `fromMap()` y `toMap()` para base de datos
- Método `copyWith()` para inmutabilidad

#### `user.dart`
**Función**: Modelo de datos para usuarios
```dart
class User {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final DateTime createdAt;
  final DateTime? updatedAt;
}
```
- Información de perfil de usuario
- Conversión a/desde base de datos
- Validación de datos

#### `reservation.dart`
**Función**: Modelo de datos para reservaciones
```dart
class Reservation {
  final int? id;
  final int placeId; // Foreign key
  final int userId;  // Foreign key
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int numberOfGuests;
  final double totalPrice;
  final ReservationStatus status;
  final String? specialRequests;
}
```
- Estados: pending, confirmed, cancelled, completed
- Relaciones con Place y User
- Cálculos de duración y precios

#### `category.dart`
**Función**: Modelo de datos para categorías de lugares
```dart
class Category {
  final int? id;
  final String name;
  final String imageAsset;
}
```
- Clasificación de lugares (Hotel, Casa, Villa, Camp)
- Íconos asociados

### 🔧 Servicios de Negocio (`lib/services/`)

#### `place_service.dart`
**Función**: Lógica de negocio para gestión de lugares
- **CRUD completo** de lugares
- **Sistema de fallback** cuando BD falla
- Búsqueda de lugares por texto
- Filtrado por tipo (popular/nearby)
- **Agregar lugares dinámicamente**
- Gestión de favoritos

#### `user_service.dart`
**Función**: Lógica de negocio para gestión de usuarios
- Registro y autenticación de usuarios
- CRUD de perfiles de usuario
- Búsqueda por email
- Validación de datos

#### `reservation_service.dart`
**Función**: Lógica de negocio para reservaciones
- **Crear, leer, actualizar reservas**
- **Confirmar y cancelar reservas**
- Verificación de disponibilidad de fechas
- **Cálculo automático de precios**
- Obtener reservas por usuario/lugar/fecha
- Estados de reserva

#### `category_service.dart`
**Función**: Lógica de negocio para categorías
- CRUD de categorías
- Listado de tipos de lugares
- Gestión de íconos

### 🗄️ Base de Datos (`lib/database/`)

#### `database_helper.dart`
**Función**: Gestión de base de datos SQLite
- **Singleton pattern** para instancia única
- Creación y migración de esquemas
- **4 tablas principales**:
  - `places` - Lugares
  - `users` - Usuarios  
  - `reservations` - Reservas
  - `categories` - Categorías
- **Relaciones Foreign Key**
- Operaciones CRUD para todas las entidades
- Manejo de errores y transacciones

### 🔄 Datos de Respaldo (`lib/data/`)

#### `fallback_data.dart`
**Función**: Datos predeterminados cuando la BD falla
- **Listas estáticas mutables** de lugares
- Datos de categorías por defecto
- **Método `addPlace()`** para agregar dinámicamente
- Generación de IDs únicos
- Respaldo completo sin conexión

### 🎨 Widgets Personalizados (`lib/widgets/`)

#### `popular_section.dart`
**Función**: Widget reutilizable para mostrar lugares
- Lista horizontal scrolleable
- Tarjetas de lugares con imagen, título, precio
- **Botón de favoritos interactivo**
- Callback para navegación
- Usado en home y favorites

#### `booking_form_screen.dart` ⭐ **NUEVO**
**Función**: Formulario completo de reservación
- **Calendario interactivo** con Table Calendar
- Selección de fechas check-in/check-out
- **Selector de huéspedes** con botones +/-
- Formulario de datos personales
- **Cálculo automático de precios** en tiempo real
- Validación completa de formulario
- **Animaciones suaves**
- Verificación de disponibilidad
- Creación automática de usuarios

#### `user_profile_screen.dart` ⭐ **NUEVO**
**Función**: Pantalla de perfil y gestión de reservas
- **Edición de perfil** con validación
- **Historial completo de reservaciones**
- **Botones confirmar/cancelar** por reserva
- Estadísticas visuales del usuario
- **Múltiples animaciones** coordinadas
- Estados visuales por tipo de reserva
- Recarga automática de datos

### 🧪 Archivos de Testing (`test/`)

#### `widget_test.dart`
**Función**: Tests básicos de widgets
- Test de creación de la app principal
- Verificación de widgets básicos

#### `crud_test.dart`
**Función**: Tests completos de operaciones CRUD
- Tests de base de datos para todas las entidades
- Verificación de relaciones Foreign Key
- **Tests de flujo completo de reservación**
- Validación de integridad de datos

#### `price_extraction_test.dart`
**Función**: Tests de extracción de precios
- Validación de parsing de precios "Rp 300.000"
- Manejo de diferentes formatos
- Cases edge para entradas inválidas

### 📱 Configuración por Plataforma

#### `android/` 
**Función**: Configuración específica de Android
- `build.gradle.kts` - Configuración de build
- `app/src/main/AndroidManifest.xml` - Permisos y configuración
- Íconos y recursos específicos de Android

#### `ios/`
**Función**: Configuración específica de iOS
- `Runner.xcodeproj/` - Proyecto Xcode
- `Info.plist` - Configuración de la app
- Íconos y recursos específicos de iOS

#### `web/`
**Función**: Configuración para Flutter Web
- `index.html` - Página principal web
- `manifest.json` - PWA configuration
- Íconos para web

#### `windows/`, `linux/`, `macos/`
**Función**: Configuraciones para aplicaciones de escritorio
- Archivos de build específicos por plataforma
- Configuraciones nativas

### 📊 Assets (`assets/`)

#### `assets/images/practica3/`
**Función**: Recursos visuales de la aplicación
- Imágenes de lugares (hoteles, casas, villas)
- Íconos de categorías
- Assets utilizados en la UI

## 🔄 Flujo de Datos

### Arquitectura de Capas:
1. **UI Layer** (`*.dart` screens) → Interfaz de usuario
2. **Widget Layer** (`widgets/`) → Componentes reutilizables  
3. **Service Layer** (`services/`) → Lógica de negocio
4. **Data Layer** (`database/` + `data/`) → Persistencia y fallback
5. **Model Layer** (`models/`) → Estructura de datos

### Flujo Típico:
```
UI → Service → Database → Fallback (si falla)
   ← Service ← Data    ←
```

## 📋 Resumen de Responsabilidades

| Tipo | Archivos | Responsabilidad Principal |
|------|----------|---------------------------|
| **Entry Points** | `main.dart`, `Splash_screen.dart` | Inicialización de la app |
| **Authentication** | `login.dart` | Autenticación de usuarios |
| **Main Screens** | `home_page.dart`, `detail.dart`, `calendar_screen.dart` | Navegación principal |
| **Feature Screens** | `favorites_page.dart`, `map.dart` | Funcionalidades específicas |
| **Custom Widgets** | `widgets/*.dart` | Componentes reutilizables complejos |
| **Business Logic** | `services/*.dart` | Lógica de negocio y operaciones |
| **Data Models** | `models/*.dart` | Estructura y validación de datos |
| **Data Persistence** | `database/`, `data/` | Almacenamiento y respaldo |
| **Testing** | `test/*.dart` | Validación y verificación |
| **Configuration** | Plataformas específicas | Build y configuración |

Cada archivo tiene una **responsabilidad única y bien definida**, siguiendo principios de **arquitectura limpia** y **separación de responsabilidades**.