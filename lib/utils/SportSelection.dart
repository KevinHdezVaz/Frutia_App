import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:Frutia/utils/ChoiceChipCard.dart';
import 'package:Frutia/utils/CustomTextField.dart';
import 'package:Frutia/l10n/app_localizations.dart'; // ⭐ IMPORTAR

class SportSelection extends StatelessWidget {
  final String name;
  final List<String>? initialValue;
  final ValueChanged<List<String>?>? onChanged;

  const SportSelection({
    super.key,
    required this.name,
    this.initialValue,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // ⭐ OBTENER TRADUCCIONES

    // ⭐ TRADUCCIÓN DINÁMICA: UI Key → DB Value
    final Map<String, String> sportsWithEmojis = {
      l10n.gym: 'Gym', // ⭐ TRADUCIDO
      l10n.soccer:
          'Soccer', // ⭐ TRADUCIDO (Soccer en inglés, Fútbol en español)
      l10n.running: 'Running', // ⭐ TRADUCIDO
      l10n.tennis: 'Tennis', // ⭐ TRADUCIDO
      l10n.other: 'Other', // ⭐ TRADUCIDO
      l10n.none: 'None', // ⭐ TRADUCIDO
    };

    return FormBuilderField<List<String>>(
      name: name,
      initialValue: initialValue ?? [],
      onChanged: onChanged,
      builder: (FormFieldState<List<String>> field) {
        final selectedSports = field.value ?? [];

        // ⭐ CAMBIO: Verificar si "Other" está seleccionado usando el valor DB
        bool isOtherSelected =
            selectedSports.contains('Other') || selectedSports.contains('Otro');

        bool hasCustomSport = selectedSports.any((sport) =>
            !sportsWithEmojis.values.contains(sport) && sport.isNotEmpty);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: [
                ...sportsWithEmojis.entries.map((entry) {
                  // ⭐ CAMBIO: Verificar selección usando el valor DB
                  final isSelected = selectedSports.contains(entry.value);
                  final isOther = entry.value == 'Other';

                  return ChoiceChipCard(
                    label: entry.key, // ⭐ Muestra el texto traducido
                    isSelected: isSelected,
                    onTap: () {
                      final newSelection = List<String>.from(selectedSports);
                      if (isSelected) {
                        newSelection.remove(entry.value); // ⭐ Guarda valor DB
                        // Si deselecciona "Other", también quitamos el deporte personalizado
                        if (isOther) {
                          newSelection.removeWhere((sport) =>
                              !sportsWithEmojis.values.contains(sport));
                        }
                      } else {
                        newSelection.add(entry.value); // ⭐ Guarda valor DB
                      }
                      field.didChange(newSelection);
                    },
                  );
                }).toList(),
              ],
            ),
            if (isOtherSelected || hasCustomSport)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: CustomTextField(
                  label: l10n.specifyYourSport, // ⭐ TRADUCIDO
                  initialValue: hasCustomSport
                      ? selectedSports.firstWhere(
                          (sport) => !sportsWithEmojis.values.contains(sport),
                          orElse: () => '')
                      : null,
                  onChanged: (newValue) {
                    final newSelection = List<String>.from(selectedSports)
                      ..removeWhere(
                          (sport) => !sportsWithEmojis.values.contains(sport));

                    if (newValue != null && newValue.isNotEmpty) {
                      newSelection.add(newValue);
                    }

                    // ⭐ CAMBIO: Mantener "Other" en DB value
                    if (newValue?.isNotEmpty == true &&
                        !newSelection.contains('Other')) {
                      newSelection.add('Other');
                    }

                    field.didChange(newSelection);
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
