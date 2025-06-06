import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:Frutia/utils/colors.dart';

class CreatePlanScreen extends StatefulWidget {
  const CreatePlanScreen({Key? key}) : super(key: key);

  @override
  _CreatePlanScreenState createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends State<CreatePlanScreen> {
  String _goal = 'Pérdida de peso';
  double _currentWeight = 70.0;
  double _height = 170.0;
  int _age = 30;
  String _activityLevel = 'Moderado';
  bool _glutenFree = false;
  bool _dairyFree = false;
  bool _vegan = false;
  String _avoidIngredients = '';
  double _targetWeight = 65.0;
  int _exerciseDays = 3;
  double _waterGoal = 2.0;
  String _updateFrequency = 'Semanal';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Crea tu plan',
          style: GoogleFonts.lato(
            fontSize: 24,
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
            colors: [
              Color(0xFFFFD1B3),
              Color(0xFFFF6F61),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personaliza tu plan para alcanzar tus metas',
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: FrutiaColors.primaryText,
                  ),
                ).animate().fadeIn(duration: 800.ms).slideY(
                      begin: 0.3,
                      end: 0.0,
                      duration: 800.ms,
                      curve: Curves.easeOut,
                    ),
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
                          'Tu objetivo',
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: FrutiaColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButton<String>(
                          value: _goal,
                          onChanged: (String? newValue) {
                            setState(() {
                              _goal = newValue!;
                            });
                          },
                          items: <String>['Pérdida de peso', 'Mantenimiento', 'Ganancia muscular', 'Mejorar salud general']
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
                        Text(
                          'Datos físicos',
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: FrutiaColors.primaryText,
                          ),
                        ),
                        TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Peso actual (kg)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          controller: TextEditingController(text: _currentWeight.toStringAsFixed(1)),
                          onChanged: (value) {
                            setState(() {
                              _currentWeight = double.tryParse(value) ?? 70.0;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Altura (cm)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          controller: TextEditingController(text: _height.toStringAsFixed(1)),
                          onChanged: (value) {
                            setState(() {
                              _height = double.tryParse(value) ?? 170.0;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
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
                        const SizedBox(height: 8),
                        DropdownButton<String>(
                          value: _activityLevel,
                          onChanged: (String? newValue) {
                            setState(() {
                              _activityLevel = newValue!;
                            });
                          },
                          items: <String>['Sedentario', 'Moderado', 'Activo']
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
                        Text(
                          'Preferencias dietéticas',
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: FrutiaColors.primaryText,
                          ),
                        ),
                        CheckboxListTile(
                          title: Text('Sin gluten', style: GoogleFonts.lato()),
                          value: _glutenFree,
                          onChanged: (bool? value) {
                            setState(() {
                              _glutenFree = value!;
                            });
                          },
                          activeColor: FrutiaColors.accent,
                        ),
                        CheckboxListTile(
                          title: Text('Sin lácteos', style: GoogleFonts.lato()),
                          value: _dairyFree,
                          onChanged: (bool? value) {
                            setState(() {
                              _dairyFree = value!;
                            });
                          },
                          activeColor: FrutiaColors.accent,
                        ),
                        CheckboxListTile(
                          title: Text('Vegano', style: GoogleFonts.lato()),
                          value: _vegan,
                          onChanged: (bool? value) {
                            setState(() {
                              _vegan = value!;
                            });
                          },
                          activeColor: FrutiaColors.accent,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Ingredientes a evitar',
                            hintText: 'Ejemplo: huevos, cacahuates',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _avoidIngredients = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Metas específicas',
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: FrutiaColors.primaryText,
                          ),
                        ),
                        TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Peso objetivo (kg)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          controller: TextEditingController(text: _targetWeight.toStringAsFixed(1)),
                          onChanged: (value) {
                            setState(() {
                              _targetWeight = double.tryParse(value) ?? 65.0;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Días de ejercicio por semana',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          controller: TextEditingController(text: _exerciseDays.toString()),
                          onChanged: (value) {
                            setState(() {
                              _exerciseDays = int.tryParse(value) ?? 3;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Agua diaria (litros)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          controller: TextEditingController(text: _waterGoal.toStringAsFixed(1)),
                          onChanged: (value) {
                            setState(() {
                              _waterGoal = double.tryParse(value) ?? 2.0;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        DropdownButton<String>(
                          value: _updateFrequency,
                          onChanged: (String? newValue) {
                            setState(() {
                              _updateFrequency = newValue!;
                            });
                          },
                          items: <String>['Semanal', 'Quincenal', 'Mensual']
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
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Resumen y botón de guardar
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
                          'Resumen de tu plan',
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: FrutiaColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Objetivo: $_goal',
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            color: FrutiaColors.secondaryText,
                          ),
                        ),
                        Text(
                          'Calorías sugeridas: ~${_calculateCalories().round()} kcal (aprox.)',
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            color: FrutiaColors.secondaryText,
                          ),
                        ),
                        Text(
                          'Preferencias: ${_getPreferences()}',
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            color: FrutiaColors.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              // Guardar plan y navegar de vuelta
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '¡Plan creado con éxito!',
                                    style: GoogleFonts.lato(color: Colors.white),
                                  ),
                                  backgroundColor: FrutiaColors.accent,
                                ),
                              );
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: FrutiaColors.accent,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 8,
                            ),
                            child: Text(
                              'Guardar plan',
                              style: GoogleFonts.lato(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: FrutiaColors.primaryBackground,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms, duration: 800.ms).slideY(
                      begin: 0.3,
                      end: 0.0,
                      duration: 800.ms,
                      curve: Curves.easeOut,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Calcular calorías aproximadas usando BMR (Mifflin-St Jeor Equation)
  double _calculateCalories() {
    double bmr = 10 * _currentWeight + 6.25 * _height - 5 * _age + 5; // Para hombres
    if (_activityLevel == 'Sedentario') return bmr * 1.2;
    if (_activityLevel == 'Moderado') return bmr * 1.375;
    return bmr * 1.55; // Activo
  }

  // Obtener preferencias seleccionadas
  String _getPreferences() {
    List<String> preferences = [];
    if (_glutenFree) preferences.add('Sin gluten');
    if (_dairyFree) preferences.add('Sin lácteos');
    if (_vegan) preferences.add('Vegano');
    if (_avoidIngredients.isNotEmpty) preferences.add('Evitar: $_avoidIngredients');
    return preferences.isNotEmpty ? preferences.join(', ') : 'Ninguna';
  }
}