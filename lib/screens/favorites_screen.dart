import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/pelicula.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with TickerProviderStateMixin {
  List<Pelicula> _favorites = [];
  List<Pelicula> _filteredFavorites = [];
  int? _userAge;
  String? _username;
  bool _isLoading = true;

  late DatabaseReference _favoritesRef;
  late User? _currentUser;

  // Animaciones
  late AnimationController _glowController;
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;

  // Colores neón
  final Color neonPink = const Color(0xFFFF0080);
  final Color neonBlue = const Color(0xFF00FFFF);
  final Color neonGreen = const Color(0xFF00FF41);
  final Color neonPurple = const Color(0xFF8A2BE2);
  final Color neonYellow = const Color(0xFFFFFF00);

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _favoritesRef = FirebaseDatabase.instance.ref('usuarios_favoritos');
    _currentUser = FirebaseAuth.instance.currentUser;
    _loadUserDataAndFavorites();
  }

  void _initAnimations() {
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _glowController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
  }

  Future<void> _loadUserDataAndFavorites() async {
    try {
      // Cargar datos del usuario
      if (_currentUser?.displayName != null) {
        final userSnapshot = await FirebaseDatabase.instance
            .ref('users')
            .child(_currentUser!.displayName!)
            .get();
        
        if (userSnapshot.exists) {
          final userData = Map<String, dynamic>.from(userSnapshot.value as Map);
          setState(() {
            _userAge = userData['age'];
            _username = userData['username'];
          });
        }
      }

      // Cargar favoritos
      await _loadFavorites();
    } catch (e) {
      print('Error al cargar datos: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFavorites() async {
    if (_currentUser == null) return;

    try {
      final snapshot = await _favoritesRef.child(_currentUser!.uid).get();
      
      if (snapshot.exists) {
        final favoritesData = Map<String, dynamic>.from(snapshot.value as Map);
        
        _favorites = favoritesData.entries.map((entry) {
          final movieData = Map<String, dynamic>.from(entry.value);
          return Pelicula(
            titulo: movieData['titulo'] ?? '',
            descripcion: movieData['descripcion'] ?? '',
            imagen: movieData['imagen'] ?? '',
            trailer: movieData['trailer'] ?? '',
            categoria: movieData['categoria'] ?? '',
            edadMinima: movieData['edadMinima'] ?? 0,
          );
        }).toList();

        // Filtrar por edad
        _filteredFavorites = _userAge != null
            ? _favorites.where((movie) => movie.esApropiadaParaEdad(_userAge!)).toList()
            : _favorites.where((movie) => movie.edadMinima <= 0).toList();
      } else {
        _favorites = [];
        _filteredFavorites = [];
      }

      setState(() {});
    } catch (e) {
      print('Error al cargar favoritos: $e');
    }
  }

  String _sanitizeKey(String key) {
    return key
        .replaceAll('.', '_')
        .replaceAll('#', '_')
        .replaceAll('\$', '_')
        .replaceAll('[', '_')
        .replaceAll(']', '_')
        .replaceAll('/', '_');
  }

  Future<void> _removeFavorite(Pelicula pelicula) async {
    if (_currentUser == null) return;

    try {
      final movieKey = _sanitizeKey(pelicula.titulo);
      await _favoritesRef.child(_currentUser!.uid).child(movieKey).remove();
      
      // Actualizar listas locales
      setState(() {
        _favorites.removeWhere((p) => p.titulo == pelicula.titulo);
        _filteredFavorites.removeWhere((p) => p.titulo == pelicula.titulo);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.heart_broken, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('"${pelicula.titulo}" removida de favoritos')),
            ],
          ),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al remover: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildGlowingContainer({
    required Widget child,
    required Color glowColor,
    double glowRadius = 20,
  }) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: glowColor.withOpacity(0.3 * _glowAnimation.value),
                blurRadius: glowRadius * _glowAnimation.value,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.grey[900]!.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: neonPink.withOpacity(0.5), width: 2),
      ),
      child: _buildGlowingContainer(
        glowColor: neonPink,
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [neonPink, neonPurple],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite, color: Colors.white, size: 32),
                  ),
                );
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _username != null ? 'Favoritos de $_username' : 'Mis Favoritos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: neonPink, blurRadius: 15)],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: neonGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: neonGreen, width: 1),
                        ),
                        child: Text(
                          '${_filteredFavorites.length} disponibles',
                          style: TextStyle(
                            color: neonGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_favorites.length > _filteredFavorites.length)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange, width: 1),
                          ),
                          child: Text(
                            '${_favorites.length - _filteredFavorites.length} restringidas',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      if (_userAge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: neonBlue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: neonBlue, width: 1),
                          ),
                          child: Text(
                            'Edad: $_userAge',
                            style: TextStyle(
                              color: neonBlue,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildGlowingContainer(
            glowColor: neonPurple,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: neonPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: neonPurple.withOpacity(0.5)),
              ),
              child: Icon(
                Icons.favorite_border,
                size: 80,
                color: neonPurple,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _favorites.isEmpty 
                ? 'Aún no tienes favoritos'
                : 'No hay favoritos disponibles\npara tu edad',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
              shadows: [Shadow(color: neonPurple, blurRadius: 5)],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _favorites.isEmpty
                ? 'Explora películas y marca las que más te gusten ❤️'
                : 'Tienes ${_favorites.length - _filteredFavorites.length} películas restringidas por edad',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          _buildGlowingContainer(
            glowColor: neonBlue,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/categories');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                  side: BorderSide(color: neonBlue, width: 2),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [neonBlue.withOpacity(0.3), neonPurple.withOpacity(0.3)],
                  ),
                  borderRadius: BorderRadius.circular(23),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.explore, size: 20),
                    SizedBox(width: 8),
                    Text('Explorar Películas'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(Pelicula pelicula) {
    final bool canWatch = _userAge != null && pelicula.esApropiadaParaEdad(_userAge!);
    
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/detail',
          arguments: {
            'titulo': pelicula.titulo,
            'descripcion': pelicula.descripcion,
            'imagen': pelicula.imagen,
            'trailer': pelicula.trailer,
            'categoria': pelicula.categoria,
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.grey[900]!.withOpacity(0.9),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: canWatch ? neonPink.withOpacity(0.5) : Colors.red.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: _buildGlowingContainer(
          glowColor: canWatch ? neonPink : Colors.red,
          glowRadius: 15,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: neonPink.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          pelicula.imagen,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[800],
                              child: const Icon(Icons.movie, color: Colors.white, size: 30),
                            );
                          },
                        ),
                      ),
                    ),
                    // Clasificación por edad
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: pelicula.colorClasificacion,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: pelicula.colorClasificacion.withOpacity(0.5),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Text(
                          pelicula.clasificacion,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Overlay si no puede ver
                    if (!canWatch)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.lock, color: Colors.red, size: 20),
                                SizedBox(height: 2),
                                Text(
                                  'RESTRINGIDO',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pelicula.titulo,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          shadows: [
                            Shadow(
                              color: neonPink.withOpacity(0.7),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: neonPurple.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: neonPurple.withOpacity(0.5)),
                        ),
                        child: Text(
                          pelicula.categoria,
                          style: TextStyle(
                            color: neonPurple,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        pelicula.descripcion,
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 13,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    _buildGlowingContainer(
                      glowColor: Colors.red,
                      child: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.red, Colors.red[800]!],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        onPressed: () => _removeFavorite(pelicula),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [neonBlue, neonGreen],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.favorite, color: neonPink, size: 28),
            const SizedBox(width: 8),
            Text(
              'Favoritos',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: neonPink, blurRadius: 10)],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.grey[900]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          if (_favorites.isNotEmpty)
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: neonBlue.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: neonBlue),
                ),
                child: Icon(Icons.refresh, color: neonBlue, size: 20),
              ),
              onPressed: _loadFavorites,
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(neonPink),
                      strokeWidth: 4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Cargando favoritos...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      shadows: [Shadow(color: neonPink, blurRadius: 10)],
                    ),
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                
                Expanded(
                  child: _filteredFavorites.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadFavorites,
                          color: neonPink,
                          child: ListView.builder(
                            itemCount: _filteredFavorites.length,
                            itemBuilder: (context, index) {
                              return _buildFavoriteCard(_filteredFavorites[index]);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}