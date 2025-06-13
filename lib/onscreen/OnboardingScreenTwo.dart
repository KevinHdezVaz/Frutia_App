import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Frutia/auth/auth_check.dart';
import 'package:vibration/vibration.dart';

import 'constants2.dart';

class OnboardingScreenTwo extends StatelessWidget {
  final PageController pageController;
  OnboardingScreenTwo({required this.pageController});

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
    double screenHeight = size.height;
    double screenWidth = size.width;

    Widget FeatureItem(String text) {
      return Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green[300],
              size: 22,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: getResponsiveText(15),
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
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
              // Contenido principal (título y lista) en la parte superior
              Positioned(
                top: size.height * 0.05,
                left: 0,
                right: 0,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "¿QUÉ PLAN OFRECEMOS?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontSize: 28,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          "Plan Frutia:",
                          style: TextStyle(
                            fontSize: getResponsiveText(24),
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FeatureItem("Nutricionista virtual personalizado"),
                            FeatureItem(
                                "Seguimiento de alimentos, hábitos y peso"),
                            FeatureItem("Recetas según tu presupuesto"),
                            FeatureItem("Historial de conversaciones guardado"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Imagen de la fruta en la parte inferior
              Positioned(
                bottom: size.height * 0.10,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    height: 300,
                    width: 300,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/fruta44.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
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
                    _buildPageIndicator(true),
                    const SizedBox(width: 8),
                    _buildPageIndicator(false),
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
