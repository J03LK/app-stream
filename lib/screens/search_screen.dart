import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/pelicula.dart';
import '../data/peliculas_data.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  List<Pelicula> _todasLasPeliculas = [];
  List<Pelicula> _peliculasFiltradas = [];
  bool _isSearching = false;
  
  // Datos del usuario para filtrado
  int? _userAge;
  String? _username;
  String? _favoriteGenre;
  bool _isLoadingUser = true;

  // Animaciones
  late AnimationController _glowController;
  late AnimationController _pulseController;
  late AnimationController _searchAnimController;
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _searchAnimation;

  // Colores neón
  final Color neonPink = const Color(0xFFFF0080);
  final Color neonBlue = const Color(0xFF00FFFF);
  final Color neonGreen = const Color(0xFF00FF41);
  final Color neonPurple = const Color(0xFF8A2BE2);
  final Color neonYellow = const Color(0xFFFFFF00);
  final Color neonOrange = const Color(0xFFFF4500);

  @override
  void initState() {
    super.initState();
    _todasLasPeliculas = obtenerPeliculas();
    _peliculasFiltradas = [];
    _initAnimations();
    _loadUserData();
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
    _searchAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _searchAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _searchAnimController, curve: Curves.elasticOut),
    );

    _glowController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
    _searchAnimController.forward();
  }

  Future<void> _loadUserData() async {
    try {
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
            _favoriteGenre = userData['favoriteGenre'];
          });
        }
      }
    } catch (e) {
      print('Error al cargar datos del usuario: $e');
    } finally {
      setState(() {
        _isLoadingUser = false;
      });
    }
  }

  void _filtrarPeliculas(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        _peliculasFiltradas = [];
      } else {
        // Filtrar por búsqueda
        var resultados = _todasLasPeliculas.where((pelicula) {
          return pelicula.titulo.toLowerCase().contains(query.toLowerCase()) ||
              pelicula.descripcion.toLowerCase().contains(query.toLowerCase()) ||
              pelicula.categoria.toLowerCase().contains(query.toLowerCase());
        }).toList();

        // Filtrar por edad del usuario
        if (_userAge != null) {
          resultados = resultados.where((pelicula) => 
            pelicula.esApropiadaParaEdad(_userAge!)
          ).toList();
        } else {
          // Si no hay edad, solo mostrar contenido apto para todo público
          resultados = resultados.where((pelicula) => 
            pelicula.edadMinima <= 0
          ).toList();
        }

        // Priorizar género favorito en los resultados
        if (_favoriteGenre != null) {
          final favoritos = resultados.where((p) => 
            p.categoria.toLowerCase().contains(_favoriteGenre!.toLowerCase())
          ).toList();
          final otros = resultados.where((p) => 
            !p.categoria.toLowerCase().contains(_favoriteGenre!.toLowerCase())
          ).toList();
          _peliculasFiltradas = [...favoritos, ...otros];
        } else {
          _peliculasFiltradas = resultados;
        }
      }
    });
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

  Widget _buildSearchBar() {
    return AnimatedBuilder(
      animation: _searchAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _searchAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: _buildGlowingContainer(
              glowColor: neonBlue,
              glowRadius: 25,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.grey[900]!.withOpacity(0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: neonBlue.withOpacity(0.5), width: 2),
                ),
                child: TextField(
                  controller: _textController,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: "Buscar películas disponibles para ti...",
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      shadows: [Shadow(color: neonBlue, blurRadius: 5)],
                    ),
                    prefixIcon: _buildGlowingContainer(
                      glowColor: neonPink,
                      glowRadius: 10,
                      child: Icon(Icons.search, color: neonPink, size: 28),
                    ),
                    suffixIcon: _textController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: neonOrange),
                            onPressed: () {
                              _textController.clear();
                              _filtrarPeliculas('');
                            },
                          )
                        : _userAge != null 
                            ? Container(
                                margin: const EdgeInsets.all(8),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: neonGreen.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: neonGreen, width: 1),
                                ),
                                child: Text(
                                  'Edad: $_userAge',
                                  style: TextStyle(
                                    color: neonGreen,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  onChanged: _filtrarPeliculas,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInitialContent() {
    final List<Map<String, dynamic>> categoriasPopulares = [
      {"nombre": "Terror", "color": neonPink, "icon": Icons.nightlife},
      {"nombre": "Acción", "color": neonOrange, "icon": Icons.local_fire_department},
      {"nombre": "Romance", "color": Colors.pink, "icon": Icons.favorite},
      {"nombre": "Comedia", "color": neonYellow, "icon": Icons.sentiment_very_satisfied},
      {"nombre": "Aventura", "color": neonGreen, "icon": Icons.explore},
      {"nombre": "Infantiles", "color": neonBlue, "icon": Icons.child_care},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de bienvenida
          Center(
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: _buildGlowingContainer(
                        glowColor: neonPurple,
                        glowRadius: 30,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [neonPurple, neonPink],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.search,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  _username != null ? '¡Hola, $_username!' : '¿Qué quieres ver hoy?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(color: neonPurple, blurRadius: 15),
                      Shadow(color: neonPink, blurRadius: 25),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _userAge != null 
                      ? 'Películas disponibles para tu edad ($_userAge años)'
                      : 'Busca por título, descripción o categoría',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                    shadows: [Shadow(color: neonBlue, blurRadius: 5)],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Información del usuario
          if (_username != null)
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.grey[900]!.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: neonGreen.withOpacity(0.5), width: 1),
              ),
              child: _buildGlowingContainer(
                glowColor: neonGreen,
                child: Row(
                  children: [
                    Icon(Icons.person, color: neonGreen, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Perfil de búsqueda',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              shadows: [Shadow(color: neonGreen, blurRadius: 5)],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Género favorito: $_favoriteGenre • Edad: $_userAge años',
                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Categorías populares
          Text(
            "🔥 Categorías Populares",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: neonYellow, blurRadius: 10)],
            ),
          ),
          const SizedBox(height: 20),
          
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: categoriasPopulares.map((categoria) {
              return GestureDetector(
                onTap: () {
                  _textController.text = categoria["nombre"];
                  _filtrarPeliculas(categoria["nombre"]);
                },
                child: _buildGlowingContainer(
                  glowColor: categoria["color"],
                  glowRadius: 15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          categoria["color"].withOpacity(0.3),
                          categoria["color"].withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: categoria["color"], width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          categoria["icon"],
                          color: categoria["color"],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          categoria["nombre"],
                          style: TextStyle(
                            color: categoria["color"],
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildGlowingContainer(
            glowColor: Colors.orange,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.withOpacity(0.5)),
              ),
              child: const Icon(
                Icons.search_off,
                size: 80,
                color: Colors.orange,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "No se encontraron películas",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Colors.orange, blurRadius: 10)],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _userAge != null 
                ? "No hay películas disponibles para tu edad\ncon estos términos de búsqueda"
                : "Intenta con otros términos de búsqueda",
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _peliculasFiltradas.length,
      itemBuilder: (context, index) {
        final pelicula = _peliculasFiltradas[index];
        final bool canWatch = _userAge != null && pelicula.esApropiadaParaEdad(_userAge!);
        
        return GestureDetector(
          onTap: () {
            if (canWatch || _userAge == null) {
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
            } else {
              _showAgeRestrictionDialog(pelicula);
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.grey[900]!.withOpacity(0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: canWatch ? neonBlue.withOpacity(0.5) : Colors.red.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: _buildGlowingContainer(
              glowColor: canWatch ? neonBlue : Colors.red,
              glowRadius: 15,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagen de la película
                    Stack(
                      children: [
                        Container(
                          width: 70,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: neonPink.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
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
                                  child: const Icon(
                                    Icons.movie,
                                    color: Colors.white,
                                    size: 30,
                                  ),
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
                      ],
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Información de la película
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
                                Shadow(color: neonPink.withOpacity(0.7), blurRadius: 5),
                              ],
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
                          const SizedBox(height: 8),
                          Row(
                            children: [
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
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: canWatch ? [neonGreen, neonBlue] : [Colors.red, Colors.red[800]!],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  canWatch ? Icons.play_arrow : Icons.lock,
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
      },
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
            child: Text('Entendido', style: TextStyle(color: neonPink)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _glowController.dispose();
    _pulseController.dispose();
    _searchAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "🔍 Buscar Películas",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: neonBlue, blurRadius: 10)],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
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
      body: _isLoadingUser
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
                    'Preparando búsqueda...',
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
              children: [
                _buildSearchBar(),
                Expanded(child: _buildContent()),
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
              color: neonBlue.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: neonBlue,
          unselectedItemColor: Colors.grey[600],
          currentIndex: 1,
          elevation: 0,
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(context, '/categories');
                break;
              case 1:
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

  Widget _buildContent() {
    if (!_isSearching) {
      return _buildInitialContent();
    } else if (_peliculasFiltradas.isEmpty) {
      return _buildNoResults();
    } else {
      return _buildSearchResults();
    }
  }
}