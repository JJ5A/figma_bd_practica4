import 'package:flutter/material.dart';
import 'map.dart';
import 'models/place.dart';
import 'models/favorite.dart';
import 'services/favorite_service.dart';
import 'widgets/booking_form_screen.dart';

class Detailed extends StatefulWidget {
  final Place place;

  const Detailed({
    super.key,
    required this.place,
  });

  @override
  State<Detailed> createState() => _DetailedState();
}

class _DetailedState extends State<Detailed> {
  final FavoriteService _favoriteService = FavoriteService();
  bool _isFavorite = false;
  bool _isLoading = true;
  Favorite? _currentFavorite;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    try {
      final favorite = await _favoriteService.getFavoriteByPlaceId(widget.place.id!);
      setState(() {
        _isFavorite = favorite != null;
        _currentFavorite = favorite;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      if (_isFavorite && _currentFavorite != null) {
        // Remover de favoritos usando el placeId
        await _favoriteService.removeFromFavorites(widget.place.id!);
        setState(() {
          _isFavorite = false;
          _currentFavorite = null;
        });
        _showSnackBar('Removido de favoritos', Colors.red);
      } else {
        // Agregar a favoritos con diálogo
        await _showAddToFavoritesDialog();
      }
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    }
  }

  Future<void> _showAddToFavoritesDialog() async {
    final notesController = TextEditingController();
    final tagsController = TextEditingController();
    int selectedPriority = 2;
    bool notificationsEnabled = false;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Agregar a Favoritos'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notas (opcional)',
                    hintText: 'Agrega notas personales...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags (opcional)',
                    hintText: 'playa, familiar, económico',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Prioridad:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [1, 2, 3].map((priority) {
                    String label = priority == 1 ? 'Alta' : priority == 2 ? 'Media' : 'Baja';
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(label),
                          selected: selectedPriority == priority,
                          onSelected: (selected) {
                            setDialogState(() {
                              selectedPriority = priority;
                            });
                          },
                          selectedColor: priority == 1 
                              ? Colors.red.shade100 
                              : priority == 2 
                                  ? Colors.orange.shade100 
                                  : Colors.green.shade100,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Notificaciones'),
                  value: notificationsEnabled,
                  onChanged: (value) {
                    setDialogState(() {
                      notificationsEnabled = value;
                    });
                  },
                  activeThumbColor: const Color(0xFF22B07D),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF22B07D),
              ),
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      try {
        final favoriteId = await _favoriteService.addToFavorites(
          placeId: widget.place.id!,
          notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
          tags: tagsController.text.trim().isEmpty ? null : tagsController.text.trim(),
          priority: selectedPriority,
          notificationsEnabled: notificationsEnabled,
        );
        
        final newFavorite = await _favoriteService.getFavoriteById(favoriteId);
        setState(() {
          _isFavorite = true;
          _currentFavorite = newFavorite;
        });
        _showSnackBar('Agregado a favoritos', const Color(0xFF22B07D));
      } catch (e) {
        _showSnackBar('Error al agregar: $e', Colors.red);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // ===== Imagen principal con nombre superpuesto =====
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          widget.place.imageAsset,
                          height: 280,
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.cover,
                        ),
                      ),

                      // Botón de regreso en la esquina superior izquierda
                      Positioned(
                        top: 16,
                        left: 16,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Color(0xFF22B07D),
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ===== Cajas superpuestas al frente =====
                  Transform.translate(
                    offset: const Offset(
                      0,
                      -30,
                    ), 
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          // Cajita 1 y 2 juntas: Nombre, ubicación y corazón
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          widget.place.title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on,
                                              size: 14,
                                              color: Colors.black,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                widget.place.subtitle,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  // Corazón dentro de la misma caja
                                  GestureDetector(
                                    onTap: _isLoading ? null : _toggleFavorite,
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 30,
                                            height: 30,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                Color(0xFF22B07D),
                                              ),
                                            ),
                                          )
                                        : Icon(
                                            Icons.favorite,
                                            color: _isFavorite
                                                ? Colors.red
                                                : Colors.grey,
                                            size: 30,
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Cajita principal blanca que contiene el precio verde y /day
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Caja verde con el precio
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF22B07D),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                    child: Text(
                                    widget.place.price,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Texto /day sin caja
                                const Text(
                                  '/day',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ===== Features =====
                  const Text(
                    'Features',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF22B07D),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      _FeatureItem(icon: Icons.wifi_outlined, label: 'Free Wifi'),
                      const SizedBox(width: 24),
                      _FeatureItem(icon: Icons.bed_outlined, label: '3 Beds'),
                      const SizedBox(width: 24),
                      _FeatureItem(icon: Icons.local_pizza_outlined, label: 'Food'),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ===== About =====
                  const Text(
                    'About',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF22B07D),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    'elementum tempus egestas sed sed risus pretium quam vulputate dignissim suspendisse in est ante in nibh mauris cursus',
                    style: TextStyle(
                      fontSize: 18,
                      height: 1.6,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 80), // Reducido para evitar overflow
                ],
              ),
            ),
          ],
        ),
      ),

      // ===== Barra inferior con precio y botón =====
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // ===== Precio =====
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.place.price,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF22B07D),
                      ),
                    ),
                  ],
                ),
              ),

              // ===== Iconos de herramientas =====
              GestureDetector(
                onTap: () {
                  // Navegar a pantalla de mapa
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Map(
                        place: widget.place,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.pin_drop_outlined,
                    color: Color(0xFF22B07D),
                    size: 20,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.message_rounded,
                  color: Color(0xFF22B07D),
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              // ===== Botón Book Now =====
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    // Use the actual place passed to this screen so bookings use the correct id/data
                    Place place = widget.place;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingFormScreen(place: place),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF326E6C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Book Now',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== Widget para mostrar características (Features) =====
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Color(0xFF22B07D),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, size: 20, color: Colors.black87),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
