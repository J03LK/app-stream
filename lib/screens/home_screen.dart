import 'package:app_stream/screens/movie_details_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final List<Map<String, String>> peliculas = [
    {
      "titulo": "El Padrino",
      "descripcion": "Drama criminal de la mafia italiana.",
      "imagen": "url_imagen1.jpg",
    },
    {
      "titulo": "Titanic",
      "descripcion": "Romance épico en el barco hundido.",
      "imagen": "url_imagen2.jpg",
    },
    {
      "titulo": "Jurassic Park",
      "descripcion": "Aventura con dinosaurios clonados.",
      "imagen": "url_imagen3.jpg",
    },
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MovieDetailScreen(
                    titulo: peliculas[index]['titulo']!,
                    descripcion: peliculas[index]['descripcion']!,
                    imagen: peliculas[index]['imagen']!,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
