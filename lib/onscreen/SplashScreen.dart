import 'dart:math';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audio_session/audio_session.dart';
import 'package:Frutia/auth/auth_check.dart';
import 'package:Frutia/onscreen/onboardingWrapper.dart';

class SplashScreen extends StatefulWidget {
  final int isviewed;
  const SplashScreen({super.key, required this.isviewed});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  VideoPlayerController? _controller;  
  bool _hasError = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
       final session = await AudioSession.instance;
      await session.configure(AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.ambient,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
      ));

      _controller = VideoPlayerController.asset('assets/images/videonfondo.mp4');
      await _controller!.initialize();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _controller!.play();
        _controller!.addListener(() {
          if (_controller!.value.position >= _controller!.value.duration) {
            _navigateToNextScreen();
          }
        });
      }
    } catch (e) {
      print('Error initializing video: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isInitialized = true;
        });
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
          transitionDuration: const Duration(milliseconds: 800),
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
    _controller?.dispose(); // Usar null-aware operator
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E8E0),
      body: _hasError
          ? const Center(
              child: Text(
                'Error al cargar el video',
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
            )
          : _isInitialized && _controller != null && _controller!.value.isInitialized
              ? Center(
                  child: AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  ),
                )
              : const Center(child: CircularProgressIndicator()),
    );
  }
}

class _CircleRevealClipper extends CustomClipper<Path> {
  final double progress;
  _CircleRevealClipper(this.progress);

  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = sqrt(size.width * size.width + size.height * size.height);
    final radius = maxRadius * progress;
    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(_CircleRevealClipper oldClipper) =>
      oldClipper.progress != progress;
}