import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/category.dart';
import '../models/place.dart';
import '../models/reservation.dart';
import '../models/user.dart';

class DatabaseHelper {
  static const _databaseName = 'figma_hotels.db';
  static const _databaseVersion = 1;

  // Nombres de las tablas
  static const String categoriesTable = 'categories';
  static const String placesTable = 'places';
  static const String usersTable = 'users';
  static const String reservationsTable = 'reservations';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper _instance = DatabaseHelper._privateConstructor();
  static DatabaseHelper get instance => _instance;

  static Database? _database;

  // Method to reset database
  Future<void> resetDatabase() async {
    try {
      if (_database != null) {
        await _database!.close();
        _database = null;
      }
      
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, _databaseName);
      
      // Delete existing database
      await databaseFactory.deleteDatabase(path);
      print('Database deleted and will be recreated');
      
      // Force recreation on next access
      _database = null;
    } catch (e) {
      print('Error resetting database: $e');
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    
    try {
      _database = await _initDatabase();
      return _database!;
    } catch (e) {
      print('Error al acceder a la base de datos: $e');
      
      // Si hay error, intentar una vez más
      try {
        await Future.delayed(const Duration(milliseconds: 500));
        _database = await _initDatabase();
        return _database!;
      } catch (e2) {
        print('Error en segundo intento: $e2');
        rethrow;
      }
    }
  }

  Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), _databaseName);
      print('Ruta de la base de datos: $path');
      
      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onOpen: (db) async {
          // Habilitar foreign keys
          await db.execute('PRAGMA foreign_keys = ON');
          print('Base de datos abierta correctamente');
        },
      );
    } catch (e) {
      print('Error al inicializar la base de datos: $e');
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      print('Creando tablas de la base de datos...');
      
      // Habilitar foreign keys
      await db.execute('PRAGMA foreign_keys = ON');
      
      // Crear tabla de usuarios primero (sin dependencias)
      await db.execute('''
        CREATE TABLE $usersTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          phone TEXT,
          profile_image_url TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT,
          is_active INTEGER NOT NULL DEFAULT 1
        )
      ''');
      print('Tabla de usuarios creada');
      
      // Crear tabla de categorías
      await db.execute('''
        CREATE TABLE $categoriesTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          image_asset TEXT NOT NULL,
          is_active INTEGER NOT NULL DEFAULT 1
        )
      ''');
      print('Tabla de categorías creada');

      // Crear tabla de lugares (con FK a categorías)
      await db.execute('''
        CREATE TABLE $placesTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          subtitle TEXT NOT NULL,
          image_asset TEXT NOT NULL,
          price TEXT NOT NULL,
          rating REAL NOT NULL,
          type TEXT NOT NULL,
          is_favorite INTEGER NOT NULL DEFAULT 0,
          description TEXT,
          features TEXT,
          category_id INTEGER,
          FOREIGN KEY (category_id) REFERENCES $categoriesTable(id) ON DELETE SET NULL ON UPDATE CASCADE
        )
      ''');
      print('Tabla de lugares creada');

      // Crear tabla de reservaciones (con FK a lugares y usuarios)
      await db.execute('''
        CREATE TABLE $reservationsTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          place_id INTEGER NOT NULL,
          user_id INTEGER NOT NULL,
          check_in_date TEXT NOT NULL,
          check_out_date TEXT NOT NULL,
          number_of_guests INTEGER NOT NULL,
          total_price REAL NOT NULL,
          status TEXT NOT NULL DEFAULT 'pending',
          special_requests TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT,
          FOREIGN KEY (place_id) REFERENCES $placesTable(id) ON DELETE CASCADE ON UPDATE CASCADE,
          FOREIGN KEY (user_id) REFERENCES $usersTable(id) ON DELETE CASCADE ON UPDATE CASCADE
        )
      ''');
      print('Tabla de reservaciones creada');

      // Insertar datos iniciales
      await _insertInitialData(db);
      print('Datos iniciales insertados');
    } catch (e) {
      print('Error al crear las tablas: $e');
      rethrow;
    }
  }

  Future<void> _insertInitialData(Database db) async {
    try {
      print('Insertando datos iniciales...');
      
      // Insertar usuarios iniciales
      List<User> initialUsers = [
        User(
          name: 'Juan Pérez',
          email: 'juan@example.com',
          phone: '+52 555 1234567',
          createdAt: DateTime.now(),
        ),
        User(
          name: 'María García',
          email: 'maria@example.com',
          phone: '+52 555 7654321',
          createdAt: DateTime.now(),
        ),
        User(
          name: 'Carlos López',
          email: 'carlos@example.com',
          phone: '+52 555 9876543',
          createdAt: DateTime.now(),
        ),
      ];

      for (User user in initialUsers) {
        await db.insert(usersTable, user.toMap());
      }
      print('Usuarios iniciales insertados: ${initialUsers.length}');
      
      // Categorías iniciales
      List<Category> initialCategories = [
        Category(name: 'Casas', imageAsset: 'assets/practica3/house.png'),
        Category(name: 'Camp', imageAsset: 'assets/practica3/camping.png'),
        Category(name: 'Villa', imageAsset: 'assets/practica3/villa.png'),
        Category(name: 'Hotel', imageAsset: 'assets/practica3/hotel.png'),
      ];

      for (Category category in initialCategories) {
        await db.insert(categoriesTable, category.toMap());
      }
      print('Categorías iniciales insertadas: ${initialCategories.length}');

      // Lugares iniciales
      List<Place> initialPlaces = [
        // Lugares populares
        Place(
          title: 'Daebak Hotel',
          subtitle: 'Cisarua, Bogor',
          imageAsset: 'assets/practica3/daebakhotel.png',
          price: 'Rp 300.000',
          rating: 4.9,
          type: PlaceType.popular,
          description: 'elementum tempus egestas sed sed risus pretium quam vulputate dignissim suspendisse in est ante in nibh mauris cursus',
          features: ['Free Wifi', '3 Beds', 'Food'],
        ),
        Place(
          title: 'Bumi Katulampa',
          subtitle: 'Cisarua, Bogor',
          imageAsset: 'assets/practica3/katulumpa.png',
          price: 'Rp 280.000',
          rating: 4.8,
          type: PlaceType.popular,
          description: 'elementum tempus egestas sed sed risus pretium quam vulputate dignissim suspendisse in est ante in nibh mauris cursus',
          features: ['Free Wifi', '2 Beds', 'Food'],
        ),
        Place(
          title: 'Villa Sawah',
          subtitle: 'Cisarua, Bogor',
          imageAsset: 'assets/practica3/sawah.png',
          price: 'Rp 320.000',
          rating: 4.9,
          type: PlaceType.popular,
          description: 'elementum tempus egestas sed sed risus pretium quam vulputate dignissim suspendisse in est ante in nibh mauris cursus',
          features: ['Free Wifi', '4 Beds', 'Food', 'Pool'],
        ),
        // Lugares cercanos
        Place(
          title: 'Camp Ratu Gede',
          subtitle: 'Cisarua, Bogor',
          imageAsset: 'assets/practica3/camp.png',
          price: 'Rp 150.000',
          rating: 4.9,
          type: PlaceType.nearby,
          description: 'elementum tempus egestas sed sed risus pretium quam vulputate dignissim suspendisse in est ante in nibh mauris cursus',
          features: ['Free Wifi', 'Camping', 'BBQ'],
        ),
        Place(
          title: 'Camp hulu cai',
          subtitle: 'Cisarua, Bogor',
          imageAsset: 'assets/practica3/hulu.png',
          price: 'Rp 150.000',
          rating: 4.9,
          type: PlaceType.nearby,
          description: 'elementum tempus egestas sed sed risus pretium quam vulputate dignissim suspendisse in est ante in nibh mauris cursus',
          features: ['Free Wifi', 'Camping', 'River Access'],
        ),
      ];

      for (Place place in initialPlaces) {
        await db.insert(placesTable, place.toMap());
      }
      print('Lugares iniciales insertados: ${initialPlaces.length}');

      // Reservaciones iniciales
      List<Reservation> initialReservations = [
        Reservation(
          placeId: 1,
          userId: 1,
          checkInDate: DateTime.now().add(const Duration(days: 7)),
          checkOutDate: DateTime.now().add(const Duration(days: 10)),
          numberOfGuests: 2,
          totalPrice: 900000.0,
          status: ReservationStatus.confirmed,
          specialRequests: 'Vista al jardín',
          createdAt: DateTime.now(),
        ),
        Reservation(
          placeId: 2,
          userId: 2,
          checkInDate: DateTime.now().add(const Duration(days: 14)),
          checkOutDate: DateTime.now().add(const Duration(days: 16)),
          numberOfGuests: 4,
          totalPrice: 560000.0,
          status: ReservationStatus.pending,
          specialRequests: 'Cuna para bebé',
          createdAt: DateTime.now(),
        ),
        Reservation(
          placeId: 4,
          userId: 3,
          checkInDate: DateTime.now().add(const Duration(days: 21)),
          checkOutDate: DateTime.now().add(const Duration(days: 23)),
          numberOfGuests: 6,
          totalPrice: 300000.0,
          status: ReservationStatus.confirmed,
          specialRequests: 'Área de BBQ disponible',
          createdAt: DateTime.now(),
        ),
      ];

      for (Reservation reservation in initialReservations) {
        await db.insert(reservationsTable, reservation.toMap());
      }
      print('Reservaciones iniciales insertadas: ${initialReservations.length}');
    } catch (e) {
      print('Error al insertar datos iniciales: $e');
      rethrow;
    }
  }

  // ============= CRUD CATEGORÍAS =============

  Future<int> insertCategory(Category category) async {
    Database db = await instance.database;
    return await db.insert(categoriesTable, category.toMap());
  }

  Future<List<Category>> getAllCategories() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      categoriesTable,
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<Category?> getCategoryById(int id) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      categoriesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Category.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateCategory(Category category) async {
    Database db = await instance.database;
    return await db.update(
      categoriesTable,
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    Database db = await instance.database;
    return await db.update(
      categoriesTable,
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============= CRUD LUGARES =============

  Future<int> insertPlace(Place place) async {
    Database db = await instance.database;
    return await db.insert(placesTable, place.toMap());
  }

  Future<List<Place>> getAllPlaces() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      placesTable,
      orderBy: 'rating DESC',
    );
    return List.generate(maps.length, (i) => Place.fromMap(maps[i]));
  }

  Future<List<Place>> getPlacesByType(PlaceType type) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      placesTable,
      where: 'type = ?',
      whereArgs: [type.name],
      orderBy: 'rating DESC',
    );
    return List.generate(maps.length, (i) => Place.fromMap(maps[i]));
  }

  Future<List<Place>> getFavoritePlaces() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      placesTable,
      where: 'is_favorite = ?',
      whereArgs: [1],
      orderBy: 'rating DESC',
    );
    return List.generate(maps.length, (i) => Place.fromMap(maps[i]));
  }

  Future<Place?> getPlaceById(int id) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      placesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Place.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updatePlace(Place place) async {
    Database db = await instance.database;
    return await db.update(
      placesTable,
      place.toMap(),
      where: 'id = ?',
      whereArgs: [place.id],
    );
  }

  Future<int> toggleFavorite(int placeId) async {
    Place? place = await getPlaceById(placeId);
    if (place != null) {
      Place updatedPlace = place.copyWith(isFavorite: !place.isFavorite);
      return await updatePlace(updatedPlace);
    }
    return 0;
  }

  // CRUD Operations for Reservations
  Future<int> createReservation(Reservation reservation) async {
    final db = await instance.database;
    return await db.insert(reservationsTable, reservation.toMap());
  }

  Future<List<Reservation>> getAllReservations() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(reservationsTable);
    return List.generate(maps.length, (i) => Reservation.fromMap(maps[i]));
  }

  Future<List<Reservation>> getReservationsByUser(int userId) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      reservationsTable,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'check_in_date ASC',
    );
    return List.generate(maps.length, (i) => Reservation.fromMap(maps[i]));
  }

  Future<List<Reservation>> getReservationsByPlace(int placeId) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      reservationsTable,
      where: 'place_id = ?',
      whereArgs: [placeId],
      orderBy: 'check_in_date ASC',
    );
    return List.generate(maps.length, (i) => Reservation.fromMap(maps[i]));
  }

  Future<List<Reservation>> getReservationsByDateRange(DateTime start, DateTime end) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      reservationsTable,
      where: 'check_in_date >= ? AND check_out_date <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'check_in_date ASC',
    );
    return List.generate(maps.length, (i) => Reservation.fromMap(maps[i]));
  }

  Future<int> updateReservation(Reservation reservation) async {
    final db = await instance.database;
    return await db.update(
      reservationsTable,
      reservation.toMap(),
      where: 'id = ?',
      whereArgs: [reservation.id],
    );
  }

  Future<int> deleteReservation(int id) async {
    final db = await instance.database;
    return await db.delete(
      reservationsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD Operations for Users
  Future<int> createUser(User user) async {
    final db = await instance.database;
    return await db.insert(usersTable, user.toMap());
  }

  Future<List<User>> getAllUsers() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(usersTable);
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  Future<User?> getUserById(int id) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      usersTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      usersTable,
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    final db = await instance.database;
    return await db.update(
      usersTable,
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await instance.database;
    return await db.delete(
      usersTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deletePlace(int id) async {
    Database db = await instance.database;
    return await db.delete(
      placesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Place>> searchPlaces(String query) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      placesTable,
      where: 'title LIKE ? OR subtitle LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'rating DESC',
    );
    return List.generate(maps.length, (i) => Place.fromMap(maps[i]));
  }

  // ============= UTILIDADES =============

  Future<void> close() async {
    Database db = await instance.database;
    await db.close();
  }

  Future<void> deleteDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    await databaseFactory.deleteDatabase(path);
  }
}