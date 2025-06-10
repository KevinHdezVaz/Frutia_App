import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math; // Para las nubes

// --- PANTALLA PRINCIPAL DE PROGRESO ---

class ProgressScreen extends StatelessWidget {
  // Estos datos vendrían de tu estado de la app (Provider, BLoC, etc.)
  final int streakDays;
  final int totalSteps; // La meta final
  final String userName;

  const ProgressScreen({
    super.key,
    this.streakDays = 7, // Ejemplo: 7 días de racha
    this.totalSteps = 15, // Ejemplo: Meta de 15 días
    this.userName = "John",
  });

  @override
  Widget build(BuildContext context) {
    // Asegurarnos que la racha no exceda el total de pasos
    final currentStep = streakDays.clamp(0, totalSteps);

    return Scaffold(
      body: Stack(
        children: [
          // 1. FONDO DINÁMICO (Día / Atardecer)
          _DynamicBackground(),

          // 2. NUBES ANIMADAS
          ..._buildClouds(),

          // 3. DIBUJO DE LAS ESCALERAS Y LA ESTRELLA
          _StairsAndStar(totalSteps: totalSteps),

          // 4. PERSONAJE DE LA FRESA (ANIMADO)
          _StrawberryCharacter(
            currentStep: currentStep,
            totalSteps: totalSteps,
          ),

          // 5. INTERFAZ DE USUARIO (TEXTOS)
          _ProgressUI(
            streakDays: streakDays,
            userName: userName,
          ),
        ],
      ),
    );
  }
}

// --- WIDGETS COMPONENTES DE LA PANTALLA ---

// 1. WIDGET PARA EL FONDO
class _DynamicBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    // Gradiente de día (ej. 6 AM a 6 PM)
    final dayGradient = [Color(0xFF81C7F5), Color(0xFFA5D8F8)];
    // Gradiente de atardecer (ej. 6 PM a 6 AM)
    final sunsetGradient = [Color(0xFFF8A170), Color(0xFFFFCC80)];

    bool isDayTime = hour >= 6 && hour < 18;

    return AnimatedContainer(
      duration: 1.seconds,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDayTime ? dayGradient : sunsetGradient,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}

// 2. WIDGET PARA LAS ESCALERAS Y LA ESTRELLA
class _StairsAndStar extends StatelessWidget {
  final int totalSteps;
  const _StairsAndStar({required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final stepSize = Size(constraints.maxWidth / 8, 20);
      final starPosition = _calculatePositionForStep(
          totalSteps + 2, totalSteps, constraints.biggest, stepSize);

      return Stack(
        children: [
          // Dibujo de las escaleras
          for (int i = 1; i <= totalSteps; i++)
            _buildStep(i, totalSteps, constraints.biggest, stepSize),

          // La estrella al final
          Positioned(
            left: starPosition.dx,
            bottom: starPosition.dy,
            child: Image.asset('assets/images/star.png', width: 100)
                .animate(onPlay: (c) => c.repeat(min: 2))
                .shimmer(
                    duration: 1.5.seconds,
                    color: Colors.yellow.withOpacity(0.5))
                .then()
                .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.1, 1.1),
                    duration: 1.seconds)
                .then()
                .scale(end: const Offset(1, 1), duration: 1.seconds),
          )
        ],
      );
    });
  }

  Widget _buildStep(int stepIndex, int total, Size canvasSize, Size stepSize) {
    final position =
        _calculatePositionForStep(stepIndex, total, canvasSize, stepSize);
    return Positioned(
      left: position.dx,
      bottom: position.dy,
      child: Image.asset('assets/images/step.png',
          width: stepSize.width, height: stepSize.height),
    );
  }
}

// 3. WIDGET PARA EL PERSONAJE
class _StrawberryCharacter extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _StrawberryCharacter(
      {required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    // El LayoutBuilder nos da el tamaño de la pantalla para hacer cálculos
    return LayoutBuilder(builder: (context, constraints) {
      final stepSize = Size(constraints.maxWidth / 8, 20);
      final position = _calculatePositionForStep(
          currentStep, totalSteps, constraints.biggest, stepSize);

      // Usamos AnimatedPositioned para que el cambio de racha cree una animación suave
      return AnimatedPositioned(
        duration: 800.milliseconds,
        curve: Curves.easeOutBack,
        left: position.dx - 10, // Ajuste para centrar la fresa
        bottom: position.dy +
            stepSize.height -
            5, // Ajuste para que esté "sobre" el escalón
        child: Image.asset(
          'assets/images/strawberry.png',
          width: 80,
        )
            .animate()
            .moveY(
                begin: -10,
                end: 0,
                curve: Curves.easeInOut,
                duration: 1.seconds)
            .then()
            .shake(hz: 2, duration: 500.ms),
      );
    });
  }
}

// 4. WIDGET PARA LOS TEXTOS DE LA UI
class _ProgressUI extends StatelessWidget {
  final int streakDays;
  final String userName;

  const _ProgressUI({required this.streakDays, required this.userName});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'Tu Progreso, $userName',
              style: GoogleFonts.lato(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [const Shadow(blurRadius: 5, color: Colors.black26)],
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: -0.5),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department,
                      color: Colors.orangeAccent, size: 30),
                  const SizedBox(width: 12),
                  Text(
                    '$streakDays Días de Racha',
                    style: GoogleFonts.lato(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 500.ms).scale(),
            const Spacer(),
            Text(
              '¡Sigue así, vas por buen camino!',
              style: GoogleFonts.lato(
                fontSize: 18,
                color: Colors.white.withOpacity(0.9),
                shadows: [const Shadow(blurRadius: 5, color: Colors.black26)],
              ),
            ).animate().fadeIn(delay: 700.ms),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// --- LÓGICA DE POSICIONAMIENTO Y ELEMENTOS EXTRA ---

// Función clave para calcular dónde va cada elemento
Offset _calculatePositionForStep(
    int stepIndex, int totalSteps, Size canvasSize, Size stepSize) {
  // Distribuimos los escalones en el 80% del ancho y 70% del alto
  final availableWidth = canvasSize.width * 0.8;
  final availableHeight = canvasSize.height * 0.7;

  final x =
      (canvasSize.width * 0.1) + (availableWidth / totalSteps) * stepIndex;
  final y =
      (canvasSize.height * 0.1) + (availableHeight / totalSteps) * stepIndex;

  return Offset(x, y);
}

// Función para generar nubes aleatorias
List<Widget> _buildClouds() {
  return List.generate(5, (index) {
    final size = math.Random().nextDouble() * 80 + 60;
    final top = math.Random().nextDouble() * 200 + 50;
    final left = math.Random().nextDouble() * 300;
    final duration = math.Random().nextInt(10) + 20;

    return Positioned(
            top: top,
            left: left,
            child: Image.asset('assets/images/cloud.png', width: size))
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .moveX(end: 20, duration: duration.seconds, curve: Curves.easeInOut);
  });
}
