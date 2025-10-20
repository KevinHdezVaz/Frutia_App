import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';
import 'package:Frutia/utils/colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of the controller to free resources
    super.dispose();
  }

  // Función de utilidad MODIFICADA: Usa .custom() para forzar el ClipRect horizontal.
  Widget _buildAnimatedText(String text, {required Duration delay, required Duration duration}) {
    return Text(
      text,
      style: GoogleFonts.lato(
        fontSize: 16,
        color: FrutiaColors.secondaryText,
      ),
    )
        .animate(delay: delay)
        // Efecto de "Pintado" usando custom para implementar ClipRect
        .custom(
          duration: duration, // Duración del pintado
          builder: (context, value, child) {
            // 'value' va de 0.0 (inicio) a 1.0 (fin)
            return ClipRect(
              // Recorta el texto de izquierda a derecha
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: value, // Controla el ancho visible del texto
                child: child,
              ),
            );
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    // Definimos la animación base para el video (Floating/Pulsating Glow)
    final videoAnimation = (Widget child) => child
        .animate(
          onPlay: (controller) => controller.repeat(reverse: true),
        )
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1.05, 1.05),
          duration: 5500.ms,
          curve: Curves.easeInOutSine,
        )
        .then()
        .shimmer(
          duration: 5000.ms,
          color: FrutiaColors.accent.withOpacity(0.5),
        );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [FrutiaColors.accent, FrutiaColors.accent2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Nosotros',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        )
            .animate()
            .slideY(
              begin: -1,
              end: 0,
              duration: 700.ms,
              curve: Curves.fastOutSlowIn,
            ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fondoPantalla1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 32),
                Center(
                  child: ClipOval(
                    child: videoAnimation(
                      _controller.value.isInitialized
                          ? SizedBox(
                              height: 180,
                              width: 180, // Adjust size to match previous image
                              child: AspectRatio(
                                aspectRatio: _controller.value.aspectRatio,
                                child: VideoPlayer(_controller),
                              ),
                            )
                          : Container(
                              height: 180,
                              width: 180,
                              color: Colors.grey, // Placeholder while video loads
                              child: Center(child: CircularProgressIndicator()),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    elevation: 12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: FrutiaColors.secondaryBackground.withOpacity(0.95),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nuestra Historia',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: FrutiaColors.accent,
                            ),
                          )
                              .animate()
                              .rotate(
                                begin: -0.05,
                                end: 0,
                                duration: 800.ms,
                                curve: Curves.easeOutCubic,
                              )
                              .slideX(begin: -0.5, end: 0, duration: 800.ms),
                          const Divider(height: 25, thickness: 2),
                          // Párrafos con efecto de "pintado" y velocidad progresivamente mayor
                          // 1. Velocidad Lenta (2000 ms)
                          _buildAnimatedText(
                            'Creamos esta app con una idea clara: la nutrición no debería sentirse como una carga, ni depender de planes genéricos que no se adaptan a tu vida. Por eso combinamos ciencia, tecnología e inteligencia artificial para ofrecerte un acompañamiento real, sin fórmulas mágicas, sin promesas vacías, y sin complicarte el día a día.',
                            delay: 400.ms,
                            duration: 2000.ms,
                          ),
                          const SizedBox(height: 16),
                          // 2. Velocidad Media (1500 ms)
                          _buildAnimatedText(
                            'Cada cuerpo es distinto, y creemos que tu alimentación debe respetarlo. Por eso, nuestro sistema se adapta a tus metas, tus gustos, tu rutina y hasta tu presupuesto. No importa si entrenas en el gimnasio, juegas fútbol los domingos o simplemente quieres comer mejor sin gastar de más: tu plan es tuyo y evoluciona contigo.',
                            delay: 600.ms,
                            duration: 1500.ms,
                          ),
                          const SizedBox(height: 16),
                          // 3. Velocidad Rápida (1000 ms)
                          _buildAnimatedText(
                            'Nos mueve la idea de que la tecnología puede humanizarse. Por eso nuestra IA, Frutia, no es solo un robot que te lanza datos. Puedes decidir cómo quieres que te trate: motivadora, relajada o directa. Como si tuvieras un nutricionista virtual que sí te entiende.',
                            delay: 800.ms,
                            duration: 1000.ms,
                          ),
                          const SizedBox(height: 16),
                          // 4. Velocidad Muy Rápida (700 ms)
                          _buildAnimatedText(
                            'Somos un equipo de nutricionistas, desarrolladores, diseñadores y soñadores, comprometidos con una nutrición accesible, realista y personalizada. Y lo más importante: hecha para durar.',
                            delay: 1000.ms,
                            duration: 700.ms,
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .slideY(
                        begin: 0.2,
                        end: 0,
                        duration: 800.ms,
                        curve: Curves.easeOut,
                      ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
    );
  }
}