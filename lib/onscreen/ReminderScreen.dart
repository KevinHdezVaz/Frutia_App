import 'package:flutter/material.dart';
import 'package:user_auth_crudd10/utils/colors.dart';
import 'package:user_auth_crudd10/auth/auth_check.dart'; // Import AuthCheckMain for navigation

class ReminderScreen extends StatefulWidget {
  @override
  _ReminderScreenState createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

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
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: Interval(0.3, 0.8, curve: Curves.elasticOut)),
    );
    _slideAnimation =
        Tween<Offset>(begin: Offset(0, 0.5), end: Offset(0, 0)).animate(
      CurvedAnimation(
          parent: _controller,
          curve: Interval(0.5, 1.0, curve: Curves.easeOut)),
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
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back_ios, color: FrutiaColors.primaryBackground),
          onPressed: () => Navigator.pop(context),
        ),
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
                          '¡Recuerda!',
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
                            gradient: LinearGradient(
                              colors: [
                                FrutiaColors.primaryBackground,
                                Color(0xFFFFE0B2),
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
                                    _buildReminderTile(
                                      icon: Icons.warning,
                                      text:
                                          'Los planes genéricos no funcionan. Cada cuerpo es distinto.',
                                    ),
                                    SizedBox(height: 12),
                                    _buildReminderTile(
                                      icon: Icons.block,
                                      text:
                                          'No existen soluciones mágicas ni "tés milagrosos".',
                                    ),
                                    SizedBox(height: 12),
                                    _buildReminderTile(
                                      icon: Icons.account_balance_wallet,
                                      text:
                                          'Tu presupuesto importa y debería ser parte del plan.',
                                    ),
                                    SizedBox(height: 12),
                                    _buildReminderTile(
                                      icon: Icons.favorite,
                                      text:
                                          'Tu comida debe gustarte, no estresarte.',
                                    ),
                                    SizedBox(height: 12),
                                    _buildReminderTile(
                                      icon: Icons.lightbulb,
                                      text:
                                          'Estamos acá para darte un plan real, inteligente y hecho para ti.',
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
                                    'assets/images/fruta3.jpg',
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.warning_rounded,
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
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          'Respaldo por Profesionales',
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
                                FrutiaColors.nutrition.withOpacity(0.1),
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
                                    _buildProfessionalTile(
                                      icon: Icons.person,
                                      title: 'Nutricionista 1',
                                    ),
                                    SizedBox(height: 12),
                                    _buildProfessionalTile(
                                      icon: Icons.medical_services,
                                      title: 'Médico 1',
                                    ),
                                    SizedBox(height: 12),
                                    _buildProfessionalTile(
                                      icon: Icons.medical_services,
                                      title: 'Médico 2',
                                    ),
                                    SizedBox(height: 12),
                                    _buildProfessionalTile(
                                      icon: Icons.fitness_center,
                                      title: 'Entrenador Certificado 1',
                                    ),
                                    SizedBox(height: 12),
                                    _buildProfessionalTile(
                                      icon: Icons.fitness_center,
                                      title: 'Entrenador Certificado 2',
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
                                    'assets/images/fruta1.jpg',
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.medical_services,
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
                      // Button Row: Volver and Finalizar buttons
                      SlideTransition(
                        position: _slideAnimation,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    FrutiaColors.accent.withOpacity(0.2),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  side: BorderSide(color: FrutiaColors.accent),
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.arrow_back,
                                      color: FrutiaColors.accent),
                                  SizedBox(width: 8),
                                  Text(
                                    'Volver',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: FrutiaColors.accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () {
                                // Navigate to AuthCheckMain to handle login flow
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AuthCheckMain()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: FrutiaColors.accent,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 8,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Finalizar',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: FrutiaColors.primaryBackground,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.check,
                                      color: FrutiaColors.primaryBackground),
                                ],
                              ),
                            ),
                          ],
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

  Widget _buildReminderTile({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: FrutiaColors.accent,
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

  Widget _buildProfessionalTile(
      {required IconData icon, required String title}) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: FrutiaColors.accent,
          radius: 16,
          child: Icon(
            icon,
            color: FrutiaColors.primaryBackground,
            size: 18,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF2D2D2D),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
