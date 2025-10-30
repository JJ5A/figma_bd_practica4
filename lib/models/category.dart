class Category {
  final int? id;
  final String name;
  final String imageAsset;
  final bool isActive;

  Category({
    this.id,
    required this.name,
    required this.imageAsset,
    this.isActive = true,
  });

  // Convertir de Map (base de datos) a objeto Category
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      imageAsset: map['image_asset'],
      isActive: map['is_active'] == 1,
    );
  }

  // Convertir de objeto Category a Map (para base de datos)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image_asset': imageAsset,
      'is_active': isActive ? 1 : 0,
    };
  }

  // Crear copia con modificaciones
  Category copyWith({
    int? id,
    String? name,
    String? imageAsset,
    bool? isActive,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      imageAsset: imageAsset ?? this.imageAsset,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'Category{id: $id, name: $name, imageAsset: $imageAsset, isActive: $isActive}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category &&
        other.id == id &&
        other.name == name &&
        other.imageAsset == imageAsset &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ imageAsset.hashCode ^ isActive.hashCode;
  }
}