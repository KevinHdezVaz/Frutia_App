import 'package:Frutia/utils/ChoiceChipCard.dart';
import 'package:Frutia/utils/CustomTextField.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:google_fonts/google_fonts.dart';

class SportSelection extends StatelessWidget {
  final String name;
  final String? initialValue;
  final ValueChanged<String?>? onChanged;

  const SportSelection({
    super.key,
    required this.name,
    this.initialValue,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Definimos los deportes con sus emojis correspondientes
    final Map<String, String> sportsWithEmojis = {
      '❌ Ninguno': 'Ninguno',
      '💪 Gym': 'Gym',
      '⚽ Fútbol': 'Fútbol',
      '🏃 Running': 'Running',
      '🎾 Tenis': 'Tenis',
      '✏️ Otro': 'Otro',
    };

    return FormBuilderField<String>(
      name: name,
      initialValue: initialValue ?? 'Ninguno',
      onChanged: onChanged,
      builder: (FormFieldState<String> field) {
        bool isOtherSelected = field.value != null &&
            !sportsWithEmojis.values.contains(field.value);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: [
                ...sportsWithEmojis.entries.map((entry) {
                  final isSelected = field.value == entry.value;
                  final isOther = entry.value == 'Otro';

                  return ChoiceChipCard(
                    label: entry.key, // Usamos la clave que contiene el emoji
                    isSelected: isSelected,
                    onTap: () {
                      field.didChange(isOther ? '' : entry.value);
                    },
                  );
                }).toList(),
              ],
            ),
            if (isOtherSelected)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: CustomTextField(
                  label: '✏️ Especifica tu deporte',
                  initialValue: field.value,
                  onChanged: (newValue) {
                    field.didChange(newValue);
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
