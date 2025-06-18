import 'package:flutter/material.dart';
import 'dart:math' as math;

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _fadeController;
  
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
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
  }

  void _initAnimations() {
    // Animación de brillo
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Animación de pulso
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Animación de rotación sutil
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    // Animación de fade in
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    // Iniciar animaciones
    _glowController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
    _fadeController.forward();
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
                color: glowColor.withOpacity(0.4 * _glowAnimation.value),
                blurRadius: glowRadius * _glowAnimation.value,
                spreadRadius: 3,
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }

  Widget _buildNeonButton({
    required String text,
    required Color primaryColor,
    required Color secondaryColor,
    required VoidCallback onPressed,
    required IconData icon,
    bool isPrimary = false,
  }) {
    return _buildGlowingContainer(
      glowColor: primaryColor,
      glowRadius: isPrimary ? 20 : 15,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isPrimary ? _pulseAnimation.value : 1.0,
            child: Container(
              width: isPrimary ? double.infinity : 250,
              height: isPrimary ? 45 : 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withOpacity(0.2),
                    secondaryColor.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primaryColor, width: 1.5),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: onPressed,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: isPrimary ? 18 : 16),
                    const SizedBox(width: 8),
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: isPrimary ? 14 : 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: isPrimary ? 1.5 : 1,
                        color: primaryColor,
                        shadows: [Shadow(color: primaryColor, blurRadius: 6)],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value * 0.1, // Rotación muy sutil
          child: _buildGlowingContainer(
            glowColor: neonPink,
            glowRadius: 40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    neonPink.withOpacity(0.8),
                    neonPurple.withOpacity(0.6),
                    neonBlue.withOpacity(0.4),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: neonPink.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [neonBlue, neonPurple], // CAMBIO AQUÍ: cambié neonGreen por neonPurple
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: Container(
                          width: 140,
                          height: 140,
                          padding: const EdgeInsets.all(8),
                          child: Image.asset(
                            'assets/images/fondo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              // Widget de respaldo en caso de que no se encuentre la imagen
                              return const Icon(
                                Icons.movie_creation_outlined,
                                size: 80,
                                color: Colors.white,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNeonText(String text, {
    required double fontSize,
    required Color color,
    FontWeight fontWeight = FontWeight.normal,
    double letterSpacing = 0,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        color: Colors.white,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        shadows: [
          Shadow(color: color, blurRadius: 15),
          Shadow(color: color.withOpacity(0.5), blurRadius: 30),
          Shadow(color: Colors.white, blurRadius: 5),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildFloatingParticles() {
    return Stack(
      children: List.generate(12, (index) {
        final colors = [neonPink, neonBlue, neonGreen, neonPurple, neonYellow, neonOrange];
        final color = colors[index % colors.length];
        
        return AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            final offset = Offset(
              200 * math.cos(_rotationAnimation.value + index * 0.5),
              150 * math.sin(_rotationAnimation.value + index * 0.3),
            );
            
            return Positioned(
              left: MediaQuery.of(context).size.width / 2 + offset.dx,
              top: MediaQuery.of(context).size.height / 2 + offset.dy,
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.8),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
        child: Stack(
          children: [
            // Partículas flotantes de fondo
            _buildFloatingParticles(),
            
            // Contenido principal
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height - 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),
                        
                        // Logo animado
                        _buildAnimatedLogo(),
                        
                        const SizedBox(height: 40),
                        
                        // Título principal
                        _buildNeonText(
                          'CINE STREAM',
                          fontSize: 42,
                          color: neonPink,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Subtítulo
                        _buildNeonText(
                          'SoArlFlix',
                          fontSize: 24,
                          color: neonBlue,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Eslogan - SIN RECUADRO, SOLO TEXTO NEÓN
                        _buildNeonText(
                          '"Donde los estrenos cobran vida"',
                          fontSize: 16,
                          color: neonGreen,
                          fontWeight: FontWeight.w400,
                        ),
                        
                        const SizedBox(height: 60),
                        
                        // Botón principal - Iniciar Sesión
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: _buildNeonButton(
                            text: 'INICIAR SESIÓN',
                            primaryColor: neonPink,
                            secondaryColor: neonPurple,
                            icon: Icons.login,
                            onPressed: () => Navigator.pushNamed(context, '/login'),
                            isPrimary: true,
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Botón secundario - Registrarse
                        _buildNeonButton(
                          text: 'REGISTRARSE',
                          primaryColor: neonBlue,
                          secondaryColor: neonGreen,
                          icon: Icons.person_add,
                          onPressed: () => Navigator.pushNamed(context, '/register'),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Información adicional
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 32),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: neonYellow.withOpacity(0.3), width: 1),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildFeatureItem(Icons.hd, 'HD Quality', neonBlue),
                                  _buildFeatureItem(Icons.security, 'Seguro', neonGreen),
                                  _buildFeatureItem(Icons.access_time, '24/7', neonPink),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildGlowingContainer(
          glowColor: color,
          glowRadius: 6,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Icon(icon, color: color, size: 14),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 8,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: color, blurRadius: 3)],
          ),
        ),
      ],
    );
  }
}