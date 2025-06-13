// Agregar estos métodos a tu data_service.dart existente

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/pelicula.dart';
import '../data/peliculas_data.dart';

class DataService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ... tus métodos existentes ...

  // NUEVOS MÉTODOS PARA FILTRADO POR EDAD:

  /// Obtener la edad del usuario actual
  Future<int?> obtenerEdadUsuarioActual() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser?.displayName != null) {
        final snapshot = await _database
            .child('users')
            .child(currentUser!.displayName!)
            .child('age')
            .get();
        
        if (snapshot.exists) {
          return snapshot.value as int;
        }
      }
      return null;
    } catch (e) {
      print('Error al obtener edad del usuario: $e');
      return null;
    }
  }

  /// Obtener películas filtradas por la edad del usuario actual
  Future<List<Pelicula>> obtenerPeliculasFiltradasPorEdad() async {
    try {
      final edadUsuario = await obtenerEdadUsuarioActual();
      if (edadUsuario == null) {
        // Si no se puede obtener la edad, mostrar solo contenido apto para todo público
        return obtenerPeliculas().where((p) => p.edadMinima <= 0).toList();
      }
      
      return obtenerPeliculasPorEdad(edadUsuario);
    } catch (e) {
      print('Error al filtrar películas por edad: $e');
      return obtenerPeliculas().where((p) => p.edadMinima <= 0).toList();
    }
  }

  /// Obtener películas de una categoría específica filtradas por edad
  Future<List<Pelicula>> obtenerPeliculasPorCategoriaFiltradas(String categoria) async {
    try {
      final edadUsuario = await obtenerEdadUsuarioActual();
      if (edadUsuario == null) {
        return obtenerPeliculas()
            .where((p) => p.categoria.toLowerCase() == categoria.toLowerCase() && p.edadMinima <= 0)
            .toList();
      }
      
      return obtenerPeliculasPorCategoriaYEdad(categoria, edadUsuario);
    } catch (e) {
      print('Error al filtrar películas por categoría y edad: $e');
      return [];
    }
  }

  /// Obtener películas recomendadas basadas en el género favorito y edad
  Future<List<Pelicula>> obtenerPeliculasRecomendadasPersonalizadas() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser?.displayName == null) {
        return await obtenerPeliculasFiltradasPorEdad();
      }

      // Obtener género favorito del usuario
      final generoSnapshot = await _database
          .child('users')
          .child(currentUser!.displayName!)
          .child('favoriteGenre')
          .get();

      final edadUsuario = await obtenerEdadUsuarioActual();
      
      if (generoSnapshot.exists && edadUsuario != null) {
        final generoFavorito = generoSnapshot.value as String;
        return obtenerPeliculasRecomendadas(generoFavorito, edadUsuario);
      }
      
      return await obtenerPeliculasFiltradasPorEdad();
    } catch (e) {
      print('Error al obtener recomendaciones personalizadas: $e');
      return await obtenerPeliculasFiltradasPorEdad();
    }
  }

  /// Verificar si el usuario puede ver una película específica
  Future<bool> puedeVerPelicula(Pelicula pelicula) async {
    try {
      final edadUsuario = await obtenerEdadUsuarioActual();
      if (edadUsuario == null) return pelicula.edadMinima <= 0;
      
      return pelicula.esApropiadaParaEdad(edadUsuario);
    } catch (e) {
      print('Error al verificar si puede ver la película: $e');
      return false;
    }
  }

  /// Obtener información del usuario actual (edad, género favorito, etc.)
  Future<Map<String, dynamic>?> obtenerPerfilUsuarioActual() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser?.displayName != null) {
        final snapshot = await _database
            .child('users')
            .child(currentUser!.displayName!)
            .get();
        
        if (snapshot.exists) {
          return Map<String, dynamic>.from(snapshot.value as Map);
        }
      }
      return null;
    } catch (e) {
      print('Error al obtener perfil del usuario: $e');
      return null;
    }
  }

  /// Actualizar el género favorito del usuario
  Future<bool> actualizarGeneroFavorito(String nuevoGenero) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser?.displayName != null) {
        await _database
            .child('users')
            .child(currentUser!.displayName!)
            .child('favoriteGenre')
            .set(nuevoGenero);
        return true;
      }
      return false;
    } catch (e) {
      print('Error al actualizar género favorito: $e');
      return false;
    }
  }
}