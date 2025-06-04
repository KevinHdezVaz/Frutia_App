import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:user_auth_crudd10/auth/auth_check.dart';
import 'package:user_auth_crudd10/onscreen/onboardingWrapper.dart';

class SplashScreen extends StatefulWidget {
  final int isviewed;

  const SplashScreen({super.key, required this.isviewed});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      _controller = VideoPlayerController.asset('assets/images/videoFondo.mp4');
      await _controller.initialize();
      if (mounted) {
        setState(() {});
        _controller.play();
        _controller.addListener(() {
          if (_controller.value.position >= _controller.value.duration) {
            _navigateToNextScreen();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
        // Si hay un error, navegar después de un tiempo fijo para no bloquear la app
        Future.delayed(const Duration(seconds: 3), () {
          _navigateToNextScreen();
        });
      }
    }
  }

  void _navigateToNextScreen() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => widget.isviewed != 0
              ? OnboardingWrapper()
              : const AuthCheckMain(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E8E0), // Fondo beige claro
      body: _hasError
          ? const Center(
              child: Text(
                'Error al cargar el video',
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
            )
          : _controller.value.isInitialized
              ? Stack(
                  children: [
                    Positioned.fill(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _controller.value.size.width,
                          height: _controller.value.size.height,
                          child: VideoPlayer(_controller),
                        ),
                      ),
                    ),
                  ],
                )
              : const Center(child: CircularProgressIndicator()),
    );
  }
}
