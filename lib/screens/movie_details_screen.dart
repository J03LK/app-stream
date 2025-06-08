import 'package:flutter/material.dart';

class MovieDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Obtiene los argumentos pasados desde HomeScreen
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    final String titulo = args['titulo']!;
    final String descripcion = args['descripcion']!;
    final String imagen = args['imagen']!;

    return Scaffold(
      appBar: AppBar(title: Text("Detalle de la Película")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
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
