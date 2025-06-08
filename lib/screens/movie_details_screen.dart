import 'package:flutter/material.dart';

class MovieDetailScreen extends StatelessWidget {
  final String titulo;
  final String descripcion;
  final String imagen;

  // Constructor que recibe los datos específicos de la película
  const MovieDetailScreen({
    required this.titulo,
    required this.descripcion,
    required this.imagen,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detalle de la Película")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Muestra la imagen (si está disponible)
            imagen.isNotEmpty
                ? Image.network(imagen, height: 200, fit: BoxFit.cover)
                : Placeholder(fallbackHeight: 200),
            SizedBox(height: 16),
            Text(titulo, style: TextStyle(fontSize: 24)),
            SizedBox(height: 10),
            Text(descripcion),
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
