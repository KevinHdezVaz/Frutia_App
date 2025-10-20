import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart'; // 1. Importa el paquete

class FrutiaProgresoVideo extends StatefulWidget {
  const FrutiaProgresoVideo({super.key});

  @override
  State<FrutiaProgresoVideo> createState() => _FrutiaProgresoVideoState();
}

class _FrutiaProgresoVideoState extends State<FrutiaProgresoVideo> {
  // 2. Declara el controlador
  late VideoPlayerController _controller; 
  
  // Asumiendo que el video está en: assets/videos/frutaprogreso1_video.mp4
  final String _videoAssetPath = 'assets/images/frutaProgreso1_video.mp4';

  @override
  void initState() {
    super.initState();
    
    // 3. Inicializa el controlador con el asset
    _controller = VideoPlayerController.asset(_videoAssetPath)
      ..initialize().then((_) {
        // 4. Configura y comienza a reproducir
        _controller.setLooping(true); // Reproducción en bucle
        _controller.play();
        setState(() {}); // Actualiza la UI para mostrar el video
      })
      .onError((error, stackTrace) {
        // Manejo de error si el video no se carga
        print('Error al cargar el video: $error');
      });
  }

  @override
  void dispose() {
    // 5. LIBERA los recursos del controlador al salir del widget
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 6. Retorna el widget del reproductor
    return _controller.value.isInitialized
        ? AspectRatio(
            // El aspect ratio asegura que el video se muestre correctamente
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : const Center(
            child: CircularProgressIndicator(), // Muestra un cargador mientras inicializa
          );
  }
}