import 'package:figmahotels/models/category.dart';
import 'package:figmahotels/models/place.dart';




class FallbackData {
  static final List<Place> _popularPlaces = [
    Place(
      id: 1,
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
      id: 2,
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
      id: 3,
      title: 'Villa Sawah',
      subtitle: 'Cisarua, Bogor',
      imageAsset: 'assets/practica3/sawah.png',
      price: 'Rp 320.000',
      rating: 4.9,
      type: PlaceType.popular,
      description: 'elementum tempus egestas sed sed risus pretium quam vulputate dignissim suspendisse in est ante in nibh mauris cursus',
      features: ['Free Wifi', '4 Beds', 'Food', 'Pool'],
    ),
  ];

  static final List<Place> _nearbyPlaces = [
    Place(
      id: 4,
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
      id: 5,
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

  static List<Category> getCategories() {
    return [
      Category(id: 1, name: 'Casas', imageAsset: 'assets/practica3/house.png'),
      Category(id: 2, name: 'Camp', imageAsset: 'assets/practica3/camping.png'),
      Category(id: 3, name: 'Villa', imageAsset: 'assets/practica3/villa.png'),
      Category(id: 4, name: 'Hotel', imageAsset: 'assets/practica3/hotel.png'),
    ];
  }

  static List<Place> getPopularPlaces() {
    return _popularPlaces;
  }

  static List<Place> getNearbyPlaces() {
    return _nearbyPlaces;
  }

  static int addPlace(Place newPlace) {
    // Generate new ID
    int maxId = 0;
    for (Place place in _popularPlaces) {
      int placeId = place.id ?? 0;
      if (placeId > maxId) maxId = placeId;
    }
    for (Place place in _nearbyPlaces) {
      int placeId = place.id ?? 0;
      if (placeId > maxId) maxId = placeId;
    }
    
    int newId = maxId + 1;
    Place placeWithId = Place(
      id: newId,
      title: newPlace.title,
      subtitle: newPlace.subtitle,
      imageAsset: newPlace.imageAsset,
      price: newPlace.price,
      rating: newPlace.rating,
      type: newPlace.type,
      description: newPlace.description,
      features: newPlace.features,
    );

    if (newPlace.type == PlaceType.popular) {
      _popularPlaces.add(placeWithId);
    } else if (newPlace.type == PlaceType.nearby) {
      _nearbyPlaces.add(placeWithId);
    }
    
    return newId;
  }

  static List<Place> getAllPlaces() {
    return [...getPopularPlaces(), ...getNearbyPlaces()];
  }
}