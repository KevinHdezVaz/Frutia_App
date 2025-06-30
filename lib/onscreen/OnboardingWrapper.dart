import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

// Asegúrate de que las rutas de importación a tus pantallas sean correctas
import 'package:Frutia/onscreen/OnboardingScreenOne.dart';
import 'package:Frutia/onscreen/OnboardingScreenTwo.dart';
import 'package:Frutia/onscreen/OnboardingScreenThree.dart';
import 'package:Frutia/onscreen/screen_cuatro.dart'; // O como se llame el archivo de la pantalla 4

/// Este widget actúa como el contenedor principal para las pantallas de onboarding.
/// Gestiona la navegación entre páginas y reproduce un sonido al deslizar.
class OnboardingWrapper extends StatefulWidget {
  const OnboardingWrapper({Key? key}) : super(key: key);

  @override
  _OnboardingWrapperState createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends State<OnboardingWrapper> {
  final PageController _pageController = PageController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _lastPage = 0; // Inicia en la página 0

  @override
  void initState() {
    super.initState();
    // Ya no cargamos el audio aquí. Lo haremos justo antes de reproducirlo.
    // Esto evita errores de carga iniciales que puedan bloquear la app.
    _pageController.addListener(_handlePageChange);
  }

  /// Detecta cuando el usuario ha deslizado a una nueva página.
  void _handlePageChange() {
    // Si el controlador de página no está listo, no hacemos nada.
    if (!_pageController.hasClients || _pageController.page == null) return;

    // Obtenemos la página actual redondeando el valor del scroll.
    final currentPage = _pageController.page!.round();

    // Si la página actual es diferente a la última que registramos,
    // significa que el usuario ha completado el deslizamiento a una nueva página.
    if (currentPage != _lastPage) {
      print("Página cambió de $_lastPage a $currentPage");
      _lastPage = currentPage;
      _playSwipeSound(); // Reproducimos el sonido de swipe.
    }
  }

  /// Reproduce un sonido corto para dar feedback al usuario al deslizar.
  /// Está protegido con try-catch para evitar que la app se bloquee si el audio falla.
  Future<void> _playSwipeSound() async {
    try {
      // Usamos play() que es más directo y eficiente para sonidos cortos.
      // AssetSource busca el archivo en la carpeta 'assets' que declaraste en pubspec.yaml.
      // Asegúrate de que la ruta 'sonidos/sonido3.mp3' es correcta.
      await _audioPlayer.play(AssetSource('sonidos/sonido3.mp3'));
    } catch (e) {
      // Si hay un error (ej: archivo no encontrado), solo se imprimirá en la consola
      // y la aplicación no se bloqueará. Los videos en otras pantallas seguirán funcionando.
      print('Error al reproducir sonido de swipe: $e');
    }
  }

  /// Es importante liberar los recursos cuando el widget ya no está en pantalla
  /// para evitar fugas de memoria.
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
          // Pasa el mismo pageController a cada pantalla hija
          OnboardingScreenOne(pageController: _pageController),
          OnboardingScreenTwo(pageController: _pageController),
          OnboardingScreenThree(pageController: _pageController),
          OnBoardingCuatro(pageController: _pageController),
        ],
      ),
    );
  }
}
