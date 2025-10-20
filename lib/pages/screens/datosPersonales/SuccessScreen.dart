import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';
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
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize the video controller with the video asset
    _controller = VideoPlayerController.asset('assets/images/fondoAppFrutiaVideo.mp4')
      ..initialize().then((_) {
        setState(() {}); // Update UI when video is initialized
        _controller.setLooping(true); // Loop the video
        _controller.play(); // Auto-play the video
      });
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
    _controller.dispose(); // Dispose of the video controller
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
                                color: Colors.grey, // Placeholder while video loads
                                child: Center(child: CircularProgressIndicator()),
                              ),
                      ),
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
                  // Text without fade-in animation
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
                  // Second text without fade-in
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
                  // Button without fade-in
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
        ],
      ),
    );
  }
}