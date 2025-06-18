import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:Frutia/utils/colors.dart';
import 'package:Frutia/auth/auth_check.dart';
import 'package:audioplayers/audioplayers.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  _SuccessScreenState createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playSuccessSound();
  }

  Future<void> _playSuccessSound() async {
    try {
      await _audioPlayer.play(AssetSource('sonidos/sonido2.mp3'));
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo de pantalla
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/fondoPantalla1.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Stack para la imagen de fondo y la animación Lottie
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Imagen de fondo detrás de la animación Lottie con efecto circular
                      ClipOval(
                        child: Image.asset(
                          'assets/images/imagenFrutia.png',
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Lottie animation with scaling effect
                      Animate(
                        effects: [
                          ScaleEffect(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1, 1),
                            duration: 600.ms,
                            curve: Curves.elasticOut,
                          ),
                          ShimmerEffect(duration: 1000.ms),
                        ],
                        child: Lottie.asset(
                          'assets/images/animacioncontra.json',
                          width: 400,
                          height: 400,
                          fit: BoxFit.contain,
                          repeat: true,
                        ),
                      ),
                    ],
                  ),
                   // Text with fade-in animation
                  Animate(
                    effects: [
                      FadeEffect(duration: 800.ms, curve: Curves.easeOut)
                    ],
                    child: Text(
                      '¡Tu plan alimenticio ha sido creado! 🎉',
                      style: GoogleFonts.lato(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: FrutiaColors.primaryText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Second text with delayed fade-in
                  Animate(
                    effects: [FadeEffect(duration: 800.ms, delay: 200.ms)],
                    child: Text(
                      'Estás listo para empezar tu viaje hacia una vida más saludable.',
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        color: FrutiaColors.secondaryText,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Button with delayed fade-in
                  Animate(
                    effects: [FadeEffect(duration: 800.ms, delay: 400.ms)],
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => AuthCheckMain()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FrutiaColors.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        elevation: 5,
                      ),
                      child: Text(
                        'Comenzar ahora',
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
