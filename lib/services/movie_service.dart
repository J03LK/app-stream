
import '../models/pelicula.dart';
import 'database_service.dart';

class MovieService {
  final DatabaseService _databaseService = DatabaseService();

  // Filtrar películas según la edad del usuario
  Future<List<Pelicula>> getFilteredMovies(String username, List<Pelicula> allMovies) async {
    try {
      final userAge = await _databaseService.getUserAge(username);
      if (userAge == null) return allMovies;

      return allMovies.where((movie) {
        // Asumiendo que tienes una propiedad ageRestriction en tu modelo Pelicula
        return movie.ageRestriction <= userAge;
      }).toList();
    } catch (e) {
      print('Error al filtrar películas: $e');
      return allMovies; // Retorna todas si hay error
    }
  }
}