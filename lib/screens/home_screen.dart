import 'package:flutter/material.dart';
import '../models/pelicula.dart';
import '../data/peliculas_data.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final String? categoria = ModalRoute.of(context)!.settings.arguments as String?;

    final List<Pelicula> peliculas = obtenerPeliculas();

    final List<Pelicula> peliculasFiltradas = categoria == null
        ? peliculas
        : peliculas.where((p) => p.categoria == categoria).toList();

    return Scaffold(
      appBar: AppBar(title: Text(categoria ?? "Todas las Películas")),
      body: ListView.builder(
        itemCount: peliculasFiltradas.length,
        itemBuilder: (context, index) {
          final pelicula = peliculasFiltradas[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: ListTile(
              leading: Image.asset(
                pelicula.imagen,
                width: 50,
                height: 70,
                fit: BoxFit.cover,
              ),
              title: Text(pelicula.titulo),
              subtitle: Text(pelicula.descripcion),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/detail',
                  arguments: {
                    'titulo': pelicula.titulo,
                    'descripcion': pelicula.descripcion,
                    'imagen': pelicula.imagen,
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
