import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:Frutia/utils/colors.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  int _currentStreak = 0; // Racha actual
  bool _dailyGoalMet = false; // Si se cumplió el objetivo diario
  bool _isDayTime = true; // Determina si es día o noche
  final int _maxSteps = 10; // Máximo número de escalones

  @override
  void initState() {
    super.initState();
    // Determinar si es día o noche según la hora actual
    final hour = DateTime.now().hour;
    _isDayTime = hour >= 6 && hour < 18; // Día: 6 AM - 6 PM, Noche: 6 PM - 6 AM
  }

  // Método para mostrar un SnackBar con mensaje
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.lato(color: Colors.white),
        ),
        backgroundColor: FrutiaColors.accent,
      ),
    );
  }

  // Método para avanzar o retroceder en la racha
  void _updateStreak(bool goalMet) {
    setState(() {
      if (goalMet) {
        _currentStreak = (_currentStreak + 1).clamp(0, _maxSteps - 1);
        _showSnackBar('¡Objetivo cumplido! Avanzas un escalón.');
      } else {
        _currentStreak = (_currentStreak - 1).clamp(0, _maxSteps - 1);
        _showSnackBar('Objetivo no cumplido. Retrocedes un escalón.');
      }
      _dailyGoalMet = goalMet;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // AppBar con título y botón de retroceso
      appBar: AppBar(
        title: Text(
          'PROGRESO',
          style: GoogleFonts.lato(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: FrutiaColors.accent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // Cuerpo con gradiente e imagen de fondo
      body: Stack(
        children: [
          // Fondo con gradiente
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  FrutiaColors.secondaryBackground,
                  FrutiaColors.accent,
                ],
              ),
            ),
          ),
          // Imagen de fondo según la hora
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(_isDayTime ? 'assets/day_background.jpg' : 'assets/night_background.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.3),
                  BlendMode.dstATop,
                ),
              ),
            ),
          ),
          // Contenido principal
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Texto descriptivo
                  Text(
                    '¡Sigue tu racha y alcanza la cima con tu mono!',
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      color: FrutiaColors.primaryText,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 800.ms).slideY(
                        begin: 0.3,
                        end: 0.0,
                        duration: 800.ms,
                        curve: Curves.easeOut,
                      ),
                  const SizedBox(height: 16),
                  // Escalones de progreso
                  Expanded(
                    child: Stack(
                      children: [
                        // Líneas que conectan los escalones
                        CustomPaint(
                          size: Size(screenWidth, screenHeight),
                          painter: StaircasePainter(
                            steps: _maxSteps,
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                          ),
                        ),
                        // Escalones como cards en diagonal
                        ...List.generate(_maxSteps, (index) {
                          final stepNumber = index + 1;
                          final isCurrentStep = stepNumber == (_currentStreak + 1);

                          // Calcular posición en diagonal
                          final stepHeight = screenHeight * 0.5 / (_maxSteps - 1);
                          final stepWidth = screenWidth * 0.6 / (_maxSteps - 1);
                          final top = screenHeight * 0.3 - (index * stepHeight);
                          final left = (index * stepWidth) + 16;

                          return Positioned(
                            top: top,
                            left: left,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Escalón como Card
                                Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  color: isCurrentStep ? FrutiaColors.accent : Colors.white,
                                  child: Container(
                                    width: 60,
                                    height: 30,
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Escalón $stepNumber',
                                      style: GoogleFonts.lato(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isCurrentStep ? Colors.white : FrutiaColors.primaryText,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ).animate().fadeIn(duration: 800.ms, delay: (index * 200).ms),
                                const SizedBox(height: 4),
                                // Día de racha debajo del escalón
                                Text(
                                  'Día $index',
                                  style: GoogleFonts.lato(
                                    fontSize: 12,
                                    color: FrutiaColors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        // Mono en el escalón actual
                        if (_currentStreak < _maxSteps)
                          Positioned(
                            top: screenHeight * 0.3 - (_currentStreak * (screenHeight * 0.5 / (_maxSteps - 1))) - 50,
                            left: (_currentStreak * (screenWidth * 0.6 / (_maxSteps - 1))) + 16,
                            child: Image.asset(
                              'assets/monkey_mascot.png',
                              width: 40,
                              height: 40,
                            ).animate().slide(
                                  begin: const Offset(0.5, 0.5),
                                  end: Offset.zero,
                                  duration: 800.ms,
                                  curve: Curves.easeOut,
                                ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Checkbox para objetivo diario
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _dailyGoalMet,
                            onChanged: (bool? value) {
                              _updateStreak(value ?? false);
                            },
                            activeColor: FrutiaColors.accent,
                          ),
                          Expanded(
                            child: Text(
                              '¿Cumpliste tu objetivo diario?',
                              style: GoogleFonts.lato(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: FrutiaColors.primaryText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 800.ms).slideY(
                        begin: 0.3,
                        end: 0.0,
                        duration: 800.ms,
                        curve: Curves.easeOut,
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

// Pintor personalizado para dibujar las líneas que conectan los escalones
class StaircasePainter extends CustomPainter {
  final int steps;
  final double screenWidth;
  final double screenHeight;

  StaircasePainter({
    required this.steps,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 2;

    final stepHeight = screenHeight * 0.5 / (steps - 1);
    final stepWidth = screenWidth * 0.6 / (steps - 1);

    for (int i = 0; i < steps - 1; i++) {
      final startX = (i * stepWidth) + 46; // Ajuste según la posición del centro del card
      final startY = screenHeight * 0.3 - (i * stepHeight) + 15;
      final endX = ((i + 1) * stepWidth) + 46;
      final endY = screenHeight * 0.3 - ((i + 1) * stepHeight) + 15;

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}