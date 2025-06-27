import 'package:Frutia/model/Ingredient.dart';
import 'package:equatable/equatable.dart';

// --- Modelo para un solo item de comida/snack (MealItem) ---
class MealItem extends Equatable {
  final String option;
  final String description;
  final int calories;
  final int prepTimeMinutes;
  final String? imageUrl;
  final String? imagePrompt; // Agregado para compatibilidad con image_prompt
  final List<Ingredient> ingredients;
  final List<String> instructions;

  MealItem({
    required this.option,
    required this.description,
    required this.calories,
    required this.prepTimeMinutes,
    this.imageUrl,
    this.imagePrompt,
    required this.ingredients,
    required this.instructions,
  });

  factory MealItem.fromJson(Map<String, dynamic> json) {
    final details = json['details'] as Map<String, dynamic>? ?? {};

    final List<Ingredient> parsedIngredients =
        (details['ingredients'] as List<dynamic>?)
                ?.map((itemJson) =>
                    Ingredient.fromJson(itemJson as Map<String, dynamic>))
                .toList() ??
            [];

    return MealItem(
      option: json['opcion'] as String? ?? 'Receta sin título',
      description: details['description'] as String? ?? 'Sin descripción.',
      calories: details['calories'] as int? ?? 0,
      prepTimeMinutes: details['prep_time_minutes'] as int? ?? 0,
      imageUrl: details['image_url'] as String?,
      imagePrompt: details['image_prompt'] as String?,
      ingredients: parsedIngredients,
      instructions:
          (details['instructions'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  // Método para convertir el objeto a un mapa
  Map<String, dynamic> toJson() {
    return {
      'opcion': option,
      'details': {
        'description': description,
        'calories': calories,
        'prep_time_minutes': prepTimeMinutes,
        'image_url': imageUrl,
        'image_prompt': imagePrompt,
        'ingredients': ingredients.map((i) => i.toJson()).toList(),
        'instructions': instructions,
      },
    };
  }

  // Método para crear un MealItem vacío
  factory MealItem.empty() {
    return MealItem(
      option: '',
      description: '',
      calories: 0,
      prepTimeMinutes: 0,
      imageUrl: null,
      imagePrompt: null,
      ingredients: [],
      instructions: [],
    );
  }

  @override
  List<Object?> get props => [
        option,
        description,
        calories,
        prepTimeMinutes,
        imageUrl,
        imagePrompt,
        ingredients,
        instructions,
      ];
}

// --- Modelo para los datos completos del plan ---
class MealPlanData extends Equatable {
  final String summaryTitle;
  final String summaryText1;
  final String summaryText2;
  final String summaryText3;
  final String? summaryText4;
  final List<MealItem> desayunos;
  final List<MealItem> almuerzos;
  final List<MealItem> cenas;
  final List<MealItem> snacks;
  final Map<String, MealItem> alternativas; // Nueva propiedad para alternativas
  final List<String> recomendaciones;

  MealPlanData({
    required this.summaryTitle,
    required this.summaryText1,
    required this.summaryText2,
    required this.summaryText3,
    this.summaryText4,
    required this.desayunos,
    required this.almuerzos,
    required this.cenas,
    required this.snacks,
    required this.alternativas,
    required this.recomendaciones,
  });

  factory MealPlanData.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> mealPlanMap = json['meal_plan'] ?? {};
    final Map<String, dynamic> alternativasJson =
        mealPlanMap['alternatives'] as Map<String, dynamic>? ?? {};

    List<MealItem> parseMealList(String key) {
      return (mealPlanMap[key] as List<dynamic>?)
              ?.map((item) => MealItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [];
    }

    return MealPlanData(
      summaryTitle: json['summary_title'] as String? ?? 'Resumen de tu Plan',
      summaryText1:
          json['summary_text_1'] as String? ?? 'Plan basado en tus objetivos.',
      summaryText2:
          json['summary_text_2'] as String? ?? 'Personalizado para ti.',
      summaryText3:
          json['summary_text_3'] as String? ?? 'Motivación para el éxito.',
      summaryText4: json['summary_text_4'] as String?,
      desayunos: parseMealList('desayuno'),
      almuerzos: parseMealList('almuerzo'),
      cenas: parseMealList('cena'),
      snacks: parseMealList('snacks'),
      alternativas: {
        'desayuno': alternativasJson['desayuno'] != null
            ? MealItem.fromJson(
                alternativasJson['desayuno'] as Map<String, dynamic>)
            : MealItem.empty(),
        'almuerzo': alternativasJson['almuerzo'] != null
            ? MealItem.fromJson(
                alternativasJson['almuerzo'] as Map<String, dynamic>)
            : MealItem.empty(),
        'cena': alternativasJson['cena'] != null
            ? MealItem.fromJson(
                alternativasJson['cena'] as Map<String, dynamic>)
            : MealItem.empty(),
        'snacks': alternativasJson['snacks'] != null
            ? MealItem.fromJson(
                alternativasJson['snacks'] as Map<String, dynamic>)
            : MealItem.empty(),
      },
      recomendaciones:
          (json['recomendaciones'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  @override
  List<Object?> get props => [
        summaryTitle,
        summaryText1,
        summaryText2,
        summaryText3,
        summaryText4,
        desayunos,
        almuerzos,
        cenas,
        snacks,
        alternativas,
        recomendaciones,
      ];
}
