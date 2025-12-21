import 'package:Frutia/auth/auth_check.dart';
import 'package:Frutia/l10n/app_localizations.dart'; // ⭐ AGREGAR
import 'package:Frutia/services/profile_service.dart';
import 'package:Frutia/utils/colors.dart';
import 'package:Frutia/utils/gender_card.dart';
import 'package:country_picker/country_picker.dart';
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
  Country? _selectedCountry;

  // ⭐ AGREGAR HELPER
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_formKey.currentState != null) {
        _formKey.currentState!.patchValue({
          'height': _height,
          'weight': _weight,
          'age': _age,
          'sex': l10n.male, // ⭐ CAMBIADO
          'pais': _selectedCountry?.name ?? '',
        });
      }
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() => _isLoading = true);

      final formData = _formKey.currentState!.value;
      final profileData = {
        'height': _height.round().toString(),
        'weight': _weight.toStringAsFixed(1),
        'age': _age.round().toString(),
        'sex': formData['sex'],
        'pais': formData['pais'] ?? _selectedCountry?.name ?? '',
      };

      try {
        await _profileService.saveProfile(profileData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(l10n.dataSavedSuccess), // ⭐ CAMBIADO
                backgroundColor: Colors.green),
          );

          widget.onSuccess();

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const AuthCheckMain()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('${l10n.errorSavingProfile}: $e'), // ⭐ CAMBIADO
                backgroundColor: Colors.redAccent),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.completeAllRequiredFields), // ⭐ CAMBIADO
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          l10n.personalData, // ⭐ CAMBIADO
          style: GoogleFonts.lato(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: FrutiaColors.primaryText,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(60.0),
                child: CircularProgressIndicator(color: FrutiaColors.accent),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: FormBuilder(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.tellUsAboutYou, // ⭐ CAMBIADO
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: FrutiaColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.dataEssentialForPlan, // ⭐ CAMBIADO
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
                      _buildCountrySelector(),
                      const SizedBox(height: 20),
                      _buildSexSelector(),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: FrutiaColors.accent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            l10n.saveAndContinue, // ⭐ CAMBIADO
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildHeightSlider() {
    final double meters = _height / 100.0;
    final double totalInches = _height / 2.54;
    final int feet = totalInches ~/ 12;
    final int inches = (totalInches % 12).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormBuilderField<double>(
          name: 'height',
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(
                errorText: l10n.heightRequired), // ⭐ CAMBIADO
            (value) {
              if (value == null) return l10n.heightRequired; // ⭐ CAMBIADO
              if (value < 120 || value > 220) {
                return l10n.heightBetween; // ⭐ CAMBIADO
              }
              return null;
            },
          ]),
          builder: (FormFieldState<double> field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.height, // ⭐ CAMBIADO
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: FrutiaColors.primaryText,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: FrutiaColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: FrutiaColors.accent.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${meters.toStringAsFixed(2)} ${l10n.meters}', // ⭐ CAMBIADO
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: FrutiaColors.accent,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '|',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Text(
                            '$feet\'$inches"',
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: FrutiaColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    IconButton(
                      icon:
                          const Icon(Icons.remove, color: FrutiaColors.accent),
                      onPressed: () {
                        setState(() {
                          _height = (_height - 1).clamp(120.0, 220.0);
                          field.didChange(_height);
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
                        onChanged: (dynamic value) {
                          setState(() {
                            _height = value;
                            field.didChange(_height);
                          });
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: FrutiaColors.accent),
                      onPressed: () {
                        setState(() {
                          _height = (_height + 1).clamp(120.0, 220.0);
                          field.didChange(_height);
                        });
                      },
                    ),
                  ],
                ),
                if (field.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                    child: Text(
                      field.errorText ?? '',
                      style: const TextStyle(
                          color: Colors.redAccent, fontSize: 12),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildWeightSlider() {
    final double lbs = _weight * 2.20462;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormBuilderField<double>(
          name: 'weight',
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(
                errorText: l10n.weightRequired), // ⭐ CAMBIADO
            (value) {
              if (value == null) return l10n.weightRequired; // ⭐ CAMBIADO
              if (value < 30 || value > 180) {
                return l10n.weightBetween; // ⭐ CAMBIADO
              }
              return null;
            },
          ]),
          builder: (FormFieldState<double> field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.weight, // ⭐ CAMBIADO
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: FrutiaColors.primaryText,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: FrutiaColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: FrutiaColors.accent.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${_weight.toStringAsFixed(1)} kg',
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: FrutiaColors.accent,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '|',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Text(
                            '${lbs.toStringAsFixed(1)} ${l10n.pounds}', // ⭐ CAMBIADO
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: FrutiaColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    IconButton(
                      icon:
                          const Icon(Icons.remove, color: FrutiaColors.accent),
                      onPressed: () {
                        setState(() {
                          _weight = (_weight - 0.5).clamp(30.0, 180.0);
                          field.didChange(_weight);
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
                        onChanged: (dynamic value) {
                          setState(() {
                            _weight = value;
                            field.didChange(_weight);
                          });
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: FrutiaColors.accent),
                      onPressed: () {
                        setState(() {
                          _weight = (_weight + 0.5).clamp(30.0, 180.0);
                          field.didChange(_weight);
                        });
                      },
                    ),
                  ],
                ),
                if (field.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                    child: Text(
                      field.errorText ?? '',
                      style: const TextStyle(
                          color: Colors.redAccent, fontSize: 12),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildAgeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormBuilderField<double>(
          name: 'age',
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(
                errorText: l10n.ageRequired), // ⭐ CAMBIADO
            (value) {
              if (value == null) return l10n.ageRequired; // ⭐ CAMBIADO
              if (value < 16 || value > 90) {
                return l10n.ageBetween; // ⭐ CAMBIADO
              }
              return null;
            },
          ]),
          builder: (FormFieldState<double> field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.age} ${l10n.ageYears(_age.round())}', // ⭐ CAMBIADO
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon:
                          const Icon(Icons.remove, color: FrutiaColors.accent),
                      onPressed: () {
                        setState(() {
                          _age = (_age - 1).clamp(16.0, 90.0);
                          field.didChange(_age);
                        });
                      },
                    ),
                    Expanded(
                      child: SfSlider(
                        min: 16.0,
                        max: 90.0,
                        value: _age,
                        interval: 20,
                        showTicks: true,
                        enableTooltip: false,
                        inactiveColor: Colors.grey[300],
                        showLabels: true,
                        activeColor: FrutiaColors.accent,
                        onChanged: (dynamic value) {
                          setState(() {
                            _age = value;
                            field.didChange(_age);
                          });
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: FrutiaColors.accent),
                      onPressed: () {
                        setState(() {
                          _age = (_age + 1).clamp(16.0, 90.0);
                          field.didChange(_age);
                        });
                      },
                    ),
                  ],
                ),
                if (field.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                    child: Text(
                      field.errorText ?? '',
                      style: const TextStyle(
                          color: Colors.redAccent, fontSize: 12),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildCountrySelector() {
    return FormBuilderField<String>(
      name: 'pais',
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(
            errorText: l10n.selectCountryRequired), // ⭐ CAMBIADO
      ]),
      builder: (FormFieldState<String> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.country, // ⭐ CAMBIADO
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () {
                showCountryPicker(
                  context: context,
                  showPhoneCode: false,
                  onSelect: (Country country) {
                    setState(() {
                      _selectedCountry = country;
                      field.didChange(country.name);
                    });
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    if (_selectedCountry != null)
                      Text(
                        _selectedCountry!.flagEmoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedCountry?.name ??
                            l10n.selectCountry, // ⭐ CAMBIADO
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          color: _selectedCountry == null
                              ? Colors.grey
                              : FrutiaColors.primaryText,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down,
                        color: FrutiaColors.accent),
                  ],
                ),
              ),
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

  Widget _buildSexSelector() {
    return FormBuilderField<String>(
      name: 'sex',
      initialValue: l10n.male, // ⭐ CAMBIADO
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(
            errorText: l10n.selectOptionRequired), // ⭐ CAMBIADO
      ]),
      builder: (FormFieldState<String> field) {
        return Column(
          children: [
            const SizedBox(height: 10),
            Text(
              l10n.iIdentifyAs, // ⭐ CAMBIADO
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
                    title: l10n.male, // ⭐ CAMBIADO
                    icon: Icons.male,
                    value: l10n.male, // ⭐ CAMBIADO
                    selectedValue: field.value,
                    onTap: (value) => field.didChange(value),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GenderCard(
                    title: l10n.female, // ⭐ CAMBIADO
                    icon: Icons.female,
                    value: l10n.female, // ⭐ CAMBIADO
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
