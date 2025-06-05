import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_auth_crudd10/auth/auth_check.dart';
import 'package:vibration/vibration.dart';

import 'constants2.dart';

class OnboardingScreenThree extends StatelessWidget {
  final PageController pageController;
  OnboardingScreenThree({required this.pageController});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode(BuildContext context) {
      return Theme.of(context).brightness == Brightness.dark;
    }

    Color fondo = isDarkMode(context) ? Colors.white : Colors.black;

    final sizeReference = 700.0;

    double getResponsiveText(double size) {
      final mediaQuery = MediaQuery.of(context);
      final longestSide = mediaQuery.size.longestSide;
      return size * sizeReference / longestSide;
    }

    Size size = MediaQuery.of(context).size;

    Widget FeatureItem(String text) {
      return Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/fondoPantalla1.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              // Imagen de la fruta en la parte superior
              Positioned(
                top: size.height * 0.10,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    height: 250,
                    width: 350,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/frutastop.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),

              // Contenido principal centrado (título y lista)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 200),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        "Recuerda",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontSize: 28,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FeatureItem(
                                  "❌ Los planes genéricos no funcionan. Cada cuerpo es distinto."),
                              FeatureItem(
                                  "🚫 No existen soluciones mágicas ni “tés milagrosos”."),
                              FeatureItem(
                                  "💸 Tu presupuesto importa, y debería ser parte del plan."),
                              FeatureItem(
                                  "🍽️ Tu comida debe gustarte, no estresarte."),
                              FeatureItem(
                                  "🤝 Estamos acá para darte un plan real, inteligente y hecho para ti."),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Indicadores de página
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPageIndicator(false),
                    const SizedBox(width: 8),
                    _buildPageIndicator(false),
                    const SizedBox(width: 8),
                    _buildPageIndicator(true),
                    const SizedBox(width: 8),
                    _buildPageIndicator(false),
                  ],
                ),
              ),

              // Botón de siguiente
              Positioned(
                bottom: 30,
                right: 30,
                child: FloatingActionButton(
                  onPressed: () async {
                    // Trigger vibration on button press
                    if (await Vibration.hasVibrator() ?? false) {
                      Vibration.vibrate(duration: 50); // Short vibration
                    }
                    pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  backgroundColor: Colors.white,
                  child: const Icon(
                    Icons.navigate_next_rounded,
                    color: Colors.black,
                    size: 30,
                  ),
                ),
              ),

              // Botón "Omitir"
              Padding(
                padding:
                    EdgeInsets.only(top: appPadding * 2, right: appPadding),
                child: Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: () {
                      _storeOnboardInfo();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AuthCheckMain(),
                        ),
                      );
                    },
                    child: Text(
                      "OMITIR",
                      style: TextStyle(
                        color: fondo,
                        fontSize: 20.0,
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

  Widget _buildPageIndicator(bool isActive) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.black87 : Colors.grey[400],
        border: Border.all(
          color: Colors.black87,
          width: 1,
        ),
      ),
    );
  }

  _storeOnboardInfo() async {
    print("Shared pref called");
    int isViewed = 0;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('onBoard', isViewed);
    print(prefs.getInt('onBoard'));
  }
}
