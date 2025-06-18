import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/pelicula.dart';
import '../data/peliculas_data.dart' as peliculas_data;

class DataService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // MÉTODOS BASE PARA PELÍCULAS

  /// Obtener todas las películas
  List<Pelicula> obtenerPeliculas() {
    return peliculas_data.obtenerPeliculas(); // Usando la función de tu archivo peliculas_data.dart
  }

  /// Obtener películas por categoría
  List<Pelicula> obtenerPeliculasPorCategoria(String categoria) {
    return obtenerPeliculas()
        .where((pelicula) => pelicula.categoria.toLowerCase() == categoria.toLowerCase())
        .toList();
  }

  /// Obtener películas filtradas por edad mínima
  List<Pelicula> obtenerPeliculasPorEdad(int edadUsuario) {
    return obtenerPeliculas()
        .where((pelicula) => pelicula.esApropiadaParaEdad(edadUsuario))
        .toList();
  }

  /// Obtener películas por categoría y edad
  List<Pelicula> obtenerPeliculasPorCategoriaYEdad(String categoria, int edadUsuario) {
    return obtenerPeliculas()
        .where((pelicula) => 
            pelicula.categoria.toLowerCase() == categoria.toLowerCase() &&
            pelicula.esApropiadaParaEdad(edadUsuario))
        .toList();
  }

  /// Obtener películas recomendadas por género favorito y edad
  List<Pelicula> obtenerPeliculasRecomendadas(String generoFavorito, int edadUsuario) {
    // Filtrar por género favorito y edad apropiada
    final peliculasDelGenero = obtenerPeliculas()
        .where((pelicula) => 
            pelicula.categoria.toLowerCase() == generoFavorito.toLowerCase() &&
            pelicula.esApropiadaParaEdad(edadUsuario))
        .toList();
    
    // Si no hay suficientes películas del género favorito, agregar otras apropiadas para la edad
    if (peliculasDelGenero.length < 10) {
      final otrasApropriadas = obtenerPeliculas()
          .where((pelicula) => 
              pelicula.categoria.toLowerCase() != generoFavorito.toLowerCase() &&
              pelicula.esApropiadaParaEdad(edadUsuario))
          .toList();
      
      peliculasDelGenero.addAll(otrasApropriadas);
    }
    
    // Limitar a máximo 20 recomendaciones y eliminar duplicados
    return peliculasDelGenero.toSet().toList().take(20).toList();
  }

  // MÉTODOS PARA GESTIÓN DE USUARIOS Y EDAD

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

  // MÉTODOS PARA GESTIÓN DE PERFIL DE USUARIO

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

  /// Actualizar la edad del usuario
  Future<bool> actualizarEdadUsuario(int nuevaEdad) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser?.displayName != null) {
        await _database
            .child('users')
            .child(currentUser!.displayName!)
            .child('age')
            .set(nuevaEdad);
        return true;
      }
      return false;
    } catch (e) {
      print('Error al actualizar edad del usuario: $e');
      return false;
    }
  }

  // MÉTODOS ADICIONALES ÚTILES

  /// Buscar películas por título
  List<Pelicula> buscarPeliculasPorTitulo(String titulo) {
    return obtenerPeliculas()
        .where((pelicula) => 
            pelicula.titulo.toLowerCase().contains(titulo.toLowerCase()))
        .toList();
  }

  /// Buscar películas por título filtrado por edad del usuario
  Future<List<Pelicula>> buscarPeliculasPorTituloFiltrado(String titulo) async {
    try {
      final edadUsuario = await obtenerEdadUsuarioActual();
      final peliculasEncontradas = buscarPeliculasPorTitulo(titulo);
      
      if (edadUsuario == null) {
        return peliculasEncontradas.where((p) => p.edadMinima <= 0).toList();
      }
      
      return peliculasEncontradas
          .where((pelicula) => pelicula.esApropiadaParaEdad(edadUsuario))
          .toList();
    } catch (e) {
      print('Error al buscar películas por título filtrado: $e');
      return [];
    }
  }

  /// Obtener categorías disponibles para la edad del usuario
  Future<List<String>> obtenerCategoriasDisponibles() async {
    try {
      final peliculasDisponibles = await obtenerPeliculasFiltradasPorEdad();
      return peliculasDisponibles
          .map((pelicula) => pelicula.categoria)
          .toSet()
          .toList();
    } catch (e) {
      print('Error al obtener categorías disponibles: $e');
      return [];
    }
  }
}