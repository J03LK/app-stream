import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final List<Map<String, String>> peliculas = [
    {"titulo": "Película 1", "descripcion": "Acción y aventura", "imagen": ""},
    {"titulo": "Película 2", "descripcion": "Romance", "imagen": ""},
    {"titulo": "Película 3", "descripcion": "Terror", "imagen": ""},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Catálogo de Películas")),
      body: ListView.builder(
        itemCount: peliculas.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(peliculas[index]['titulo']!),
            subtitle: Text(peliculas[index]['descripcion']!),
            onTap: () => Navigator.pushNamed(context, '/detail'),
          );
        },
      ),
    );
  }
}
