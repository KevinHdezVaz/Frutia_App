import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:video_player/video_player.dart';

class OnboardingScreenOne extends StatefulWidget {
  final PageController pageController;

  const OnboardingScreenOne({Key? key, required this.pageController})
      : super(key: key);

  @override
  _OnboardingScreenOneState createState() => _OnboardingScreenOneState();
}

class _OnboardingScreenOneState extends State<OnboardingScreenOne> {
  late VideoPlayerController _videoController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize the video controller
    _videoController = VideoPlayerController.asset(
      'assets/images/videoDoc.mp4',
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
    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo que incluye el fondo y el personaje
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/fondoPantalla1.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Contenido principal centrado
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                    height: 20), // Reducido para mover el video hacia arriba

                // Video circular, reemplazando la imagen de la fresa
                Center(
                  child: ClipOval(
                    child: Container(
                      width: 350, // Tamaño igual que la imagen original
                      height: 350, // Tamaño igual que la imagen original
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

                const SizedBox(height: 40),

                // Título
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    "Nutrición 100% personalizada",
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

                // Lista de puntos con línea degradada de fondo
                Stack(
                  children: [
                    // Texto de los puntos
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        children: [
                          _buildBulletPoint(
                              "Planes adaptados a tus objetivos y gustos"),
                          const SizedBox(height: 12),
                          _buildBulletPoint(
                              "Coach de IA con seguimiento personal"),
                          const SizedBox(height: 12),
                          _buildBulletPoint(
                              "Adaptable a tu estilo y presupuesto"),
                          const SizedBox(height: 12),
                          _buildBulletPoint("Rápido y hecho solo para ti"),
                        ],
                      ),
                    ),
                  ],
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
                _buildPageIndicator(true),
                const SizedBox(width: 8),
                _buildPageIndicator(false),
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
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4, right: 8),
          child: Icon(
            Icons.circle,
            size: 8,
            color: Colors.black87,
          ),
        ),
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
}
