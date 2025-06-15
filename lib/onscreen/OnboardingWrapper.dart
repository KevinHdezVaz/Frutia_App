import 'package:flutter/material.dart';
import 'package:Frutia/onscreen/OnboardingScreenOne.dart';
import 'package:Frutia/onscreen/OnboardingScreenThree.dart';
import 'package:Frutia/onscreen/OnboardingScreenTwo.dart';
import 'package:Frutia/onscreen/screen_cuatro.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';

class OnboardingWrapper extends StatefulWidget {
  const OnboardingWrapper({Key? key}) : super(key: key);

  @override
  _OnboardingWrapperState createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends State<OnboardingWrapper> {
  final PageController _pageController = PageController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  int? _lastPage; // Para rastrear la última página

  @override
  void initState() {
    super.initState();
    _audioPlayer.setSource(AssetSource('sonidos/sonido3.mp3'));

    _pageController.addListener(_handlePageChange);
  }

  void _handlePageChange() {
    if (_pageController.page == null) return;

    final currentPage = _pageController.page!.round();

    // Solo activar si la página cambió y la animación está completa
    if (currentPage != _lastPage &&
        _pageController.position.pixels ==
            _pageController.position.maxScrollExtent * (currentPage / 3)) {
      _lastPage = currentPage;
      _playSwipeSound();
      _triggerVibration();
    }
  }

  Future<void> _playSwipeSound() async {
    try {
      await _audioPlayer.stop(); // Detener cualquier reproducción previa
      await _audioPlayer.seek(Duration.zero); // Reiniciar el audio
      await _audioPlayer.resume();
    } catch (e) {
      print('Error al reproducir sonido: $e');
    }
  }

  Future<void> _triggerVibration() async {
    if (await Vibration.hasVibrator() ?? false) {
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        Vibration.vibrate(duration: 1, amplitude: 10);
      } else {
        Vibration.vibrate(duration: 1, amplitude: 10);
      }
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_handlePageChange);
    _pageController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          OnboardingScreenOne(pageController: _pageController),
          OnboardingScreenTwo(pageController: _pageController),
          OnboardingScreenThree(pageController: _pageController),
          OnBoardingCuatro(pageController: _pageController),
        ],
      ),
    );
  }
}
