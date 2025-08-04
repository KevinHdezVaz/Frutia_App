import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Frutia/auth/auth_check.dart';
import 'package:Frutia/auth/auth_service.dart';
import 'package:Frutia/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

class PhoneVerificationPage extends StatefulWidget {
  final String name;
  final String email;
  final String password;
  final String phoneNumber;
  final String affiliateCode; // <-- AÑADE ESTA LÍNEA

  const PhoneVerificationPage({
    super.key,
    required this.name,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.affiliateCode, // <-- AÑADE ESTA LÍNEA
  });

  @override
  State<PhoneVerificationPage> createState() => _PhoneVerificationPageState();
}

class _PhoneVerificationPageState extends State<PhoneVerificationPage>
    with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  final TextEditingController _smsController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();

  String? _verificationId;
  bool _isLoading = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.5, curve: Curves.easeInOut)),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.3, 0.8, curve: Curves.easeOut)),
    );
    _controller.forward();
    _sendSmsCode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _smsController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  Future<void> _sendSmsCode() async {
    setState(() => _isLoading = true);
    await _auth.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        setState(() => _isLoading = true);
        _smsController.setText(credential.smsCode ?? "");
        await _verifyCodeAndRegister(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error de Firebase: ${e.message}"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        // ----- CAMBIO AQUÍ -----
        // Muestra un SnackBar de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Código de verificación enviado con éxito."),
            backgroundColor: Colors.green, // Color verde para éxito
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        setState(() {
          _verificationId = verificationId;
          _isLoading = false;
        });
        // -----------------------
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<void> _verifyAndRegisterWithSmsCode(String smsCode) async {
    if (_verificationId == null) return;
    setState(() => _isLoading = true);

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );
    await _verifyCodeAndRegister(credential);
  }

  Future<void> _verifyCodeAndRegister(PhoneAuthCredential credential) async {
    if (!_isLoading) setState(() => _isLoading = true);

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
        affiliateCode: widget.affiliateCode, // <-- AÑADE ESTA LÍNEA
      );
      print(
          "✅ Registro en backend exitoso. Usuario: ${response['user']['name']}");

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthCheckMain()),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: GoogleFonts.lato(
          fontSize: 22, color: const Color.fromARGB(255, 45, 45, 45)),
      decoration: BoxDecoration(
        color: FrutiaColors.primaryBackground.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FrutiaColors.secondaryText),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: FrutiaColors.accent, width: 2),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: FrutiaColors.accent.withOpacity(0.5),
        border: Border.all(color: FrutiaColors.accent),
      ),
    );

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
                    titleTextStyle: const TextStyle(
                      color: Color(0xFF2D2D2D),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios,
                          color: Color(0xFFE63946)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Expanded(
                    child: Center(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 20.0),
                          child: Card(
                            elevation: 20,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Container(
                              height: size.height * 0.5,
                              width: size.width * 0.9,
                              padding: const EdgeInsets.all(16.0),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 20),
                                    Text(
                                      "Enviamos un código de verificación a ${widget.phoneNumber}",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.lato(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: FrutiaColors.accent,
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    SlideTransition(
                                      position: _slideAnimation,
                                      child: Pinput(
                                        length: 6,
                                        controller: _smsController,
                                        focusNode: _pinFocusNode,
                                        defaultPinTheme: defaultPinTheme,
                                        focusedPinTheme: focusedPinTheme,
                                        submittedPinTheme: submittedPinTheme,
                                        pinputAutovalidateMode:
                                            PinputAutovalidateMode.onSubmit,
                                        showCursor: true,
                                        onCompleted: (pin) async {
                                          await _verifyAndRegisterWithSmsCode(
                                              pin);
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 40),
                                    if (_isLoading)
                                      const CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                FrutiaColors.accent),
                                      )
                                    else
                                      SlideTransition(
                                        position: _slideAnimation,
                                        child: Container(
                                          width: size.width * 0.8,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              if (_smsController.text.length ==
                                                  6) {
                                                _verifyAndRegisterWithSmsCode(
                                                    _smsController.text);
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  FrutiaColors.accent,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              elevation: 8,
                                            ),
                                            child: Text(
                                              "Verificar y Crear Cuenta",
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
