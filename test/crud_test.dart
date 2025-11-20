import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:figmahotels/database/database_helper.dart';
import 'package:figmahotels/models/category.dart';
import 'package:figmahotels/models/place.dart';
import 'package:figmahotels/models/user.dart';
import 'package:figmahotels/models/reservation.dart';
import 'package:figmahotels/services/category_service.dart';
import 'package:figmahotels/services/place_service.dart';
import 'package:figmahotels/services/user_service.dart';
import 'package:figmahotels/services/reservation_service.dart';

void main() {
  // Initialize FFI for desktop testing
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('Hotel App CRUD Tests', () {
    late DatabaseHelper dbHelper;
    late CategoryService categoryService;
    late PlaceService placeService;
    late UserService userService;
    late ReservationService reservationService;

    setUpAll(() async {
      dbHelper = DatabaseHelper.instance;
      await dbHelper.resetDatabase();
      categoryService = CategoryService();
      placeService = PlaceService();
      userService = UserService();
      reservationService = ReservationService();
    });

    group('Category CRUD Tests', () {
      test('should create and retrieve categories', () async {
        // Create test category
        Category testCategory = Category(
          name: 'Test Category',
          imageAsset: 'assets/test.png',
        );

        int categoryId = await categoryService.createCategory(testCategory);
        expect(categoryId, greaterThan(0));

        // Retrieve category
        Category? retrievedCategory = await categoryService.getCategoryById(categoryId);
        expect(retrievedCategory, isNotNull);
        expect(retrievedCategory!.name, equals('Test Category'));
      });

      test('should update category', () async {
        List<Category> categories = await categoryService.getAllCategories();
        if (categories.isNotEmpty) {
          Category category = categories.first;
          Category updatedCategory = category.copyWith(name: 'Updated Category');
          
          int result = await categoryService.updateCategory(updatedCategory);
          expect(result, greaterThan(0));

          Category? retrieved = await categoryService.getCategoryById(category.id!);
          expect(retrieved!.name, equals('Updated Category'));
        }
      });

      test('should delete category', () async {
        List<Category> categories = await categoryService.getAllCategories();
        if (categories.isNotEmpty) {
          Category category = categories.last;
          int result = await categoryService.deleteCategory(category.id!);
          expect(result, greaterThan(0));
        }
      });
    });

    group('User CRUD Tests', () {
      test('should create and retrieve users', () async {
        // Create test user
        User testUser = User(
          name: 'Test User',
          email: 'test@example.com',
          phone: '+1234567890',
          createdAt: DateTime.now(),
        );

        int userId = await userService.createUser(testUser);
        expect(userId, greaterThan(0));

        // Retrieve user
        User? retrievedUser = await userService.getUserById(userId);
        expect(retrievedUser, isNotNull);
        expect(retrievedUser!.name, equals('Test User'));
        expect(retrievedUser.email, equals('test@example.com'));
      });

      test('should register user with validation', () async {
        User? newUser = await userService.registerUser(
          name: 'New User',
          email: 'newuser@example.com',
          phone: '+9876543210',
        );
        
        expect(newUser, isNotNull);
        expect(newUser!.name, equals('New User'));
      });

      test('should not allow duplicate emails', () async {
        expect(
          () async => await userService.registerUser(
            name: 'Duplicate User',
            email: 'test@example.com', // Already exists
            phone: '+1111111111',
          ),
          throwsException,
        );
      });

      test('should update user profile', () async {
        User? user = await userService.getUserByEmail('test@example.com');
        if (user != null) {
          User? updatedUser = await userService.updateUserProfile(
            userId: user.id!,
            name: 'Updated Test User',
            phone: '+0987654321',
          );
          
          expect(updatedUser, isNotNull);
          expect(updatedUser!.name, equals('Updated Test User'));
          expect(updatedUser.phone, equals('+0987654321'));
        }
      });
    });

    group('Place CRUD Tests', () {
      test('should create and retrieve places', () async {
        // Create test place
        Place testPlace = Place(
          title: 'Test Hotel',
          subtitle: 'Test Location',
          imageAsset: 'assets/test.png',
          price: 'Rp 100.000',
          rating: 4.5,
          type: PlaceType.popular,
          description: 'Test description',
          features: ['Wifi', 'Pool'],
        );

        int placeId = await placeService.createPlace(testPlace);
        expect(placeId, greaterThan(0));

        // Retrieve place
        Place? retrievedPlace = await placeService.getPlaceById(placeId);
        expect(retrievedPlace, isNotNull);
        expect(retrievedPlace!.title, equals('Test Hotel'));
        expect(retrievedPlace.rating, equals(4.5));
      });

      test('should get places by type', () async {
        List<Place> popularPlaces = await placeService.getPlacesByType(PlaceType.popular);
        List<Place> nearbyPlaces = await placeService.getPlacesByType(PlaceType.nearby);
        
        expect(popularPlaces, isNotEmpty);
        for (Place place in popularPlaces) {
          expect(place.type, equals(PlaceType.popular));
        }

        expect(nearbyPlaces, isNotEmpty);
        for (Place place in nearbyPlaces) {
          expect(place.type, equals(PlaceType.nearby));
        }
      });

      test('should toggle favorite status', () async {
        List<Place> places = await placeService.getAllPlaces();
        if (places.isNotEmpty) {
          Place place = places.first;
          bool originalFavorite = place.isFavorite;
          
          await placeService.toggleFavorite(place.id!);
          
          Place? updatedPlace = await placeService.getPlaceById(place.id!);
          expect(updatedPlace!.isFavorite, equals(!originalFavorite));
        }
      });
    });

    group('Reservation CRUD Tests', () {
      late int testUserId;
      late int testPlaceId;

      setUpAll(() async {
        // Create test user and place for reservations
        User testUser = User(
          name: 'Reservation Test User',
          email: 'reservation@example.com',
          phone: '+5555555555',
          createdAt: DateTime.now(),
        );
        testUserId = await userService.createUser(testUser);

        Place testPlace = Place(
          title: 'Reservation Test Hotel',
          subtitle: 'Test Location',
          imageAsset: 'assets/test.png',
          price: 'Rp 200.000',
          rating: 4.8,
          type: PlaceType.popular,
          description: 'Test hotel for reservations',
          features: ['Wifi', 'Breakfast'],
        );
        testPlaceId = await placeService.createPlace(testPlace);
      });

      test('should create and retrieve reservations', () async {
        // Create test reservation
        Reservation testReservation = Reservation(
          placeId: testPlaceId,
          userId: testUserId,
          checkInDate: DateTime.now().add(const Duration(days: 7)),
          checkOutDate: DateTime.now().add(const Duration(days: 10)),
          numberOfGuests: 2,
          totalPrice: 600000.0,
          status: ReservationStatus.pending,
          specialRequests: 'Test request',
          createdAt: DateTime.now(),
        );

        int reservationId = await reservationService.createReservation(testReservation);
        expect(reservationId, greaterThan(0));

        // Retrieve all reservations
        List<Reservation> allReservations = await reservationService.getAllReservations();
        expect(allReservations, isNotEmpty);

        // Find our test reservation
        Reservation? ourReservation = allReservations.firstWhere(
          (r) => r.id == reservationId,
          orElse: () => throw Exception('Reservation not found'),
        );
        expect(ourReservation.placeId, equals(testPlaceId));
        expect(ourReservation.userId, equals(testUserId));
        expect(ourReservation.totalPrice, equals(600000.0));
      });

      test('should get reservations by user', () async {
        List<Reservation> userReservations = await reservationService.getReservationsByUser(testUserId);
        expect(userReservations, isNotEmpty);
        
        for (Reservation reservation in userReservations) {
          expect(reservation.userId, equals(testUserId));
        }
      });

      test('should get reservations by place', () async {
        List<Reservation> placeReservations = await reservationService.getReservationsByPlace(testPlaceId);
        expect(placeReservations, isNotEmpty);
        
        for (Reservation reservation in placeReservations) {
          expect(reservation.placeId, equals(testPlaceId));
        }
      });

      test('should calculate total price correctly', () async {
        DateTime checkIn = DateTime.now().add(const Duration(days: 1));
        DateTime checkOut = DateTime.now().add(const Duration(days: 4)); // 3 nights
        
        double totalPrice = await reservationService.calculateTotalPrice(
          testPlaceId,
          checkIn,
          checkOut,
          3, // 3 guests (1 extra guest)
        );
        
        expect(totalPrice, greaterThan(0));
        // Should include base price + extra guest fee
        expect(totalPrice, greaterThan(600000)); // Base price for 3 nights
      });

      test('should check date availability', () async {
        DateTime futureDate1 = DateTime.now().add(const Duration(days: 30));
        DateTime futureDate2 = DateTime.now().add(const Duration(days: 33));
        
        bool isAvailable = await reservationService.isDateAvailable(
          testPlaceId,
          futureDate1,
          futureDate2,
        );
        
        expect(isAvailable, isTrue);
      });

      test('should confirm reservation', () async {
        List<Reservation> reservations = await reservationService.getAllReservations();
        if (reservations.isNotEmpty) {
          Reservation reservation = reservations.first;
          if (reservation.status == ReservationStatus.pending) {
            int result = await reservationService.confirmReservation(reservation.id!);
            expect(result, greaterThan(0));
            
            // Verify status changed
            List<Reservation> updatedReservations = await reservationService.getAllReservations();
            Reservation? updatedReservation = updatedReservations.firstWhere(
              (r) => r.id == reservation.id,
              orElse: () => throw Exception('Reservation not found'),
            );
            expect(updatedReservation.status, equals(ReservationStatus.confirmed));
          }
        }
      });

      test('should get reservations for calendar view', () async {
        DateTime thisMonth = DateTime.now();
        List<Reservation> monthlyReservations = await reservationService.getReservationsForMonth(thisMonth);
        
        // Should return reservations for current month (even if empty)
        expect(monthlyReservations, isA<List<Reservation>>());
      });
    });

    group('Integration Tests', () {
      test('should handle complete booking flow', () async {
        // 1. Get available places
        List<Place> places = await placeService.getPlacesByType(PlaceType.popular);
        expect(places, isNotEmpty);
        
        Place selectedPlace = places.first;
        
        // 2. Register a new user
        User? newUser = await userService.registerUser(
          name: 'Integration Test User',
          email: 'integration@example.com',
          phone: '+1111111111',
        );
        expect(newUser, isNotNull);
        
        // 3. Check date availability
        DateTime checkIn = DateTime.now().add(const Duration(days: 40));
        DateTime checkOut = DateTime.now().add(const Duration(days: 43));
        
        bool isAvailable = await reservationService.isDateAvailable(
          selectedPlace.id!,
          checkIn,
          checkOut,
        );
        expect(isAvailable, isTrue);
        
        // 4. Calculate price
        double totalPrice = await reservationService.calculateTotalPrice(
          selectedPlace.id!,
          checkIn,
          checkOut,
          2,
        );
        expect(totalPrice, greaterThan(0));
        
        // 5. Create reservation
        Reservation newReservation = Reservation(
          placeId: selectedPlace.id!,
          userId: newUser!.id!,
          checkInDate: checkIn,
          checkOutDate: checkOut,
          numberOfGuests: 2,
          totalPrice: totalPrice,
          status: ReservationStatus.pending,
          createdAt: DateTime.now(),
        );
        
        int reservationId = await reservationService.createReservation(newReservation);
        expect(reservationId, greaterThan(0));
        
        // 6. Confirm reservation
        int confirmResult = await reservationService.confirmReservation(reservationId);
        expect(confirmResult, greaterThan(0));
        
        // 7. Verify final state
        List<Reservation> userReservations = await reservationService.getReservationsByUser(newUser.id!);
        expect(userReservations, isNotEmpty);
        
        Reservation? finalReservation = userReservations.firstWhere(
          (r) => r.id == reservationId,
          orElse: () => throw Exception('Reservation not found'),
        );
        expect(finalReservation.status, equals(ReservationStatus.confirmed));
      });

      test('should handle database relationships correctly', () async {
        // Test foreign key constraints
        List<Reservation> allReservations = await reservationService.getAllReservations();
        
        for (Reservation reservation in allReservations) {
          // Verify user exists
          User? user = await userService.getUserById(reservation.userId);
          expect(user, isNotNull, reason: 'User should exist for reservation ${reservation.id}');
          
          // Verify place exists
          Place? place = await placeService.getPlaceById(reservation.placeId);
          expect(place, isNotNull, reason: 'Place should exist for reservation ${reservation.id}');
        }
      });
    });
  });
}