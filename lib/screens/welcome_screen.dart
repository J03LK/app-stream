import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final redColor = Colors.redAccent;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/fondo.png',
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 20),
                Text(
                  'Bienvenido a SoArlFlix',
                  style: TextStyle(
                    fontSize: 28,
                    color: redColor,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  '"Donde los estrenos cobran vida."',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: redColor),
                  child: Text('Iniciar Sesión'),
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                ),
                TextButton(
                  child: Text(
                    'Registrarse',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
