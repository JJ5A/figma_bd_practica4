import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/practica3/splash.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Textos en la parte inferior izquierda
            Positioned(
              bottom: 190,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Find new places to\nstay and homes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Explore interesting places to live\nand choose something for\nyourself.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
            ),

            // Botón centrado + texto de "Create Account"
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Aquí va la navegación, por ejemplo:
                      // Navigator.pushNamed(context, "/mealfigma");
                      Navigator.pushNamed(context, "/home");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF326e6c),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Sign in',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      // Aquí pones lo que quieras que haga "Create Account"
                      // Navigator.pushNamed(context, "/register");
                    },
                    child: const Text(
                      'Create Account',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
