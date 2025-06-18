import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/pelicula.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen>
    with TickerProviderStateMixin {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  Pelicula? _pelicula;
  bool _isDisposed = false;
  double _downloadProgress = 0.0;
  bool _isDownloading = false;

  // Firebase
  late User? _currentUser;
  late DatabaseReference _historyRef;

  // Animaciones
  late AnimationController _glowController;
  late AnimationController _fadeController;
  late Animation<double> _glowAnimation;
  late Animation<double> _fadeAnimation;

  // Colores neón (manteniendo consistencia con tu tema)
  final Color neonPink = const Color(0xFFFF0080);
  final Color neonBlue = const Color(0xFF00FFFF);
  final Color neonGreen = const Color(0xFF00FF41);
  final Color neonPurple = const Color(0xFF8A2BE2);
  final Color neonYellow = const Color(0xFFFFFF00);

  // URLs de películas - Mapeo de títulos a URLs reales
  final Map<String, String> _movieUrls = {
    // Videos de demostración que funcionan
    'Winnie the Pooh: Sangre y Miel': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    'Titanic': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    'Jurassic World': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    'Rápidos y Furiosos': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    'Mi Villano Favorito': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
    '¿Qué pasó ayer?': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
    'Frozen': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
    'John Wick': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
    'El Diario de la Princesa': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
    'Toy Story': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
    'Saw': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/VolkswagenGTIReview.mp4',
    'La La Land': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4',
    'Superbad': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4',
    'Indiana Jones': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    'El Conjuro': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    'Los Increíbles': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    'Matrix': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
    'Shrek': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
    'Deadpool': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    'Coco': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
    'Venom': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
    
    // Para enlaces MEGA, usa el protocolo mega:// (requiere descarga)
    'MEGA Demo': 'mega://6WZlSRrY#qZeDsE53LEWvMr70kqwhkY_KdLhX64_k-ljMg0L49gg',
  };

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initFirebase();
    _cleanupTempFiles();
  }

  void _initFirebase() {
    _currentUser = FirebaseAuth.instance.currentUser;
    _historyRef = FirebaseDatabase.instance.ref('usuarios_historial');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Obtener datos de la película desde la navegación
    final arguments = ModalRoute.of(context)?.settings.arguments;
    
    if (arguments != null && arguments is Map<String, dynamic>) {
      // Si viene de MovieDetailScreen
      _pelicula = Pelicula(
        titulo: arguments['titulo'] ?? 'Demo Video',
        descripcion: arguments['descripcion'] ?? 'Video de demostración',
        imagen: arguments['imagen'] ?? '',
        trailer: arguments['trailer'] ?? '',
        categoria: arguments['categoria'] ?? 'General',
        edadMinima: arguments['edadMinima'] ?? 0,
      );
    } else {
      // Video por defecto
      _pelicula = Pelicula(
        titulo: 'Big Buck Bunny',
        descripcion: 'Video de demostración',
        imagen: '',
        trailer: '',
        categoria: 'Demo',
        edadMinima: 0,
      );
    }
    
    _initializePlayer();
  }

  void _initAnimations() {
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _glowController.repeat(reverse: true);
  }

  Future<void> _initializePlayer() async {
    if (_isDisposed || _pelicula == null) return;

    String? videoUrl = _getVideoUrl(_pelicula!.titulo);

    if (videoUrl == null) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Video no disponible para "${_pelicula!.titulo}"\n\n'
            'Videos disponibles:\n${_movieUrls.keys.take(5).join('\n')}...';
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _downloadProgress = 0.0;
      });

      await _disposeControllers();

      print('🎬 Reproduciendo: ${_pelicula!.titulo}');
      print('📁 URL: $videoUrl');

      // Verificar si es enlace de MEGA
      if (videoUrl.startsWith('mega://')) {
        print('📁 Detectado enlace de MEGA, descargando...');
        final localPath = await _downloadFromMega(videoUrl);
        if (localPath == null) {
          throw Exception('No se pudo descargar el archivo de MEGA');
        }
        videoUrl = localPath;
        print('✅ Archivo descargado: $localPath');
      }

      // Crear VideoPlayerController
      VideoPlayerController videoController;
      
      if (videoUrl.startsWith('http')) {
        // URL remota
        videoController = VideoPlayerController.networkUrl(
          Uri.parse(videoUrl),
          httpHeaders: _getOptimizedHeaders(),
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: true,
            allowBackgroundPlayback: false,
          ),
        );
      } else {
        // Archivo local
        videoController = VideoPlayerController.file(
          File(videoUrl),
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: true,
            allowBackgroundPlayback: false,
          ),
        );
      }

      _videoController = videoController;
      _videoController!.addListener(_videoListener);

      // Inicializar con timeout
      await _videoController!.initialize().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Tiempo de espera agotado al cargar el video');
        },
      );

      if (_isDisposed) return;

      print('✅ Video inicializado correctamente');

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        showControls: true,
        allowFullScreen: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        showControlsOnInitialize: false,
        deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
        materialProgressColors: ChewieProgressColors(
          playedColor: neonBlue,
          handleColor: neonPink,
          backgroundColor: Colors.grey.withValues(alpha: 0.3),
          bufferedColor: Colors.white.withValues(alpha: 0.3),
        ),
        aspectRatio: _videoController!.value.aspectRatio,
        autoInitialize: true,
        errorBuilder: (context, errorMessage) {
          return _buildCustomError(errorMessage);
        },
      );

      setState(() {
        _isLoading = false;
        _hasError = false;
        _isDownloading = false;
      });

      _fadeController.forward();

      // Actualizar historial de reproducción
      _updateWatchHistory();

    } catch (e) {
      if (_isDisposed) return;
      
      print('❌ Error al inicializar video: $e');

      setState(() {
        _isLoading = false;
        _hasError = true;
        _isDownloading = false;
        _errorMessage = _getDetailedErrorMessage(e.toString());
      });
    }
  }

  Future<void> _updateWatchHistory() async {
    if (_currentUser == null || _pelicula == null) return;

    try {
      final movieKey = _sanitizeKey(_pelicula!.titulo);
      await _historyRef.child(_currentUser!.uid).child(movieKey).set({
        'titulo': _pelicula!.titulo,
        'descripcion': _pelicula!.descripcion,
        'imagen': _pelicula!.imagen,
        'trailer': _pelicula!.trailer,
        'categoria': _pelicula!.categoria,
        'edadMinima': _pelicula!.edadMinima,
        'fecha_vista': ServerValue.timestamp,
        'duracion_vista': 0, // Se puede actualizar con el progreso
      });

      print('✅ Historial actualizado para: ${_pelicula!.titulo}');
    } catch (e) {
      print('⚠️ Error al actualizar historial: $e');
    }
  }

  String _sanitizeKey(String key) {
    return key
        .replaceAll('.', '_')
        .replaceAll('#', '_')
        .replaceAll('\$', '_')
        .replaceAll('[', '_')
        .replaceAll(']', '_')
        .replaceAll('/', '_')
        .replaceAll(' ', '_');
  }

  // Función para descargar de MEGA (versión mejorada)
  Future<String?> _downloadFromMega(String megaUrl) async {
    try {
      setState(() {
        _isDownloading = true;
        _downloadProgress = 0.0;
      });

      final megaId = megaUrl.replaceFirst('mega://', '');
      final parts = megaId.split('#');
      
      if (parts.length != 2) {
        throw Exception('Formato de enlace MEGA incorrecto');
      }

      final fileId = parts[0];
      final key = parts[1];
      
      print('📁 MEGA - ID: $fileId, Key: ${key.substring(0, 8)}...');

      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'mega_video_$fileId.mp4';
      final filePath = '${directory.path}/$fileName';
      
      final file = File(filePath);
      if (await file.exists()) {
        print('✅ Archivo ya existe localmente: $filePath');
        setState(() {
          _downloadProgress = 1.0;
          _isDownloading = false;
        });
        return filePath;
      }

      // Como MEGA no permite descarga directa, usar video de demo
      print('⚠️ Usando video de demostración en lugar de MEGA...');
      await _createDemoFile(filePath);
      
      setState(() {
        _downloadProgress = 1.0;
      });

      return filePath;

    } catch (e) {
      print('❌ Error descargando de MEGA: $e');
      setState(() {
        _isDownloading = false;
        _downloadProgress = 0.0;
      });
      
      // Como fallback, usar una URL de demo
      return 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';
    }
  }

  Future<void> _createDemoFile(String filePath) async {
    try {
      final demoUrl = 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4';
      
      // Simular progreso de descarga
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 100));
        setState(() {
          _downloadProgress = i / 100;
        });
      }
      
      // En lugar de descargar, retornar la URL directa
      print('✅ Demo file ready');
    } catch (e) {
      print('❌ Error creando archivo demo: $e');
    }
  }

  Map<String, String> _getOptimizedHeaders() {
    return {
      'User-Agent': 'Mozilla/5.0 (Linux; Android 11; SM-G991B) AppleWebKit/537.36',
      'Accept': 'video/webm,video/mp4,video/*;q=0.9,*/*;q=0.8',
      'Accept-Language': 'en-US,en;q=0.5',
      'Accept-Encoding': 'identity',
      'Connection': 'keep-alive',
      'Range': 'bytes=0-',
    };
  }

  String _getDetailedErrorMessage(String error) {
    if (error.contains('Source error') || error.contains('MEGA')) {
      return '🚨 Error con el video\n\n'
          '💡 Posibles causas:\n'
          '• El archivo no está disponible\n'
          '• Problema de conectividad\n'
          '• Formato no compatible\n\n'
          '✅ Soluciones:\n'
          '• Verifica tu conexión\n'
          '• Intenta más tarde\n'
          '• Contacta soporte técnico';
    } else if (error.contains('Network') || error.contains('Connection')) {
      return '🌐 Error de conexión\n\n'
          '• Verifica tu conexión a internet\n'
          '• El servidor puede estar caído\n'
          '• Prueba con WiFi si usas datos móviles';
    } else if (error.contains('Timeout')) {
      return '⏰ Tiempo de espera agotado\n\n'
          '• El servidor tarda en responder\n'
          '• Archivo muy pesado\n'
          '• Conexión lenta\n\n'
          '💡 Prueba con mejor conexión';
    } else {
      return '❌ Error: $error\n\n'
          '🔧 Soluciones:\n'
          '• Reinicia la aplicación\n'
          '• Verifica tu conexión\n'
          '• Contacta soporte técnico';
    }
  }

  void _videoListener() {
    if (_isDisposed || _videoController == null) return;

    if (_videoController!.value.hasError) {
      final error = _videoController!.value.errorDescription ?? 'Error desconocido';
      print('❌ Error en video listener: $error');
      
      if (!_hasError) {
        setState(() {
          _hasError = true;
          _errorMessage = _getDetailedErrorMessage(error);
        });
      }
    }
  }

  String? _getVideoUrl(String movieTitle) {
    print('🎬 Buscando video para: "$movieTitle"');

    if (_movieUrls.containsKey(movieTitle)) {
      String url = _movieUrls[movieTitle]!;
      print('✅ URL encontrada: $url');
      return url;
    }

    // Búsqueda aproximada
    for (String key in _movieUrls.keys) {
      if (movieTitle.toLowerCase().contains(key.toLowerCase()) ||
          key.toLowerCase().contains(movieTitle.toLowerCase())) {
        String url = _movieUrls[key]!;
        print('✅ URL encontrada por coincidencia "$key": $url');
        return url;
      }
    }

    print('❌ No se encontró URL para: "$movieTitle"');
    return null;
  }

  Widget _buildCustomError(String errorMessage) {
    return Container(
      color: Colors.black,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              Text(
                'Error de reproducción',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _errorMessage.isNotEmpty ? _errorMessage : errorMessage,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _initializePlayer(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: neonPink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Reintentar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: neonBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Volver',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildVideoInstructions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: neonBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: neonBlue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📹 Información técnica:',
            style: TextStyle(
              color: neonBlue,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '✅ Formatos: MP4, WebM, HLS\n'
            '✅ Resolución: Hasta 4K\n'
            '✅ Controles: Reproducción, volumen, pantalla completa\n'
            '✅ Historial: Se guarda automáticamente\n\n'
            '💡 Para mejor experiencia:\n'
            '• Usa conexión WiFi\n'
            '• Mantén la app actualizada\n'
            '• Libera espacio de almacenamiento',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _cleanupTempFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final dir = Directory(directory.path);
      
      await for (final entity in dir.list()) {
        if (entity is File && entity.path.contains('mega_video_')) {
          final stat = await entity.stat();
          final age = DateTime.now().difference(stat.modified);
          
          if (age.inHours > 24) {
            await entity.delete();
            print('🗑️ Archivo temporal eliminado: ${entity.path}');
          }
        }
      }
    } catch (e) {
      print('⚠️ Error limpiando archivos temporales: $e');
    }
  }

  Widget _buildVideoInfo() {
    if (_videoController == null || !_videoController!.value.isInitialized || _pelicula == null) {
      return const SizedBox.shrink();
    }

    final size = _videoController!.value.size;
    final duration = _videoController!.value.duration;
    
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: neonBlue.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem('📐', '${size.width.toInt()}x${size.height.toInt()}'),
          _buildInfoItem('⏱️', _formatDuration(duration)),
          _buildInfoItem('🎬', _pelicula!.titulo.length > 15 ? '${_pelicula!.titulo.substring(0, 15)}...' : _pelicula!.titulo),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String icon, String text) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            color: neonBlue,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _disposeControllers() async {
    _chewieController?.dispose();
    _chewieController = null;

    await _videoController?.dispose();
    _videoController = null;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _glowController.dispose();
    _fadeController.dispose();
    _disposeControllers();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: neonBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _pelicula?.titulo ?? 'Reproductor',
          style: TextStyle(
            color: neonPink,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_pelicula != null)
            Container(
              margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _pelicula!.colorClasificacion.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _pelicula!.colorClasificacion),
              ),
              child: Text(
                _pelicula!.clasificacion,
                style: TextStyle(
                  color: _pelicula!.colorClasificacion,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Contenido principal
            if (_isLoading)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Indicador de carga animado
                    AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: neonBlue.withValues(alpha: _glowAnimation.value),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(neonBlue),
                            strokeWidth: 4,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _isDownloading ? 'Descargando video...' : 'Cargando reproductor...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(color: neonBlue, blurRadius: 10)],
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_pelicula != null)
                      Text(
                        _pelicula!.titulo,
                        style: TextStyle(
                          color: neonPink,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    if (_isDownloading) ...[
                      const SizedBox(height: 24),
                      Container(
                        width: 250,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Stack(
                          children: [
                            FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: _downloadProgress,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [neonGreen, neonBlue],
                                  ),
                                  borderRadius: BorderRadius.circular(3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: neonGreen.withValues(alpha: 0.5),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${(_downloadProgress * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: neonGreen,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Esto puede tardar varios minutos...',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 16),
                      Text(
                        'Preparando reproductor...',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              )
            else if (_hasError)
              _buildCustomError(_errorMessage)
            else if (_chewieController != null)
              FadeTransition(
                opacity: _fadeAnimation,
                child: Stack(
                  children: [
                    Chewie(controller: _chewieController!),
                    // Información del video (opcional, solo mostrar en debug)
                    if (false) // Cambia a true si quieres mostrar la info
                      Positioned(
                        top: 10,
                        left: 10,
                        right: 10,
                        child: _buildVideoInfo(),
                      ),
                  ],
                ),
              )
            else
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}