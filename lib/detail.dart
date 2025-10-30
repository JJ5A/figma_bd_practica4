import 'package:flutter/material.dart';
import 'map.dart';
import 'models/place.dart';
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
  bool isFavorite = false;

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
                                    onTap: () => setState(
                                      () => isFavorite = !isFavorite,
                                    ),
                                    child: Icon(
                                      Icons.favorite,
                                      color: isFavorite
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
                        title: widget.place.title,
                        location: widget.place.subtitle,
                        asset: widget.place.imageAsset,
                        rating: widget.place.rating,
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
