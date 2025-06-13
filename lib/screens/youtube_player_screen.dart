import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YouTubePlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String? movieTitle;

  const YouTubePlayerScreen({
    super.key, 
    required this.videoUrl,
    this.movieTitle,
  });

  @override
  _YouTubePlayerScreenState createState() => _YouTubePlayerScreenState();
}

class _YouTubePlayerScreenState extends State<YouTubePlayerScreen> with TickerProviderStateMixin {
  YoutubePlayerController? _controller;
  bool _isPlayerReady = false;
  bool _isFullScreen = false;
  late String _videoId;

  // Animaciones
  late AnimationController _glowController;
  late AnimationController _pulseController;
  late AnimationController _thumbnailController;
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _thumbnailAnimation;

  // Colores neón
  final Color neonPink = const Color(0xFFFF0080);
  final Color neonBlue = const Color(0xFF00FFFF);
  final Color neonGreen = const Color(0xFF00FF41);
  final Color neonPurple = const Color(0xFF8A2BE2);
  final Color neonYellow = const Color(0xFFFFFF00);

  @override
  void initState() {
    super.initState();
    _videoId = YoutubePlayer.convertUrlToId(widget.videoUrl) ?? '';
    _initAnimations();
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
    _thumbnailController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _thumbnailAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _thumbnailController, curve: Curves.elasticOut),
    );

    _glowController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
    _thumbnailController.forward();
  }

  void _initializePlayer() {
    _controller = YoutubePlayerController(
      initialVideoId: _videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        forceHD: true,
        enableCaption: true,
      ),
    );

    _controller!.addListener(() {
      if (_controller!.value.isFullScreen != _isFullScreen) {
        setState(() {
          _isFullScreen = _controller!.value.isFullScreen;
        });
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

  Widget _buildThumbnailScreen() {
    final thumbnailUrl = YoutubePlayer.getThumbnail(videoId: _videoId);
    
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            neonPurple.withOpacity(0.1),
            Colors.black,
            Colors.black,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header con información
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    widget.movieTitle ?? 'Tráiler',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(color: neonPink, blurRadius: 15),
                        Shadow(color: neonBlue, blurRadius: 25),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toca para reproducir el tráiler',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                      shadows: [Shadow(color: neonBlue, blurRadius: 5)],
                    ),
                  ),
                ],
              ),
            ),

            // Thumbnail principal con botón de play
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _thumbnailAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _thumbnailAnimation.value,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _initializePlayer();
                            _isPlayerReady = true;
                          });
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.width * 0.9 * 9/16,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: neonBlue, width: 3),
                          ),
                          child: _buildGlowingContainer(
                            glowColor: neonBlue,
                            glowRadius: 30,
                            child: Stack(
                              children: [
                                // Thumbnail de YouTube
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(17),
                                  child: Image.network(
                                    thumbnailUrl,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              neonPurple.withOpacity(0.3),
                                              neonBlue.withOpacity(0.2),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(17),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.movie,
                                            size: 80,
                                            color: Colors.white,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                // Overlay con gradiente
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.3),
                                        Colors.transparent,
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(17),
                                  ),
                                ),

                                // Botón de play central
                                Center(
                                  child: AnimatedBuilder(
                                    animation: _pulseAnimation,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _pulseAnimation.value,
                                        child: _buildGlowingContainer(
                                          glowColor: neonPink,
                                          glowRadius: 35,
                                          child: Container(
                                            width: 100,
                                            height: 100,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [neonPink, neonPurple],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.white, width: 3),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: neonPink.withOpacity(0.5),
                                                  blurRadius: 25,
                                                  spreadRadius: 5,
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.play_arrow,
                                              color: Colors.white,
                                              size: 50,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                // Indicador de calidad
                                Positioned(
                                  top: 15,
                                  right: 15,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [neonYellow, Colors.orange],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: neonYellow.withOpacity(0.5),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: const Text(
                                      'HD',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),

                                // Indicador de YouTube
                                Positioned(
                                  bottom: 15,
                                  left: 15,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.red.withOpacity(0.5),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: const Text(
                                      'YouTube',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Información adicional
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildInfoChip(Icons.hd, 'Calidad HD', neonBlue),
                      _buildInfoChip(Icons.volume_up, 'Audio', neonGreen),
                      _buildInfoChip(Icons.subtitles, 'Subtítulos', neonYellow),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '¡Disfruta del tráiler en alta calidad!',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return _buildGlowingContainer(
      glowColor: color,
      glowRadius: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerScreen() {
    return YoutubePlayerBuilder(
      onEnterFullScreen: () {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      },
      onExitFullScreen: () {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      },
      player: YoutubePlayer(
        controller: _controller!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: neonPink,
        progressColors: ProgressBarColors(
          playedColor: neonPink,
          handleColor: neonBlue,
          bufferedColor: Colors.white.withOpacity(0.3),
          backgroundColor: Colors.white.withOpacity(0.1),
        ),
        bottomActions: [
          const SizedBox(width: 14.0),
          CurrentPosition(),
          const SizedBox(width: 8.0),
          ProgressBar(
            isExpanded: true,
            colors: ProgressBarColors(
              playedColor: neonPink,
              handleColor: neonBlue,
              bufferedColor: Colors.white.withOpacity(0.3),
              backgroundColor: Colors.white.withOpacity(0.1),
            ),
          ),
          RemainingDuration(),
          const PlaybackSpeedButton(),
          FullScreenButton(),
        ],
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: _isFullScreen ? null : AppBar(
            title: Text(
              widget.movieTitle ?? 'Tráiler',
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
          body: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [
                  neonPurple.withOpacity(0.1),
                  Colors.black,
                  Colors.black,
                ],
              ),
            ),
            child: Column(
              children: [
                // Reproductor
                _buildGlowingContainer(
                  glowColor: neonBlue,
                  glowRadius: 25,
                  child: Container(
                    margin: _isFullScreen ? EdgeInsets.zero : const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: _isFullScreen ? null : BorderRadius.circular(20),
                      border: _isFullScreen ? null : Border.all(color: neonBlue, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: _isFullScreen ? BorderRadius.zero : BorderRadius.circular(18),
                      child: player,
                    ),
                  ),
                ),

                // Información adicional (solo en modo normal)
                if (!_isFullScreen)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            'Reproduciendo Tráiler',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              shadows: [Shadow(color: neonGreen, blurRadius: 10)],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildInfoChip(Icons.play_circle, 'Reproduciendo', neonGreen),
                              _buildInfoChip(Icons.hd, 'Calidad HD', neonBlue),
                              _buildInfoChip(Icons.fullscreen, 'Pantalla completa', neonPurple),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            '• Usa los controles del reproductor para navegar\n• Toca el botón de pantalla completa para mejor experiencia\n• Disfruta del tráiler en alta calidad',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _glowController.dispose();
    _pulseController.dispose();
    _thumbnailController.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: !_isPlayerReady && !_isFullScreen ? AppBar(
        title: Text(
          widget.movieTitle ?? 'Tráiler',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: neonPink, blurRadius: 10)],
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: neonPink),
        elevation: 0,
      ) : null,
      body: _isPlayerReady ? _buildPlayerScreen() : _buildThumbnailScreen(),
    );
  }
}