import 'package:Frutia/auth/PhoneVerificationPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_intl_phone_field/flutter_intl_phone_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:Frutia/auth/auth_check.dart';
import 'package:Frutia/auth/auth_service.dart';
import 'package:Frutia/auth/login_page.dart';
import 'package:Frutia/services/storage_service.dart';
import 'package:Frutia/utils/colors.dart'; // Import FrutiaColors

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterPage({super.key, required this.showLoginPage});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  bool isObscure = true;
  bool isObscureConfirm = true; // Estado separado para el campo de confirmación
  String _fullPhoneNumber = ''; // <-- AÑADIR ESTA VARIABLE

  // Text Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController =
      TextEditingController(); // Nuevo controlador
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController(); // <-- AÑADIR ESTE

  final _ageController = TextEditingController();
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

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose(); // Dispose del nuevo controlador
    _phoneController.dispose(); // <-- AÑADIR ESTE
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
    showDialog(
      context: context,
      barrierDismissible:
          false, // El usuario no puede cerrar el diálogo tocando fuera
      builder: (_) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(FrutiaColors.accent),
        ),
      ),
    );

    try {
      final response = await _authService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
      );

      Navigator.of(context).pop();

      // 3. Manejar la respuesta exitosa.
      final userName = response['user']['name'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Bienvenido, $userName! Registro exitoso.'),
          backgroundColor: FrutiaColors.success,
        ),
      );
    } on AuthException catch (e) {
      // 4. Manejar errores de autenticación específicos (ej. email ya existe).
      // El mensaje 'e.message' viene directamente de nuestro backend.
      Navigator.of(context)
          .pop(); // Asegúrate de cerrar el diálogo también en caso de error.

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      // 5. Manejar cualquier otro error inesperado (ej. no hay internet).
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Ocurrió un error inesperado. Por favor, inténtalo de nuevo.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  bool validateRegister() {
    // Priorizar validación de contraseñas si no están vacías
    if (_passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _passwordController.text != _confirmPasswordController.text) {
      showErrorSnackBar("Las contraseñas no coinciden");
      return false;
    }

    // Verificar campos vacíos (solo nombre, correo, contraseña y confirmar contraseña)
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _nameController.text.isEmpty) {
      showErrorSnackBar("Por favor complete todos los campos obligatorios");
      return false;
    }

    // Otras validaciones relevantes
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
              Column(
                children: [
                  AppBar(
                    title: const Text("Registro"),
                    titleTextStyle: TextStyle(
                      color: Color(0xFF2D2D2D),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios,
                          color: Color(0xFFE63946)),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                LoginPage(showLoginPage: widget.showLoginPage),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 20.0),
                          child: Card(
                            elevation: 20,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Container(
                              height: size.height *
                                  0.75, // Ajustado para incluir AppBar
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
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: FrutiaColors.secondaryText,
                                              width: 1.0,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: FrutiaColors.accent,
                                              width: 1.5,
                                            ),
                                          ),
                                          labelText: "Nombre completo",
                                          labelStyle: TextStyle(
                                              color: Color(0xFF2D2D2D)),
                                          prefixIcon: Icon(
                                            Icons.person,
                                            color: FrutiaColors.accent,
                                          ),
                                          filled: true,
                                          fillColor:
                                              FrutiaColors.primaryBackground,
                                        ),
                                        style:
                                            TextStyle(color: Color(0xFF2D2D2D)),
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
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: FrutiaColors.secondaryText,
                                              width: 1.0,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: FrutiaColors.accent,
                                              width: 1.5,
                                            ),
                                          ),
                                          labelText: "Correo electrónico",
                                          labelStyle: TextStyle(
                                              color: Color(0xFF2D2D2D)),
                                          prefixIcon: Icon(
                                            Icons.email_outlined,
                                            color: FrutiaColors.accent,
                                          ),
                                          filled: true,
                                          fillColor:
                                              FrutiaColors.primaryBackground,
                                        ),
                                        style:
                                            TextStyle(color: Color(0xFF2D2D2D)),
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    // Phone Field con selector de país
                                    SlideTransition(
                                      position: _slideAnimation,
                                      child: IntlPhoneField(
                                        decoration: InputDecoration(
                                          labelText: 'Número de teléfono',
                                          // Mantenemos el estilo de tu app
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: FrutiaColors.secondaryText,
                                              width: 1.0,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: FrutiaColors.accent,
                                              width: 1.5,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor:
                                              FrutiaColors.primaryBackground,
                                        ),
                                        initialCountryCode:
                                            'MX', // El país que aparecerá por defecto (México)
                                        onChanged: (phone) {
                                          // Cada vez que el usuario cambia el número o el país,
                                          // guardamos el número completo en formato E.164
                                          setState(() {
                                            _fullPhoneNumber =
                                                phone.completeNumber;
                                          });
                                        },
                                          validator: (phoneNumber) {
        if (phoneNumber == null || phoneNumber.number.isEmpty) {
          return 'Por favor ingresa un número';
        }
        // La librería puede validar si el número es plausiblemente correcto en longitud
        if (!phoneNumber.isValidNumber()) { 
          return 'El número de teléfono no es válido para el país seleccionado.';
        }
        return null; // Retorna null si es válido
      },
                                        // Estilo del texto y cursor
                                        style:
                                            TextStyle(color: Color(0xFF2D2D2D)),
                                        cursorColor: FrutiaColors.accent,
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
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: FrutiaColors.secondaryText,
                                              width: 1.0,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: FrutiaColors.accent,
                                              width: 1.5,
                                            ),
                                          ),
                                          labelText: "Contraseña",
                                          labelStyle: TextStyle(
                                              color: Color(0xFF2D2D2D)),
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
                                          fillColor:
                                              FrutiaColors.primaryBackground,
                                        ),
                                        style:
                                            TextStyle(color: Color(0xFF2D2D2D)),
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    // Confirm Password TextField
                                    SlideTransition(
                                      position: _slideAnimation,
                                      child: TextField(
                                        cursorColor: FrutiaColors.accent,
                                        controller: _confirmPasswordController,
                                        obscureText: isObscureConfirm,
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: FrutiaColors.secondaryText,
                                              width: 1.0,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: FrutiaColors.accent,
                                              width: 1.5,
                                            ),
                                          ),
                                          labelText: "Confirmar Contraseña",
                                          labelStyle: TextStyle(
                                              color: Color(0xFF2D2D2D)),
                                          prefixIcon: Icon(
                                            Icons.lock_outline,
                                            color: FrutiaColors.accent,
                                          ),
                                          suffixIcon: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                isObscureConfirm =
                                                    !isObscureConfirm;
                                              });
                                            },
                                            icon: Icon(
                                              isObscureConfirm
                                                  ? Icons.visibility_off
                                                  : Icons.visibility,
                                              color: FrutiaColors.accent,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor:
                                              FrutiaColors.primaryBackground,
                                        ),
                                        style:
                                            TextStyle(color: Color(0xFF2D2D2D)),
                                      ),
                                    ),
                                    SizedBox(height: 40),
                                    // Sign Up Button
                                    SlideTransition(
                                      position: _slideAnimation,
                                      child: Container(
                                        width: size.width * 0.8,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            if (validateRegister()) {
                                              // Si la validación es correcta, navega y pasa los datos
                                              Navigator.push(
                                                // Usamos push para que pueda regresar si hay un error
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      PhoneVerificationPage(
                                                    name: _nameController.text
                                                        .trim(),
                                                    email: _emailController.text
                                                        .trim(),
                                                    password:
                                                        _passwordController
                                                            .text,
                                                    phoneNumber:
                                                        _fullPhoneNumber, // La variable del intl_phone_field
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                FrutiaColors.accent,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            elevation: 8,
                                          ),
                                          child: Text(
                                            "Crea tu cuenta",
                                            style: GoogleFonts.inter(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: FrutiaColors
                                                  .primaryBackground,
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
                                          onPressed: () => {},
                                          style: OutlinedButton.styleFrom(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 16),
                                            side: BorderSide(
                                                color: FrutiaColors.accent,
                                                width: 1.5),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
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
                                                errorBuilder: (context, error,
                                                    stackTrace) {
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
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
