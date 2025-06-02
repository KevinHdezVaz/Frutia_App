import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:user_auth_crudd10/auth/auth_check.dart';
import 'package:user_auth_crudd10/auth/auth_service.dart';
import 'package:user_auth_crudd10/auth/forget_pass_page.dart';
import 'package:user_auth_crudd10/utils/colors.dart'; // Import FrutiaColors

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

  // Google Sign-In Logic
  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final response = await _authService.loginWithGoogle(googleAuth.idToken);

      if (response) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AuthCheckMain()),
        );
      }
      return response;
    } catch (e) {
      showErrorSnackBar('Error durante el login con Google: $e');
      return false;
    }
  }

  // Email/Password Sign-In Logic
  Future signIn() async {
    if (!validateLogin()) return;

    try {
      showDialog(
        context: context,
        builder: (context) => Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(FrutiaColors.accent),
          ),
        ),
      );

      final success = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      Navigator.pop(context); // Close loader

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AuthCheckMain()),
        );
      } else {
        showErrorSnackBar('Credenciales inválidas');
      }
    } catch (e) {
      showErrorSnackBar(e.toString());
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
          style: TextStyle(color: FrutiaColors.primaryBackground),
        ),
        backgroundColor: FrutiaColors.accent,
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
      backgroundColor: FrutiaColors.primaryBackground, // Solid white background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  child: Card(
                    elevation: 20,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      height:
                          size.height * 0.8, // Fixed height at 80% of screen
                      width: size.width * 0.9,
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo
                          Image.asset(
                            'assets/icons/logoapp.webp',
                            width: 80,
                            height: 80,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.local_dining,
                                size: 80,
                                color: FrutiaColors.accent,
                              );
                            },
                          ),
                          SizedBox(height: 20),
                          // Welcome Text
                          Text(
                            "Ingresa tu correo y contraseña o crea una cuenta.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF2D2D2D),
                            ),
                          ),
                          SizedBox(height: 40),
                          // Email TextField
                          SlideTransition(
                            position: _slideAnimation,
                            child: TextField(
                              cursorColor: FrutiaColors.accent,
                              controller: _emailController,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: FrutiaColors.secondaryText,
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: FrutiaColors.accent,
                                    width: 1.5,
                                  ),
                                ),
                                labelText: "Correo",
                                labelStyle: TextStyle(color: Color(0xFF2D2D2D)),
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: FrutiaColors.accent,
                                ),
                                filled: true,
                                fillColor: FrutiaColors.primaryBackground,
                              ),
                              style: TextStyle(color: Color(0xFF2D2D2D)),
                            ),
                          ),
                          SizedBox(height: 20),
                          // Password TextField
                          SlideTransition(
                            position: _slideAnimation,
                            child: TextField(
                              cursorColor: FrutiaColors.accent,
                              controller: _passwordController,
                              obscureText: isObscure,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: FrutiaColors.secondaryText,
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: FrutiaColors.accent,
                                    width: 1.5,
                                  ),
                                ),
                                labelText: "Contraseña",
                                labelStyle: TextStyle(color: Color(0xFF2D2D2D)),
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: FrutiaColors.accent,
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
                                    color: FrutiaColors.accent,
                                  ),
                                ),
                                filled: true,
                                fillColor: FrutiaColors.primaryBackground,
                              ),
                              style: TextStyle(color: Color(0xFF2D2D2D)),
                            ),
                          ),
                          SizedBox(height: 20),
                          // Remember Me and Forget Password Row
                          SlideTransition(
                            position: _slideAnimation,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      activeColor: FrutiaColors.accent,
                                      checkColor:
                                          FrutiaColors.primaryBackground,
                                    ),
                                    Text(
                                      'Recordarme',
                                      style: TextStyle(
                                        fontSize: 16,
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
                                    style: TextStyle(
                                      color: FrutiaColors.accent,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      decoration: TextDecoration.underline,
                                      decorationColor: FrutiaColors.accent,
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
                                  backgroundColor: FrutiaColors.accent,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 8,
                                ),
                                child: Text(
                                  "Entrar",
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: FrutiaColors.primaryBackground,
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
                                onPressed: signInWithGoogle,
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  side: BorderSide(
                                      color: FrutiaColors.accent, width: 1.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/icons/google.png',
                                      height: 24,
                                      width: 24,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Icon(
                                          Icons.account_circle,
                                          color: FrutiaColors.accent,
                                          size: 24,
                                        );
                                      },
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Unirse con Google",
                                      style: GoogleFonts.inter(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: FrutiaColors.accent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Create Account Link
              FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: TextButton(
                    onPressed: widget.showLoginPage,
                    child: Text(
                      "Crea tu cuenta",
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: FrutiaColors.accent,
                        decoration: TextDecoration.underline,
                        decorationColor: FrutiaColors.accent,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
