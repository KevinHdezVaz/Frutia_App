import 'package:Frutia/pages/screens/datosPersonales/SummaryScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:Frutia/utils/colors.dart';

class DietSccreen extends StatefulWidget {
  final int age;
  final String sex;
  final double weight;
  final bool hasConditions;
  final String conditions;
  final bool isSmoker;
  final bool isPregnant;
  final bool hasAllergies;
  final String allergies;

  const DietSccreen({
    Key? key,
    required this.age,
    required this.sex,
    required this.weight,
    required this.hasConditions,
    required this.conditions,
    required this.isSmoker,
    required this.isPregnant,
    required this.hasAllergies,
    required this.allergies,
  }) : super(key: key);

  @override
  _DietScreenState createState() => _DietScreenState();
}

class _DietScreenState extends State<DietSccreen> {
  String _dietStyle = 'Omnívoro';
  bool _cooksForSelf = false;
  bool _eatsOutOften = false;
  String _budget = 'S/ 50 - S/ 100';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '¿Listo para un plan hecho solo para ti?',
          style: GoogleFonts.lato(
            fontSize: 20,
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFD1B3), Color(0xFFFF6F61)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Responde estas preguntas para armar tu plan según tu vida',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: FrutiaColors.secondaryText,
                  ),
                ).animate().fadeIn(duration: 800.ms),
                const SizedBox(height: 24),
                Card(
                  elevation: 4,
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
                          'Pantalla 2: Tu alimentación',
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: FrutiaColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButton<String>(
                          value: _dietStyle,
                          onChanged: (String? newValue) {
                            setState(() {
                              _dietStyle = newValue!;
                            });
                          },
                          items: <String>['Omnívoro', 'Vegetariano', 'Vegano', 'Keto / Low carb']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: GoogleFonts.lato()),
                            );
                          }).toList(),
                          underline: const SizedBox(),
                          style: GoogleFonts.lato(color: FrutiaColors.primaryText),
                          dropdownColor: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        CheckboxListTile(
                          title: Text('¿Cocinas tú o alguien por ti?', style: GoogleFonts.lato()),
                          value: _cooksForSelf,
                          onChanged: (bool? value) {
                            setState(() {
                              _cooksForSelf = value!;
                            });
                          },
                          activeColor: FrutiaColors.accent,
                        ),
                        CheckboxListTile(
                          title: Text('¿Comes fuera a menudo?', style: GoogleFonts.lato()),
                          value: _eatsOutOften,
                          onChanged: (bool? value) {
                            setState(() {
                              _eatsOutOften = value!;
                            });
                          },
                          activeColor: FrutiaColors.accent,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '¿Cuál es tu presupuesto semanal para comida?',
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: FrutiaColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButton<String>(
                          value: _budget,
                          onChanged: (String? newValue) {
                            setState(() {
                              _budget = newValue!;
                            });
                          },
                          items: <String>['S/ 0 - S/ 50', 'S/ 50 - S/ 100', 'S/ 100 - S/ 150', 'Más de S/ 150']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: GoogleFonts.lato()),
                            );
                          }).toList(),
                          underline: const SizedBox(),
                          style: GoogleFonts.lato(color: FrutiaColors.primaryText),
                          dropdownColor: Colors.white,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SummaryScreen(
                                age: widget.age,
                                sex: widget.sex,
                                weight: widget.weight,
                                hasConditions: widget.hasConditions,
                                conditions: widget.conditions,
                                isSmoker: widget.isSmoker,
                                isPregnant: widget.isPregnant,
                                hasAllergies: widget.hasAllergies,
                                allergies: widget.allergies,
                                dietStyle: _dietStyle,
                                cooksForSelf: _cooksForSelf,
                                eatsOutOften: _eatsOutOften,
                                budget: _budget,
                              )),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: FrutiaColors.accent,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Siguiente',
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: FrutiaColors.primaryBackground,
                            ),
                          ),
                        ).animate().fadeIn(duration: 800.ms),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}