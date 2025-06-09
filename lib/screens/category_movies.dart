import 'package:flutter/material.dart';

class CategoryScreen extends StatelessWidget {
  final String categoria;
  final List<Map<String, String>> peliculas;

  const CategoryScreen({required this.categoria, required this.peliculas});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(categoria)),
      body: ListView.builder(
        itemCount: peliculas.length,
        itemBuilder: (context, index) {
          final pelicula = peliculas[index];
          return ListTile(
            title: Text(pelicula["titulo"]!),
            subtitle: Text(pelicula["descripcion"]!),
            onTap: () => Navigator.pushNamed(
              context,
              '/detail',
              arguments: pelicula, 
            ),
          );
        },
      ),
    );
  }
}
