import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:confetti/confetti.dart'; // ⭐ IMPORTAR
import 'package:Frutia/utils/colors.dart';
import 'package:Frutia/auth/auth_check.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  _SuccessScreenState createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late VideoPlayerController _controller;

  // ⭐ CONTROLADORES DE CONFETTI
  late ConfettiController _confettiControllerCenter;
  late ConfettiController _confettiControllerLeft;
  late ConfettiController _confettiControllerRight;

  @override
  void initState() {
    super.initState();

    // Initialize the video controller
    _controller =
        VideoPlayerController.asset('assets/images/fondoAppFrutiaVideo.mp4')
          ..initialize().then((_) {
            setState(() {});
            _controller.setLooping(true);
            _controller.play();
          });

    _playSuccessSound();

    // ⭐ INICIALIZAR CONTROLADORES DE CONFETTI
    _confettiControllerCenter =
        ConfettiController(duration: const Duration(seconds: 3));
    _confettiControllerLeft =
        ConfettiController(duration: const Duration(seconds: 3));
    _confettiControllerRight =
        ConfettiController(duration: const Duration(seconds: 3));

    // ⭐ DISPARAR CONFETTI DESPUÉS DE 500ms
    Future.delayed(const Duration(milliseconds: 500), () {
      _confettiControllerCenter.play();
      _confettiControllerLeft.play();
      _confettiControllerRight.play();
    });
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
    _controller.dispose();
    _audioPlayer.dispose();

    // ⭐ LIMPIAR CONTROLADORES DE CONFETTI
    _confettiControllerCenter.dispose();
    _confettiControllerLeft.dispose();
    _confettiControllerRight.dispose();

    super.dispose();
  }

  // ⭐ GENERADOR DE COLORES ALEATORIOS PARA CONFETTI
  Color _randomColor() {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.pink,
      Colors.purple,
      Colors.orange,
      FrutiaColors.accent,
    ];
    return colors[Random().nextInt(colors.length)];
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
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipOval(
                        child: _controller.value.isInitialized
                            ? SizedBox(
                                width: 200,
                                height: 200,
                                child: AspectRatio(
                                  aspectRatio: _controller.value.aspectRatio,
                                  child: VideoPlayer(_controller),
                                ),
                              )
                            : Container(
                                width: 200,
                                height: 200,
                                color: Colors.grey,
                                child: const Center(
                                    child: CircularProgressIndicator()),
                              ),
                      ),
                    ],
                  ),
                  Text(
                    '¡Tu plan alimenticio ha sido creado! 🎉',
                    style: GoogleFonts.lato(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: FrutiaColors.primaryText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Estás listo para empezar tu viaje hacia una vida más saludable.',
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      color: FrutiaColors.secondaryText,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
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
                ],
              ),
            ),
          ),

          // ⭐ CONFETTI CENTRAL (EXPLOSION)
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiControllerCenter,
              blastDirection: pi / 2, // Hacia abajo
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              gravity: 0.3,
              shouldLoop: false,
              colors: [
                Colors.red,
                Colors.blue,
                Colors.green,
                Colors.yellow,
                Colors.pink,
                Colors.purple,
                FrutiaColors.accent,
              ],
            ),
          ),

          // ⭐ CONFETTI IZQUIERDA
          Align(
            alignment: Alignment.centerLeft,
            child: ConfettiWidget(
              confettiController: _confettiControllerLeft,
              blastDirection: 0, // Hacia la derecha
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.2,
              shouldLoop: false,
              colors: [
                Colors.red,
                Colors.blue,
                Colors.green,
                Colors.yellow,
                Colors.pink,
              ],
            ),
          ),

          // ⭐ CONFETTI DERECHA
          Align(
            alignment: Alignment.centerRight,
            child: ConfettiWidget(
              confettiController: _confettiControllerRight,
              blastDirection: pi, // Hacia la izquierda
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.2,
              shouldLoop: false,
              colors: [
                Colors.orange,
                Colors.purple,
                Colors.pink,
                Colors.yellow,
                FrutiaColors.accent,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
