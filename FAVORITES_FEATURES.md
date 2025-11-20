# Sistema de Favoritos - Funcionalidades Implementadas

## 📋 Descripción General
Sistema completo de CRUD para gestión de lugares favoritos con funcionalidades avanzadas de organización y búsqueda.

## 🎯 Características Principales

### 1. Modelo de Datos (`models/favorite.dart`)
- **ID**: Identificador único del favorito
- **Place ID**: Relación con el lugar (Foreign Key)
- **Notas**: Texto personalizado del usuario
- **Tags**: Etiquetas separadas por comas (ej: "playa,familiar,económico")
- **Fecha de Agregado**: Timestamp automático
- **Prioridad**: 3 niveles (1=Alta, 2=Media, 3=Baja)
- **Notificaciones**: Toggle para recibir notificaciones

### 2. Operaciones CRUD (`services/favorite_service.dart`)

#### CREATE
- `addToFavorites()` - Agregar lugar a favoritos con configuración completa
- `toggleFavorite()` - Agregar/remover favorito inteligentemente

#### READ
- `getAllFavoritesWithPlaces()` - Obtener todos los favoritos con datos del lugar
- `getFavoriteById()` - Buscar favorito por ID
- `getFavoriteByPlaceId()` - Buscar favorito por ID de lugar
- `isFavorite()` - Verificar si un lugar está en favoritos
- `getFavoritesByPriority()` - Filtrar por nivel de prioridad
- `getFavoritesByTag()` - Filtrar por tag específico
- `searchFavoritesByNotes()` - Búsqueda en notas
- `getAllTags()` - Obtener todos los tags únicos
- `getFavoritesStats()` - Estadísticas completas

#### UPDATE
- `updateFavorite()` - Actualizar favorito completo
- `updateNotes()` - Actualizar solo notas
- `updateTags()` - Actualizar solo tags
- `addTag()` - Agregar un tag
- `removeTag()` - Remover un tag
- `updatePriority()` - Cambiar prioridad
- `toggleNotifications()` - Activar/desactivar notificaciones

#### DELETE
- `removeFromFavorites()` - Eliminar favorito por ID o placeId

#### ORDENAMIENTO
- `sortByDate()` - Por fecha de agregado (ascendente/descendente)
- `sortByPriority()` - Por nivel de prioridad
- `sortByName()` - Por nombre del lugar
- `sortByRating()` - Por rating del lugar

### 3. Interfaz de Usuario (`favorites_page.dart`)

#### Barra Superior
- **Botón Filtros** - Abrir diálogo de filtros
- **Botón Ordenar** - Elegir criterio de ordenamiento
- **Botón Estadísticas** - Ver resumen de favoritos

#### Búsqueda
- **Barra de búsqueda** - Búsqueda en tiempo real
- Busca en: nombre del lugar, ubicación y notas personales
- Botón de limpiar búsqueda

#### Filtros Activos
- **Chips visuales** mostrando filtros aplicados
- Opción de eliminar cada filtro individualmente
- Filtros disponibles:
  - Por prioridad (Alta/Media/Baja)
  - Por tag personalizado

#### Tarjetas de Favoritos
Cada tarjeta muestra:
- **Imagen** del lugar
- **Rating** con estrella verde
- **Prioridad** con bandera de color:
  - 🔴 Roja = Alta prioridad
  - 🟠 Naranja = Media prioridad
  - 🟢 Verde = Baja prioridad
- **Icono de notificaciones** (si están activadas)
- **Tags** (hasta 2 visibles)
- **Preview de notas**
- **Nombre y ubicación** del lugar
- **Precio**
- **Botón Editar** (✏️ verde)
- **Botón Remover** (❤️ rojo)

#### Diálogo de Edición
Al tocar el botón de editar:
- Campo de texto para **notas** (multilinea)
- Campo de texto para **tags** (separados por coma)
- Selector de **prioridad** (3 chips)
- Switch para **notificaciones**
- Botones Cancelar y Guardar

#### Diálogo de Filtros
Permite filtrar por:
- **Prioridad**: Todos, Alta, Media, Baja
- **Tag**: Lista dinámica de todos los tags usados
- Botón "Limpiar Filtros"

#### Diálogo de Ordenamiento
4 opciones:
- Fecha de agregado (más recientes primero)
- Prioridad (alta a baja)
- Nombre (alfabético)
- Rating (mayor a menor)

#### Diálogo de Estadísticas
Muestra:
- Total de favoritos
- Cantidad por prioridad (Alta/Media/Baja)
- Favoritos con notificaciones
- Rating promedio

#### Estados Vacíos
- **Sin favoritos**: Mensaje y botón para explorar lugares
- **Sin resultados**: Mensaje sugiriendo ajustar filtros

#### Pull-to-Refresh
Deslizar hacia abajo recarga la lista de favoritos

## 🗄️ Base de Datos (`database/database_helper.dart`)

### Tabla `favorites`
```sql
CREATE TABLE favorites (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  place_id INTEGER UNIQUE NOT NULL,
  notes TEXT,
  tags TEXT,
  added_at TEXT NOT NULL,
  priority INTEGER DEFAULT 2,
  notifications_enabled INTEGER DEFAULT 0,
  FOREIGN KEY (place_id) REFERENCES places (id) ON DELETE CASCADE
)
```

### Métodos Implementados
- `insertFavorite()` - Insertar nuevo favorito
- `getAllFavoritesWithPlaces()` - JOIN con tabla places
- `getFavoriteById()` - Buscar por ID
- `getFavoriteByPlaceId()` - Buscar por place_id
- `getFavoritesByPriority()` - Filtrar por prioridad
- `getFavoritesByTag()` - Filtrar por tag (LIKE)
- `searchFavoritesByNotes()` - Buscar en notas (LIKE)
- `getAllFavoriteTags()` - Obtener tags únicos
- `updateFavorite()` - Actualizar favorito
- `deleteFavorite()` - Eliminar por ID
- `deleteFavoriteByPlaceId()` - Eliminar por place_id

## 🎨 Diseño Visual

### Colores
- **Verde principal**: `#22B07D` - Botones y elementos activos
- **Rojo**: Prioridad alta y botón de remover
- **Naranja**: Prioridad media
- **Verde**: Prioridad baja
- **Azul**: Icono de notificaciones

### Iconos
- ✏️ Editar
- ❤️ Favorito/Remover
- ⭐ Rating
- 🚩 Prioridad
- 🔔 Notificaciones
- 🔍 Búsqueda
- 📊 Estadísticas
- 🗂️ Filtros
- ↕️ Ordenar

## 🔄 Flujo de Usuario

1. **Ver Favoritos**: Lista en grid 2 columnas con información visual
2. **Buscar**: Escribir en barra superior, resultados en tiempo real
3. **Filtrar**: Seleccionar prioridad o tag desde diálogo
4. **Ordenar**: Elegir criterio de ordenamiento
5. **Editar**: Modificar notas, tags, prioridad, notificaciones
6. **Remover**: Tocar icono de corazón en tarjeta
7. **Ver Detalles**: Tocar tarjeta para ir a página de detalle
8. **Actualizar**: Pull-to-refresh para recargar

## 📱 Características Técnicas

- **Arquitectura**: Model → Service → Database Helper → UI
- **Estado**: StatefulWidget con gestión local de estado
- **Persistencia**: SQLite con foreign keys
- **Búsqueda**: Filtrado en memoria + queries SQL
- **Ordenamiento**: In-memory sorting
- **UI**: Material Design con widgets personalizados
- **Responsive**: Grid adaptativo, scroll infinito
- **Feedback**: SnackBars para confirmaciones y errores

## ✅ Testing Recomendado

1. Agregar lugares a favoritos desde página de detalles
2. Editar notas y tags de favoritos
3. Filtrar por diferentes prioridades
4. Buscar por nombre, ubicación y notas
5. Ordenar por diferentes criterios
6. Ver estadísticas
7. Remover favoritos
8. Verificar persistencia (cerrar/abrir app)
9. Probar estados vacíos
10. Verificar foreign key cascade (eliminar lugar)
