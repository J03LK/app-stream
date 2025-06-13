import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with TickerProviderStateMixin {
  List<Map<String, dynamic>> _historyMovies = [];
  bool _isLoading = true;
  
  late DatabaseReference _historyRef;
  late User? _currentUser;

  // Animaciones
  late AnimationController _glowController;
  late AnimationController _fadeController;
  late Animation<double> _glowAnimation;
  late Animation<double> _fadeAnimation;

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
    _initAnimations();
    _currentUser = FirebaseAuth.instance.currentUser;
    _historyRef = FirebaseDatabase.instance.ref('usuarios_historial');
    _loadHistory();
  }

  void _initAnimations() {
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    
    _glowController.repeat(reverse: true);
    _fadeController.forward();
  }

  Future<void> _loadHistory() async {
    if (_currentUser == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final snapshot = await _historyRef.child(_currentUser!.uid).get();
      
      if (snapshot.exists) {
        final historyData = Map<String, dynamic>.from(snapshot.value as Map);
        
        final List<Map<String, dynamic>> movies = [];
        historyData.forEach((key, value) {
          final movieData = Map<String, dynamic>.from(value);
          movieData['key'] = key;
          movies.add(movieData);
        });
        
        // Ordenar por fecha más reciente
        movies.sort((a, b) {
          final timestampA = a['fecha_vista'] ?? 0;
          final timestampB = b['fecha_vista'] ?? 0;
          return timestampB.compareTo(timestampA);
        });
        
        setState(() {
          _historyMovies = movies;
        });
      }
    } catch (e) {
      print('Error al cargar historial: $e');
      _showMessage('Error al cargar el historial', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearHistory() async {
    if (_currentUser == null) return;
    
    try {
      await _historyRef.child(_currentUser!.uid).remove();
      setState(() {
        _historyMovies.clear();
      });
      _showMessage('Historial eliminado completamente 🗑️', neonOrange);
    } catch (e) {
      print('Error al limpiar historial: $e');
      _showMessage('Error al eliminar el historial', Colors.red);
    }
  }

  Future<void> _removeMovieFromHistory(String movieKey, String movieTitle) async {
    if (_currentUser == null) return;
    
    try {
      await _historyRef.child(_currentUser!.uid).child(movieKey).remove();
      setState(() {
        _historyMovies.removeWhere((movie) => movie['key'] == movieKey);
      });
      _showMessage('"$movieTitle" eliminada del historial', Colors.grey);
    } catch (e) {
      print('Error al eliminar película del historial: $e');
      _showMessage('Error al eliminar la película', Colors.red);
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

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Fecha desconocida';
    
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays == 0) {
        return 'Hoy';
      } else if (difference.inDays == 1) {
        return 'Ayer';
      } else if (difference.inDays < 7) {
        return 'Hace ${difference.inDays} días';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Fecha desconocida';
    }
  }

  Widget _buildMovieCard(Map<String, dynamic> movie) {
    return _buildGlowingContainer(
      glowColor: neonBlue,
      glowRadius: 15,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.grey[900]!.withOpacity(0.9),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: neonBlue.withOpacity(0.5), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Imagen de la película
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 60,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: neonBlue.withOpacity(0.3)),
                  ),
                  child: Image.network(
                    movie['imagen'] ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.movie, color: neonBlue, size: 30);
                    },
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Información de la película
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie['titulo'] ?? 'Película sin título',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        shadows: [Shadow(color: neonBlue, blurRadius: 5)],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: neonPurple.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: neonPurple.withOpacity(0.5)),
                      ),
                      child: Text(
                        movie['categoria'] ?? 'Sin categoría',
                        style: TextStyle(
                          color: neonPurple,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(movie['fecha_vista']),
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Botones de acción
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: neonGreen.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: neonGreen.withOpacity(0.5)),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.play_arrow, color: neonGreen, size: 20),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/movie_details',
                          arguments: {
                            'titulo': movie['titulo'],
                            'descripcion': movie['descripcion'],
                            'imagen': movie['imagen'],
                            'trailer': movie['trailer'],
                            'categoria': movie['categoria'],
                          },
                        );
                      },
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.red.withOpacity(0.5)),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      onPressed: () => _showDeleteDialog(movie),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> movie) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            const Text('Eliminar del \nHistorial', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${movie['titulo']}" del historial?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey[400])),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removeMovieFromHistory(movie['key'], movie['titulo']);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning, color: neonOrange, size: 28),
            const SizedBox(width: 8),
            const Text('Limpiar Historial', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          '¿Estás seguro de que quieres eliminar todo el historial?\n\nEsta acción no se puede deshacer.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey[400])),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearHistory();
            },
            child: Text('Limpiar Todo', style: TextStyle(color: neonOrange)),
          ),
        ],
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
                shape: BoxShape.circle,
                border: Border.all(color: neonPurple.withOpacity(0.3), width: 2),
              ),
              child: Icon(Icons.history, size: 60, color: neonPurple),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Sin Historial',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: neonPurple, blurRadius: 10)],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Aún no has visto ninguna película.\n¡Explora nuestro catálogo!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            height: 45,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: neonGreen.withOpacity(0.8), width: 2),
              boxShadow: [
                BoxShadow(
                  color: neonGreen.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                'Explorar Películas',
                style: TextStyle(
                  color: neonGreen,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Mi Historial',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: neonBlue, blurRadius: 10)],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: neonBlue),
          onPressed: () => Navigator.pop(context),
        ),
        actions: _historyMovies.isNotEmpty
            ? [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: neonOrange.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: neonOrange.withOpacity(0.5)),
                    ),
                    child: Icon(Icons.delete_sweep, color: neonOrange, size: 24),
                  ),
                  onPressed: _showClearHistoryDialog,
                ),
              ]
            : null,
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
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              neonPurple.withOpacity(0.1),
              Colors.black,
              Colors.black,
            ],
          ),
        ),
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(neonBlue),
                        strokeWidth: 4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Cargando historial...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        shadows: [Shadow(color: neonBlue, blurRadius: 10)],
                      ),
                    ),
                  ],
                ),
              )
            : _historyMovies.isEmpty
                ? _buildEmptyState()
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Column(
                        children: [
                          // Header con estadísticas
                          Container(
                            margin: const EdgeInsets.only(bottom: 24),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  neonBlue.withOpacity(0.1),
                                  neonPurple.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: neonBlue.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.history, color: neonBlue, size: 32),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Películas Vistas',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          shadows: [Shadow(color: neonBlue, blurRadius: 5)],
                                        ),
                                      ),
                                      Text(
                                        '${_historyMovies.length} película${_historyMovies.length == 1 ? '' : 's'}',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Lista de películas
                          ...(_historyMovies.map((movie) => _buildMovieCard(movie)).toList()),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}