import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:user_auth_crudd10/utils/colors.dart'; // Import FrutiaColors

class QuestionnairePage extends StatefulWidget {
  const QuestionnairePage({super.key});

  @override
  State<QuestionnairePage> createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends State<QuestionnairePage> {
  final _fullNameController = TextEditingController();
  final _ageController = TextEditingController();
  int _weight = 70; // Default weight
  int _height = 175; // Default height

  void _incrementWeight() {
    setState(() {
      _weight++;
    });
  }

  void _decrementWeight() {
    setState(() {
      if (_weight > 0) _weight--;
    });
  }

  void _incrementHeight() {
    setState(() {
      _height++;
    });
  }

  void _decrementHeight() {
    setState(() {
      if (_height > 0) _height--;
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // Define size here

    return Scaffold(
      backgroundColor: FrutiaColors.primaryBackground, // White background
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: FrutiaColors.accent),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Cuestionario',
          style: TextStyle(
            color: Color(0xFF2D2D2D),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Paso 1 de 4',
                    style: TextStyle(
                      color: FrutiaColors.secondaryText,
                      fontSize: 14,
                    ),
                  ),
                  Container(
                    height: 4,
                    width: 50,
                    color: FrutiaColors.accent, // Red progress bar
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Title
              Text(
                'Sobre Ti',
                style: GoogleFonts.lato(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              SizedBox(height: 10),
              // Subtitle
              Text(
                'Cuéntanos un poco sobre ti para empezar.',
                style: TextStyle(
                  color: FrutiaColors.secondaryText,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 30),
              // Full Name Field
              TextField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'Nombre completo',
                  labelStyle: TextStyle(color: Color(0xFF2D2D2D)),
                  prefixIcon: Icon(Icons.person, color: FrutiaColors.accent),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: FrutiaColors.secondaryText,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: FrutiaColors.accent,
                      width: 1.5,
                    ),
                  ),
                  filled: true,
                  fillColor: FrutiaColors.primaryBackground,
                ),
                style: TextStyle(color: Color(0xFF2D2D2D)),
              ),
              SizedBox(height: 20),
              // Age Field
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Edad',
                  labelStyle: TextStyle(color: Color(0xFF2D2D2D)),
                  prefixIcon:
                      Icon(Icons.calendar_today, color: FrutiaColors.accent),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: FrutiaColors.secondaryText,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: FrutiaColors.accent,
                      width: 1.5,
                    ),
                  ),
                  filled: true,
                  fillColor: FrutiaColors.primaryBackground,
                ),
                style: TextStyle(color: Color(0xFF2D2D2D)),
              ),
              SizedBox(height: 20),
              // Weight Field
              Row(
                children: [
                  Icon(Icons.fitness_center, color: FrutiaColors.accent),
                  SizedBox(width: 10),
                  Text(
                    'Peso',
                    style: TextStyle(
                      color: Color(0xFF2D2D2D),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: 20),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: FrutiaColors.secondaryText),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon:
                                Icon(Icons.remove, color: FrutiaColors.accent),
                            onPressed: _decrementWeight,
                          ),
                          Text(
                            '$_weight kg',
                            style: TextStyle(
                              color: Color(0xFF2D2D2D),
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add, color: FrutiaColors.accent),
                            onPressed: _incrementWeight,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Height Field
              Row(
                children: [
                  Icon(Icons.straighten, color: FrutiaColors.accent),
                  SizedBox(width: 10),
                  Text(
                    'Altura',
                    style: TextStyle(
                      color: Color(0xFF2D2D2D),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: 20),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: FrutiaColors.secondaryText),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon:
                                Icon(Icons.remove, color: FrutiaColors.accent),
                            onPressed: _decrementHeight,
                          ),
                          Text(
                            '$_height cm',
                            style: TextStyle(
                              color: Color(0xFF2D2D2D),
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add, color: FrutiaColors.accent),
                            onPressed: _incrementHeight,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
              // Next Button
              Center(
                child: Container(
                  width: size.width * 0.8, // Use defined size here
                  child: ElevatedButton(
                    onPressed: () {
                      // Add navigation or form submission logic here
                      print('Nombre: ${_fullNameController.text}');
                      print('Edad: ${_ageController.text}');
                      print('Peso: $_weight kg');
                      print('Altura: $_height cm');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FrutiaColors.accent,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 8,
                    ),
                    child: Text(
                      'Siguiente',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: FrutiaColors.primaryBackground,
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
}
