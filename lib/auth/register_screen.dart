import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String _selectedGenre = 'Acción';
  
  // Animaciones para efectos neón
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  // Colores neón
  final Color neonPink = const Color(0xFFFF0080);
  final Color neonBlue = const Color(0xFF00FFFF);
  final Color neonGreen = const Color(0xFF00FF41);
  final Color neonPurple = const Color(0xFF8A2BE2);
  final Color neonOrange = const Color(0xFFFF6600);
  
  final List<String> _genres = [
    'Acción',
    'Comedia',
    'Drama',
    'Terror',
    'Romance',
    'Ciencia Ficción',
    'Aventura',
    'Animación',
    'Documental',
    'Infantil'
  ];

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

  // Verificar si el username ya existe
  Future<bool> _isUsernameAvailable(String username) async {
    try {
      final snapshot = await FirebaseDatabase.instance
          .ref('users')
          .child(username)
          .get();
      return !snapshot.exists;
    } catch (e) {
      return false;
    }
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Verificar si el username está disponible
      final isAvailable = await _isUsernameAvailable(_usernameController.text.trim());
      if (!isAvailable) {
        if (mounted) {
          _showError('El nombre de usuario ya está en uso');
        }
        return;
      }

      // Crear usuario en Firebase Auth
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        // Guardar datos usando el username como ID único
        await FirebaseDatabase.instance
            .ref('users')
            .child(_usernameController.text.trim())
            .set({
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'age': int.parse(_ageController.text.trim()),
          'favoriteGenre': _selectedGenre,
          'uid': userCredential.user!.uid,
          'createdAt': ServerValue.timestamp,
        });

        // Actualizar el displayName del usuario con el username
        await userCredential.user!.updateDisplayName(_usernameController.text.trim());
        
        if (!mounted) return;
        
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Bienvenido ${_usernameController.text.trim()}! 🎬'),
            backgroundColor: neonGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 1000));
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error desconocido';
      switch (e.code) {
        case 'weak-password':
          errorMessage = '🔒 La contraseña es muy débil';
          break;
        case 'email-already-in-use':
          errorMessage = '📧 El correo ya está registrado';
          break;
        case 'invalid-email':
          errorMessage = '❌ Correo electrónico inválido';
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
    String? Function(String?)? validator,
  }) {
    return _buildGlowingContainer(
      glowColor: glowColor,
      glowRadius: 15,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          prefixIcon: Icon(prefixIcon, color: glowColor),
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildNeonDropdown() {
    return _buildGlowingContainer(
      glowColor: neonOrange,
      glowRadius: 15,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900]?.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: neonOrange.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: neonOrange.withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 1,
            ),
          ],
        ),
        child: DropdownButtonFormField<String>(
          value: _selectedGenre,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          dropdownColor: Colors.grey[900],
          isExpanded: true,
          icon: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: neonOrange,
              size: 28,
            ),
          ),
          decoration: InputDecoration(
            labelText: "Género Favorito",
            labelStyle: TextStyle(
              color: Colors.white70,
              shadows: [Shadow(color: neonOrange, blurRadius: 5)],
            ),
            filled: false,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.movie_filter_rounded,
                color: neonOrange,
                size: 24,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
          selectedItemBuilder: (BuildContext context) {
            return _genres.map<Widget>((String genre) {
              return Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 8),
                child: Row(
                  children: [
                    Icon(
                      _getGenreIcon(genre),
                      color: neonOrange,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        genre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList();
          },
          items: _genres.map((genre) {
            return DropdownMenuItem(
              value: genre,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Row(
                  children: [
                    Icon(
                      _getGenreIcon(genre),
                      color: neonOrange.withOpacity(0.8),
                      size: 22,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        genre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedGenre = value!);
          },
        ),
      ),
    );
  }

  IconData _getGenreIcon(String genre) {
    switch (genre) {
      case 'Acción':
        return Icons.local_fire_department_rounded;
      case 'Comedia':
        return Icons.sentiment_very_satisfied_rounded;
      case 'Drama':
        return Icons.theater_comedy_rounded;
      case 'Terror':
        return Icons.psychology_rounded;
      case 'Romance':
        return Icons.favorite_rounded;
      case 'Ciencia Ficción':
        return Icons.rocket_launch_rounded;
      case 'Aventura':
        return Icons.explore_rounded;
      case 'Animación':
        return Icons.animation_rounded;
      case 'Documental':
        return Icons.article_rounded;
      case 'Infantil':
        return Icons.child_friendly_rounded;
      default:
        return Icons.movie_rounded;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: neonBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'REGISTRO',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            shadows: [
              Shadow(color: neonPink, blurRadius: 10),
            ],
          ),
        ),
        centerTitle: true,
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Icono con efecto neón
                  _buildGlowingContainer(
                    glowColor: neonPink,
                    glowRadius: 25,
                    child: Container(
                      padding: const EdgeInsets.all(16),
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
                            blurRadius: 15,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1_rounded,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Título
                  Text(
                    'Únete a CINE STREAM',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(color: neonBlue, blurRadius: 10),
                        Shadow(color: neonPink, blurRadius: 15),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Campo de username
                  _buildNeonTextField(
                    controller: _usernameController,
                    labelText: "Nombre de Usuario",
                    prefixIcon: Icons.person,
                    glowColor: neonPink,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa un nombre de usuario';
                      }
                      if (value.length < 3) {
                        return 'El usuario debe tener al menos 3 caracteres';
                      }
                      if (value.contains(' ')) {
                        return 'El usuario no puede contener espacios';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 25),
                  
                  // Campo de email
                  _buildNeonTextField(
                    controller: _emailController,
                    labelText: "Correo Electrónico",
                    prefixIcon: Icons.email_outlined,
                    glowColor: neonBlue,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu correo';
                      }
                      if (!value.contains('@')) {
                        return 'Ingresa un correo válido';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 25),
                  
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa una contraseña';
                      }
                      if (value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 25),
                  
                  // Campo de edad
                  _buildNeonTextField(
                    controller: _ageController,
                    labelText: "Edad",
                    prefixIcon: Icons.cake,
                    glowColor: neonPurple,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu edad';
                      }
                      final age = int.tryParse(value);
                      if (age == null || age < 13 || age > 100) {
                        return 'Ingresa una edad válida (13-100)';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 25),
                  
                  // Dropdown de género
                  _buildNeonDropdown(),
                  
                  const SizedBox(height: 40),
                  
                  // Botón de registro estilo welcome
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
                      onPressed: _isLoading ? null : _registerUser,
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
                              'Registrar',
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
                  
                  // Texto para login
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      '¿Ya tienes cuenta? Inicia sesión aquí',
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
      ),
    );
  }
}