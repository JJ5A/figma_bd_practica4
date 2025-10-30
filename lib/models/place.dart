class Place {
  final int? id;
  final String title;
  final String subtitle;
  final String imageAsset;
  final String price;
  final double rating;
  final PlaceType type; // popular, nearby
  final bool isFavorite;
  final String? description;
  final List<String>? features;

  Place({
    this.id,
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.price,
    required this.rating,
    required this.type,
    this.isFavorite = false,
    this.description,
    this.features,
  });

  // Convertir de Map (base de datos) a objeto Place
  factory Place.fromMap(Map<String, dynamic> map) {
    return Place(
      id: map['id'],
      title: map['title'],
      subtitle: map['subtitle'],
      imageAsset: map['image_asset'],
      price: map['price'],
      rating: map['rating']?.toDouble() ?? 0.0,
      type: PlaceType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => PlaceType.popular,
      ),
      isFavorite: map['is_favorite'] == 1,
      description: map['description'],
      features: map['features']?.split(','),
    );
  }

  // Convertir de objeto Place a Map (para base de datos)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'image_asset': imageAsset,
      'price': price,
      'rating': rating,
      'type': type.name,
      'is_favorite': isFavorite ? 1 : 0,
      'description': description,
      'features': features?.join(','),
    };
  }

  // Crear copia con modificaciones
  Place copyWith({
    int? id,
    String? title,
    String? subtitle,
    String? imageAsset,
    String? price,
    double? rating,
    PlaceType? type,
    bool? isFavorite,
    String? description,
    List<String>? features,
  }) {
    return Place(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageAsset: imageAsset ?? this.imageAsset,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      type: type ?? this.type,
      isFavorite: isFavorite ?? this.isFavorite,
      description: description ?? this.description,
      features: features ?? this.features,
    );
  }

  @override
  String toString() {
    return 'Place{id: $id, title: $title, subtitle: $subtitle, type: $type, rating: $rating}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Place &&
        other.id == id &&
        other.title == title &&
        other.subtitle == subtitle &&
        other.imageAsset == imageAsset &&
        other.price == price &&
        other.rating == rating &&
        other.type == type &&
        other.isFavorite == isFavorite;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        subtitle.hashCode ^
        imageAsset.hashCode ^
        price.hashCode ^
        rating.hashCode ^
        type.hashCode ^
        isFavorite.hashCode;
  }
}

enum PlaceType {
  popular,
  nearby,
}