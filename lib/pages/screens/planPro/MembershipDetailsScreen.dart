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
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
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
      backgroundColor: FrutiaColors.primaryBackground, // Solid white background
      appBar: AppBar(
        title: Text(
          'Plan PRO',
          style: GoogleFonts.lato(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: FrutiaColors.accent, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Animated Title
              FadeTransition(
                opacity: _animation,
                child: Text(
                  'Tu Membresía Actual',
                  style: GoogleFonts.lato(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Circular Progress Indicator
              Center(
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: 0.75, // 75% progress
                    strokeWidth: 8.0,
                    backgroundColor: FrutiaColors.secondaryText,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(FrutiaColors.accent),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Plan Card with Gradient and Shadow
              ScaleTransition(
                scale: _animation,
                child: Card(
                  elevation: 12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          FrutiaColors.accent.withOpacity(0.15),
                          Colors.white
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    padding: EdgeInsets.all(20.0),
                    width: size.width * 0.9,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.local_dining,
                                color: FrutiaColors.accent, size: 24),
                            SizedBox(width: 10),
                            Text(
                              'Plan Frutia',
                              style: GoogleFonts.lato(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D2D2D),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
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
              SizedBox(height: 25),
              // Warning Message with Animation
              SlideTransition(
                position:
                    Tween<Offset>(begin: Offset(0, 0.5), end: Offset(0, 0))
                        .animate(_animation),
                child: Container(
                  padding: EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        FrutiaColors.accent.withOpacity(0.2),
                        Colors.white
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15.0),
                    boxShadow: [
                      BoxShadow(
                        color: FrutiaColors.accent.withOpacity(0.2),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber,
                          color: FrutiaColors.accent, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '¡Quedate, tu mejor versión aún está por venir!',
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            color: Color(0xFF2D2D2D),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              // Action Buttons wrapped in Column
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
                      SizedBox(width: 10),
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
                  SizedBox(height: 10),
                ],
              ),
              SizedBox(height: 15),
              // Progress Note with Stylish Design
              Center(
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: FrutiaColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    '• Si te vas, tu progreso también se irá.',
                    style: TextStyle(
                      fontSize: 12,
                      color: FrutiaColors.secondaryText,
                      fontStyle: FontStyle.italic,
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
}

// Plan Feature Widget
class PlanFeature extends StatelessWidget {
  final IconData icon;
  final String text;

  const PlanFeature({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Icon(icon, color: FrutiaColors.accent, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16, color: Color(0xFF2D2D2D)),
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

  const AnimatedButton(
      {required this.text,
      required this.icon,
      required this.color,
      required this.onPressed});

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
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
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: (MediaQuery.of(context).size.width - 32 - 20) / 3 -
              10, // Adjusted width for 3 buttons with padding
          margin: EdgeInsets.symmetric(horizontal: 5.0),
          padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 10.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [widget.color, widget.color.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon,
                  color: FrutiaColors.primaryBackground, size: 20),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  widget.text,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: widget.color == FrutiaColors.secondaryText
                        ? FrutiaColors.primaryBackground
                        : FrutiaColors.primaryBackground,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
