import '../database/database_helper.dart';
import '../models/place.dart';
import '../data/fallback_data.dart';

class PlaceService {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  bool _useFallbackData = false;
  final List<Place> _fallbackFavorites = [];

  // Obtener lugares populares
  Future<List<Place>> getPopularPlaces() async {
    try {
      if (_useFallbackData) {
        return FallbackData.getPopularPlaces();
      }
      return await getPlacesByType(PlaceType.popular);
    } catch (e) {
      print('Error con SQLite, usando datos de fallback: $e');
      _useFallbackData = true;
      return FallbackData.getPopularPlaces();
    }
  }

  // Obtener lugares cercanos
  Future<List<Place>> getNearbyPlaces() async {
    try {
      if (_useFallbackData) {
        return FallbackData.getNearbyPlaces();
      }
      return await getPlacesByType(PlaceType.nearby);
    } catch (e) {
      print('Error con SQLite, usando datos de fallback: $e');
      _useFallbackData = true;
      return FallbackData.getNearbyPlaces();
    }
  }

  // Obtener todos los lugares
  Future<List<Place>> getAllPlaces() async {
    try {
      if (_useFallbackData) {
        return FallbackData.getAllPlaces();
      }
      return await _databaseHelper.getAllPlaces();
    } catch (e) {
      print('Error con SQLite, usando datos de fallback: $e');
      _useFallbackData = true;
      return FallbackData.getAllPlaces();
    }
  }

  // Obtener lugares por tipo
  Future<List<Place>> getPlacesByType(PlaceType type) async {
    try {
      if (_useFallbackData) {
        List<Place> allPlaces = FallbackData.getAllPlaces();
        return allPlaces.where((place) => place.type == type).toList();
      }
      return await _databaseHelper.getPlacesByType(type);
    } catch (e) {
      print('Error con SQLite, usando datos de fallback: $e');
      _useFallbackData = true;
      List<Place> allPlaces = FallbackData.getAllPlaces();
      return allPlaces.where((place) => place.type == type).toList();
    }
  }

  // Obtener lugar por ID
  Future<Place?> getPlaceById(int id) async {
    try {
      if (_useFallbackData) {
        List<Place> allPlaces = FallbackData.getAllPlaces();
        try {
          return allPlaces.firstWhere((place) => place.id == id);
        } catch (e) {
          return null;
        }
      }
      return await _databaseHelper.getPlaceById(id);
    } catch (e) {
      print('Error con SQLite, usando datos de fallback: $e');
      _useFallbackData = true;
      List<Place> allPlaces = FallbackData.getAllPlaces();
      try {
        return allPlaces.firstWhere((place) => place.id == id);
      } catch (e) {
        return null;
      }
    }
  }
  Future<List<Place>> getFavoritePlaces() async {
    try {
      if (_useFallbackData) {
        return _fallbackFavorites;
      }
      return await _databaseHelper.getFavoritePlaces();
    } catch (e) {
      print('Error con SQLite, usando datos de fallback: $e');
      _useFallbackData = true;
      return _fallbackFavorites;
    }
  }

  // Alternar favorito
  Future<int> toggleFavorite(int placeId) async {
    try {
      if (_useFallbackData) {
        // Simular toggle en memoria
        List<Place> allPlaces = FallbackData.getAllPlaces();
        Place? place = allPlaces.firstWhere((p) => p.id == placeId);
        
        if (_fallbackFavorites.any((p) => p.id == placeId)) {
          _fallbackFavorites.removeWhere((p) => p.id == placeId);
        } else {
          _fallbackFavorites.add(place.copyWith(isFavorite: true));
        }
        return 1;
      }
      
      return await _databaseHelper.toggleFavorite(placeId);
    } catch (e) {
      print('Error con SQLite, usando datos de fallback: $e');
      _useFallbackData = true;
      
      // Simular toggle en memoria
      List<Place> allPlaces = FallbackData.getAllPlaces();
      Place place = allPlaces.firstWhere((p) => p.id == placeId);
      
      if (_fallbackFavorites.any((p) => p.id == placeId)) {
        _fallbackFavorites.removeWhere((p) => p.id == placeId);
      } else {
        _fallbackFavorites.add(place.copyWith(isFavorite: true));
      }
      return 1;
    }
  }

  // Buscar lugares
  Future<List<Place>> searchPlaces(String query) async {
    try {
      if (_useFallbackData) {
        List<Place> allPlaces = FallbackData.getAllPlaces();
        if (query.trim().isEmpty) {
          return allPlaces;
        }
        return allPlaces.where((place) =>
            place.title.toLowerCase().contains(query.toLowerCase()) ||
            place.subtitle.toLowerCase().contains(query.toLowerCase())).toList();
      }
      
      if (query.trim().isEmpty) {
        return await getAllPlaces();
      }
      return await _databaseHelper.searchPlaces(query);
    } catch (e) {
      print('Error con SQLite, usando datos de fallback: $e');
      _useFallbackData = true;
      
      List<Place> allPlaces = FallbackData.getAllPlaces();
      if (query.trim().isEmpty) {
        return allPlaces;
      }
      return allPlaces.where((place) =>
          place.title.toLowerCase().contains(query.toLowerCase()) ||
          place.subtitle.toLowerCase().contains(query.toLowerCase())).toList();
    }
  }

  // Obtener lugares por rango de calificación
  Future<List<Place>> getPlacesByRating(double minRating, double maxRating) async {
    try {
      List<Place> allPlaces = await getAllPlaces();
      return allPlaces
          .where((place) => place.rating >= minRating && place.rating <= maxRating)
          .toList();
    } catch (e) {
      throw Exception('Error al obtener lugares por calificación: $e');
    }
  }

  // Obtener lugares ordenados por precio
  Future<List<Place>> getPlacesSortedByPrice({bool ascending = true}) async {
    try {
      List<Place> allPlaces = await getAllPlaces();
      
      // Función para extraer el número del precio (asumiendo formato "Rp 300.000")
      double extractPrice(String priceString) {
        // Remover "Rp " y puntos, convertir a número
        String cleanPrice = priceString.replaceAll(RegExp(r'[^\d]'), '');
        return double.tryParse(cleanPrice) ?? 0;
      }

      allPlaces.sort((a, b) {
        double priceA = extractPrice(a.price);
        double priceB = extractPrice(b.price);
        return ascending ? priceA.compareTo(priceB) : priceB.compareTo(priceA);
      });

      return allPlaces;
    } catch (e) {
      throw Exception('Error al ordenar lugares por precio: $e');
    }
  }

  // Obtener estadísticas de lugares
  Future<Map<String, dynamic>> getPlaceStatistics() async {
    try {
      List<Place> allPlaces = await getAllPlaces();
      List<Place> popularPlaces = await getPopularPlaces();
      List<Place> nearbyPlaces = await getNearbyPlaces();
      List<Place> favoritePlaces = await getFavoritePlaces();

      double averageRating = allPlaces.isNotEmpty
          ? allPlaces.map((p) => p.rating).reduce((a, b) => a + b) / allPlaces.length
          : 0.0;

      return {
        'totalPlaces': allPlaces.length,
        'popularPlaces': popularPlaces.length,
        'nearbyPlaces': nearbyPlaces.length,
        'favoritePlaces': favoritePlaces.length,
        'averageRating': averageRating,
        'highestRated': allPlaces.isNotEmpty
            ? allPlaces.reduce((a, b) => a.rating > b.rating ? a : b)
            : null,
      };
    } catch (e) {
      throw Exception('Error al obtener estadísticas: $e');
    }
  }

  // Validar datos del lugar
  String? validatePlace(Place place) {
    if (place.title.trim().isEmpty) {
      return 'El título es requerido';
    }
    if (place.subtitle.trim().isEmpty) {
      return 'La ubicación es requerida';
    }
    if (place.price.trim().isEmpty) {
      return 'El precio es requerido';
    }
    if (place.rating < 0 || place.rating > 5) {
      return 'La calificación debe estar entre 0 y 5';
    }
    if (place.imageAsset.trim().isEmpty) {
      return 'La imagen es requerida';
    }
    return null; // Sin errores
  }

  // Crear un nuevo lugar y devolver su ID
  Future<int> createPlace(Place place) async {
    final validationError = validatePlace(place);
    if (validationError != null) {
      throw Exception('Error de validación: $validationError');
    }

    try {
      if (_useFallbackData) {
        final id = FallbackData.addPlace(place);
        return id;
      }

      final placeId = await _databaseHelper.insertPlace(place);
      return placeId;
    } catch (e) {
      print('Error al crear lugar: $e');
      _useFallbackData = true;
      final fallbackId = FallbackData.addPlace(place);
      print('Lugar agregado en modo fallback con ID $fallbackId');
      return fallbackId;
    }
  }

  // Agregar un nuevo lugar
  Future<void> addPlace(Place place) async {
    await createPlace(place);
  }

  Future<void> updatePlace(Place place) async {
    final validationError = validatePlace(place);
    if (validationError != null) {
      throw Exception('Error de validación: $validationError');
    }

    try {
      if (_useFallbackData) {
        final updated = FallbackData.updatePlace(place);
        if (!updated) {
          throw Exception('No se encontró el lugar en datos fallback');
        }
        return;
      }

      await _databaseHelper.updatePlace(place);
    } catch (e) {
      print('Error al actualizar lugar: $e');
      _useFallbackData = true;
      final updated = FallbackData.updatePlace(place);
      if (!updated) {
        throw Exception('No se pudo actualizar el lugar en modo fallback');
      }
    }
  }

  Future<void> deletePlace(int placeId) async {
    try {
      if (_useFallbackData) {
        FallbackData.removePlace(placeId);
        return;
      }

      await _databaseHelper.deletePlace(placeId);
    } catch (e) {
      print('Error al eliminar lugar: $e');
      _useFallbackData = true;
      FallbackData.removePlace(placeId);
    }
  }
}