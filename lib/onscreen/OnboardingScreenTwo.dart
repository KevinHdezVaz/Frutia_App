import 'package:Frutia/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Frutia/auth/auth_check.dart';
import 'package:vibration/vibration.dart';
import 'package:video_player/video_player.dart';

import 'constants2.dart';

class OnboardingScreenTwo extends StatefulWidget {
  final PageController pageController;

  const OnboardingScreenTwo({Key? key, required this.pageController})
      : super(key: key);

  @override
  _OnboardingScreenTwoState createState() => _OnboardingScreenTwoState();
}

class _OnboardingScreenTwoState extends State<OnboardingScreenTwo> {
  late VideoPlayerController _videoController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize the video controller
    _videoController = VideoPlayerController.asset(
      'assets/images/videoEjercicio.mp4',
    )..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _videoController.setLooping(true); // Set video to loop
          _videoController.setVolume(0.0); // Mute the video
          _videoController.play(); // Start playing automatically
        }
      }).catchError((error) {
        print('Error initializing video: $error');
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                  fontSize: getResponsiveText(17),
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
                        Text(
                          l10n.whatPlanWeOffer,
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
                          l10n.frutiaPlan,
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
                            FeatureItem(l10n.personalizedVirtualNutritionist),
                            FeatureItem(l10n.trackingFoodHabitsWeight),
                            FeatureItem(l10n.recipesAccordingBudget),
                            FeatureItem(l10n.savedConversationHistory),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Video en la parte inferior, reemplazando la imagen
              Positioned(
                bottom: size.height * 0.10,
                left: 0,
                right: 0,
                child: Center(
                  child: ClipOval(
                    child: Container(
                      height: 300,
                      width: 300,
                      color:
                          Colors.black, // Fondo negro mientras carga el video
                      child: _isInitialized
                          ? VideoPlayer(_videoController)
                          : const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
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
                    widget.pageController.nextPage(
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
                      l10n.skip,
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

  Future<void> _storeOnboardInfo() async {
    print("Shared pref called");
    int isViewed = 0;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('onBoard', isViewed);
    print(prefs.getInt('onBoard'));
  }
}
