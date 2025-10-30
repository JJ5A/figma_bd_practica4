import '../database/database_helper.dart';
import '../models/category.dart';
import '../data/fallback_data.dart';

class CategoryService {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  bool _useFallbackData = false;

  // Obtener todas las categorías activas
  Future<List<Category>> getAllCategories() async {
    try {
      if (_useFallbackData) {
        return FallbackData.getCategories();
      }
      return await _databaseHelper.getAllCategories();
    } catch (e) {
      print('Error con SQLite, usando datos de fallback: $e');
      _useFallbackData = true;
      return FallbackData.getCategories();
    }
  }

  // Obtener categoría por ID
  Future<Category?> getCategoryById(int id) async {
    try {
      return await _databaseHelper.getCategoryById(id);
    } catch (e) {
      throw Exception('Error al obtener categoría: $e');
    }
  }

  // Crear nueva categoría
  Future<int> createCategory(Category category) async {
    try {
      // Validar que el nombre no esté vacío
      if (category.name.trim().isEmpty) {
        throw Exception('El nombre de la categoría no puede estar vacío');
      }

      // Verificar que no exista una categoría con el mismo nombre
      List<Category> existingCategories = await getAllCategories();
      bool nameExists = existingCategories.any(
        (cat) => cat.name.toLowerCase() == category.name.toLowerCase(),
      );

      if (nameExists) {
        throw Exception('Ya existe una categoría con ese nombre');
      }

      return await _databaseHelper.insertCategory(category);
    } catch (e) {
      throw Exception('Error al crear categoría: $e');
    }
  }

  // Actualizar categoría existente
  Future<int> updateCategory(Category category) async {
    try {
      if (category.id == null) {
        throw Exception('ID de categoría requerido para actualizar');
      }

      if (category.name.trim().isEmpty) {
        throw Exception('El nombre de la categoría no puede estar vacío');
      }

      // Verificar que la categoría existe
      Category? existingCategory = await getCategoryById(category.id!);
      if (existingCategory == null) {
        throw Exception('Categoría no encontrada');
      }

      // Verificar que no exista otra categoría con el mismo nombre
      List<Category> allCategories = await getAllCategories();
      bool nameExists = allCategories.any(
        (cat) => cat.id != category.id && 
                 cat.name.toLowerCase() == category.name.toLowerCase(),
      );

      if (nameExists) {
        throw Exception('Ya existe otra categoría con ese nombre');
      }

      return await _databaseHelper.updateCategory(category);
    } catch (e) {
      throw Exception('Error al actualizar categoría: $e');
    }
  }

  // Eliminar categoría (soft delete)
  Future<int> deleteCategory(int id) async {
    try {
      Category? category = await getCategoryById(id);
      if (category == null) {
        throw Exception('Categoría no encontrada');
      }

      return await _databaseHelper.deleteCategory(id);
    } catch (e) {
      throw Exception('Error al eliminar categoría: $e');
    }
  }

  // Activar/desactivar categoría
  Future<int> toggleCategoryStatus(int id) async {
    try {
      Category? category = await getCategoryById(id);
      if (category == null) {
        throw Exception('Categoría no encontrada');
      }

      Category updatedCategory = category.copyWith(isActive: !category.isActive);
      return await _databaseHelper.updateCategory(updatedCategory);
    } catch (e) {
      throw Exception('Error al cambiar estado de categoría: $e');
    }
  }

  // Buscar categorías por nombre
  Future<List<Category>> searchCategories(String query) async {
    try {
      List<Category> allCategories = await getAllCategories();
      return allCategories
          .where((category) =>
              category.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      throw Exception('Error al buscar categorías: $e');
    }
  }

  // Validar si se puede eliminar una categoría
  Future<bool> canDeleteCategory(int id) async {
    try {
      // Aquí podrías agregar lógica adicional para verificar
      // si la categoría está siendo usada por lugares u otros elementos
      Category? category = await getCategoryById(id);
      return category != null;
    } catch (e) {
      return false;
    }
  }
}