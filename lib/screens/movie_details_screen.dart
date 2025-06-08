import 'package:flutter/material.dart';

class MovieDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    final String titulo = args['titulo']!;
    final String descripcion = args['descripcion']!;
    final String imagen = args['imagen']!;

    return Scaffold(
      appBar: AppBar(title: Text("Detalle de la Película")),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                imagen.isNotEmpty
                    ? Image.asset(imagen, height: 250, fit: BoxFit.cover)
                    : Placeholder(fallbackHeight: 250),
                SizedBox(height: 20),
                Text(
                  titulo,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text(
                  descripcion,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/player'),
                  child: Text("Ver Ahora"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
