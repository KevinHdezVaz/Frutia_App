import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_auth_crudd10/utils/colors.dart'; // Import FrutiaColors

class MembershipDetailsScreen extends StatefulWidget {
  const MembershipDetailsScreen({super.key});

  @override
  State<MembershipDetailsScreen> createState() =>
      _MembershipDetailsScreenState();
}

class _MembershipDetailsScreenState extends State<MembershipDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _scaleAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _slideAnimation = Tween<Offset>(
            begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: FrutiaColors.primaryBackground,
      appBar: AppBar(
        title: Text(
          'Plan PRO',
          style: GoogleFonts.lato(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: FrutiaColors.primaryText,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: FrutiaColors.accent, size: 30),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Animated Title with Badge
              FadeTransition(
                opacity: _fadeAnimation,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tu Membresía Actual',
                      style: GoogleFonts.lato(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: FrutiaColors.primaryText,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: FrutiaColors.success,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: FrutiaColors.success.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        'Activa',
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: FrutiaColors.primaryBackground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              // Progress Section
              Center(
                child: Column(
                  children: [
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              FrutiaColors.accent.withOpacity(0.2),
                              FrutiaColors.primaryBackground,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: FrutiaColors.accent.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            value: 0.75, // 75% progress
                            strokeWidth: 10.0,
                            backgroundColor:
                                FrutiaColors.secondaryText.withOpacity(0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(
                                FrutiaColors.accent),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      '75% Completado',
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: FrutiaColors.primaryText,
                      ),
                    ),
                    Text(
                      'Vence el 15/06/2025',
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: FrutiaColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Plan Card with Enhanced Design
              ScaleTransition(
                scale: _scaleAnimation,
                child: Card(
                  elevation: 15,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          FrutiaColors.accent.withOpacity(0.1),
                          FrutiaColors.secondaryBackground,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25.0),
                      boxShadow: [
                        BoxShadow(
                          color: FrutiaColors.accent.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(25.0),
                    width: size.width * 0.95,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.local_dining,
                                color: FrutiaColors.accent, size: 28),
                            const SizedBox(width: 12),
                            Text(
                              'Plan Frutia',
                              style: GoogleFonts.lato(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: FrutiaColors.primaryText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        PlanFeature(
                            icon: Icons.person, text: 'Nutricionista virtual'),
                        PlanFeature(
                            icon: Icons.favorite, text: 'Plan personalizado'),
                        PlanFeature(
                            icon: Icons.trending_up,
                            text: 'Seguimiento de progreso'),
                        PlanFeature(
                            icon: Icons.receipt,
                            text: 'Recetas según presupuesto'),
                        PlanFeature(
                            icon: Icons.history,
                            text: 'Historial de conversaciones'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Enhanced Warning Message
              SlideTransition(
                position: _slideAnimation,
                child: Container(
                  padding: const EdgeInsets.all(18.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        FrutiaColors.accent.withOpacity(0.15),
                        FrutiaColors.primaryBackground,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18.0),
                    boxShadow: [
                      BoxShadow(
                        color: FrutiaColors.accent.withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber,
                          color: FrutiaColors.accent, size: 30),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          '¡Quédate, tu mejor versión aún está por venir!',
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            color: FrutiaColors.primaryText,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 35),
              // Enhanced Action Buttons
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: AnimatedButton(
                          text: 'Cancelar Membresía',
                          icon: Icons.cancel,
                          color: FrutiaColors.accent,
                          onPressed: () {
                            // Placeholder for cancel action
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AnimatedButton(
                          text: 'Método de Pago',
                          icon: Icons.payment,
                          color: FrutiaColors.nutrition,
                          onPressed: () {
                            // Placeholder for payment method action
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Center(
                    child: AnimatedButton(
                      text: 'Actualizar Plan',
                      icon: Icons.upgrade,
                      color: FrutiaColors.plan,
                      onPressed: () {
                        // Placeholder for upgrade action
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Enhanced Progress Note
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: FrutiaColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                        color: FrutiaColors.accent.withOpacity(0.3), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline,
                          size: 16, color: FrutiaColors.secondaryText),
                      const SizedBox(width: 8),
                      Text(
                        '• Si te vas, tu progreso también se irá.',
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          color: FrutiaColors.secondaryText,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}

// Plan Feature Widget
class PlanFeature extends StatelessWidget {
  final IconData icon;
  final String text;

  const PlanFeature({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: FrutiaColors.accent, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.lato(
                fontSize: 16,
                color: FrutiaColors.primaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Animated Button Widget with Icon
class AnimatedButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const AnimatedButton({
    required this.text,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: (MediaQuery.of(context).size.width - 32 - 24) / 2.5,
                margin: const EdgeInsets.symmetric(horizontal: 6.0),
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 12.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.color,
                      widget.color.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(widget.icon,
                        color: FrutiaColors.primaryBackground, size: 22),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        widget.text,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: FrutiaColors.primaryBackground,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
