import 'package:Frutia/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:Frutia/auth/auth_check.dart';
import 'package:Frutia/auth/auth_service.dart';
import 'package:Frutia/auth/forget_pass_page.dart';
import 'package:Frutia/utils/colors.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const LoginPage({super.key, required this.showLoginPage});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  bool isRemember = false;
  bool isObscure = true;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '237230625824-uhg81q3ro2at559t31bnorjqrlooe3lr.apps.googleusercontent.com',
  );
  final _authService = AuthService();

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

  Future<void> _requestNotificationPermissions() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final bool hasPermission = await OneSignal.Notifications.permission;

      if (!hasPermission) {
        final bool permissionGranted =
            await OneSignal.Notifications.requestPermission(true);

        if (permissionGranted) {
          print("Permisos de notificación concedidos");
        } else {
          print("Permisos de notificación denegados");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.notificationsDisabled)),
          );
        }
      }
    } catch (e) {
      print("Error al verificar permisos de notificación: $e");
    }
  }

  Future<void> signIn() async {
    final l10n = AppLocalizations.of(context)!;

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

      Navigator.of(context).pop();

      await _requestNotificationPermissions();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => AuthCheckMain()),
      );
    } on AuthException catch (e) {
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.unexpectedError),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  bool validateLogin() {
    final l10n = AppLocalizations.of(context)!;

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      showErrorSnackBar(l10n.completeAllFields);
      return false;
    }

    if (!_emailController.text.contains('@')) {
      showErrorSnackBar(l10n.invalidEmail);
      return false;
    }

    if (_passwordController.text.length < 6) {
      showErrorSnackBar(l10n.passwordMinLength);
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
    final l10n = AppLocalizations.of(context)!;
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
                        image: AssetImage('assets/images/fruta22.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
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
                                l10n.welcomeToFrutia,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lato(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D2D2D),
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                l10n.enterCredentials,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lato(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF2D2D2D).withOpacity(0.7),
                                ),
                              ),
                              SizedBox(height: 40),
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
                                    labelText: l10n.email,
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
                                    labelText: l10n.password,
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
                                          l10n.rememberMe,
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
                                        l10n.forgotPassword,
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
                                      l10n.signIn,
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
                                              color: FrutiaColors.accent,
                                            ),
                                          ),
                                        );

                                        final success = await _authService
                                            .signInWithGoogle();

                                        if (!mounted) return;
                                        Navigator.pop(context);

                                        if (success) {
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    AuthCheckMain()),
                                          );
                                        }
                                      } catch (e) {
                                        if (!mounted) return;
                                        Navigator.pop(context);
                                        showErrorSnackBar(
                                            l10n.googleSignInError);
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
                                          l10n.signInWithGoogle,
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
                              TextButton(
                                onPressed: widget.showLoginPage,
                                child: Text(
                                  l10n.createAccount,
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
