import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _database = FirebaseDatabase.instance.ref();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  
  // Animaciones para efectos neón
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  // Colores neón
  final Color neonPink = const Color(0xFFFF0080);
  final Color neonBlue = const Color(0xFF00FFFF);
  final Color neonGreen = const Color(0xFF00FF41);
  final Color neonPurple = const Color(0xFF8A2BE2);

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _glowController.repeat(reverse: true);
  }

  Future<String?> _findUsernameByEmail(String email) async {
    try {
      final snapshot = await _database.child('users').get();
      if (snapshot.exists) {
        final users = Map<String, dynamic>.from(snapshot.value as Map);
        for (final entry in users.entries) {
          final userData = Map<String, dynamic>.from(entry.value);
          if (userData['email'] == email) {
            return entry.key; // Retorna el username (que es la key)
          }
        }
      }
      return null;
    } catch (e) {
      print('Error buscando username: $e');
      return null;
    }
  }

  Future<void> _loginUser() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      _showError('Por favor completa todos los campos');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Autenticar con Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        // Buscar el username asociado al email
        final username = await _findUsernameByEmail(_emailController.text.trim());
        
        if (username != null) {
          // Actualizar el displayName del usuario con el username
          await userCredential.user!.updateDisplayName(username);
          
          if (!mounted) return;
          
          // Mostrar mensaje de bienvenida
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('¡Bienvenido de vuelta, $username! 🎬'),
              backgroundColor: neonGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );

          // Navegar a home después de un breve delay
          await Future.delayed(const Duration(milliseconds: 1000));
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          _showError('No se pudo encontrar la información del usuario');
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error al iniciar sesión';
      switch (e.code) {
        case 'user-not-found':
          errorMessage = '👤 Usuario no encontrado';
          break;
        case 'wrong-password':
          errorMessage = '🔒 Contraseña incorrecta';
          break;
        case 'invalid-email':
          errorMessage = '📧 Correo electrónico inválido';
          break;
        case 'user-disabled':
          errorMessage = '🚫 Usuario deshabilitado';
          break;
        case 'too-many-requests':
          errorMessage = '⚠️ Demasiados intentos. Intenta más tarde';
          break;
        case 'invalid-credential':
          errorMessage = '❌ Credenciales inválidas';
          break;
      }
      _showError(errorMessage);
    } catch (e) {
      _showError('Error inesperado: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  Widget _buildNeonTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    required Color glowColor,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return _buildGlowingContainer(
      glowColor: glowColor,
      glowRadius: 15,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: Colors.white70,
            shadows: [Shadow(color: glowColor, blurRadius: 5)],
          ),
          filled: true,
          fillColor: Colors.grey[900]?.withOpacity(0.8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: glowColor.withOpacity(0.5), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: glowColor.withOpacity(0.3), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: glowColor, width: 2),
          ),
          prefixIcon: Icon(prefixIcon, color: glowColor),
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
            child: Column(
              children: [
                const SizedBox(height: 60),
                
                // Logo con efecto neón
                _buildGlowingContainer(
                  glowColor: neonPink,
                  glowRadius: 30,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [neonPink, neonPurple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
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
                      Icons.movie_filter_rounded,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Título con efecto neón
                Text(
                  'CINE STREAM',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 4,
                    shadows: [
                      Shadow(color: neonBlue, blurRadius: 15),
                      Shadow(color: neonPink, blurRadius: 25),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  'Inicia sesión para continuar',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    shadows: [Shadow(color: neonGreen, blurRadius: 5)],
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // Campo de email
                _buildNeonTextField(
                  controller: _emailController,
                  labelText: "Correo Electrónico",
                  prefixIcon: Icons.email_outlined,
                  glowColor: neonBlue,
                  keyboardType: TextInputType.emailAddress,
                ),
                
                const SizedBox(height: 30),
                
                // Campo de contraseña
                _buildNeonTextField(
                  controller: _passwordController,
                  labelText: "Contraseña",
                  prefixIcon: Icons.lock_outline,
                  glowColor: neonGreen,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: neonGreen,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                
                const SizedBox(height: 50),
                
                // Botón de login estilo welcome
                Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: neonPink.withOpacity(0.8),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: neonPink.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _loginUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: neonPink,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'Iniciar Sesión',
                            style: TextStyle(
                              color: neonPink,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Texto simple para registro
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: Text(
                    '¿No tienes aún cuenta? Regístrate aquí',
                    style: TextStyle(
                      color: neonBlue.withOpacity(0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.underline,
                      decorationColor: neonBlue.withOpacity(0.6),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}