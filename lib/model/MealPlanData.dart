// Model for the entire plan data
class MealPlanData {
  final String summaryTitle;
  final String summaryText1;
  final String summaryText2;
  final String summaryText3;
  final String? summaryText4;
  final List<MealItem> desayunos;
  final List<MealItem> almuerzos;
  final List<MealItem> cenas;
  final List<MealItem> snacks;
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
    required this.recomendaciones,
  });

  factory MealPlanData.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> mealPlanMap = json['meal_plan'] ?? {};

    return MealPlanData(
      summaryTitle: json['summary_title'] ?? 'Resumen de tu Plan',
      summaryText1: json['summary_text_1'] ??
          'Hemos creado este plan basado en tus objetivos.',
      summaryText2: json['summary_text_2'] ??
          'Tu plan está personalizado según tus necesidades.',
      summaryText3: json['summary_text_3'] ??
          'Te ayudamos a superar tus retos y mantenerte motivado.',
      summaryText4: json['summary_text_4'],
      desayunos: (mealPlanMap['desayuno'] as List?)
              ?.map((item) => MealItem.fromJson(item))
              .toList() ??
          [],
      almuerzos: (mealPlanMap['almuerzo'] as List?)
              ?.map((item) => MealItem.fromJson(item))
              .toList() ??
          [],
      cenas: (mealPlanMap['cena'] as List?)
              ?.map((item) => MealItem.fromJson(item))
              .toList() ??
          [],
      snacks: (mealPlanMap['snacks'] as List?)
              ?.map((item) => MealItem.fromJson(item))
              .toList() ??
          [],
      recomendaciones: (json['recomendaciones'] as List?)?.cast<String>() ?? [],
    );
  }
}

// Model for a single meal/snack item
class MealItem {
  final String option;
  final String description;
  final int calories;
  final int prepTimeMinutes;
  final List<String> ingredients;
  final List<String> instructions;
  final Map<String, dynamic>? details;

  MealItem({
    required this.option,
    required this.description,
    required this.calories,
    required this.prepTimeMinutes,
    required this.ingredients,
    required this.instructions,
    this.details,
  });

  factory MealItem.fromJson(Map<String, dynamic> json) {
    final ingredientsList = <String>[];
    final rawIngredients = json['details']?['ingredients'] as List? ?? [];

    for (var ingredient in rawIngredients) {
      if (ingredient is String) {
        ingredientsList.add(ingredient);
      } else if (ingredient is Map<String, dynamic>) {
        ingredientsList.add(ingredient['name'] ?? '');
      }
    }

    return MealItem(
      option: json['opcion'] ?? 'Receta sin título',
      description:
          json['details']?['description'] ?? 'Descubriendo una nueva receta...',
      calories: json['details']?['calories'] ?? 0,
      prepTimeMinutes: json['details']?['prep_time_minutes'] ?? 0,
      ingredients: ingredientsList,
      instructions:
          (json['details']?['instructions'] as List?)?.cast<String>() ?? [],
      details: json['details'],
    );
  }
}
