import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:user_auth_crudd10/auth/auth_check.dart';
import 'package:user_auth_crudd10/auth/auth_service.dart';
import 'package:user_auth_crudd10/auth/login_page.dart';
import 'package:user_auth_crudd10/services/storage_service.dart';
import 'package:user_auth_crudd10/utils/colors.dart'; // Import FrutiaColors

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterPage({super.key, required this.showLoginPage});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  bool isObscure = true;

  // Text Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  int _weight = 70; // Default weight
  int _height = 175; // Default height
  final _authService = AuthService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '237230625824-uhg81q3ro2at559t31bnorjqrlooe3lr.apps.googleusercontent.com',
  );

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

  void _incrementWeight() {
    setState(() {
      _weight++;
    });
  }

  void _decrementWeight() {
    setState(() {
      if (_weight > 0) _weight--;
    });
  }

  void _incrementHeight() {
    setState(() {
      _height++;
    });
  }

  void _decrementHeight() {
    setState(() {
      if (_height > 0) _height--;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  // Google Sign-Up Logic
  Future<bool> signUpWithGoogle() async {
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
      showErrorSnackBar('Error durante el registro con Google: $e');
      return false;
    }
  }

  Future signUp() async {
    if (!validateRegister()) return;
    try {
      showDialog(
        context: context,
        builder: (_) => Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(FrutiaColors.accent),
          ),
        ),
      );

      final emailExists =
          await _authService.checkEmailExists(_emailController.text);
      if (emailExists) {
        Navigator.pop(context);
        showErrorSnackBar(
            "Este correo electrónico ya está registrado, agrega otro.");
        _emailController.clear();
        return;
      }

      final success = await _authService.register(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      Navigator.pop(context);

      if (success) {
        final token = await StorageService().getToken();
        print("Token after registration: $token");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AuthCheckMain()),
        );
      } else {
        print("Registration failed");
      }
    } catch (e) {
      Navigator.pop(context);
      showErrorSnackBar(e.toString());
    }
  }

  bool validateRegister() {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _ageController.text.isEmpty) {
      showErrorSnackBar("Por favor complete todos los campos obligatorios");
      return false;
    }

    if (!_emailController.text.contains('@')) {
      showErrorSnackBar("Correo electrónico inválido");
      return false;
    }
    if (_nameController.text.contains(RegExp(r'[^a-zA-Z\s]'))) {
      showErrorSnackBar("El nombre solo debe contener letras");
      return false;
    }
    if (_passwordController.text.length < 6) {
      showErrorSnackBar("La contraseña debe tener al menos 6 caracteres");
      return false;
    }
    if (int.tryParse(_ageController.text) == null ||
        int.parse(_ageController.text) <= 0) {
      showErrorSnackBar("Por favor ingrese una edad válida");
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                LoginPage(showLoginPage: widget.showLoginPage),
          ),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor:
            FrutiaColors.primaryBackground, // Solid white background
        appBar: AppBar(
          title: const Text("Registro"),
          titleTextStyle: TextStyle(
            color: Color(0xFF2D2D2D),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: FrutiaColors.accent),
            onPressed: widget.showLoginPage,
          ),
        ),
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
                        height: size.height *
                            0.8, // Increased height to accommodate more fields
                        width: size.width * 0.9,
                        padding: EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 20),
                              // Welcome Text
                              Text(
                                "Bienvenido, Completa tu registro.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lato(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: FrutiaColors.accent,
                                ),
                              ),
                              SizedBox(height: 30),
                              // Name TextField
                              SlideTransition(
                                position: _slideAnimation,
                                child: TextField(
                                  cursorColor: FrutiaColors.accent,
                                  controller: _nameController,
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
                                    labelText: "Nombre completo",
                                    labelStyle:
                                        TextStyle(color: Color(0xFF2D2D2D)),
                                    prefixIcon: Icon(
                                      Icons.person,
                                      color: FrutiaColors.accent,
                                    ),
                                    filled: true,
                                    fillColor: FrutiaColors.primaryBackground,
                                  ),
                                  style: TextStyle(color: Color(0xFF2D2D2D)),
                                ),
                              ),
                              SizedBox(height: 20),
                              // Age Field
                              SlideTransition(
                                position: _slideAnimation,
                                child: TextField(
                                  cursorColor: FrutiaColors.accent,
                                  controller: _ageController,
                                  keyboardType: TextInputType.number,
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
                                    labelText: 'Edad',
                                    labelStyle:
                                        TextStyle(color: Color(0xFF2D2D2D)),
                                    prefixIcon: Icon(Icons.calendar_today,
                                        color: FrutiaColors.accent),
                                    filled: true,
                                    fillColor: FrutiaColors.primaryBackground,
                                  ),
                                  style: TextStyle(color: Color(0xFF2D2D2D)),
                                ),
                              ),
                              SizedBox(height: 20),
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
                                    labelText: "Correo electrónico",
                                    labelStyle:
                                        TextStyle(color: Color(0xFF2D2D2D)),
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
                                    labelStyle:
                                        TextStyle(color: Color(0xFF2D2D2D)),
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
                              // Weight Field
                              SlideTransition(
                                position: _slideAnimation,
                                child: Row(
                                  children: [
                                    Icon(Icons.fitness_center,
                                        color: FrutiaColors.accent),
                                    SizedBox(width: 10),
                                    Text(
                                      'Peso',
                                      style: TextStyle(
                                        color: Color(0xFF2D2D2D),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        margin: EdgeInsets.only(left: 20),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color:
                                                  FrutiaColors.secondaryText),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.remove,
                                                  color: FrutiaColors.accent),
                                              onPressed: _decrementWeight,
                                            ),
                                            Text(
                                              '$_weight kg',
                                              style: TextStyle(
                                                color: Color(0xFF2D2D2D),
                                                fontSize: 16,
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.add,
                                                  color: FrutiaColors.accent),
                                              onPressed: _incrementWeight,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                              // Height Field
                              SlideTransition(
                                position: _slideAnimation,
                                child: Row(
                                  children: [
                                    Icon(Icons.straighten,
                                        color: FrutiaColors.accent),
                                    SizedBox(width: 10),
                                    Text(
                                      'Altura',
                                      style: TextStyle(
                                        color: Color(0xFF2D2D2D),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        margin: EdgeInsets.only(left: 20),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color:
                                                  FrutiaColors.secondaryText),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.remove,
                                                  color: FrutiaColors.accent),
                                              onPressed: _decrementHeight,
                                            ),
                                            Text(
                                              '$_height cm',
                                              style: TextStyle(
                                                color: Color(0xFF2D2D2D),
                                                fontSize: 16,
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.add,
                                                  color: FrutiaColors.accent),
                                              onPressed: _incrementHeight,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 40),
                              // Sign Up Button
                              SlideTransition(
                                position: _slideAnimation,
                                child: Container(
                                  width: size.width * 0.8,
                                  child: ElevatedButton(
                                    onPressed: signUp,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: FrutiaColors.accent,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 8,
                                    ),
                                    child: Text(
                                      "Crea tu cuenta",
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
                              // Sign Up with Google Button
                              SlideTransition(
                                position: _slideAnimation,
                                child: Container(
                                  width: size.width * 0.8,
                                  child: OutlinedButton(
                                    onPressed: signUpWithGoogle,
                                    style: OutlinedButton.styleFrom(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16),
                                      side: BorderSide(
                                          color: FrutiaColors.accent,
                                          width: 1.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
