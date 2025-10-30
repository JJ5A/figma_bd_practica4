import 'package:flutter/material.dart';
import 'detail.dart';
import 'favorites_page.dart';
import 'calendar_screen.dart';
import 'widgets/user_profile_screen.dart';
import 'models/category.dart';
import 'models/place.dart';
import 'services/category_service.dart';
import 'services/place_service.dart';
import 'widgets/category_section.dart';
import 'widgets/popular_section.dart';
import 'widgets/nearby_section.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  
  // Services
  final CategoryService _categoryService = CategoryService();
  final PlaceService _placeService = PlaceService();
  
  // Data
  List<Category> _categories = [];
  List<Place> _popularPlaces = [];
  List<Place> _nearbyPlaces = [];
  
  // Loading states
  bool _isLoadingCategories = true;
  bool _isLoadingPlaces = true;
  
  // Search
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadCategories(),
      _loadPlaces(),
    ]);
  }

  Future<void> _loadCategories() async {
    try {
      setState(() => _isLoadingCategories = true);
      final categories = await _categoryService.getAllCategories();
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() => _isLoadingCategories = false);
      _showErrorSnackBar('Error al cargar categorías: $e');
    }
  }

  Future<void> _loadPlaces() async {
    try {
      setState(() => _isLoadingPlaces = true);
      final popular = await _placeService.getPopularPlaces();
      final nearby = await _placeService.getNearbyPlaces();
      setState(() {
        _popularPlaces = popular;
        _nearbyPlaces = nearby;
        _isLoadingPlaces = false;
      });
    } catch (e) {
      setState(() => _isLoadingPlaces = false);
      _showErrorSnackBar('Error al cargar lugares: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF22B07D),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _onSearch(String query) async {
    if (query.trim().isEmpty) {
      await _loadPlaces();
      return;
    }

    try {
      final searchResults = await _placeService.searchPlaces(query);
      setState(() {
        _popularPlaces = searchResults.where((p) => p.type == PlaceType.popular).toList();
        _nearbyPlaces = searchResults.where((p) => p.type == PlaceType.nearby).toList();
      });
    } catch (e) {
      _showErrorSnackBar('Error al buscar: $e');
    }
  }

  void _onCategoryTap(Category category) {
    // Aquí podrías filtrar lugares por categoría
    _showSuccessSnackBar('Categoría seleccionada: ${category.name}');
  }

  void _onPlaceTap(Place place) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Detailed(place: place),
      ),
    );
  }

  Future<void> _onFavoriteTap(Place place) async {
    try {
      await _placeService.toggleFavorite(place.id!);
      
      // Actualizar el estado local
      setState(() {
        // Actualizar en la lista popular
        int popularIndex = _popularPlaces.indexWhere((p) => p.id == place.id);
        if (popularIndex != -1) {
          _popularPlaces[popularIndex] = place.copyWith(isFavorite: !place.isFavorite);
        }
        
        // Actualizar en la lista nearby
        int nearbyIndex = _nearbyPlaces.indexWhere((p) => p.id == place.id);
        if (nearbyIndex != -1) {
          _nearbyPlaces[nearbyIndex] = place.copyWith(isFavorite: !place.isFavorite);
        }
      });
      
      String message = place.isFavorite 
          ? 'Removido de favoritos' 
          : 'Agregado a favoritos';
      _showSuccessSnackBar(message);
    } catch (e) {
      _showErrorSnackBar('Error al cambiar favorito: $e');
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  void _showAddPlaceDialog(PlaceType placeType) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();
    final priceController = TextEditingController();
    final ratingController = TextEditingController();
    final descriptionController = TextEditingController();
    final featuresController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar lugar ${placeType.name}'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del lugar',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: subtitleController,
                  decoration: const InputDecoration(
                    labelText: 'Ubicación',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Precio (ej: Rp 300.000)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: ratingController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Rating (1.0 - 5.0)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Campo requerido';
                    final rating = double.tryParse(value!);
                    if (rating == null || rating < 1.0 || rating > 5.0) {
                      return 'Rating debe ser entre 1.0 y 5.0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: featuresController,
                  decoration: const InputDecoration(
                    labelText: 'Características (separadas por comas)',
                    hintText: 'Free Wifi, Pool, Food',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Campo requerido' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await _addNewPlace(
                  titleController.text,
                  subtitleController.text,
                  priceController.text,
                  double.parse(ratingController.text),
                  descriptionController.text,
                  featuresController.text.split(',').map((e) => e.trim()).toList(),
                  placeType,
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF22B07D),
              foregroundColor: Colors.white,
            ),
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  Future<void> _addNewPlace(
    String title,
    String subtitle,
    String price,
    double rating,
    String description,
    List<String> features,
    PlaceType placeType,
  ) async {
    try {
      // Crear el nuevo lugar
      Place newPlace = Place(
        title: title,
        subtitle: subtitle,
        imageAsset: _getDefaultImageForType(placeType),
        price: price,
        rating: rating,
        type: placeType,
        description: description,
        features: features,
      );

      // Agregarlo a la base de datos
      await _placeService.addPlace(newPlace);

      // Recargar los datos para mostrar el nuevo lugar
      await _loadPlaces();

      // Mostrar mensaje de éxito
      _showSuccessSnackBar('¡Lugar agregado exitosamente!');
    } catch (e) {
      _showErrorSnackBar('Error al agregar lugar: $e');
    }
  }

  String _getDefaultImageForType(PlaceType type) {
    switch (type) {
      case PlaceType.popular:
        return 'assets/practica3/hotel.png';
      case PlaceType.nearby:
        return 'assets/practica3/house.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: const Color(0xFF22B07D),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 0, 24),
            children: [
              // Header
              RichText(
                text: TextSpan(
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.black87,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                  ),
                  children: const [
                    TextSpan(
                      text: 'Where do\n',
                      style: TextStyle(color: Colors.black87, fontSize: 36),
                    ),
                    TextSpan(
                      text: 'you want to go ?',
                      style: TextStyle(color: Color(0xFF22B07D), fontSize: 36),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Search bar
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'find a place to stay',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search_rounded),
                      onPressed: () => _onSearch(_searchController.text),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    filled: true,
                    fillColor: const Color(0xFFF1F2F4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: _onSearch,
                ),
              ),
              const SizedBox(height: 20),

              // Categories section
              if (_isLoadingCategories)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      color: Color(0xFF22B07D),
                    ),
                  ),
                )
              else
                CategorySection(
                  categories: _categories,
                  onCategoryTap: _onCategoryTap,
                ),

              // Popular section
              if (_isLoadingPlaces)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      color: Color(0xFF22B07D),
                    ),
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Popular',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _showAddPlaceDialog(PlaceType.popular),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Agregar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF22B07D),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              minimumSize: const Size(0, 32),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    PopularSection(
                      popularPlaces: _popularPlaces,
                      onPlaceTap: _onPlaceTap,
                      onFavoriteTap: _onFavoriteTap,
                    ),
                  ],
                ),

              const SizedBox(height: 20),

              // Nearby section
              if (!_isLoadingPlaces)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Nearby',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _showAddPlaceDialog(PlaceType.nearby),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Agregar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF22B07D),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              minimumSize: const Size(0, 32),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    NearbySection(
                      nearbyPlaces: _nearbyPlaces,
                      onPlaceTap: _onPlaceTap,
                      onFavoriteTap: _onFavoriteTap,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
          
          // Navegación según el índice seleccionado
          switch (i) {
            case 0:
              // Home - ya estamos aquí
              break;
            case 1:
              // Favoritos
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesPage(),
                ),
              ).then((_) {
                // Recargar datos cuando regrese de favoritos
                _loadPlaces();
                setState(() => _currentIndex = 0);
              });
              break;
            case 2:
              // Calendar
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CalendarScreen(),
                ),
              ).then((_) {
                setState(() => _currentIndex = 0);
              });
              break;
            case 3:
              // Profile
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserProfileScreen(),
                ),
              ).then((_) {
                setState(() => _currentIndex = 0);
              });
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF22B07D),
        unselectedItemColor: Colors.grey.shade500,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border_rounded), label: 'Fav'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_rounded), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}
