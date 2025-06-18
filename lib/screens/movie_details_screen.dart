import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/pelicula.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key});

  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen>
    with TickerProviderStateMixin {
  late Pelicula pelicula;
  bool isFavorite = false;
  bool _canWatch = true;
  int? _userAge;
  String? _username;

  late DatabaseReference _favoritesRef;
  late User? _currentUser;

  // Animaciones
  late AnimationController _glowController;
  late AnimationController _pulseController;
  late AnimationController _heartController;
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _heartAnimation;

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
    _heartController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _heartAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.elasticOut),
    );

    _glowController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
  }

  Future<void> _loadUserData() async {
    try {
      if (_currentUser?.displayName != null) {
        final snapshot = await FirebaseDatabase.instance
            .ref('users')
            .child(_currentUser!.displayName!)
            .get();

        if (snapshot.exists) {
          final userData = Map<String, dynamic>.from(snapshot.value as Map);
          setState(() {
            _userAge = userData['age'];
            _username = userData['username'];
          });

          // Verificar si puede ver la película después de cargar la edad
          _checkIfCanWatch();
        }
      }
    } catch (e) {
      print('Error al cargar datos del usuario: $e');
    }
  }

  void _checkIfCanWatch() {
    if (_userAge != null && pelicula != null) {
      setState(() {
        _canWatch = pelicula.esApropiadaParaEdad(_userAge!);
      });
      print(
        'Edad del usuario: $_userAge, Edad mínima película: ${pelicula.edadMinima}, Puede ver: $_canWatch',
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;

    // Crear el objeto Pelicula desde los argumentos
    pelicula = Pelicula(
      titulo: args['titulo']!,
      descripcion: args['descripcion']!,
      imagen: args['imagen']!,
      trailer: args['trailer']!,
      categoria: args['categoria'] ?? 'Sin categoría',
      edadMinima: _getEdadMinimaFromTitle(args['titulo']!),
    );

    // Verificar si puede ver la película después de crear el objeto
    _checkIfCanWatch();
    _checkIfFavorite();
  }

  int _getEdadMinimaFromTitle(String titulo) {
    // Mapeo básico - en producción esto vendría de la base de datos
    final edadesPorTitulo = <String, int>{
      'Winnie the Pooh: Sangre y Miel': 18,
      'Titanic': 13,
      'Jurassic World': 13,
      'Rápidos y Furiosos': 16,
      'Mi Villano Favorito': 0,
      '¿Qué pasó ayer?': 16,
      'Frozen': 0,
      'John Wick': 18,
      'Toy Story': 0,
      'Saw': 18,
      'La La Land': 13,
      'Superbad': 16,
      'Indiana Jones': 13,
      'El Conjuro': 16,
      'Los Increíbles': 0,
      'Matrix': 13,
      'Shrek': 0,
      'Deadpool': 18,
      'Coco': 0,
      'Venom': 16,
    };
    return edadesPorTitulo[titulo] ?? 13;
  }

  Future<void> _checkIfFavorite() async {
    if (_currentUser == null) return;

    final snapshot = await _favoritesRef
        .child(_currentUser!.uid)
        .child(_sanitizeKey(pelicula.titulo))
        .get();

    if (mounted) {
      setState(() {
        isFavorite = snapshot.exists;
      });
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

  Future<void> _toggleFavorite() async {
    if (_currentUser == null) {
      _showMessage(
        'Debes iniciar sesión para guardar favoritos',
        Colors.orange,
      );
      return;
    }

    // Animación del corazón
    _heartController.forward().then((_) => _heartController.reverse());

    setState(() {
      isFavorite = !isFavorite;
    });

    try {
      final userFavoritesRef = _favoritesRef.child(_currentUser!.uid);
      final movieKey = _sanitizeKey(pelicula.titulo);

      if (isFavorite) {
        await userFavoritesRef.child(movieKey).set({
          'titulo': pelicula.titulo,
          'descripcion': pelicula.descripcion,
          'imagen': pelicula.imagen,
          'trailer': pelicula.trailer,
          'categoria': pelicula.categoria,
          'edadMinima': pelicula.edadMinima,
          'fecha_guardado': ServerValue.timestamp,
        });

        _showMessage('"${pelicula.titulo}" agregada a favoritos ❤️', neonPink);
      } else {
        await userFavoritesRef.child(movieKey).remove();
        _showMessage(
          '"${pelicula.titulo}" removida de favoritos 💔',
          Colors.grey,
        );
      }
    } catch (e) {
      setState(() {
        isFavorite = !isFavorite;
      });
      _showMessage('Error: ${e.toString()}', Colors.red);
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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

  Widget _buildRestrictedOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildGlowingContainer(
              glowColor: Colors.red,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red, width: 2),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.lock, color: Colors.red, size: 60),
                    const SizedBox(height: 16),
                    const Text(
                      'CONTENIDO RESTRINGIDO',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Esta película requiere ${pelicula.edadMinima}+ años',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Text(
                      'Tu edad actual: $_userAge años',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTrailerDialog(BuildContext context, String videoUrl) {
    if (!_canWatch) {
      _showAgeRestrictionDialog();
      return;
    }

    final videoId = YoutubePlayer.convertUrlToId(videoUrl);
    if (videoId == null) return;

    final controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
    );

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(10),
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: neonBlue.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: YoutubePlayer(
                controller: controller,
                aspectRatio: 16 / 9,
                showVideoProgressIndicator: true,
                progressIndicatorColor: neonPink,
                onEnded: (metaData) {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAgeRestrictionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 30),
            const SizedBox(width: 8),
            const Text(
              'Contenido Restringido',
              style: TextStyle(color: Colors.white),
            ),
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

  // En tu MovieDetailScreen, reemplaza el método _watchMovie con este:

  void _watchMovie() {
    if (!_canWatch) {
      _showAgeRestrictionDialog();
      return;
    }

    // Guardar en historial antes de ver la película
    _saveToHistory();

    // Navegar al reproductor pasando todos los datos de la película
    Navigator.pushNamed(
      context,
      '/player',
      arguments: {
        'titulo': pelicula.titulo,
        'descripcion': pelicula.descripcion,
        'imagen': pelicula.imagen,
        'trailer': pelicula.trailer,
        'categoria': pelicula.categoria,
        'edadMinima': pelicula.edadMinima,
      },
    );
  }

  Future<void> _saveToHistory() async {
    if (_currentUser == null) return;

    try {
      final historyRef = FirebaseDatabase.instance.ref('usuarios_historial');
      final movieKey = _sanitizeKey(pelicula.titulo);

      await historyRef.child(_currentUser!.uid).child(movieKey).set({
        'titulo': pelicula.titulo,
        'descripcion': pelicula.descripcion,
        'imagen': pelicula.imagen,
        'trailer': pelicula.trailer,
        'categoria': pelicula.categoria,
        'edadMinima': pelicula.edadMinima,
        'fecha_vista': ServerValue.timestamp,
      });

      print('Movie saved to history: ${pelicula.titulo}');
    } catch (e) {
      print('Error al guardar en historial: $e');
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pulseController.dispose();
    _heartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    pelicula.imagen,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.movie,
                          color: Colors.white,
                          size: 100,
                        ),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                          Colors.black,
                        ],
                      ),
                    ),
                  ),
                  if (!_canWatch) _buildRestrictedOverlay(),
                  if (_canWatch)
                    Center(
                      child: _buildGlowingContainer(
                        glowColor: neonPink,
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: IconButton(
                                icon: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [neonPink, neonPurple],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: neonPink.withOpacity(0.5),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow,
                                    size: 32,
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () => _showTrailerDialog(
                                  context,
                                  pelicula.trailer,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  // Clasificación por edad
                  Positioned(
                    top: 100,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: pelicula.colorClasificacion,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: pelicula.colorClasificacion.withOpacity(0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Text(
                        pelicula.clasificacion,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              AnimatedBuilder(
                animation: _heartAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _heartAnimation.value,
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isFavorite
                              ? neonPink.withOpacity(0.2)
                              : Colors.black.withOpacity(0.3),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isFavorite ? neonPink : Colors.white,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? neonPink : Colors.white,
                          size: 24,
                        ),
                      ),
                      onPressed: _toggleFavorite,
                    ),
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título con efecto neón
                  Text(
                    pelicula.titulo,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: neonBlue, blurRadius: 15)],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Categoría con chip neón
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          neonPurple.withOpacity(0.3),
                          neonPink.withOpacity(0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: neonPurple, width: 1),
                    ),
                    child: Text(
                      pelicula.categoria,
                      style: TextStyle(
                        color: neonPurple,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Descripción
                  Text(
                    'Sinopsis',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: neonGreen, blurRadius: 10)],
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    pelicula.descripcion,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Botón principal
                  Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: _canWatch
                            ? neonGreen.withOpacity(0.8)
                            : Colors.red.withOpacity(0.8),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _canWatch
                              ? neonGreen.withOpacity(0.3)
                              : Colors.red.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _watchMovie,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _canWatch ? Icons.play_arrow : Icons.lock,
                            size: 24,
                            color: _canWatch ? neonGreen : Colors.red,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _canWatch ? 'VER AHORA' : 'CONTENIDO RESTRINGIDO',
                            style: TextStyle(
                              color: _canWatch ? neonGreen : Colors.red,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
