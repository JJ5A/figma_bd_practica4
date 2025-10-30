import 'package:flutter/material.dart';

class Map extends StatefulWidget {
  final String title;
  final String location;
  final String asset;
  final double rating;

  const Map({
    super.key,
    required this.title,
    required this.location,
    required this.asset,
    required this.rating,
  });

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // ===== Header =====
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              size: 18,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'My Location ',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                Icon(
                                  Icons.location_on,
                                  size: 18,
                                  color: Colors.black87,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 40), // Para balance visual
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Desa Cibedug - Kec. Ciawi - Kab. Bogor',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ===== Mapa Alternativo con diseño moderno (extendido hasta abajo) =====
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              bottom: 0, // Extendido hasta abajo
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFE8F5E8),
                          const Color(0xFFF0F8F0),
                          Colors.grey.shade100,
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Fondo del mapa con calles
                        CustomPaint(
                          painter: ModernMapPainter(),
                          size: Size.infinite,
                        ),

                        // Marcador principal del hotel
                        Positioned(
                          top: 180,
                          left: 160,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF22B07D),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF22B07D).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  widget.title,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Marcadores adicionales decorativos
                        const Positioned(
                          top: 120,
                          left: 80,
                          child: Icon(
                            Icons.location_on,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ),
                        const Positioned(
                          top: 280,
                          right: 100,
                          child: Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 18,
                          ),
                        ),
                        const Positioned(
                          top: 240,
                          left: 120,
                          child: Icon(
                            Icons.location_on,
                            color: Colors.orange,
                            size: 16,
                          ),
                        ),

                        // Controles del mapa simulados
                        Positioned(
                          top: 20,
                          right: 20,
                          child: Column(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.black54,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.remove,
                                  color: Colors.black54,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Botón de ubicación actual
                        Positioned(
                          bottom: 140, // Movido hacia arriba para dar espacio a la tarjeta
                          right: 20,
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.my_location,
                              color: Color(0xFF22B07D),
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ===== Card del hotel superpuesta sobre el mapa =====
            Positioned(
              bottom: 25,
              left: 60, // Más padding del lado izquierdo
              right: 60, // Más padding del lado derecho
              child: Container(
                padding: const EdgeInsets.all(12), // Reducido de 20 a 12
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16), // Reducido de 20 a 16
                ),
                child: Row(
                  children: [
                    // Contenedor de la imagen con la cajita de distancia superpuesta
                    Stack(
                      children: [
                        // Imagen del hotel
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12), // Reducido de 16 a 12
                          child: Image.asset(
                            widget.asset,
                            width: 120, // Aumentado de 60 a 75
                            height: 80, // Aumentado de 60 a 75
                            fit: BoxFit.cover,
                          ),
                        ),
                        
                        // Cajita de distancia superpuesta
                        Positioned(
                          bottom: -6, // Reducido de -8 a -6
                          left: 8, // Reducido de 10 a 8
                          right: 8, // Reducido de 10 a 8
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 3, 
                              vertical: 2, 
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10), // Reducido de 12 a 10
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 8, // Reducido de 12 a 10
                                  color: Color(0xFF22B07D),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '1.5 KM',
                                  style: TextStyle(
                                    fontSize: 9, // Reducido de 10 a 9
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(width: 12), // Reducido de 16 a 12

                    // Información del hotel (lado derecho)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nombre del hotel
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 16, // Reducido de 18 a 16
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          
                          const SizedBox(height: 2), // Reducido de 8 a 6
                          
                          // Puntuación
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4, // Reducido de 8 a 6
                                  vertical: 2, // Reducido de 4 a 3
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF22B07D),
                                  borderRadius: BorderRadius.circular(10), // Reducido de 8 a 6
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.white,
                                      size: 12, // Reducido de 14 a 12
                                    ),
                                    const SizedBox(width: 3), // Reducido de 4 a 3
                                    Text(
                                      widget.rating.toString(),
                                      style: const TextStyle(
                                        fontSize: 12, // Reducido de 14 a 12
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 8), // Reducido de 12 a 8
                          
                          // Botón Set Location
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Location set successfully!'),
                                        backgroundColor: Color(0xFF22B07D),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(255, 101, 201, 174).withOpacity(0.5),
                                    foregroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 5, // Botón más pequeño
                                      horizontal: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 14,
                                        color: Colors.green,
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'Set Location',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== Painter personalizado para un mapa moderno =====
class ModernMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Pintura para las calles principales
    final mainRoadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    // Pintura para calles secundarias
    final secondaryRoadPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Pintura para áreas verdes (parques)
    final parkPaint = Paint()
      ..color = const Color(0xFF4CAF50).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Pintura para edificios
    final buildingPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    // Dibujar algunas calles principales
    // Calle horizontal principal
    canvas.drawLine(
      Offset(0, size.height * 0.4),
      Offset(size.width, size.height * 0.4),
      mainRoadPaint,
    );
    
    // Calle vertical principal
    canvas.drawLine(
      Offset(size.width * 0.5, 0),
      Offset(size.width * 0.5, size.height),
      mainRoadPaint,
    );

    // Calles secundarias
    for (int i = 1; i < 8; i++) {
      // Líneas horizontales
      if (i != 3) { // Evitar la calle principal
        canvas.drawLine(
          Offset(0, size.height * i / 8),
          Offset(size.width, size.height * i / 8),
          secondaryRoadPaint,
        );
      }
      // Líneas verticales
      if (i != 4) { // Evitar la calle principal
        canvas.drawLine(
          Offset(size.width * i / 8, 0),
          Offset(size.width * i / 8, size.height),
          secondaryRoadPaint,
        );
      }
    }

    // Dibujar áreas verdes (parques)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.1,
          size.height * 0.1,
          size.width * 0.15,
          size.height * 0.15,
        ),
        const Radius.circular(8),
      ),
      parkPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.7,
          size.height * 0.65,
          size.width * 0.2,
          size.height * 0.2,
        ),
        const Radius.circular(8),
      ),
      parkPaint,
    );

    // Dibujar algunos edificios representativos
    final buildings = [
      Rect.fromLTWH(size.width * 0.3, size.height * 0.15, size.width * 0.08, size.height * 0.1),
      Rect.fromLTWH(size.width * 0.6, size.height * 0.3, size.width * 0.1, size.height * 0.08),
      Rect.fromLTWH(size.width * 0.15, size.height * 0.6, size.width * 0.12, size.height * 0.12),
      Rect.fromLTWH(size.width * 0.75, size.height * 0.15, size.width * 0.1, size.height * 0.15),
    ];

    for (final building in buildings) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(building, const Radius.circular(4)),
        buildingPaint,
      );
    }

    // Dibujar un río o cuerpo de agua
    final waterPaint = Paint()
      ..color = const Color(0xFF2196F3).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final waterPath = Path();
    waterPath.moveTo(0, size.height * 0.8);
    waterPath.quadraticBezierTo(
      size.width * 0.3, size.height * 0.75,
      size.width * 0.6, size.height * 0.85,
    );
    waterPath.quadraticBezierTo(
      size.width * 0.8, size.height * 0.9,
      size.width, size.height * 0.85,
    );
    waterPath.lineTo(size.width, size.height);
    waterPath.lineTo(0, size.height);
    waterPath.close();

    canvas.drawPath(waterPath, waterPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}