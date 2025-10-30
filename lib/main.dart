import 'package:flutter/material.dart';
import 'Splash_screen.dart';
import 'home_page.dart';
import 'database/database_helper.dart';

void main() async {
  // Asegurar que los widgets estén inicializados
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar la base de datos
  await _initializeDatabase();
  
  runApp(const MyApp());
}

Future<void> _initializeDatabase() async {
  try {
    // Intentar inicializar la base de datos
    final db = await DatabaseHelper.instance.database;
    print('Base de datos inicializada correctamente en: ${db.path}');
  } catch (e) {
    print('Error al inicializar la base de datos: $e');
    // No lanzar el error para que la app pueda funcionar con datos de fallback
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Figma Hotels',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SplashScreen(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
