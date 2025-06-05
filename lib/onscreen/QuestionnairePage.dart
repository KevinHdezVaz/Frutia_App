import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:Frutia/auth/auth_check.dart';
import 'package:Frutia/auth/login_page.dart';
import 'package:Frutia/utils/colors.dart';

class PersonalDataPage extends StatefulWidget {
  final VoidCallback showLoginPage;

  const PersonalDataPage({super.key, required this.showLoginPage});

  @override
  State<PersonalDataPage> createState() => _PersonalDataPageState();
}

class _PersonalDataPageState extends State<PersonalDataPage> {
  /// Clave global para el formulario
  final _formKey = GlobalKey<FormBuilderState>();

  /// Valores iniciales para los sliders
  double _height = 1.70; // Altura en metros (inicialmente 170 cm = 1.70 mt)
  double _weight = 70.0; // Peso en kg
  double _age = 25.0; // Edad en años
  String _selectedSex = 'Masculino';

  /// Método para manejar el envío del formulario y cerrar el modal
  void _submitForm() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState?.value;
      debugPrint('Formulario enviado: $formData');
      Navigator.pop(context); // Cierra el modal
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor completa todos los campos correctamente.',
            style: TextStyle(color: FrutiaColors.primaryBackground),
          ),
          backgroundColor: FrutiaColors.accent,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent, // Fondo transparente
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Card(
            elevation: 20,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: Colors.white, // Fondo semitransparente del card
            child: Container(
              width: size.width * 0.9,
              padding: const EdgeInsets.all(16.0),
              child: FormBuilder(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Título animado
                    Text(
                      'Completa tus datos personales',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: FrutiaColors.accent,
                      ),
                    ).animate().fadeIn(duration: 800.ms).slideY(
                        begin: 0.3,
                        end: 0.0,
                        duration: 800.ms,
                        curve: Curves.easeOut),

                    const SizedBox(height: 30),

                    // Altura (Slider) - Solo en metros
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estatura (mt): ${_height.toStringAsFixed(2)} mt',
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            color: Color(0xFF2D2D2D),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SfSlider(
                          min: 0.5, // 50 cm = 0.5 mt
                          max: 2.1, // 250 cm = 2.5 mt
                          value: _height,
                          interval: 0.5, // Intervalos de 0.5 mt (50 cm)
                          activeColor: Colors.orange,
                          showTicks: true,
                          showLabels: true,
                          enableTooltip: false, // Desactiva el tooltip
                          minorTicksPerInterval: 1,
                          onChanged: (dynamic value) {
                            setState(() {
                              _height = value;
                            });
                          },
                        )
                            .animate()
                            .fadeIn(delay: 200.ms, duration: 800.ms)
                            .slideX(
                                begin: -0.2,
                                end: 0.0,
                                duration: 800.ms,
                                curve: Curves.easeOut),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Peso (Slider)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Peso (kg): ${_weight.toStringAsFixed(1)} kg',
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            color: Color(0xFF2D2D2D),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SfSlider(
                          min: 20.0,
                          max: 150.0,
                          value: _weight,
                          activeColor: Colors.orange,
                          interval: 40,
                          showTicks: true,
                          showLabels: true,
                          enableTooltip: false, // Desactiva el tooltip
                          minorTicksPerInterval: 1,
                          onChanged: (dynamic value) {
                            setState(() {
                              _weight = value;
                            });
                          },
                        )
                            .animate()
                            .fadeIn(delay: 400.ms, duration: 800.ms)
                            .slideX(
                                begin: -0.2,
                                end: 0.0,
                                duration: 800.ms,
                                curve: Curves.easeOut),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Edad (Slider)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edad (años): ${_age.round()} años',
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            color: Color(0xFF2D2D2D),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SfSlider(
                          min: 0.0,
                          max: 50.0,
                          value: _age,
                          interval: 20,
                          showTicks: true,
                          activeColor: Colors.orange,
                          showLabels: true,
                          enableTooltip: false, // Desactiva el tooltip
                          minorTicksPerInterval: 1,
                          onChanged: (dynamic value) {
                            setState(() {
                              _age = value;
                            });
                          },
                        )
                            .animate()
                            .fadeIn(delay: 600.ms, duration: 800.ms)
                            .slideX(
                                begin: -0.2,
                                end: 0.0,
                                duration: 800.ms,
                                curve: Curves.easeOut),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Sexo (Dropdown)
                    FormBuilderDropdown<String>(
                      name: 'sex',
                      decoration: InputDecoration(
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
                        labelText: "Sexo",
                        labelStyle: const TextStyle(color: Color(0xFF2D2D2D)),
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: FrutiaColors.accent,
                        ),
                        filled: true,
                        fillColor: FrutiaColors.primaryBackground,
                      ),
                      style: const TextStyle(color: Color(0xFF2D2D2D)),
                      dropdownColor: FrutiaColors.primaryBackground,
                      initialValue: _selectedSex,
                      items: ['Masculino', 'Femenino', 'Otro']
                          .map((String value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ))
                          .toList(),
                      validator: FormBuilderValidators.required(
                          errorText: 'Selecciona tu sexo.'),
                      onChanged: (value) {
                        setState(() {
                          _selectedSex = value!;
                        });
                      },
                    ).animate().fadeIn(delay: 800.ms, duration: 800.ms).slideX(
                        begin: -0.2,
                        end: 0.0,
                        duration: 800.ms,
                        curve: Curves.easeOut),

                    const SizedBox(height: 40),

                    // Botón de envío
                    Container(
                      width: size.width * 0.8,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FrutiaColors.accent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
                    ).animate().fadeIn(delay: 1000.ms, duration: 800.ms).scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.0, 1.0),
                        duration: 800.ms,
                        curve: Curves.easeOut),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
