class Reservation {
  final int? id;
  final int placeId; // Foreign key to Place
  final int userId; // Foreign key to User
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int numberOfGuests;
  final double totalPrice;
  final ReservationStatus status;
  final String? specialRequests;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Reservation({
    this.id,
    required this.placeId,
    required this.userId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numberOfGuests,
    required this.totalPrice,
    this.status = ReservationStatus.pending,
    this.specialRequests,
    required this.createdAt,
    this.updatedAt,
  });

  // Convertir de Map (base de datos) a objeto Reservation
  factory Reservation.fromMap(Map<String, dynamic> map) {
    return Reservation(
      id: map['id'],
      placeId: map['place_id'],
      userId: map['user_id'],
      checkInDate: DateTime.parse(map['check_in_date']),
      checkOutDate: DateTime.parse(map['check_out_date']),
      numberOfGuests: map['number_of_guests'],
      totalPrice: map['total_price']?.toDouble() ?? 0.0,
      status: ReservationStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ReservationStatus.pending,
      ),
      specialRequests: map['special_requests'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  // Convertir de objeto Reservation a Map (para base de datos)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'place_id': placeId,
      'user_id': userId,
      'check_in_date': checkInDate.toIso8601String(),
      'check_out_date': checkOutDate.toIso8601String(),
      'number_of_guests': numberOfGuests,
      'total_price': totalPrice,
      'status': status.name,
      'special_requests': specialRequests,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Crear copia con modificaciones
  Reservation copyWith({
    int? id,
    int? placeId,
    int? userId,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? numberOfGuests,
    double? totalPrice,
    ReservationStatus? status,
    String? specialRequests,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reservation(
      id: id ?? this.id,
      placeId: placeId ?? this.placeId,
      userId: userId ?? this.userId,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      numberOfGuests: numberOfGuests ?? this.numberOfGuests,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      specialRequests: specialRequests ?? this.specialRequests,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Calcular duración de la estadía
  int get durationInDays {
    return checkOutDate.difference(checkInDate).inDays;
  }

  // Validar si la reservación está activa
  bool get isActive {
    final now = DateTime.now();
    return checkInDate.isBefore(now) && checkOutDate.isAfter(now);
  }

  // Validar si la reservación es futura
  bool get isFuture {
    return checkInDate.isAfter(DateTime.now());
  }

  // Validar si la reservación es pasada
  bool get isPast {
    return checkOutDate.isBefore(DateTime.now());
  }

  @override
  String toString() {
    return 'Reservation{id: $id, placeId: $placeId, userId: $userId, checkIn: $checkInDate, checkOut: $checkOutDate, status: $status}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reservation &&
        other.id == id &&
        other.placeId == placeId &&
        other.userId == userId &&
        other.checkInDate == checkInDate &&
        other.checkOutDate == checkOutDate &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        placeId.hashCode ^
        userId.hashCode ^
        checkInDate.hashCode ^
        checkOutDate.hashCode ^
        status.hashCode;
  }
}

enum ReservationStatus {
  pending,
  confirmed,
  cancelled,
  completed,
  checkedIn,
  checkedOut,
}

// Extensión para obtener colores y texto por status
extension ReservationStatusExtension on ReservationStatus {
  String get displayName {
    switch (this) {
      case ReservationStatus.pending:
        return 'Pendiente';
      case ReservationStatus.confirmed:
        return 'Confirmada';
      case ReservationStatus.cancelled:
        return 'Cancelada';
      case ReservationStatus.completed:
        return 'Completada';
      case ReservationStatus.checkedIn:
        return 'Check-in';
      case ReservationStatus.checkedOut:
        return 'Check-out';
    }
  }

  String get color {
    switch (this) {
      case ReservationStatus.pending:
        return '#FFA500'; // Orange
      case ReservationStatus.confirmed:
        return '#22B07D'; // Green
      case ReservationStatus.cancelled:
        return '#FF4444'; // Red
      case ReservationStatus.completed:
        return '#2196F3'; // Blue
      case ReservationStatus.checkedIn:
        return '#9C27B0'; // Purple
      case ReservationStatus.checkedOut:
        return '#607D8B'; // Gray
    }
  }
}