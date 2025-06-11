import 'package:app_stream/screens/favorites_manager.dart';
import 'package:flutter/material.dart';
import '../models/pelicula.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Pelicula> favorites = [];

  @override
  void initState() {
    super.initState();
    favorites = FavoritesManager().favorites;
  }

  void removeFavorite(Pelicula pelicula) {
    setState(() {
      FavoritesManager().removeFavorite(pelicula);
      favorites = FavoritesManager().favorites;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Películas Favoritas'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: favorites.isEmpty
          ? Center(
              child: Text(
                'Aquí se mostrarán tus películas favoritas',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final pelicula = favorites[index];
                return Card(
                  color: Colors.grey[900],
                  margin: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        pelicula.imagen,
                        width: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.movie, color: Colors.grey),
                      ),
                    ),
                    title: Text(
                      pelicula.titulo,
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      pelicula.categoria,
                      style: TextStyle(color: Colors.redAccent),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.favorite, color: Colors.redAccent),
                      onPressed: () => removeFavorite(pelicula),
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/detail',
                        arguments: {
                          'titulo': pelicula.titulo,
                          'descripcion': pelicula.descripcion,
                          'imagen': pelicula.imagen,
                          'trailer': pelicula.trailer,
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
