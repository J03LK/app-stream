import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/pelicula.dart';
import '../data/peliculas_data.dart';

class CategoryScreen extends StatefulWidget {
  final String categoria;

  const CategoryScreen({super.key, required this.categoria});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> with TickerProviderStateMixin {
  List<Pelicula> _peliculas = [];
  List<Pelicula> _peliculasFiltradas = [];
  int? _userAge;
  String? _username;
  bool _isLoading = true;

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

  // Colores por categoría
  final Map<String, Color> categoryColors = {
    'Terror': Color(0xFFFF0080),
    'Romance': Color(0xFFFF1493),
    'Aventura': Color(0xFF00FF41),
    'Acción': Color(0xFFFF4500),
    'Infantiles': Color(0xFF00FFFF),
    'Comedia': Color(0xFFFFFF00),
    'Ciencia Ficción': Color(0xFF8A2BE2),
    'Drama': Color(0xFFFF6B6B),
  };

  // Iconos por categoría
  final Map<String, IconData> categoryIcons = {
    'Terror': Icons.nightlife,
    'Romance': Icons.favorite,
    'Aventura': Icons.explore,
    'Acción': Icons.local_fire_department,
    'Infantiles': Icons.child_care,
    'Comedia': Icons.sentiment_very_satisfied,
    'Ciencia Ficción': Icons.rocket_launch,
    'Drama': Icons.theater_comedy,
  };

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadData();
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
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _glowController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
  }

  Future<void> _loadData() async {
    try {
      // Cargar datos del usuario
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser?.displayName != null) {
        final snapshot = await FirebaseDatabase.instance
            .ref('users')
            .child(currentUser!.displayName!)
            .get();
        
        if (snapshot.exists) {
          final userData = Map<String, dynamic>.from(snapshot.value as Map);
          setState(() {
            _userAge = userData['age'];
            _username = userData['username'];
          });
        }
      }

      // Cargar películas de la categoría
      final todasLasPeliculas = obtenerPeliculas();
      _peliculas = todasLasPeliculas.where((p) => 
        p.categoria.toLowerCase() == widget.categoria.toLowerCase()
      ).toList();

      // Filtrar por edad
      _peliculasFiltradas = _userAge != null
          ? _peliculas.where((p) => p.esApropiadaParaEdad(_userAge!)).toList()
          : _peliculas.where((p) => p.edadMinima <= 0).toList();

    } catch (e) {
      print('Error al cargar datos: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Color get _categoryColor => categoryColors[widget.categoria] ?? neonPink;
  IconData get _categoryIcon => categoryIcons[widget.categoria] ?? Icons.movie;

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
        border: Border.all(color: _categoryColor.withOpacity(0.5), width: 2),
      ),
      child: _buildGlowingContainer(
        glowColor: _categoryColor,
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
                        colors: [_categoryColor, _categoryColor.withOpacity(0.7)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_categoryIcon, color: Colors.white, size: 32),
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
                    widget.categoria,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: _categoryColor, blurRadius: 15)],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _categoryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _categoryColor, width: 1),
                        ),
                        child: Text(
                          '${_peliculasFiltradas.length} películas disponibles',
                          style: TextStyle(
                            color: _categoryColor,
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

  Widget _buildMovieCard(Pelicula pelicula) {
    final bool canWatch = _userAge != null && pelicula.esApropiadaParaEdad(_userAge!);
    
    return GestureDetector(
      onTap: () {
        if (canWatch) {
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
        } else {
          _showAgeRestrictionDialog(pelicula);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
            color: canWatch ? _categoryColor.withOpacity(0.5) : Colors.red.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: _buildGlowingContainer(
          glowColor: canWatch ? _categoryColor : Colors.red,
          glowRadius: 15,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: _categoryColor.withOpacity(0.3),
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
                              child: Icon(
                                Icons.movie,
                                color: Colors.grey[600],
                                size: 40,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Clasificación por edad
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: pelicula.colorClasificacion,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: pelicula.colorClasificacion.withOpacity(0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Text(
                          pelicula.clasificacion,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
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
                                Icon(Icons.lock, color: Colors.red, size: 30),
                                SizedBox(height: 4),
                                Text(
                                  'RESTRINGIDO',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 10,
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
                          fontSize: 18,
                          shadows: [
                            Shadow(
                              color: _categoryColor.withOpacity(0.7),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        pelicula.descripcion,
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 14,
                          height: 1.4,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [_categoryColor.withOpacity(0.3), _categoryColor.withOpacity(0.1)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: _categoryColor.withOpacity(0.7), width: 1),
                            ),
                            child: Text(
                              pelicula.categoria,
                              style: TextStyle(
                                color: _categoryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [_categoryColor, _categoryColor.withOpacity(0.7)],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _categoryColor.withOpacity(0.5),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 20,
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
        ),
      ),
    );
  }

  void _showAgeRestrictionDialog(Pelicula pelicula) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 30),
            const SizedBox(width: 8),
            const Text('Contenido Restringido', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          'Esta película requiere ${pelicula.edadMinima}+ años para verla.\nTu edad actual es: $_userAge años.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Entendido', style: TextStyle(color: _categoryColor)),
          ),
        ],
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
            Icon(_categoryIcon, color: _categoryColor, size: 28),
            const SizedBox(width: 8),
            Text(
              widget.categoria,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: _categoryColor, blurRadius: 10)],
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
                      valueColor: AlwaysStoppedAnimation<Color>(_categoryColor),
                      strokeWidth: 4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Cargando películas...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      shadows: [Shadow(color: _categoryColor, blurRadius: 10)],
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                _buildHeader(),
                
                Expanded(
                  child: _peliculasFiltradas.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.movie_outlined,
                                size: 100,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No hay películas de ${widget.categoria}',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 18,
                                  shadows: [Shadow(color: _categoryColor, blurRadius: 5)],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'disponibles para tu edad ($_userAge años)',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _peliculasFiltradas.length,
                          itemBuilder: (context, index) {
                            return _buildMovieCard(_peliculasFiltradas[index]);
                          },
                        ),
                ),
              ],
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.grey[900]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: _categoryColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: _categoryColor,
          unselectedItemColor: Colors.grey[600],
          currentIndex: 2,
          elevation: 0,
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(context, '/categories');
                break;
              case 1:
                Navigator.pushReplacementNamed(context, '/search');
                break;
              case 2:
                Navigator.pushReplacementNamed(context, '/home');
                break;
              case 3:
                Navigator.pushReplacementNamed(context, '/profile');
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.category),
              label: 'Categorías',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Buscar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.movie),
              label: 'Películas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}