import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final List<Map<String, String>> peliculas = [
    {
      "titulo": "Winnie the Pooh: Sangre y Miel",
      "descripcion": ".",
      "imagen": "",
    },
    {
      "titulo": "Titanic",
      "descripcion": "Romance épico en el barco hundido.",
      "imagen": "",
    },
    {
      "titulo": "Jurassic Park",
      "descripcion": "Aventura con dinosaurios clonados.",
      "imagen": "",
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
              Navigator.pushNamed(
                context,
                '/detail', // Ruta nombrada (no requiere cambios en la configuración de rutas)
                arguments: {
                  // Datos específicos de la película
                  'titulo': peliculas[index]['titulo']!,
                  'descripcion': peliculas[index]['descripcion']!,
                  'imagen': peliculas[index]['imagen']!,
                },
              );
            },
          );
        },
      ),
    );
  }
}
