import 'package:Frutia/pages/screens/datosPersonales/DietScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:Frutia/utils/colors.dart';

class AboutYouScreen extends StatefulWidget {
  final int age;
  final String sex;
  final double weight;
  final bool hasConditions;
  final String conditions;

  const AboutYouScreen({
    Key? key,
    required this.age,
    required this.sex,
    required this.weight,
    required this.hasConditions,
    required this.conditions,
  }) : super(key: key);

  @override
  _AboutYouScreenState createState() => _AboutYouScreenState();
}

class _AboutYouScreenState extends State<AboutYouScreen> {
  bool _isSmoker = false;
  bool _isPregnant = false;
  bool _hasAllergies = false;
  String _allergies = '';

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
                          'Pantalla 1: Sobre ti',
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: FrutiaColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CheckboxListTile(
                          title: Text('¿Fumas?', style: GoogleFonts.lato()),
                          value: _isSmoker,
                          onChanged: (bool? value) {
                            setState(() {
                              _isSmoker = value!;
                            });
                          },
                          activeColor: FrutiaColors.accent,
                        ),
                        CheckboxListTile(
                          title: Text('¿Estás embarazada?', style: GoogleFonts.lato()),
                          value: _isPregnant,
                          onChanged: (bool? value) {
                            setState(() {
                              _isPregnant = value!;
                            });
                          },
                          activeColor: FrutiaColors.accent,
                        ),
                        CheckboxListTile(
                          title: Text('¿Tienes alergias?', style: GoogleFonts.lato()),
                          value: _hasAllergies,
                          onChanged: (bool? value) {
                            setState(() {
                              _hasAllergies = value!;
                            });
                          },
                          activeColor: FrutiaColors.accent,
                        ),
                        if (_hasAllergies) ...[
                          const SizedBox(height: 8),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Alergias (ejemplo: cacahuates, mariscos)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _allergies = value;
                              });
                            },
                          ),
                        ],
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => DietSccreen(
                                age: widget.age,
                                sex: widget.sex,
                                weight: widget.weight,
                                hasConditions: widget.hasConditions,
                                conditions: widget.conditions,
                                isSmoker: _isSmoker,
                                isPregnant: _isPregnant,
                                hasAllergies: _hasAllergies,
                                allergies: _allergies,
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