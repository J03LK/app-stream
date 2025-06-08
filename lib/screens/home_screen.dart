import 'package:app_stream/screens/category_movies.dart';
import 'package:flutter/material.dart';

final Map<String, List<Map<String, String>>> categoriasPeliculas = {
  "Acción": [
    {"titulo": "John Wick", "descripcion": "Venganza implacable", "imagen": ""},
    {
      "titulo": "Mad Max",
      "descripcion": "Carreteras postapocalípticas",
      "imagen": "",
    },
  ],
  "Romance": [
    {"titulo": "Titanic", "descripcion": "Amor en alta mar", "imagen": ""},
    {
      "titulo": "El Diario de Noa",
      "descripcion": "Historia de amor eterno",
      "imagen": "",
    },
  ],
};

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Categorías")),
      body: ListView(
        children: categoriasPeliculas.keys.map((categoria) {
          return ListTile(
            title: Text(categoria),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryScreen(
                  categoria: categoria,
                  peliculas: categoriasPeliculas[categoria]!,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
