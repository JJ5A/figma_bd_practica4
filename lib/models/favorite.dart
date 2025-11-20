class Favorite {
  final int? id;
  final int placeId; // Foreign key to places table
  final String? notes; // Notas personales del usuario
  final String? tags; // Tags separados por comas: "romántico,playa,familiar"
  final DateTime addedAt; // Fecha cuando se agregó a favoritos
  final int priority; // Prioridad: 1=alta, 2=media, 3=baja
  final bool notificationsEnabled; // Si quiere notificaciones del lugar

  Favorite({
    this.id,
    required this.placeId,
    this.notes,
    this.tags,
    DateTime? addedAt,
    this.priority = 2, // Default: media
    this.notificationsEnabled = false,
  }) : addedAt = addedAt ?? DateTime.now();

  // Convertir a Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'place_id': placeId,
      'notes': notes,
      'tags': tags,
      'added_at': addedAt.toIso8601String(),
      'priority': priority,
      'notifications_enabled': notificationsEnabled ? 1 : 0,
    };
  }

  // Crear desde Map de SQLite
  factory Favorite.fromMap(Map<String, dynamic> map) {
    return Favorite(
      id: map['id'] as int?,
      placeId: map['place_id'] as int,
      notes: map['notes'] as String?,
      tags: map['tags'] as String?,
      addedAt: DateTime.parse(map['added_at'] as String),
      priority: map['priority'] as int? ?? 2,
      notificationsEnabled: (map['notifications_enabled'] as int? ?? 0) == 1,
    );
  }

  // Copiar con cambios
  Favorite copyWith({
    int? id,
    int? placeId,
    String? notes,
    String? tags,
    DateTime? addedAt,
    int? priority,
    bool? notificationsEnabled,
  }) {
    return Favorite(
      id: id ?? this.id,
      placeId: placeId ?? this.placeId,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      addedAt: addedAt ?? this.addedAt,
      priority: priority ?? this.priority,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  // Obtener lista de tags
  List<String> getTagsList() {
    if (tags == null || tags!.isEmpty) return [];
    return tags!.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  // Agregar un tag
  String addTag(String newTag) {
    final currentTags = getTagsList();
    if (!currentTags.contains(newTag.trim())) {
      currentTags.add(newTag.trim());
    }
    return currentTags.join(',');
  }

  // Remover un tag
  String removeTag(String tagToRemove) {
    final currentTags = getTagsList();
    currentTags.remove(tagToRemove.trim());
    return currentTags.join(',');
  }

  // Obtener nombre de prioridad
  String getPriorityName() {
    switch (priority) {
      case 1:
        return 'Alta';
      case 2:
        return 'Media';
      case 3:
        return 'Baja';
      default:
        return 'Media';
    }
  }

  @override
  String toString() {
    return 'Favorite{id: $id, placeId: $placeId, priority: $priority, tags: $tags}';
  }
}
