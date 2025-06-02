import 'package:flutter/material.dart';
import 'package:user_auth_crudd10/onscreen/ReminderScreen.dart';
import 'package:user_auth_crudd10/utils/colors.dart';

class HowItWorksScreen extends StatefulWidget {
  @override
  _HowItWorksScreenState createState() => _HowItWorksScreenState();
}

class _HowItWorksScreenState extends State<HowItWorksScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: Interval(0.0, 0.5, curve: Curves.easeInOut)),
    );
    _slideAnimation =
        Tween<Offset>(begin: Offset(0, 0.5), end: Offset(0, 0)).animate(
      CurvedAnimation(
          parent: _controller,
          curve: Interval(0.3, 0.8, curve: Curves.easeOut)),
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: Interval(0.5, 1.0, curve: Curves.elasticOut)),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: FrutiaColors.accent,
        elevation: 0,
        title: Text(
          "Frutia",
          style: TextStyle(
            color: FrutiaColors.primaryBackground,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: FrutiaColors.primaryBackground,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          '¿Cómo Funciona la App?',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: FrutiaColors.primaryBackground,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    'assets/images/fruta2.jpg', // Ruta relativa a tu imagen
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.person_rounded,
                                        size: 120,
                                        color: FrutiaColors.accent,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildFeatureTile(
                                      icon: Icons.person_search,
                                      text:
                                          'Nos cuentas sobre ti: tus objetivos, gustos, rutina y presupuesto.',
                                    ),
                                    SizedBox(height: 12),
                                    _buildFeatureTile(
                                      icon: Icons.restaurant_menu,
                                      text:
                                          'Creamos un plan de nutrición hecho a tu medida, adaptado a tu presupuesto y lo que te gusta comer.',
                                    ),
                                    SizedBox(height: 12),
                                    _buildFeatureTile(
                                      icon: Icons.style,
                                      text:
                                          'Tú eliges cómo quieres que te trate la app, ¡se adapta a tu estilo!',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 32),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          '¿Qué Plan Ofrecemos?',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                FrutiaColors.nutrition.withOpacity(0.3),
                                FrutiaColors.nutrition.withOpacity(0.1)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Plan Frutia',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2D2D2D),
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    _buildFeatureTile(
                                      icon: Icons.local_dining,
                                      text: 'Nutrición virtual personalizada',
                                    ),
                                    SizedBox(height: 8),
                                    _buildFeatureTile(
                                      icon: Icons.track_changes,
                                      text:
                                          'Seguimiento de alimentos, hábitos y peso',
                                    ),
                                    SizedBox(height: 8),
                                    _buildFeatureTile(
                                      icon: Icons.refresh,
                                      text:
                                          'Restablece comida según tu progreso',
                                    ),
                                    SizedBox(height: 8),
                                    _buildFeatureTile(
                                      icon: Icons.history,
                                      text:
                                          'Guardado histórico de conversaciones',
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                flex: 1,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    'assets/images/fruta4.jpg', // Ruta relativa a tu imagen
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.person_rounded,
                                        size: 120,
                                        color: FrutiaColors.accent,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 32),
                      SlideTransition(
                        position: _slideAnimation,
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ReminderScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: FrutiaColors.accent,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Siguiente',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: FrutiaColors.primaryBackground,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward,
                                    color: FrutiaColors.primaryBackground),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: FrutiaColors.accent, // Cambiado a rojo (accent color)
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Eliminado el IconButton de retroceso
          Expanded(
            child: Center(
              child: Text(
                'Frutia',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors
                      .white, // Texto en blanco para contrastar con el fondo rojo
                ),
              ),
            ),
          ),
          // Se mantiene el SizedBox para equilibrio visual
          SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildFeatureTile({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: FrutiaColors.nutrition,
          size: 24,
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF2D2D2D),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
