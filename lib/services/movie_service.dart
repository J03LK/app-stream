import '../models/pelicula.dart';
import '../services/data_service.dart';
import 'package:firebase_database/firebase_database.dart'; // ✅ AGREGAR ESTE IMPORT

class MovieService {
  final DataService _databaseService = DataService();

  // Método para obtener edad del usuario
  Future<int?> getUserAge(String username) async {
    try {
      final snapshot = await FirebaseDatabase.instance
          .ref('users')
          .child(username)
          .child('age')
          .get();
      
      if (snapshot.exists) {
        return snapshot.value as int?;
      }
      return null;
    } catch (e) {
      print('Error al obtener edad del usuario: $e');
      return null;
    }
  }

  // ✅ AGREGAR ESTE MÉTODO QUE FALTABA
  Future<List<Pelicula>> getFilteredMovies(String username, List<Pelicula> allMovies) async {
    try {
      final userAge = await getUserAge(username);
      if (userAge == null) return allMovies;

      return allMovies.where((movie) {
        return movie.edadMinima <= userAge; // Usar edadMinima
      }).toList();
    } catch (e) {
      print('Error al filtrar películas: $e');
      return allMovies; // Retorna todas si hay error
    }
  }
}