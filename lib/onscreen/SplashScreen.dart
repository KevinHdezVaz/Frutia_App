import 'dart:math'; // Added import for sqrt
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:Frutia/auth/auth_check.dart';
import 'package:Frutia/onscreen/onboardingWrapper.dart';

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
      _controller =
          VideoPlayerController.asset('assets/images/videonfondo.mp4');
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
        PageRouteBuilder(
          transitionDuration:
              const Duration(milliseconds: 800), // Duración de la transición
          pageBuilder: (context, animation, secondaryAnimation) =>
              widget.isviewed != 0
                  ? OnboardingWrapper()
                  : const AuthCheckMain(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return ClipPath(
                  clipper: _CircleRevealClipper(animation.value),
                  child: child,
                );
              },
              child: child,
            );
          },
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
              ? Center(
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                )
              : const Center(child: CircularProgressIndicator()),
    );
  }
}

// Custom clipper para la animación de círculo expansivo
class _CircleRevealClipper extends CustomClipper<Path> {
  final double progress;

  _CircleRevealClipper(this.progress);

  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = sqrt(size.width * size.width +
        size.height * size.height); // Fixed sqrt usage
    final radius = maxRadius * progress;

    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(_CircleRevealClipper oldClipper) =>
      oldClipper.progress != progress;
}
