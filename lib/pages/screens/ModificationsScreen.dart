import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:Frutia/utils/colors.dart';

class ModificationsScreen extends StatefulWidget {
  const ModificationsScreen({Key? key}) : super(key: key);

  @override
  _ModificationsScreenState createState() => _ModificationsScreenState();
}

class _ModificationsScreenState extends State<ModificationsScreen> {
  String _objective = 'Mantenimiento';
  bool _glutenFree = false;
  bool _dairyFree = false;
  bool _vegan = false;
  String _avoidIngredients = '';
  double _weight = 70.0;
  double _measureMin = 90.0;
  double _measureMax = 100.0;
  String _updateFrequency = 'Semanal';
  final DateTime _lastUpdate = DateTime(2024, 5, 7);

  // Método para mostrar un SnackBar con mensaje
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.lato(color: Colors.white),
        ),
        backgroundColor: FrutiaColors.accent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar con título y botón de retroceso
      appBar: AppBar(
        title: Text(
          'MODIFICACIONES',
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
      // Cuerpo con gradiente y formulario
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              FrutiaColors.secondaryBackground,
              FrutiaColors.accent,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Texto descriptivo
                  Text(
                    'Ajusta tu dieta o actualiza tus progresos fácilmente',
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      color: FrutiaColors.primaryText,
                    ),
                  ).animate().fadeIn(duration: 800.ms).slideY(
                        begin: 0.3,
                        end: 0.0,
                        duration: 800.ms,
                        curve: Curves.easeOut,
                      ),
                  const SizedBox(height: 16),
                  // Sección de Cambios en el Plan Alimenticio
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.local_florist, color: Colors.green, size: 24),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'CAMBIOS EN EL PLAN ALIMENTICIO',
                                  style: GoogleFonts.lato(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: FrutiaColors.primaryText,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Selector de objetivo
                          DropdownButton<String>(
                            value: _objective,
                            onChanged: (String? newValue) {
                              setState(() {
                                _objective = newValue!;
                              });
                            },
                            items: <String>['Mantenimiento', 'Pérdida de peso', 'Ganancia muscular']
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
                          // Preferencias alimentarias
                          Text(
                            'Preferencias alimentarias',
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
                            title: Text('Vegana', style: GoogleFonts.lato()),
                            value: _vegan,
                            onChanged: (bool? value) {
                              setState(() {
                                _vegan = value!;
                              });
                            },
                            activeColor: FrutiaColors.accent,
                          ),
                          const SizedBox(height: 16),
                          // Ingredientes a evitar
                          Text(
                            'Ingredientes a evitar',
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: FrutiaColors.primaryText,
                            ),
                          ),
                          TextField(
                            onChanged: (value) {
                              setState(() {
                                _avoidIngredients = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'No quiero huevo, mayonesa, etc.',
                              hintStyle: GoogleFonts.lato(color: FrutiaColors.disabledText),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: FrutiaColors.accent),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: FrutiaColors.disabledText),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: FrutiaColors.accent, width: 2),
                              ),
                            ),
                            style: GoogleFonts.lato(color: FrutiaColors.primaryText),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 800.ms).slideY(
                        begin: 0.3,
                        end: 0.0,
                        duration: 800.ms,
                        curve: Curves.easeOut,
                      ),
                  const SizedBox(height: 16),
                  // Sección de Progreso Corporal
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.fitness_center, color: Colors.blueGrey, size: 24),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'PROGRESO CORPORAL',
                                  style: GoogleFonts.lato(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: FrutiaColors.primaryText,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Peso actual
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Peso actual',
                                  style: GoogleFonts.lato(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: FrutiaColors.primaryText,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 80,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  controller: TextEditingController(text: _weight.toStringAsFixed(1)),
                                  onChanged: (value) {
                                    setState(() {
                                      _weight = double.tryParse(value) ?? 70.0;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    hintText: '70',
                                    suffixText: 'kg',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                                  ),
                                  style: GoogleFonts.lato(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Medidas (opcional)
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Medidas (opcional)',
                                  style: GoogleFonts.lato(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: FrutiaColors.primaryText,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 60,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  controller: TextEditingController(text: _measureMin.toStringAsFixed(0)),
                                  onChanged: (value) {
                                    setState(() {
                                      _measureMin = double.tryParse(value) ?? 90.0;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    hintText: '90',
                                    suffixText: 'cm',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 4),
                                  ),
                                  style: GoogleFonts.lato(fontSize: 14),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'a',
                                style: GoogleFonts.lato(
                                  fontSize: 14,
                                  color: FrutiaColors.secondaryText,
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 60,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  controller: TextEditingController(text: _measureMax.toStringAsFixed(0)),
                                  onChanged: (value) {
                                    setState(() {
                                      _measureMax = double.tryParse(value) ?? 100.0;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    hintText: "100",
                                    suffixText: 'cm',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 4),
                                  ),
                                  style: GoogleFonts.lato(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Frecuencia de actualización
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Frecuencia de actualización',
                                  style: GoogleFonts.lato(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: FrutiaColors.primaryText,
                                  ),
                                ),
                              ),
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
                          const SizedBox(height: 8),
                          // Última actualización
                          Text(
                            'Última actualización: ${_lastUpdate.day}/${_lastUpdate.month}/${_lastUpdate.year}',
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              color: FrutiaColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 800.ms).slideY(
                        begin: 0.3,
                        end: 0.0,
                        duration: 800.ms,
                        curve: Curves.easeOut,
                      ),
                  const SizedBox(height: 16),
                  // Botones
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _objective = 'Mantenimiento';
                              _glutenFree = false;
                              _dairyFree = false;
                              _vegan = false;
                              _avoidIngredients = '';
                              _weight = 70.0;
                              _measureMin = 90.0;
                              _measureMax = 100.0;
                              _updateFrequency = 'Semanal';
                            });
                            _showSnackBar('Valores restablecidos');
                          },
                          child: Text(
                            'Restablecer valores',
                            style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: FrutiaColors.primaryText,
                            minimumSize: const Size(0, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _showSnackBar('Preferencias guardadas');
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Guardar cambios',
                            style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: FrutiaColors.accent,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 800.ms).slideY(
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
      ),
    );
  }
}