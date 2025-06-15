import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:Frutia/auth/auth_check.dart';
import 'package:Frutia/auth/auth_service.dart';
import 'package:Frutia/auth/forget_pass_page.dart';
import 'package:Frutia/utils/colors.dart'; // Import FrutiaColors

class LoginPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const LoginPage({super.key, required this.showLoginPage});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  bool isRemember = false;
  bool isObscure = true;

  // Text Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '237230625824-uhg81q3ro2at559t31bnorjqrlooe3lr.apps.googleusercontent.com',
  );
  final _authService = AuthService();

  // Animations
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: Interval(0.0, 0.5, curve: Curves.easeInOut)),
    );
    _slideAnimation =
        Tween<Offset>(begin: Offset(0, 0.3), end: Offset(0, 0)).animate(
      CurvedAnimation(
          parent: _controller,
          curve: Interval(0.3, 0.8, curve: Curves.easeOut)),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Email/Password Sign-In Logic
  Future<void> signIn() async {
    // if (!validateLogin()) return; // Se asume que la validación se hace antes.

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE63946)),
        ),
      ),
    );

    try {
      final response = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      Navigator.of(context).pop(); // Cierra el diálogo de carga

      // Navega a la pantalla principal si el login es exitoso
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => AuthCheckMain()),
      );
    } on AuthException catch (e) {
      // Maneja errores específicos de la API (ej. credenciales inválidas)
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      // Maneja otros errores (ej. sin conexión a internet)
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ocurrió un error inesperado. Inténtalo de nuevo.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  bool validateLogin() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      showErrorSnackBar("Por favor complete todos los campos");
      return false;
    }

    if (!_emailController.text.contains('@')) {
      showErrorSnackBar("Correo electrónico inválido");
      return false;
    }

    if (_passwordController.text.length < 6) {
      showErrorSnackBar("La contraseña debe tener al menos 6 caracteres");
      return false;
    }

    return true;
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFFE63946),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFD1B3), // Naranja suave
              Color(0xFFFF6F61), // Rojo cálido
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Imagen de la fruta en la parte superior
              Positioned(
                top: size.height * 0.05,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    height: 150,
                    width: 150,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/fruta22.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),

              // Contenido principal
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      color: Colors.white.withOpacity(0.9),
                      child: Container(
                        width: size.width * 0.9,
                        padding: EdgeInsets.all(24.0),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 20),

                              Text(
                                "Bienvenido a Frutia",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lato(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D2D2D),
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Ingresa tus credenciales para continuar",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lato(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF2D2D2D).withOpacity(0.7),
                                ),
                              ),
                              SizedBox(height: 40),
                              // Email TextField
                              SlideTransition(
                                position: _slideAnimation,
                                child: TextField(
                                  cursorColor: Color(0xFFE63946),
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color:
                                            Color(0xFFF4A261).withOpacity(0.5),
                                        width: 1.0,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: Color(0xFFE63946),
                                        width: 2.0,
                                      ),
                                    ),
                                    labelText: "Correo",
                                    labelStyle: GoogleFonts.lato(
                                      color: Color(0xFF2D2D2D).withOpacity(0.7),
                                      fontSize: 16,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
                                      color: Color(0xFFE63946),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.8),
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 18, horizontal: 20),
                                  ),
                                  style: GoogleFonts.lato(
                                    color: Color(0xFF2D2D2D),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              // Password TextField
                              SlideTransition(
                                position: _slideAnimation,
                                child: TextField(
                                  cursorColor: Color(0xFFE63946),
                                  controller: _passwordController,
                                  obscureText: isObscure,
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color:
                                            Color(0xFFF4A261).withOpacity(0.5),
                                        width: 1.0,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                        color: Color(0xFFE63946),
                                        width: 2.0,
                                      ),
                                    ),
                                    labelText: "Contraseña",
                                    labelStyle: GoogleFonts.lato(
                                      color: Color(0xFF2D2D2D).withOpacity(0.7),
                                      fontSize: 16,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.lock_outline,
                                      color: Color(0xFFE63946),
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          isObscure = !isObscure;
                                        });
                                      },
                                      icon: Icon(
                                        isObscure
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Color(0xFFE63946),
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.8),
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 18, horizontal: 20),
                                  ),
                                  style: GoogleFonts.lato(
                                    color: Color(0xFF2D2D2D),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              // Remember Me and Forget Password Row
                              SlideTransition(
                                position: _slideAnimation,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: isRemember,
                                          onChanged: (value) {
                                            setState(() {
                                              isRemember = value ?? false;
                                            });
                                          },
                                          activeColor: Color(0xFFE63946),
                                          checkColor: Colors.white,
                                        ),
                                        Text(
                                          'Recordarme',
                                          style: GoogleFonts.lato(
                                            fontSize: 14,
                                            color: Color(0xFF2D2D2D),
                                          ),
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ForgetPassPage(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        "Olvidé mi contraseña",
                                        style: GoogleFonts.lato(
                                          color: Color(0xFFE63946),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          decoration: TextDecoration.underline,
                                          decorationColor: Color(0xFFE63946),
                                          decorationThickness: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 40),
                              // Sign In Button
                              SlideTransition(
                                position: _slideAnimation,
                                child: Container(
                                  width: size.width * 0.8,
                                  child: ElevatedButton(
                                    onPressed: signIn,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFFE63946),
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      elevation: 5,
                                    ),
                                    child: Text(
                                      "Entrar",
                                      style: GoogleFonts.lato(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              // Sign In with Google Button
                              SlideTransition(
                                position: _slideAnimation,
                                child: Container(
                                  width: size.width * 0.8,
                                  child: OutlinedButton(
                                    onPressed: () async {
                                      try {
                                        showDialog(
                                          context: context,
                                          builder: (_) => Center(
                                            child: CircularProgressIndicator(
                                              color: FrutiaColors.primary,
                                            ),
                                          ),
                                        );

                                        final success = await _authService
                                            .signInWithGoogle();

                                        if (!mounted) return;
                                        Navigator.pop(
                                            context); // Cierra el diálogo de carga
                                      } catch (e) {
                                        if (!mounted) return;
                                        Navigator.pop(
                                            context); // Cierra el diálogo de carga
                                      }
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16),
                                      side: BorderSide(
                                          color: Color(0xFFE63946), width: 1.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/icons/google.png',
                                          height: 24,
                                          width: 24,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Icon(
                                              Icons.account_circle,
                                              color: Color(0xFFE63946),
                                              size: 24,
                                            );
                                          },
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          "Unirse con Google",
                                          style: GoogleFonts.lato(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFE63946),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              // Create Account Link
                              TextButton(
                                onPressed: widget.showLoginPage,
                                child: Text(
                                  "Crea tu cuenta",
                                  style: GoogleFonts.lato(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFFE63946),
                                    decoration: TextDecoration.underline,
                                    decorationColor: Color(0xFFE63946),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
