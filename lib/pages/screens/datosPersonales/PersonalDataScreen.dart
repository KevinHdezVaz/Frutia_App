import 'package:Frutia/pages/screens/datosPersonales/AboutYouScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:Frutia/utils/colors.dart';

class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({Key? key}) : super(key: key);

  @override
  _PersonalDataScreenState createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  int _age = 30;
  String _sex = 'Hombre';
  double _weight = 70.0;
  bool _hasConditions = false;
  String _conditions = '';

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
                          'Datos personales',
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: FrutiaColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Edad',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          controller: TextEditingController(text: _age.toString()),
                          onChanged: (value) {
                            setState(() {
                              _age = int.tryParse(value) ?? 30;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButton<String>(
                          value: _sex,
                          onChanged: (String? newValue) {
                            setState(() {
                              _sex = newValue!;
                            });
                          },
                          items: <String>['Hombre', 'Mujer', 'Otro']
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
                        TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Peso (kg)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          controller: TextEditingController(text: _weight.toStringAsFixed(1)),
                          onChanged: (value) {
                            setState(() {
                              _weight = double.tryParse(value) ?? 70.0;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        CheckboxListTile(
                          title: Text('¿Tienes alguna condición médica? (diabetes, hipertensión, etc.)', style: GoogleFonts.lato()),
                          value: _hasConditions,
                          onChanged: (bool? value) {
                            setState(() {
                              _hasConditions = value!;
                            });
                          },
                          activeColor: FrutiaColors.accent,
                        ),
                        if (_hasConditions) ...[
                          const SizedBox(height: 8),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Condiciones (ejemplo: diabetes, hipertensión)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _conditions = value;
                              });
                            },
                          ),
                        ],
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => GoalsScreen(
                                age: _age,
                                sex: _sex,
                                weight: _weight,
                                hasConditions: _hasConditions,
                                conditions: _conditions,
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

class GoalsScreen extends StatelessWidget {
  final int age;
  final String sex;
  final double weight;
  final bool hasConditions;
  final String conditions;

  const GoalsScreen({
    Key? key,
    required this.age,
    required this.sex,
    required this.weight,
    required this.hasConditions,
    required this.conditions,
  }) : super(key: key);

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
                          'Objetivos',
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: FrutiaColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CheckboxListTile(
                          title: Text('¿Qué te gustaría lograr con este plan?', style: GoogleFonts.lato()),
                          value: true,
                          onChanged: null,
                          activeColor: FrutiaColors.accent,
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CheckboxListTile(
                                title: Text('Bajar grasa', style: GoogleFonts.lato()),
                                value: true,
                                onChanged: (bool? value) {},
                                activeColor: FrutiaColors.accent,
                              ),
                              CheckboxListTile(
                                title: Text('Aumentar masa muscular', style: GoogleFonts.lato()),
                                value: false,
                                onChanged: (bool? value) {},
                                activeColor: FrutiaColors.accent,
                              ),
                              CheckboxListTile(
                                title: Text('Mejorar rendimiento deportivo', style: GoogleFonts.lato()),
                                value: false,
                                onChanged: (bool? value) {},
                                activeColor: FrutiaColors.accent,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '¿Con qué frecuencia entrenas?',
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: FrutiaColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButton<String>(
                          value: '3-5 veces por semana',
                          onChanged: (String? newValue) {},
                          items: <String>['No entreno', '1-2 veces por semana', '3-5 veces por semana', '5+ veces por semana']
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
                              MaterialPageRoute(builder: (context) => AboutYouScreen(
                                age: age,
                                sex: sex,
                                weight: weight,
                                hasConditions: hasConditions,
                                conditions: conditions,
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