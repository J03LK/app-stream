import 'package:flutter/material.dart';

class MovieDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detalle de la Película")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Placeholder(fallbackHeight: 200),
            SizedBox(height: 16),
            Text("Título de la Película", style: TextStyle(fontSize: 24)),
            SizedBox(height: 10),
            Text("Descripción larga de la película. Aquí se detallan los actores, la sinopsis y más."),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text("Ver Ahora"),
              onPressed: () => Navigator.pushNamed(context, '/player'),
            ),
          ],
        ),
      ),
    );
  }
}
