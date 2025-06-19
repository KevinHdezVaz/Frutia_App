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
  String _measurementType = 'Cintura'; // New state for measurement type
  final DateTime _lastUpdate = DateTime(2024, 5, 7);

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.lato(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: FrutiaColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Modificaciones',
          style: GoogleFonts.lato(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: FrutiaColors.primaryText,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: FrutiaColors.accent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personaliza tu plan de alimentación y registra tu progreso',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: FrutiaColors.secondaryText,
                    height: 1.5,
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(
                      begin: 0.2,
                      end: 0.0,
                      duration: 600.ms,
                      curve: Curves.easeOut,
                    ),
                const SizedBox(height: 24),
                // Sección de Cambios en el Plan Alimenticio
                Card(
                  elevation: 6,
                  shadowColor: Colors.grey.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.local_florist,
                                color: FrutiaColors.accent, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Cambios en el Plan Alimenticio',
                                style: GoogleFonts.lato(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: FrutiaColors.primaryText,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildDropdown(
                          value: _objective,
                          items: [
                            'Mantenimiento',
                            'Pérdida de peso',
                            'Ganancia muscular'
                          ],
                          onChanged: (String? newValue) {
                            setState(() {
                              _objective = newValue!;
                            });
                          },
                          label: 'Objetivo',
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Preferencias alimentarias',
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: FrutiaColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildCheckboxTile(
                          title: 'Sin gluten',
                          value: _glutenFree,
                          onChanged: (bool? value) {
                            setState(() {
                              _glutenFree = value!;
                            });
                          },
                        ),
                        _buildCheckboxTile(
                          title: 'Sin lácteos',
                          value: _dairyFree,
                          onChanged: (bool? value) {
                            setState(() {
                              _dairyFree = value!;
                            });
                          },
                        ),
                        _buildCheckboxTile(
                          title: 'Vegana',
                          value: _vegan,
                          onChanged: (bool? value) {
                            setState(() {
                              _vegan = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          label: 'Ingredientes a evitar',
                          hintText: 'Escribe ingredientes, ej. huevo, mayonesa',
                          onChanged: (value) {
                            setState(() {
                              _avoidIngredients = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(
                      begin: 0.2,
                      end: 0.0,
                      duration: 600.ms,
                      curve: Curves.easeOut,
                    ),
                const SizedBox(height: 24),
                // Sección de Progreso Corporal
                Card(
                  elevation: 6,
                  shadowColor: Colors.grey.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.fitness_center,
                                color: FrutiaColors.accent, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Progreso Corporal',
                                style: GoogleFonts.lato(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: FrutiaColors.primaryText,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildNumberInput(
                          label: 'Peso actual',
                          value: _weight,
                          suffix: 'kg',
                          onChanged: (value) {
                            setState(() {
                              _weight = double.tryParse(value) ?? 70.0;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Medidas (opcional)',
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: FrutiaColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildDropdown(
                          value: _measurementType,
                          items: ['Cintura', 'Pecho', 'Caderas', 'Brazo', 'Pierna'],
                          onChanged: (String? newValue) {
                            setState(() {
                              _measurementType = newValue!;
                            });
                          },
                          label: 'Tipo de medida',
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildNumberInput(
                                label: '',
                                value: _measureMin,
                                suffix: 'cm',
                                onChanged: (value) {
                                  setState(() {
                                    _measureMin = double.tryParse(value) ?? 90.0;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'a',
                              style: GoogleFonts.lato(
                                fontSize: 16,
                                color: FrutiaColors.secondaryText,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildNumberInput(
                                label: '',
                                value: _measureMax,
                                suffix: 'cm',
                                onChanged: (value) {
                                  setState(() {
                                    _measureMax = double.tryParse(value) ?? 100.0;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildDropdown(
                          value: _updateFrequency,
                          items: ['Semanal', 'Quincenal', 'Mensual'],
                          onChanged: (String? newValue) {
                            setState(() {
                              _updateFrequency = newValue!;
                            });
                          },
                          label: 'Frecuencia de actualización',
                        ),
                        const SizedBox(height: 12),
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
                ).animate().fadeIn(duration: 600.ms).slideY(
                      begin: 0.2,
                      end: 0.0,
                      duration: 600.ms,
                      curve: Curves.easeOut,
                    ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildButton(
                        text: 'Restablecer valores',
                        color: Colors.grey[200]!,
                        textColor: FrutiaColors.primaryText,
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
                            _measurementType = 'Cintura';
                          });
                          _showSnackBar('Valores restablecidos');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildButton(
                        text: 'Guardar cambios',
                        color: FrutiaColors.accent,
                        textColor: Colors.white,
                        onPressed: () {
                          _showSnackBar('Preferencias guardadas');
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 600.ms).slideY(
                      begin: 0.2,
                      end: 0.0,
                      duration: 600.ms,
                      curve: Curves.easeOut,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: FrutiaColors.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: FrutiaColors.disabledText),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: value,
            onChanged: onChanged,
            items: items.map<DropdownMenuItem<String>>((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item, style: GoogleFonts.lato(fontSize: 16)),
              );
            }).toList(),
            isExpanded: true,
            underline: const SizedBox(),
            style: GoogleFonts.lato(color: FrutiaColors.primaryText),
            dropdownColor: Colors.white,
            icon: const Icon(Icons.arrow_drop_down, color: FrutiaColors.accent),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return CheckboxListTile(
      title: Text(
        title,
        style: GoogleFonts.lato(
          fontSize: 16,
          color: FrutiaColors.primaryText,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: FrutiaColors.accent,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildTextField({
    required String label,
    required String hintText,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: FrutiaColors.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.lato(color: FrutiaColors.disabledText),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: FrutiaColors.disabledText),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: FrutiaColors.disabledText),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: FrutiaColors.accent, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          style: GoogleFonts.lato(
            color: FrutiaColors.primaryText,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildNumberInput({
    required String label,
    required double value,
    required String suffix,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: FrutiaColors.primaryText,
            ),
          ),
        if (label.isNotEmpty) const SizedBox(height: 8),
        TextField(
          keyboardType: TextInputType.number,
          textAlign: TextAlign.start,
          controller: TextEditingController(text: value.toStringAsFixed(1)),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: value.toStringAsFixed(1),
            suffixText: suffix

            ,border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: FrutiaColors.disabledText),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: FrutiaColors.disabledText),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: FrutiaColors.accent, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          style: GoogleFonts.lato(
            color: FrutiaColors.primaryText,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    required String text,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        minimumSize: const Size(0, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        shadowColor: Colors.grey.withOpacity(0.3),
      ),
      child: Text(
        text,
        style: GoogleFonts.lato(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}