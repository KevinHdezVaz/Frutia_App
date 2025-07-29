import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Frutia/auth/auth_check.dart';
import 'package:Frutia/auth/auth_service.dart';
import 'package:Frutia/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class PhoneVerificationPage extends StatefulWidget {
  final String name;
  final String email;
  final String password;
  final String phoneNumber;

  const PhoneVerificationPage({
    super.key,
    required this.name,
    required this.email,
    required this.password,
    required this.phoneNumber,
  });

  @override
  State<PhoneVerificationPage> createState() => _PhoneVerificationPageState();
}

class _PhoneVerificationPageState extends State<PhoneVerificationPage> with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  final TextEditingController _smsController = TextEditingController();
  
  String? _verificationId;
  bool _isLoading = false;
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
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset(0, 0)).animate(
      CurvedAnimation(
          parent: _controller,
          curve: Interval(0.3, 0.8, curve: Curves.easeOut)),
    );
    _controller.forward();
    _sendSmsCode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _smsController.dispose();
    super.dispose();
  }

  Future<void> _sendSmsCode() async {
    setState(() => _isLoading = true);
    await _auth.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        setState(() => _isLoading = true);
        await _verifyCodeAndRegister(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error de Firebase: ${e.message}"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _isLoading = false;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<void> _verifyCodeAndRegister(PhoneAuthCredential credential) async {
    setState(() => _isLoading = true);

    try {
      print("Verificando credencial con Firebase...");
      await _auth.signInWithCredential(credential);
      print("✅ Credencial de Firebase verificada con éxito.");

      print("Intentando registrar en el backend de Laravel...");
      final response = await _authService.register(
        name: widget.name,
        email: widget.email,
        password: widget.password,
        phone: widget.phoneNumber,
      );
      print("✅ Registro en backend exitoso. Usuario: ${response['user']['name']}");

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => AuthCheckMain()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      print("🔥 ERROR DE FIREBASE: ${e.code} - ${e.message}");
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error de Firebase: ${e.message}"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } on AuthException catch (e) {
      print("🔥 ERROR DEL BACKEND: ${e.message}");
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error de registro: ${e.message}"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      print("🔥 ERROR INESPERADO: ${e.toString()}");
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Ocurrió un error inesperado: ${e.toString()}"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
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
              Color(0xFFFFD1B3),
              Color(0xFFFF6F61),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
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
                        image: AssetImage('assets/images/fondoAppFrutia.webp'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  AppBar(
                    title: const Text("Verificar Teléfono"),
                    titleTextStyle: TextStyle(
                      color: Color(0xFF2D2D2D),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFE63946)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                       SizedBox(height: 40),
                  Expanded(
                    child: Center(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                          child: Card(
                            elevation: 20,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Container(
                              height: size.height * 0.5,
                              width: size.width * 0.9,
                              padding: EdgeInsets.all(16.0),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 20),
                                    Text(
                                      "Enviamos un código de verificación a ${widget.phoneNumber}",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.lato(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: FrutiaColors.accent,
                                      ),
                                    ),
                                    SizedBox(height: 30),
                                    SlideTransition(
                                      position: _slideAnimation,
                                      child: TextField(
                                        cursorColor: FrutiaColors.accent,
                                        controller: _smsController,
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
                                          labelText: "Código de 6 dígitos",
                                          labelStyle: TextStyle(color: Color(0xFF2D2D2D)),
                                          prefixIcon: Icon(
                                            Icons.sms,
                                            color: FrutiaColors.accent,
                                          ),
                                          filled: true,
                                          fillColor: FrutiaColors.primaryBackground,
                                        ),
                                        keyboardType: TextInputType.number,
                                        style: TextStyle(color: Color(0xFF2D2D2D)),
                                      ),
                                    ),
                                    SizedBox(height: 40),
                                    if (_isLoading)
                                      const CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(FrutiaColors.accent),
                                      )
                                    else
                                      SlideTransition(
                                        position: _slideAnimation,
                                        child: Container(
                                          width: size.width * 0.8,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              if (_verificationId != null) {
                                                setState(() => _isLoading = true);
                                                final credential = PhoneAuthProvider.credential(
                                                  verificationId: _verificationId!,
                                                  smsCode: _smsController.text.trim(),
                                                );
                                                _verifyCodeAndRegister(credential);
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: FrutiaColors.accent,
                                              padding: EdgeInsets.symmetric(vertical: 16),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              elevation: 8,
                                            ),
                                            child: Text(
                                              "Verificar y Crear Cuenta",
                                              style: GoogleFonts.inter(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: FrutiaColors.primaryBackground,
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