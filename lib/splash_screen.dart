import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'dart:math';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
    with TickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isVideoInitialized = false;
  bool _hasNavigated = false;
  Timer? _fallbackTimer;
  
  // Controladores de animación
  late AnimationController _dotsController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  
  // Animaciones
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Inicializar controladores de animación
    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    // Configurar animaciones
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    // Iniciar animación de entrada
    _scaleController.forward();
    
    _initializeVideo();
    
    // Timer de seguridad
    _fallbackTimer = Timer(const Duration(seconds: 4), () {
      if (!_hasNavigated) {
        _navigateToHome();
      }
    });
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset('assets/videos/splash_streamzy.mp4');
      await _controller!.initialize();
      
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
        
        _controller!.addListener(_videoListener);
        _controller!.play();
      }
    } catch (e) {
      print('Error loading video: $e');
      Timer(const Duration(seconds: 3), () {
        _navigateToHome();
      });
    }
  }

  void _videoListener() {
    if (_controller != null && 
        _controller!.value.position >= _controller!.value.duration) {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    if (!_hasNavigated && mounted) {
      _hasNavigated = true;
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _dotsController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    super.dispose();
  }

  // Icono de play moderno con efectos
  Widget _buildModernPlayIcon() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.red.withOpacity(0.3),
                  Colors.orange.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  blurRadius: 50,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Icono principal de play
                Icon(
                  Icons.play_arrow,
                  color: Colors.red,
                  size: 80,
                ),
                // Efecto de brillo
                Positioned(
                  top: 10,
                  right: 15,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.6),
                          blurRadius: 8,
                          spreadRadius: 2,
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

  // Texto con efecto neón rojo/naranja
  Widget _buildNeonText() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Text(
          'SoArFlix',
          style: TextStyle(
            color: Colors.white,
            fontSize: 52,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
            shadows: [
              // Sombra principal
              Shadow(
                offset: const Offset(0, 0),
                blurRadius: 20,
                color: Colors.red.withOpacity(0.8),
              ),
              // Efecto neón exterior
              Shadow(
                offset: const Offset(0, 0),
                blurRadius: 40,
                color: Colors.orange.withOpacity(0.6),
              ),
              // Efecto neón interior
              Shadow(
                offset: const Offset(0, 0),
                blurRadius: 10,
                color: Colors.white.withOpacity(0.9),
              ),
              // Resplandor lejano
              Shadow(
                offset: const Offset(0, 0),
                blurRadius: 60,
                color: Colors.red.withOpacity(0.4),
              ),
            ],
          ),
        );
      },
    );
  }

  // Puntos de carga con efecto neón rojo/naranja
  Widget _buildNeonLoadingDots() {
    return AnimatedBuilder(
      animation: _dotsController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            double delay = index * 0.2;
            double animationValue = (_dotsController.value - delay).clamp(0.0, 1.0);
            double scale = (sin(animationValue * pi * 2) * 0.5 + 0.5).clamp(0.2, 1.0);
            
            // Colores rojo/naranja que cambian
            Color dotColor = Color.lerp(
              Colors.red,
              Colors.orange,
              sin(animationValue * pi + index) * 0.5 + 0.5,
            )!;
            
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: dotColor.withOpacity(0.8),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                      BoxShadow(
                        color: dotColor.withOpacity(0.4),
                        blurRadius: 25,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  // Partículas flotantes de fondo rojas/naranjas
  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Stack(
          children: List.generate(6, (index) {
            double offset = sin(_pulseController.value * 2 * pi + index) * 100;
            double opacity = (sin(_pulseController.value * pi + index) * 0.3 + 0.1).clamp(0.1, 0.4);
            
            return Positioned(
              left: 50 + index * 60 + offset,
              top: 100 + index * 120 + offset * 0.5,
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: index % 2 == 0 ? Colors.red : Colors.orange,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (index % 2 == 0 ? Colors.red : Colors.orange)
                            .withOpacity(0.6),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A), // Negro más profundo
      body: Stack(
        children: [
          // Gradiente de fondo rojo/negro
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  Color(0xFF2E0A0A), // Rojo oscuro
                  Color(0xFF1A0000), // Rojo muy oscuro
                  Color(0xFF000000), // Negro profundo
                ],
              ),
            ),
          ),
          
          // Partículas flotantes
          _buildFloatingParticles(),
          
          // Video de fondo (si está disponible)
          if (_isVideoInitialized && _controller != null)
            Positioned.fill(
              child: Opacity(
                opacity: 0.3,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller!.value.size.width,
                    height: _controller!.value.size.height,
                    child: VideoPlayer(_controller!),
                  ),
                ),
              ),
            ),
          
          // Contenido principal
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icono de play moderno
                  _buildModernPlayIcon(),
                  
                  const SizedBox(height: 30),
                  
                  // Texto con efecto neón
                  _buildNeonText(),
                  
                  const SizedBox(height: 50),
                  
                  // Puntos de carga neón
                  _buildNeonLoadingDots(),
                ],
              ),
            ),
          ),
          
          // Botón saltar estilizado
          Positioned(
            top: 50,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red.withOpacity(0.5)),
                gradient: LinearGradient(
                  colors: [
                    Colors.red.withOpacity(0.1),
                    Colors.orange.withOpacity(0.1),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: TextButton(
                onPressed: _navigateToHome,
                child: const Text(
                  'Saltar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}