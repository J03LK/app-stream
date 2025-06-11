// favorites_manager.dart
import '../models/pelicula.dart';

class FavoritesManager {
  static final FavoritesManager _instance = FavoritesManager._internal();
  factory FavoritesManager() => _instance;

  FavoritesManager._internal();

  final List<Pelicula> _favorites = [];

  List<Pelicula> get favorites => List.unmodifiable(_favorites);

  bool isFavorite(Pelicula pelicula) {
    return _favorites.any((p) => p.titulo == pelicula.titulo);
  }

  void addFavorite(Pelicula pelicula) {
    if (!isFavorite(pelicula)) _favorites.add(pelicula);
  }

  void removeFavorite(Pelicula pelicula) {
    _favorites.removeWhere((p) => p.titulo == pelicula.titulo);
  }
}
