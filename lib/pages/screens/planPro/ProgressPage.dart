import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:Frutia/utils/colors.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  double _characterPositionX = 0.0; // Posición horizontal
  double _characterPositionY = 0.0; // Posición vertical

  @override
  void initState() {
    super.initState();
    // Simulación de estado inicial (puedes cambiar manualmente para probar)
    _updatePosition(true); // true para subir, false para bajar
  }

  void _updatePosition(bool streakAchieved) {
    setState(() {
      if (streakAchieved) {
        // Subir: Mover hacia arriba y a la derecha (pendiente de la pirámide)
        _characterPositionX += 20.0;
        _characterPositionY -= 20.0;
      } else {
        // Bajar: Mover hacia abajo y a la izquierda
        _characterPositionX -= 20.0;
        _characterPositionY += 20.0;
      }
      // Limitar la posición para que no salga de los escalones visibles
      _characterPositionX = _characterPositionX.clamp(0.0, 150.0);
      _characterPositionY = _characterPositionY.clamp(0.0, 150.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFD1B3), // Naranja suave
              Color(0xFFFF6F61), // Rojo cálido
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Mitad superior: Pirámide y animación
              SizedBox(
                height: size.height * 0.5, // Ocupa solo la mitad superior
                child: Stack(
                  children: [
                    // Texto de racha
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Racha de Progreso',
                            style: GoogleFonts.lato(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: FrutiaColors.primaryText,
                            ),
                          ).animate().fadeIn(delay: 200.ms, duration: 800.ms),
                          const SizedBox(height: 8),
                          Text(
                            'Sube la pirámide cumpliendo tu racha diaria.',
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              color: FrutiaColors.secondaryText,
                            ),
                          ).animate().fadeIn(delay: 400.ms, duration: 800.ms),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Mitad inferior: Estadísticas
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: FrutiaColors.secondaryBackground,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estadísticas',
                            style: GoogleFonts.lato(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: FrutiaColors.primaryText,
                            ),
                          ).animate().fadeIn(delay: 600.ms, duration: 800.ms),
                          const SizedBox(height: 16),
                          _buildStatRow(
                            icon: Icons.local_fire_department,
                            label: 'Días de Racha',
                            value: '7 días',
                            delay: 800,
                          ),
                          const SizedBox(height: 12),
                          _buildStatRow(
                            icon: Icons.fitness_center,
                            label: 'Calorías Quemadas',
                            value: '1850 kcal',
                            delay: 1000,
                          ),
                          const SizedBox(height: 12),
                          _buildStatRow(
                            icon: Icons.fastfood,
                            label: 'Comidas Saludables',
                            value: '12 esta semana',
                            delay: 1200,
                          ),
                          const SizedBox(height: 12),
                          _buildStatRow(
                            icon: Icons.water_drop,
                            label: 'Hidratación',
                            value: '2.5 L hoy',
                            delay: 1400,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required double delay,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: FrutiaColors.accent,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: FrutiaColors.secondaryText,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: FrutiaColors.primaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 1000.ms, duration: 800.ms)
        .slideX(begin: -0.2, end: 0.0, duration: 800.ms, curve: Curves.easeOut);
  }
}

// Pintor personalizado para dibujar la mitad de la pirámide con escalones
class PyramidStepsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()
      ..color = FrutiaColors.accent.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final stepPaint = Paint()
      ..color = FrutiaColors.primaryBackground
      ..style = PaintingStyle.fill;

    // Dibujar el triángulo base (mitad de la pirámide)
    final path = Path()
      ..moveTo(0, size.height) // Base izquierda
      ..lineTo(size.width, size.height) // Base derecha
      ..lineTo(
          size.width / 2, -size.height) // Vértice superior (fuera de pantalla)
      ..close();

    canvas.drawPath(path, basePaint);

    // Dibujar escalones
    const stepHeight = 20.0; // Altura de cada escalón
    const stepCount = 20; // Más escalones para efecto "infinito"
    for (int i = 0; i < stepCount; i++) {
      double t = i / stepCount;
      double y =
          size.height - (i * stepHeight); // Posición vertical del escalón
      if (y < -size.height) break; // Para no dibujar más allá del vértice

      // Calcular los puntos del escalón
      double x1 = size.width * t; // Punto en la base
      double x2 = size.width / 2 +
          (size.width / 2 - size.width / 2 * t); // Punto en la pendiente

      // Dibujar el escalón (rectángulo)
      final stepPath = Path()
        ..moveTo(x1, y)
        ..lineTo(x2, y - stepHeight)
        ..lineTo(x2, y)
        ..lineTo(x1, y)
        ..close();

      canvas.drawPath(stepPath, stepPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
