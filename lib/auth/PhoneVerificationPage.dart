import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Frutia/auth/auth_check.dart';
import 'package:Frutia/auth/auth_service.dart';
import 'package:Frutia/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'dart:ui'; // Para BackdropFilter

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

class _PhoneVerificationPageState extends State<PhoneVerificationPage> {
  // --- Dependencias y Controladores ---
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  final TextEditingController _smsController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();

  // --- Estado de la UI ---
  bool _isLoading = false;
  String? _verificationId;
  int? _resendToken;

  // --- Lógica del Temporizador ---
  Timer? _timer;
  int _start = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _sendSmsCode();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _smsController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  // --- Lógica del Temporizador ---
  void startTimer() {
    setState(() => _canResend = false);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _canResend = true;
          timer.cancel();
        });
      } else {
        setState(() => _start--);
      }
    });
  }

  void _resetTimer() {
    _start = 60;
    startTimer();
  }

  // --- Lógica de Autenticación de Firebase ---
  Future<void> _sendSmsCode() async {
    setState(() => _isLoading = true);
    await _auth.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      forceResendingToken: _resendToken,
      verificationCompleted: (PhoneAuthCredential credential) async {
        _smsController.setText(credential.smsCode ?? "");
        await _verifyCodeAndRegister(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() => _isLoading = false);
        _showErrorSnackBar("Error: ${e.message}");
      },
      codeSent: (String verificationId, int? resendToken) {
        _showSuccessSnackBar("Código de verificación enviado.");
        setState(() {
          _verificationId = verificationId;
          _resendToken = resendToken;
          _isLoading = false;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // No es necesario hacer nada aquí para esta implementación.
      },
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
      await _auth.signInWithCredential(credential);
      final response = await _authService.register(
        name: widget.name,
        email: widget.email,
        password: widget.password,
        phone: widget.phoneNumber,
      );

      if (mounted) {
        _showSuccessSnackBar("¡Cuenta creada con éxito! Bienvenido ${response['user']['name']}.");
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthCheckMain()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      _showErrorSnackBar("Código de verificación incorrecto.");
    } on AuthException catch (e) {
      _showErrorSnackBar("Error de registro: ${e.message}");
    } catch (e) {
      _showErrorSnackBar("Ocurrió un error inesperado.");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- Widgets de UI y Helpers ---
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: GoogleFonts.lato(fontSize: 22, color: const Color.fromARGB(255, 45, 45, 45)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FrutiaColors.secondaryText.withOpacity(0.5)),
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Verificar Teléfono"),
        titleTextStyle: GoogleFonts.lato(
          color: const Color(0xFF2D2D2D),
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFE63946)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFD1B3), Color(0xFFFF6F61)],
          ),
        ),
        child: SafeArea(
          child: Align( // <-- CAMBIO AQUÍ: Reemplacé Center por Align
            alignment: const Alignment(0.0, -0.5), // <-- Mueve el contenido un 10% hacia arriba
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: _buildGlassCard(defaultPinTheme),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard(PinTheme defaultPinTheme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(25.0),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/fondoAppFrutia.webp', height: 120),
              const SizedBox(height: 20),
              Text(
                "Verificación de Código",
                style: GoogleFonts.lato(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                "Ingresa el código de 6 dígitos enviado a\n${widget.phoneNumber}",
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 16,
                  color: Colors.black.withOpacity(0.9),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),
              Pinput(
                length: 6,
                controller: _smsController,
                focusNode: _pinFocusNode,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    border: Border.all(color: FrutiaColors.accent, width: 2),
                  ),
                ),
                submittedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    color: FrutiaColors.accent.withOpacity(0.2),
                  ),
                ),
                onCompleted: (pin) => _verifyAndRegisterWithSmsCode(pin),
              ),
              const SizedBox(height: 30),
              if (_isLoading)
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_smsController.text.length == 6) {
                        _verifyAndRegisterWithSmsCode(_smsController.text);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FrutiaColors.accent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              const SizedBox(height: 20),
              _buildResendCodeWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResendCodeWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "¿No recibiste el código?",
          style: GoogleFonts.lato(color: Colors.white.withOpacity(0.8)),
        ),
        TextButton(
          onPressed: _canResend
              ? () {
                  _resetTimer();
                  _sendSmsCode();
                }
              : null,
          child: Text(
            _canResend ? "Reenviar ahora" : "Reenviar en $_start s",
            style: GoogleFonts.lato(
              fontWeight: FontWeight.bold,
              color: _canResend ? Colors.white : Colors.white.withOpacity(0.5),
            ),
          ),
        ),
      ],
    );
  }
}
