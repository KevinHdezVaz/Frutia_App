import 'dart:async';
import 'package:Frutia/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
 
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  // --- Simulación de Datos del Usuario ---
  final int _currentStreak = 23; 
  final double _startWeight = 85.0;
  final double _currentWeight = 78.5;
  // -----------------------------------------

  late ScrollController _scrollController;
  final double _stepHeight = 80.0; 

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animateToCurrentStreak();
    });
  }

  void _animateToCurrentStreak() {
    final targetOffset = (_currentStreak * _stepHeight) - (context.size!.height * 0.4);
    _scrollController.animateTo(
      targetOffset > 0 ? targetOffset : 0,
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FrutiaColors.primaryBackground,
      appBar: AppBar(
        title: Text('Tu Progreso', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: FrutiaColors.accent,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      body: Column(
        children: [
          _buildHeaderInfo(),
          Expanded(
            child: _buildProgressTimeline(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo() {
    double weightChange = _currentWeight - _startWeight;
    
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: FrutiaColors.secondaryBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoChip('Racha Actual', '$_currentStreak Días', Icons.local_fire_department_rounded, Colors.orange),
          _buildInfoChip('Peso Perdido', '${weightChange.abs().toStringAsFixed(1)} kg', Icons.trending_down_rounded, Colors.green),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
  
  Widget _buildInfoChip(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.lato(color: FrutiaColors.secondaryText, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 8),
        Text(value, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: FrutiaColors.primaryText)),
      ],
    );
  }

  Widget _buildProgressTimeline() {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: 3,
          color: Colors.grey.shade200,
          margin: const EdgeInsets.only(top: 20),
        ),
        ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.only(top: 20, bottom: 40),
          itemCount: _currentStreak + 10,
          itemBuilder: (context, index) {
            final stepNumber = index + 1;
            return _TimelineStepWidget(
              stepNumber: stepNumber,
              isMilestone: stepNumber % 7 == 0,
              isCurrent: stepNumber == _currentStreak,
              isLeftAligned: index.isEven,
              stepHeight: _stepHeight,
            );
          },
        ),
      ],
    );
  }
}

class _TimelineStepWidget extends StatelessWidget {
  final int stepNumber;
  final bool isMilestone;
  final bool isCurrent;
  final bool isLeftAligned;
  final double stepHeight;

  const _TimelineStepWidget({
    required this.stepNumber,
    required this.isMilestone,
    required this.isCurrent,
    required this.isLeftAligned,
    required this.stepHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: stepHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLeftAligned) ...[
             _buildLabel(),
            _buildConnector(),
            _buildNode(),
            const Spacer(),
          ] else ...[
            const Spacer(),
            _buildNode(),
            _buildConnector(),
            _buildLabel(),
          ]
        ],
      ),
    ).animate().fadeIn(delay: (100 * (stepNumber % 10)).ms).slideX(begin: isLeftAligned ? -0.2 : 0.2, curve: Curves.easeOut);
  }

  // --- WIDGET MODIFICADO ---
  // Ahora muestra la mascota en el día actual.
  Widget _buildNode() {
    // Si es el día actual, muestra la mascota "Frutia".
    if (isCurrent) {
      return Image.asset(
        'assets/images/fruta22.png', // <-- La ruta de tu mascota
        width: 45,
        height: 45,
      )
      // Añadimos una animación para que la aparición sea más atractiva.
      .animate().scale(
        delay: 300.ms,
        duration: 600.ms,
        curve: Curves.elasticOut,
      );
    }
    
    // Para los otros días, muestra el nodo normal o de hito.
    return Container(
      width: isMilestone ? 24 : 16,
      height: isMilestone ? 24 : 16,
      decoration: BoxDecoration(
        color: isMilestone ? FrutiaColors.accent2 : Colors.grey.shade300,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: isMilestone ? const Icon(Icons.star, color: Colors.white, size: 14) : null,
    );
  }

  Widget _buildConnector() {
    return Container(
      width: 40,
      height: 2,
      color: Colors.grey.shade200,
    );
  }

  Widget _buildLabel() {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      alignment: isLeftAligned ? Alignment.centerRight : Alignment.centerLeft,
      child: Text(
        'Día $stepNumber',
        style: GoogleFonts.lato(
          fontSize: 14,
          fontWeight: isCurrent || isMilestone ? FontWeight.bold : FontWeight.normal,
          color: isCurrent ? FrutiaColors.accent : FrutiaColors.secondaryText,
        ),
      ),
    );
  }
}
