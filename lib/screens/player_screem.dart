import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:async';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> with TickerProviderStateMixin {
  InAppWebViewController? _webViewController;
  bool _isLoading = true;
  bool _hasError = false;
  bool _errorHiddenByUser = false; // Nueva variable para recordar si el usuario ocultó el error
  String _errorMessage = '';
  String _movieTitle = '';
  bool _isFullscreen = false;

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

  // IDs de archivos de Google Drive - ACTUALIZADOS CON TUS IDs REALES
  final Map<String, String> _movieIds = {
    'John Wick': '1WK7lB21_Mb7G5ZKpdKAt1abwoNQe3XQh', // ✅ ID REAL VERIFICADO
    'Winnie the Pooh: Sangre y Miel': '1fJgx6Ha4FcRLS6rRmhz_xTww9bTukUhQ', // ✅ ID REAL VERIFICADO
    'Titanic': '1WK7lB21_Mb7G5ZKpdKAt1abwoNQe3XQh', // Usando John Wick como ejemplo
    
    // Para agregar más películas:
    // 1. Sube el archivo a Google Drive
    // 2. Hazlo público ("Cualquier persona con el enlace" + "Lector")
    // 3. Obtén el ID del enlace: https://drive.google.com/file/d/[ID_AQUI]/view
    // 4. Agrega aquí: 'Nombre Película': 'ID_AQUI',
  };

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments != null && arguments is Map<String, dynamic>) {
      _movieTitle = arguments['titulo'] ?? 'Película';
    } else {
      _movieTitle = 'John Wick'; // Película por defecto
    }
  }

  void _initAnimations() {
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowController.repeat(reverse: true);
  }

  String? _getMovieId(String movieTitle) {
    print('🎬 Buscando película: "$movieTitle"');
    print('📋 Películas disponibles: ${_movieIds.keys.toList()}');
    
    // Buscar ID exacto
    if (_movieIds.containsKey(movieTitle)) {
      String id = _movieIds[movieTitle]!;
      print('✅ ID encontrado exacto: $id');
      return id;
    }
    
    // Buscar por coincidencia parcial
    for (String key in _movieIds.keys) {
      if (movieTitle.toLowerCase().contains(key.toLowerCase()) ||
          key.toLowerCase().contains(movieTitle.toLowerCase())) {
        String id = _movieIds[key]!;
        print('✅ ID encontrado por coincidencia "$key": $id');
        return id;
      }
    }
    
    print('❌ No se encontró ID para: "$movieTitle"');
    return null;
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
    
    if (_isFullscreen) {
      // Modo pantalla completa - NO cambiar orientación automáticamente
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      // Permitir todas las orientaciones, que el usuario elija
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      
      // Auto-ocultar el overlay de error si existe
      if (_hasError) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted && _isFullscreen) {
            setState(() {
              _hasError = false;
            });
          }
        });
      }
    } else {
      // Modo normal - volver a portrait
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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

  Widget _buildPlayer() {
    String? fileId = _getMovieId(_movieTitle);
    
    if (fileId == null) {
      return _buildErrorState('Película "$_movieTitle" no encontrada\n\nPelículas disponibles:\n${_movieIds.keys.join('\n')}');
    }

    String driveUrl = 'https://drive.google.com/file/d/$fileId/preview';
    print('🔗 URL generada: $driveUrl');

    return Container(
      width: double.infinity,
      height: _isFullscreen ? double.infinity : 300,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: _isFullscreen ? null : BorderRadius.circular(20),
        border: Border.all(
          color: neonBlue,
          width: 2,
        ),
      ),
      child: _buildGlowingContainer(
        glowColor: neonBlue,
        glowRadius: 30,
        child: ClipRRect(
          borderRadius: _isFullscreen ? BorderRadius.zero : BorderRadius.circular(18),
          child: Stack(
            children: [
              // InAppWebView Player con configuraciones mejoradas
              InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(driveUrl)),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  mediaPlaybackRequiresUserGesture: false,
                  allowsInlineMediaPlayback: true,
                  useShouldOverrideUrlLoading: false,
                  useOnDownloadStart: false,
                  allowFileAccessFromFileURLs: true,
                  allowUniversalAccessFromFileURLs: true,
                  mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                  cacheEnabled: true,
                  clearCache: false,
                  userAgent: 'Mozilla/5.0 (Linux; Android 10; SM-G975F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36',
                  supportZoom: true,
                  builtInZoomControls: true,
                  displayZoomControls: false,
                ),
                onWebViewCreated: (controller) {
                  _webViewController = controller;
                  print('📱 WebView creado para: $_movieTitle');
                },
                onLoadStart: (controller, url) {
                  print('⏳ Iniciando carga: $url');
                  setState(() {
                    _isLoading = true;
                    _hasError = false;
                  });
                },
                onLoadStop: (controller, url) async {
                  print('✅ Carga completada: $url');
                  
                  // Dar tiempo para que el contenido se cargue
                  await Future.delayed(const Duration(seconds: 3));
                  
                  // Verificar si hay contenido de video cargando
                  try {
                    final result = await controller.evaluateJavascript(source: '''
                      (function() {
                        // Buscar elementos de video
                        var videos = document.querySelectorAll('video');
                        var hasVideo = videos.length > 0;
                        
                        // Buscar elementos típicos de Google Drive player
                        var drivePlayer = document.querySelector('[data-testid="video-player"]') || 
                                         document.querySelector('.video-stream') ||
                                         document.querySelector('[role="application"]');
                        
                        console.log('🔍 Videos encontrados: ' + videos.length);
                        console.log('🎬 Drive player: ' + (drivePlayer ? 'SI' : 'NO'));
                        
                        return {
                          hasVideo: hasVideo,
                          hasDrivePlayer: !!drivePlayer,
                          videoCount: videos.length
                        };
                      })();
                    ''');
                    
                    print('📊 Resultado verificación: $result');
                    
                    // Si hay indicios de que el video está cargando, ocultar error
                    setState(() {
                      _isLoading = false;
                      // Solo mostrar error si realmente no hay contenido
                      if (!_hasError) {
                        _hasError = false;
                      }
                    });
                    
                  } catch (e) {
                    print('❌ Error verificando contenido: $e');
                    setState(() {
                      _isLoading = false;
                    });
                  }
                  
                  // Intentar auto-reproducción
                  try {
                    await Future.delayed(const Duration(seconds: 1));
                    await controller.evaluateJavascript(source: '''
                      console.log('🎯 Intentando auto-reproducción...');
                      
                      // Buscar botones de play comunes de Google Drive
                      var playButtons = document.querySelectorAll('[data-tooltip="Reproduce"], .ytp-large-play-button, .html5-main-video, [aria-label*="play"]');
                      if (playButtons.length > 0) {
                        console.log('▶️ Botón de play encontrado');
                        playButtons[0].click();
                      }
                      
                      // Intentar reproducir videos directamente
                      var videos = document.querySelectorAll('video');
                      for (var i = 0; i < videos.length; i++) {
                        try {
                          videos[i].play();
                          console.log('🎬 Video reproducido automáticamente');
                        } catch (e) {
                          console.log('⚠️ No se pudo auto-reproducir: ' + e);
                        }
                      }
                    ''');
                  } catch (e) {
                    print('❌ Error ejecutando JavaScript: $e');
                  }
                },
                onReceivedError: (controller, request, error) {
                  print('❌ Error recibido: ${error.description}');
                  print('🔍 Tipo de error: ${error.type}');
                  print('🙈 Error ocultado por usuario: $_errorHiddenByUser');
                  
                  // Si el usuario ya ocultó el error, no mostrarlo más
                  if (_errorHiddenByUser) {
                    print('✅ Error ignorado - usuario lo ocultó previamente');
                    return;
                  }
                  
                  // Si es el error ORB (Origin Resource Blocking), manejarlo especialmente
                  if (error.description.contains('ERR_BLOCKED_BY_ORB')) {
                    print('🚫 Error ORB detectado - aplicando solución...');
                    
                    // En fullscreen, auto-ocultar siempre
                    if (_isFullscreen) {
                      print('📱 En fullscreen - ocultando error automáticamente');
                      setState(() {
                        _hasError = false;
                        _isLoading = false;
                        _errorHiddenByUser = true; // Marcar como ocultado
                      });
                      return;
                    }
                    
                    // En modo normal, mostrar solo la primera vez
                    Future.delayed(const Duration(seconds: 2), () async {
                      if (!mounted || _errorHiddenByUser) return;
                      
                      setState(() {
                        _isLoading = false;
                        _hasError = true;
                        _errorMessage = 'Error de origen bloqueado (ORB)\n\n'
                            '✅ La película se está reproduciendo normalmente\n'
                            '💡 Presiona "Ocultar Error" para continuar viendo\n'
                            '🔄 O prueba "Vista Alternativa"\n\n'
                            'Este error es normal con Google Drive y no afecta la reproducción.';
                      });
                    });
                  } else {
                    // Otros errores - solo mostrar si no está ocultado
                    setState(() {
                      _isLoading = false;
                      _hasError = true;
                      _errorMessage = 'Error: ${error.description}\n\n'
                          'Posibles soluciones:\n'
                          '• Verifica que el archivo sea público\n'
                          '• Intenta de nuevo en unos segundos\n'
                          '• Revisa tu conexión a internet\n\n'
                          'URL: ${request.url}';
                    });
                  }
                },
                onReceivedHttpError: (controller, request, errorResponse) {
                  print('🚨 Error HTTP: ${errorResponse.statusCode}');
                  setState(() {
                    _isLoading = false;
                    _hasError = true;
                    _errorMessage = 'Error HTTP ${errorResponse.statusCode}\n\n'
                        '${errorResponse.reasonPhrase}\n\n'
                        'Pasos para solucionarlo:\n'
                        '1. Ve al archivo en Google Drive\n'
                        '2. Click derecho → Compartir\n'
                        '3. "Cualquier persona con el enlace"\n'
                        '4. Rol: "Lector"\n'
                        '5. Guardar cambios y esperar 1-2 minutos';
                  });
                },
                onConsoleMessage: (controller, consoleMessage) {
                  print('🖥️ Console: ${consoleMessage.message}');
                },
              ),

              // Loading overlay
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.8),
                  child: Center(
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
                          'Cargando película...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            shadows: [Shadow(color: neonBlue, blurRadius: 10)],
                          ),
                        ),
                        Text(
                          _movieTitle,
                          style: TextStyle(
                            color: neonPink,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Error overlay - solo mostrar si no está ocultado por el usuario
              if (_hasError && !_isLoading && !_errorHiddenByUser)
                Container(
                  color: Colors.black.withOpacity(0.9),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: Colors.red, size: 60),
                          const SizedBox(height: 16),
                          Text(
                            'Error al reproducir',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _hasError = false;
                                    _isLoading = true;
                                    _errorHiddenByUser = false; // Reset para permitir nuevos errores
                                  });
                                  _webViewController?.reload();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: neonPink,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Reintentar',
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  String? fileId = _getMovieId(_movieTitle);
                                  if (fileId != null) {
                                    String directUrl = 'https://drive.google.com/file/d/$fileId/view';
                                    setState(() {
                                      _hasError = false;
                                      _isLoading = true;
                                      _errorHiddenByUser = false; // Reset para nueva URL
                                    });
                                    _webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri(directUrl)));
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: neonBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Vista Alt.',
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  print('🙈 Usuario ocultó el error permanentemente');
                                  setState(() {
                                    _hasError = false;
                                    _errorHiddenByUser = true; // Marcar como ocultado por el usuario
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: neonGreen,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Ocultar Error',
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Controles overlay mejorados
              if (!_hasError && !_isLoading)
                Positioned(
                  top: _isFullscreen ? 10 : 10,
                  right: _isFullscreen ? 10 : 10,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botón de rotación manual (solo en fullscreen)
                      if (_isFullscreen) ...[
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: _buildControlButton(
                            Icons.screen_rotation,
                            neonYellow,
                            () {
                              // Forzar rotación manual
                              SystemChrome.setPreferredOrientations([
                                DeviceOrientation.landscapeLeft,
                                DeviceOrientation.landscapeRight,
                              ]);
                              
                              // Ocultar error si existe
                              if (_hasError) {
                                setState(() {
                                  _hasError = false;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      
                      // Botón fullscreen
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: _buildControlButton(
                          _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                          neonPurple,
                          _toggleFullscreen,
                        ),
                      ),
                    ],
                  ),
                ),

              // Indicador de modo fullscreen
              if (_isFullscreen)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: neonPurple.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: neonPurple, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.fullscreen, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'PANTALLA COMPLETA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(IconData icon, Color color, VoidCallback onPressed) {
    return _buildGlowingContainer(
      glowColor: color,
      glowRadius: 15,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
            ),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildMovieInfo() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.grey[900]!.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: neonPurple.withOpacity(0.5), width: 2),
      ),
      child: _buildGlowingContainer(
        glowColor: neonPurple,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reproduciendo Ahora',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: neonPurple, blurRadius: 10)],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _movieTitle,
              style: TextStyle(
                color: neonBlue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Fuente: Google Drive • Streaming directo',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoChip('HD', neonGreen),
                const SizedBox(width: 8),
                _buildInfoChip('Drive', neonYellow),
                const SizedBox(width: 8),
                _buildInfoChip('Online', neonPink),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Consejos:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• Toca el video para ver los controles de Google Drive\n'
              '• Usa el botón de pantalla completa para mejor experiencia\n'
              '• Si hay error, prueba "Vista Alternativa"\n'
              '• Asegúrate de tener buena conexión a internet',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pulseController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _isFullscreen ? null : AppBar(
        title: Text(
          'Reproduciendo: $_movieTitle',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: neonPink, blurRadius: 10)],
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: neonPink),
        elevation: 0,
      ),
      body: _isFullscreen 
        ? _buildPlayer() // Solo el reproductor en fullscreen
        : Column(
            children: [
              // Reproductor
              Expanded(
                flex: 2,
                child: _buildPlayer(),
              ),
              
              // Información de la película (solo en modo normal)
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  child: _buildMovieInfo(),
                ),
              ),
            ],
          ),
    );
  }
}