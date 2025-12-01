import 'package:Frutia/auth/PhoneVerificationPage.dart';
import 'package:Frutia/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_intl_phone_field/flutter_intl_phone_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:Frutia/auth/auth_check.dart';
import 'package:Frutia/auth/auth_service.dart';
import 'package:Frutia/auth/login_page.dart';
import 'package:Frutia/services/storage_service.dart';
import 'package:Frutia/utils/colors.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterPage({super.key, required this.showLoginPage});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  bool isObscure = true;
  bool isObscureConfirm = true;
  String _fullPhoneNumber = '';

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _authService = AuthService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '237230625824-uhg81q3ro2at559t31bnorjqrlooe3lr.apps.googleusercontent.com',
  );
  final _affiliateCodeController = TextEditingController();

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
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _affiliateCodeController.dispose();
    super.dispose();
  }

  Future<void> signInWithGoogle() async {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(FrutiaColors.accent))),
    );

    try {
      final bool success = await _authService.signInWithGoogle();

      if (!mounted) return;
      Navigator.pop(context);
      if (success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthCheckMain()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      showErrorSnackBar(l10n.googleSignInError);
    }
  }

  Future<void> signUp() async {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
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
        phone: _fullPhoneNumber,
        password: _passwordController.text,
        affiliateCode: _affiliateCodeController.text.trim(),
      );

      Navigator.of(context).pop();

      final userName = response['user']['name'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.welcomeMessage(userName)),
          backgroundColor: FrutiaColors.success,
        ),
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

  bool validateRegister() {
    final l10n = AppLocalizations.of(context)!;

    if (_passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _passwordController.text != _confirmPasswordController.text) {
      showErrorSnackBar(l10n.passwordsDoNotMatch);
      return false;
    }

    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _nameController.text.isEmpty) {
      showErrorSnackBar(l10n.completeAllRequiredFields);
      return false;
    }

    if (!_emailController.text.contains('@')) {
      showErrorSnackBar(l10n.invalidEmail);
      return false;
    }

    if (_nameController.text.contains(RegExp(r'[^a-zA-Z\s]'))) {
      showErrorSnackBar(l10n.nameOnlyLetters);
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
              Column(
                children: [
                  AppBar(
                    title: Text(l10n.registration),
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
                              height: size.height * 0.75,
                              width: size.width * 0.9,
                              padding: EdgeInsets.all(16.0),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 20),
                                    Text(
                                      l10n.welcomeCompleteRegistration,
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
                                          labelText: l10n.fullName,
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
                                          labelText: l10n.emailAddress,
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
                                    SlideTransition(
                                      position: _slideAnimation,
                                      child: IntlPhoneField(
                                        decoration: InputDecoration(
                                          labelText: l10n.phoneNumber,
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
                                        initialCountryCode: 'MX',
                                        onChanged: (phone) {
                                          setState(() {
                                            _fullPhoneNumber =
                                                phone.completeNumber;
                                          });
                                        },
                                        validator: (phoneNumber) {
                                          if (phoneNumber == null ||
                                              phoneNumber.number.isEmpty) {
                                            return l10n.pleaseEnterNumber;
                                          }
                                          if (!phoneNumber.isValidNumber()) {
                                            return l10n.invalidPhoneNumber;
                                          }
                                          return null;
                                        },
                                        style:
                                            TextStyle(color: Color(0xFF2D2D2D)),
                                        cursorColor: FrutiaColors.accent,
                                      ),
                                    ),
                                    SizedBox(height: 20),
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
                                          labelText: l10n.password,
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
                                          labelText: l10n.confirmPassword,
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
                                    SizedBox(height: 20),
                                    SlideTransition(
                                      position: _slideAnimation,
                                      child: TextField(
                                        cursorColor: FrutiaColors.accent,
                                        controller: _affiliateCodeController,
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
                                          labelText: l10n.affiliateCodeOptional,
                                          labelStyle: TextStyle(
                                              color: Color(0xFF2D2D2D)),
                                          prefixIcon: Icon(
                                            Icons.star_border_rounded,
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
                                    SizedBox(height: 40),
                                    SlideTransition(
                                      position: _slideAnimation,
                                      child: Container(
                                        width: size.width * 0.8,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            if (validateRegister()) {
                                              Navigator.push(
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
                                                        _fullPhoneNumber,
                                                    affiliateCode:
                                                        _affiliateCodeController
                                                            .text
                                                            .trim(),
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
                                            l10n.createAccount,
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
                                    SlideTransition(
                                      position: _slideAnimation,
                                      child: Container(
                                        width: size.width * 0.8,
                                        child: OutlinedButton(
                                          onPressed: () => signInWithGoogle(),
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
                                                l10n.signInWithGoogle,
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
