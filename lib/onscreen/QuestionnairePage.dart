import 'package:Frutia/services/profile_service.dart';
import 'package:Frutia/utils/colors.dart';
import 'package:Frutia/utils/gender_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class PersonalDataPage extends StatefulWidget {
  final VoidCallback onSuccess;

  const PersonalDataPage({
    super.key,
    required this.onSuccess,
  });

  @override
  State<PersonalDataPage> createState() => _PersonalDataPageState();
}

class _PersonalDataPageState extends State<PersonalDataPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final ProfileService _profileService = ProfileService();
  bool _isLoading = false;

  double _height = 170.0;
  double _weight = 70.0;
  double _age = 25.0;

  Future<void> _submitForm() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() => _isLoading = true);

      final formData = _formKey.currentState!.value;
      final profileData = {
        'height': _height.round().toString(),
        'weight': _weight.toStringAsFixed(1),
        'age': _age.round().toString(),
        'sex': formData['sex'],
      };

      try {
        await _profileService.saveProfile(profileData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('¡Datos guardados con éxito!'),
                backgroundColor: Colors.green),
          );

          // Eliminamos Navigator.pop(context) y solo llamamos al callback
          widget.onSuccess();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error al guardar el perfil: $e'),
                backgroundColor: Colors.redAccent),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.6),
      body: Center(
        child: Card(
          elevation: 20,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(60.0),
                  child: CircularProgressIndicator(color: FrutiaColors.accent),
                )
              : ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.9,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: FormBuilder(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Cuéntanos un poco sobre ti',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: FrutiaColors.primaryText,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Estos datos son esenciales para crear tu plan.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                color: FrutiaColors.secondaryText,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildHeightSlider(),
                            const SizedBox(height: 20),
                            _buildWeightSlider(),
                            const SizedBox(height: 20),
                            _buildAgeSlider(),
                            const SizedBox(height: 20),
                            _buildSexSelector(),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _submitForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: FrutiaColors.accent,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Guardar y Continuar',
                                  style: GoogleFonts.lato(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeightSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estatura: ${_height.round()} cm',
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove, color: FrutiaColors.accent),
              onPressed: () {
                setState(() {
                  _height = (_height - 1).clamp(120.0, 220.0);
                });
              },
            ),
            Expanded(
              child: SfSlider(
                min: 120.0,
                max: 220.0,
                value: _height,
                inactiveColor: Colors.grey[300],
                showTicks: true,
                showLabels: true,
                enableTooltip: false,
                activeColor: FrutiaColors.accent,
                onChanged: (dynamic value) => setState(() => _height = value),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: FrutiaColors.accent),
              onPressed: () {
                setState(() {
                  _height = (_height + 1).clamp(120.0, 220.0);
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeightSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Peso: ${_weight.toStringAsFixed(1)} kg',
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove, color: FrutiaColors.accent),
              onPressed: () {
                setState(() {
                  _weight = (_weight - 0.5).clamp(30.0, 180.0);
                });
              },
            ),
            Expanded(
              child: SfSlider(
                min: 30.0,
                max: 180.0,
                value: _weight,
                interval: 50,
                showTicks: true,
                showLabels: true,
                enableTooltip: false,
                activeColor: FrutiaColors.accent,
                inactiveColor: Colors.grey[300],
                onChanged: (dynamic value) => setState(() => _weight = value),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: FrutiaColors.accent),
              onPressed: () {
                setState(() {
                  _weight = (_weight + 0.5).clamp(30.0, 180.0);
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAgeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Edad: ${_age.round()} años',
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove, color: FrutiaColors.accent),
              onPressed: () {
                setState(() {
                  _age = (_age - 1).clamp(16.0, 90.0);
                });
              },
            ),
            Expanded(
              child: SfSlider(
                min: 16.0,
                max: 60.0,
                value: _age,
                interval: 20,
                showTicks: true,
                enableTooltip: false,
                inactiveColor: Colors.grey[300],
                showLabels: true,
                activeColor: FrutiaColors.accent,
                onChanged: (dynamic value) => setState(() => _age = value),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: FrutiaColors.accent),
              onPressed: () {
                setState(() {
                  _age = (_age + 1).clamp(16.0, 90.0);
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSexSelector() {
    return FormBuilderField<String>(
      name: 'sex',
      initialValue: 'Masculino',
      validator: FormBuilderValidators.required(
        errorText: 'Por favor, selecciona una opción.',
      ),
      builder: (FormFieldState<String> field) {
        return Column(
          children: [
            const SizedBox(height: 10),
            Text(
              'Me identifico como: ',
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GenderCard(
                    title: 'Masculino',
                    icon: Icons.male,
                    value: 'Masculino',
                    selectedValue: field.value,
                    onTap: (value) => field.didChange(value),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GenderCard(
                    title: 'Femenino',
                    icon: Icons.female,
                    value: 'Femenino',
                    selectedValue: field.value,
                    onTap: (value) => field.didChange(value),
                  ),
                ),
              ],
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                child: Text(
                  field.errorText ?? '',
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }
}
