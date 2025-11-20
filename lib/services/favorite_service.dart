import '../database/database_helper.dart';
import '../models/favorite.dart';
import '../models/place.dart';

class FavoriteService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ===== CREATE =====
  
  /// Agregar un lugar a favoritos
  Future<int> addToFavorites({
    required int placeId,
    String? notes,
    String? tags,
    int priority = 2,
    bool notificationsEnabled = false,
  }) async {
    final favorite = Favorite(
      placeId: placeId,
      notes: notes,
      tags: tags,
      priority: priority,
      notificationsEnabled: notificationsEnabled,
    );
    
    return await _dbHelper.insertFavorite(favorite);
  }

  // ===== READ =====
  
  /// Obtener todos los favoritos con sus places
  Future<List<Map<String, dynamic>>> getAllFavoritesWithPlaces() async {
    return await _dbHelper.getAllFavoritesWithPlaces();
  }

  /// Obtener favorito por ID
  Future<Favorite?> getFavoriteById(int id) async {
    return await _dbHelper.getFavoriteById(id);
  }

  /// Obtener favorito por place ID
  Future<Favorite?> getFavoriteByPlaceId(int placeId) async {
    return await _dbHelper.getFavoriteByPlaceId(placeId);
  }

  /// Verificar si un lugar es favorito
  Future<bool> isFavorite(int placeId) async {
    final favorite = await getFavoriteByPlaceId(placeId);
    return favorite != null;
  }

  /// Obtener favoritos filtrados por prioridad
  Future<List<Map<String, dynamic>>> getFavoritesByPriority(int priority) async {
    return await _dbHelper.getFavoritesByPriority(priority);
  }

  /// Obtener favoritos filtrados por tag
  Future<List<Map<String, dynamic>>> getFavoritesByTag(String tag) async {
    return await _dbHelper.getFavoritesByTag(tag);
  }

  /// Buscar favoritos por notas
  Future<List<Map<String, dynamic>>> searchFavoritesByNotes(String query) async {
    return await _dbHelper.searchFavoritesByNotes(query);
  }

  /// Obtener todos los tags únicos
  Future<List<String>> getAllTags() async {
    return await _dbHelper.getAllFavoriteTags();
  }

  /// Obtener estadísticas de favoritos
  Future<Map<String, dynamic>> getFavoritesStats() async {
    final allFavorites = await _dbHelper.getAllFavoritesWithPlaces();
    
    int highPriority = 0;
    int mediumPriority = 0;
    int lowPriority = 0;
    int withNotes = 0;
    int withNotifications = 0;
    Set<String> uniqueTags = {};

    for (var item in allFavorites) {
      final favorite = item['favorite'] as Favorite;
      
      switch (favorite.priority) {
        case 1:
          highPriority++;
          break;
        case 2:
          mediumPriority++;
          break;
        case 3:
          lowPriority++;
          break;
      }

      if (favorite.notes != null && favorite.notes!.isNotEmpty) {
        withNotes++;
      }

      if (favorite.notificationsEnabled) {
        withNotifications++;
      }

      uniqueTags.addAll(favorite.getTagsList());
    }

    return {
      'total': allFavorites.length,
      'highPriority': highPriority,
      'mediumPriority': mediumPriority,
      'lowPriority': lowPriority,
      'withNotes': withNotes,
      'withNotifications': withNotifications,
      'totalTags': uniqueTags.length,
      'tags': uniqueTags.toList(),
    };
  }

  // ===== UPDATE =====
  
  /// Actualizar notas de un favorito
  Future<bool> updateNotes(int placeId, String notes) async {
    final favorite = await getFavoriteByPlaceId(placeId);
    if (favorite == null) return false;

    final updated = favorite.copyWith(notes: notes);
    await _dbHelper.updateFavorite(updated);
    return true;
  }

  /// Actualizar tags de un favorito
  Future<bool> updateTags(int placeId, String tags) async {
    final favorite = await getFavoriteByPlaceId(placeId);
    if (favorite == null) return false;

    final updated = favorite.copyWith(tags: tags);
    await _dbHelper.updateFavorite(updated);
    return true;
  }

  /// Agregar un tag a un favorito
  Future<bool> addTag(int placeId, String tag) async {
    final favorite = await getFavoriteByPlaceId(placeId);
    if (favorite == null) return false;

    final newTags = favorite.addTag(tag);
    final updated = favorite.copyWith(tags: newTags);
    await _dbHelper.updateFavorite(updated);
    return true;
  }

  /// Remover un tag de un favorito
  Future<bool> removeTag(int placeId, String tag) async {
    final favorite = await getFavoriteByPlaceId(placeId);
    if (favorite == null) return false;

    final newTags = favorite.removeTag(tag);
    final updated = favorite.copyWith(tags: newTags);
    await _dbHelper.updateFavorite(updated);
    return true;
  }

  /// Actualizar prioridad de un favorito
  Future<bool> updatePriority(int placeId, int priority) async {
    if (priority < 1 || priority > 3) return false;
    
    final favorite = await getFavoriteByPlaceId(placeId);
    if (favorite == null) return false;

    final updated = favorite.copyWith(priority: priority);
    await _dbHelper.updateFavorite(updated);
    return true;
  }

  /// Cambiar estado de notificaciones
  Future<bool> toggleNotifications(int placeId) async {
    final favorite = await getFavoriteByPlaceId(placeId);
    if (favorite == null) return false;

    final updated = favorite.copyWith(
      notificationsEnabled: !favorite.notificationsEnabled,
    );
    await _dbHelper.updateFavorite(updated);
    return true;
  }

  /// Actualizar favorito completo
  Future<bool> updateFavorite(Favorite favorite) async {
    await _dbHelper.updateFavorite(favorite);
    return true;
  }

  // ===== DELETE =====
  
  /// Remover de favoritos
  Future<bool> removeFromFavorites(int placeId) async {
    return await _dbHelper.deleteFavoriteByPlaceId(placeId);
  }

  /// Toggle favorito (agregar/remover)
  Future<bool> toggleFavorite({
    required int placeId,
    String? notes,
    String? tags,
    int priority = 2,
  }) async {
    final isFav = await isFavorite(placeId);
    
    if (isFav) {
      await removeFromFavorites(placeId);
      return false; // Removido
    } else {
      await addToFavorites(
        placeId: placeId,
        notes: notes,
        tags: tags,
        priority: priority,
      );
      return true; // Agregado
    }
  }

  // ===== ORDENAMIENTO =====
  
  /// Ordenar favoritos por fecha (más recientes primero)
  List<Map<String, dynamic>> sortByDate(
    List<Map<String, dynamic>> favorites,
    {bool ascending = false}
  ) {
    favorites.sort((a, b) {
      final favoriteA = a['favorite'] as Favorite;
      final favoriteB = b['favorite'] as Favorite;
      
      if (ascending) {
        return favoriteA.addedAt.compareTo(favoriteB.addedAt);
      } else {
        return favoriteB.addedAt.compareTo(favoriteA.addedAt);
      }
    });
    return favorites;
  }

  /// Ordenar favoritos por prioridad
  List<Map<String, dynamic>> sortByPriority(
    List<Map<String, dynamic>> favorites,
    {bool highToLow = true}
  ) {
    favorites.sort((a, b) {
      final favoriteA = a['favorite'] as Favorite;
      final favoriteB = b['favorite'] as Favorite;
      
      if (highToLow) {
        return favoriteA.priority.compareTo(favoriteB.priority);
      } else {
        return favoriteB.priority.compareTo(favoriteA.priority);
      }
    });
    return favorites;
  }

  /// Ordenar favoritos por nombre del lugar
  List<Map<String, dynamic>> sortByName(
    List<Map<String, dynamic>> favorites,
    {bool ascending = true}
  ) {
    favorites.sort((a, b) {
      final placeA = a['place'] as Place;
      final placeB = b['place'] as Place;
      
      if (ascending) {
        return placeA.title.compareTo(placeB.title);
      } else {
        return placeB.title.compareTo(placeA.title);
      }
    });
    return favorites;
  }

  /// Ordenar favoritos por rating del lugar
  List<Map<String, dynamic>> sortByRating(
    List<Map<String, dynamic>> favorites,
    {bool highToLow = true}
  ) {
    favorites.sort((a, b) {
      final placeA = a['place'] as Place;
      final placeB = b['place'] as Place;
      
      if (highToLow) {
        return placeB.rating.compareTo(placeA.rating);
      } else {
        return placeA.rating.compareTo(placeB.rating);
      }
    });
    return favorites;
  }
}
