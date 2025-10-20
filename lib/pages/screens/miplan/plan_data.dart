import 'dart:convert';
import 'package:flutter/material.dart';

// --- Helper Functions para convertir Strings a Widgets ---
IconData _iconFromString(String iconName) {
  switch (iconName) {
    case 'wb_sunny_outlined':
      return Icons.wb_sunny_outlined;
    case 'nightlight_round':
      return Icons.nightlight_round;
    case 'blender_outlined':
      return Icons.blender_outlined;
    case 'fastfood_outlined':
      return Icons.fastfood_outlined;
    case 'set_meal_outlined':
      return Icons.set_meal_outlined;
    case 'eco_outlined':
      return Icons.eco_outlined;
    case 'rice_bowl_outlined':
      return Icons.rice_bowl_outlined;
    case 'spa_outlined':
      return Icons.spa_outlined;
    case 'water_drop_outlined':
      return Icons.water_drop_outlined;
    case 'cake_outlined':
      return Icons.cake_outlined;
    case 'grain_outlined':
      return Icons.grain_outlined;
    case 'science_outlined':
      return Icons.science_outlined;
    case 'breakfast_dining_outlined':
      return Icons.breakfast_dining_outlined;
    default:
      return Icons.help_outline;
  }
}

Color _colorFromString(String colorName) {
  switch (colorName.toLowerCase()) {
    case 'orange':
      return Colors.orange;
    case 'indigo':
      return Colors.indigo;
    case 'pink':
      return Colors.pink;
    default:
      return Colors.grey;
  }
}

class MealPlanData {
  final NutritionPlan nutritionPlan;

  const MealPlanData({
    required this.nutritionPlan,
  });

  factory MealPlanData.fromJson(Map<String, dynamic> json) {
    return MealPlanData(
      nutritionPlan: NutritionPlan.fromJson(json['nutritionPlan'] ?? {}),
    );
  }
}

// ==========================================================
// 2. MODELOS ACTUALIZADOS PARA 'nutritionPlan'
// ==========================================================

class PriceInfo {
  final String store;
  final double price;
  final String? currency;

  const PriceInfo({required this.store, required this.price, this.currency});

  factory PriceInfo.fromJson(Map<String, dynamic> json) {
    return PriceInfo(
      store: json['store'] as String? ?? 'N/A',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'store': store,
        'price': price,
        'currency': currency,
      };
}

class AnthropometricSummary {
  final String clientName;
  final int age;
  final String sex;
  final double weight;
  final double height;
  final double bmi;
  final String weightStatus;
  final IdealWeightRange idealWeightRange;

  const AnthropometricSummary({
    required this.clientName,
    required this.age,
    required this.sex,
    required this.weight,
    required this.height,
    required this.bmi,
    required this.weightStatus,
    required this.idealWeightRange,
  });

  factory AnthropometricSummary.fromJson(Map<String, dynamic> json) {
    return AnthropometricSummary(
      clientName: json['clientName'] as String? ?? 'Usuario',
      age: (json['age'] as num?)?.toInt() ?? 0,
      sex: json['sex'] as String? ?? '',
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      height: (json['height'] as num?)?.toDouble() ?? 0.0,
      bmi: (json['bmi'] as num?)?.toDouble() ?? 0.0,
      weightStatus: json['weightStatus'] as String? ?? '',
      idealWeightRange:
          IdealWeightRange.fromJson(json['idealWeightRange'] ?? {}),
    );
  }
}

class IdealWeightRange {
  final double min;
  final double max;

  const IdealWeightRange({required this.min, required this.max});

  factory IdealWeightRange.fromJson(Map<String, dynamic> json) {
    return IdealWeightRange(
      min: (json['min'] as num?)?.toDouble() ?? 0.0,
      max: (json['max'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class NutritionalSummary {
  final int tmb;
  final int get;
  final int targetCalories;
  final String goal;
  final String monthlyProgression;
  final String activityFactor;
  final double caloriesPerKg;
  final double proteinPerKg;
  final List<String> specialConsiderations;

  const NutritionalSummary({
    required this.tmb,
    required this.get,
    required this.targetCalories,
    required this.goal,
    required this.monthlyProgression,
    required this.activityFactor,
    required this.caloriesPerKg,
    required this.proteinPerKg,
    required this.specialConsiderations,
  });

  factory NutritionalSummary.fromJson(Map<String, dynamic> json) {
    return NutritionalSummary(
      tmb: (json['tmb'] as num?)?.toInt() ?? 0,
      get: (json['get'] as num?)?.toInt() ?? 0,
      targetCalories: (json['targetCalories'] as num?)?.toInt() ?? 0,
      goal: json['goal'] as String? ?? '',
      monthlyProgression: json['monthlyProgression'] as String? ?? '',
      activityFactor: json['activityFactor'] as String? ?? '',
      caloriesPerKg: (json['caloriesPerKg'] as num?)?.toDouble() ?? 0.0,
      proteinPerKg: (json['proteinPerKg'] as num?)?.toDouble() ?? 0.0,
      specialConsiderations: List<String>.from(
          (json['specialConsiderations'] as List? ?? [])
              .map((item) => item.toString())),
    );
  }
}

class PersonalizedTips {
  final String anthropometricGuidance;
  final String difficultySupport;
  final String motivationalElements;
  final String eatingOutGuidance;
  final String ageSpecificAdvice;

  const PersonalizedTips({
    required this.anthropometricGuidance,
    required this.difficultySupport,
    required this.motivationalElements,
    required this.eatingOutGuidance,
    required this.ageSpecificAdvice,
  });

  factory PersonalizedTips.fromJson(Map<String, dynamic> json) {
    return PersonalizedTips(
      anthropometricGuidance: json['anthropometricGuidance'] as String? ?? '',
      difficultySupport: json['difficultySupport'] as String? ?? '',
      motivationalElements: json['motivationalElements'] as String? ?? '',
      eatingOutGuidance: json['eatingOutGuidance'] as String? ?? '',
      ageSpecificAdvice: json['ageSpecificAdvice'] as String? ?? '',
    );
  }
}

class NutritionPlan {
  final TargetMacros targetMacros;
  final Map<String, Meal> meals;
  final List<String> generalRecommendations;
  final List<String> rememberRecommendations;
  final String recommendation;
  final String? currencySymbol;

  // CAMPOS NUEVOS COMPLETOS:
  final String? personalizedMessage;
  final AnthropometricSummary? anthropometricSummary;
  final NutritionalSummary? nutritionalSummary;
  final PersonalizedTips? personalizedTips;
  final Map<String, String>? mealSchedule;

  const NutritionPlan({
    required this.targetMacros,
    required this.meals,
    required this.generalRecommendations,
    required this.rememberRecommendations,
    required this.recommendation,
    this.currencySymbol,
    this.personalizedMessage,
    this.anthropometricSummary,
    this.nutritionalSummary,
    this.personalizedTips,
    this.mealSchedule,
  });

  factory NutritionPlan.fromJson(Map<String, dynamic> json) {
    final mealsData = json['meals'] as Map<String, dynamic>? ?? {};
    final Map<String, Meal> parsedMeals = {};

    mealsData.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        parsedMeals[key] = Meal.fromJson(value);
      }
    });

    final recommendations =
        json['recommendations'] as Map<String, dynamic>? ?? {};
    final general = recommendations['general'] as List? ?? [];
    final remember = recommendations['remember'] as List? ?? [];

    // Parse meal schedule
    final mealScheduleData =
        json['mealSchedule'] as Map<String, dynamic>? ?? {};
    final Map<String, String> parsedMealSchedule = {};
    mealScheduleData.forEach((key, value) {
      parsedMealSchedule[key] = value.toString();
    });

    return NutritionPlan(
      targetMacros: TargetMacros.fromJson(json['targetMacros'] ?? {}),
      meals: parsedMeals,
      generalRecommendations:
          List<String>.from(general.map((item) => item.toString())),
      rememberRecommendations:
          List<String>.from(remember.map((item) => item.toString())),
      recommendation: json['recommendation'] as String? ??
          '¡Tu plan está listo para que alcances tus metas!',
      currencySymbol: json['currency_symbol'] as String?,
      personalizedMessage: json['personalizedMessage'] as String?,
      anthropometricSummary: json['anthropometricSummary'] != null
          ? AnthropometricSummary.fromJson(json['anthropometricSummary'])
          : null,
      nutritionalSummary: json['nutritionalSummary'] != null
          ? NutritionalSummary.fromJson(json['nutritionalSummary'])
          : null,
      personalizedTips: json['personalizedTips'] != null
          ? PersonalizedTips.fromJson(json['personalizedTips'])
          : null,
      mealSchedule: parsedMealSchedule.isNotEmpty ? parsedMealSchedule : null,
    );
  }
}

class TargetMacros {
  final int calories;
  final int protein;
  final int carbs;
  final int fats;
  final DetailedMacroBreakdown? detailedBreakdown;

  const TargetMacros({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.detailedBreakdown,
  });

  factory TargetMacros.fromJson(Map<String, dynamic> json) {
    return TargetMacros(
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      protein: (json['protein'] as num?)?.toInt() ?? 0,
      carbs: (json['carbohydrates'] as num?)?.toInt() ??
          (json['carbs'] as num?)?.toInt() ??
          0,
      fats: (json['fats'] as num?)?.toInt() ??
          (json['fat'] as num?)?.toInt() ??
          0,
      detailedBreakdown: json['detailedBreakdown'] != null
          ? DetailedMacroBreakdown.fromJson(json['detailedBreakdown'])
          : null,
    );
  }
}

class DetailedMacroBreakdown {
  final MacroDetail protein;
  final MacroDetail fats;
  final MacroDetail carbohydrates;

  const DetailedMacroBreakdown({
    required this.protein,
    required this.fats,
    required this.carbohydrates,
  });

  factory DetailedMacroBreakdown.fromJson(Map<String, dynamic> json) {
    return DetailedMacroBreakdown(
      protein: MacroDetail.fromJson(json['protein'] ?? {}),
      fats: MacroDetail.fromJson(json['fats'] ?? {}),
      carbohydrates: MacroDetail.fromJson(json['carbohydrates'] ?? {}),
    );
  }
}

class MacroDetail {
  final int grams;
  final int calories;
  final double percentage;
  final double perKg;

  const MacroDetail({
    required this.grams,
    required this.calories,
    required this.percentage,
    required this.perKg,
  });

  factory MacroDetail.fromJson(Map<String, dynamic> json) {
    return MacroDetail(
      grams: (json['grams'] as num?)?.toInt() ?? 0,
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      perKg: (json['perKg'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class MealCategory {
  final String title;
  final List<MealOption> options;

  const MealCategory({required this.title, required this.options});

  factory MealCategory.fromJson(Map<String, dynamic> json) {
    var optionsList = json['options'] as List? ?? [];
    List<MealOption> parsedOptions =
        optionsList.map((i) => MealOption.fromJson(i)).toList();

    return MealCategory(
      title: json['title'] ?? 'Sin título',
      options: parsedOptions,
    );
  }
}

class MealOption {
  final String name;
  final String portion;
  final int calories;
  final int protein;
  final int carbs;
  final int fats;
   final bool isHighBudget;  // AGREGAR
  final bool isLowBudget;   // AGREGAR
  final bool isEgg;         // AGREGAR
  final List<PriceInfo> prices;
  final String imageUrl;
  final List<String> ingredients;

  const MealOption({
    required this.name,
    required this.portion,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.isHighBudget,
    required this.isLowBudget,
    required this.isEgg,
    required this.prices,
    required this.imageUrl,
    required this.ingredients,
  });

  factory MealOption.fromJson(Map<String, dynamic> json) {
    var pricesList = json['prices'] as List? ?? [];
    return MealOption(
      name: json['name'] as String? ?? 'Sin nombre',
      portion: json['portion'] as String? ?? 'N/A',
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      protein: (json['protein'] as num?)?.toInt() ?? 0,
      carbs: (json['carbohydrates'] as num?)?.toInt() ??  (json['carbs'] as num?)?.toInt() ?? 0,
      fats: (json['fats'] as num?)?.toInt() ?? (json['fat'] as num?)?.toInt() ??       0,
        isHighBudget: json['isHighBudget'] ?? false,  // NUEVO
      isLowBudget: json['isLowBudget'] ?? false,    // NUEVO
      isEgg: json['isEgg'] ?? false,                // NUEVO
      prices: pricesList
          .map((p) => PriceInfo.fromJson(p as Map<String, dynamic>))
          .toList(),
      imageUrl: json['imageUrl'] as String? ?? '',
      ingredients: List<String>.from(
          (json['ingredients'] as List? ?? []).map((item) => item.toString())),
    );
  }

 
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'portion': portion,
      'calories': calories,
      'protein': protein,
      'carbohydrates': carbs,
      'fats': fats,
      'prices': prices.map((p) => p.toJson()).toList(),
    };
  }
}

// ==========================================================
// 3. MODELOS PARA 'recipes'
// ==========================================================

class RecipeIngredient {
  final String name;
  final String? quantity;

  const RecipeIngredient({required this.name, this.quantity});

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      name: json['name'] ?? '',
      quantity: json['quantity'],
    );
  }
}

class InspirationRecipe {
  final String title;
  final String? imageUrl;
  final int readyInMinutes;
  String? mealType;
  final int servings;
  final String instructions;
  final List<dynamic> extendedIngredients;
  final List<dynamic> analyzedInstructions;
  final int calories;
  final int protein;
  final int carbs;
  final int fats;
  final String? personalizedNote;
  final String? goalAlignment;
  final String? sportsSupport;
  final String? cuisineType;
  final String? difficultyLevel;

  InspirationRecipe({
    required this.title,
    this.imageUrl,
    required this.readyInMinutes,
    required this.servings,
    required this.instructions,
    required this.extendedIngredients,
    required this.analyzedInstructions,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.mealType = 'General',
    this.personalizedNote,
    this.goalAlignment,
    this.sportsSupport,
    this.cuisineType,
    this.difficultyLevel,
  });

  factory InspirationRecipe.fromJson(Map<String, dynamic> json) {
    String determineMealType(String title) {
      title = title.toLowerCase();
      if (title.contains('desayuno') ||
          title.contains('breakfast') ||
          title.contains('avena')) {
        return 'Desayuno';
      }
      if (title.contains('almuerzo') ||
          title.contains('lunch') ||
          title.contains('ensalada')) {
        return 'Almuerzo';
      }
      if (title.contains('cena') ||
          title.contains('dinner') ||
          title.contains('sopa')) {
        return 'Cena';
      }
      return 'General';
    }

    return InspirationRecipe(
      title: json['name'] ?? json['title'] ?? 'Sin título',
      imageUrl: json['imageUrl'] ?? json['image'],
      readyInMinutes: (json['readyInMinutes'] as num?)?.toInt() ?? 0,
      servings: (json['servings'] as num?)?.toInt() ?? 1,
      instructions: json['instructions'] ?? 'No hay instrucciones.',
      extendedIngredients: json['extendedIngredients'] as List<dynamic>? ?? [],
      analyzedInstructions:
          json['analyzedInstructions'] as List<dynamic>? ?? [],
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      protein: (json['protein'] as num?)?.toInt() ?? 0,
      carbs: (json['carbs'] as num?)?.toInt() ?? 0,
      fats: (json['fats'] as num?)?.toInt() ?? 0,
      mealType: json['mealType'] ??
          determineMealType(json['name'] ?? json['title'] ?? ''),
      personalizedNote: json['personalizedNote'],
      goalAlignment: json['goalAlignment'],
      sportsSupport: json['sportsSupport'],
      cuisineType: json['cuisineType'],
      difficultyLevel: json['difficultyLevel'],
    );
  }
}

class Meal {
  final List<MealCategory> components;
  final List<InspirationRecipe> suggestedRecipes;
  final String? mealTiming;
  final List<String>? personalizedTips;
    final TrialMessage? trialMessage; // NUEVO


  const Meal({
    required this.components,
    required this.suggestedRecipes,
    this.mealTiming,
    this.personalizedTips,
        this.trialMessage, // NUEVO

  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    // Parse components from the new structure
    final componentsData = json['components'] as Map<String, dynamic>? ?? {};
    final List<MealCategory> parsedComponents = [];

    // If it's the old structure, parse directly
  if (json.containsKey('Proteínas') ||
    json.containsKey('Carbohidratos') ||
    json.containsKey('Grasas') ||
    json.containsKey('Vegetales') ||
    json.containsKey('Frutas')) {  // ← AGREGAR FRUTAS

  ['Proteínas', 'Carbohidratos', 'Grasas', 'Vegetales', 'Frutas'].forEach((key) {  // ← AGREGAR FRUTAS
        if (json.containsKey(key) && json[key] is Map<String, dynamic>) {
          parsedComponents.add(MealCategory.fromJson({
            'title': key,
            'options': json[key]['options'] ?? [],
          }));
        }
      });
    } else {
      // New structure with components wrapper
      componentsData.forEach((title, optionsData) {
        if (optionsData is Map<String, dynamic>) {
          parsedComponents.add(MealCategory.fromJson({
            'title': title,
            'options': optionsData['options'] ?? [],
          }));
        }
      });
    }

    final recipesList = json['suggested_recipes'] as List? ?? [];
    final parsedRecipes = recipesList
        .map((r) => InspirationRecipe.fromJson(r as Map<String, dynamic>))
        .toList();

    final tipsList = json['personalized_tips'] as List? ?? [];
    final parsedTips = tipsList.map((tip) => tip.toString()).toList();

    return Meal(
      components: parsedComponents,
      suggestedRecipes: parsedRecipes,
      mealTiming: json['meal_timing'] as String?,
      personalizedTips: parsedTips.isNotEmpty ? parsedTips : null,
        trialMessage: json['trial_message'] != null 
          ? TrialMessage.fromJson(json['trial_message'])
          : null, // NUEVO
    );
  }
}

class TrialMessage {
  final String title;
  final String message;
  final String upgradeHint;

  const TrialMessage({
    required this.title,
    required this.message,
    required this.upgradeHint,
  });

  factory TrialMessage.fromJson(Map<String, dynamic> json) {
    return TrialMessage(
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      upgradeHint: json['upgrade_hint'] as String? ?? '',
    );
  }
}

// Legacy classes for backward compatibility
class FormulaOption {
  final String description;
  final IconData icon;

  const FormulaOption({required this.description, required this.icon});

  factory FormulaOption.fromJson(Map<String, dynamic> json) {
    return FormulaOption(
      description: json['description'] ?? '',
      icon: _iconFromString(json['icon'] ?? ''),
    );
  }
}

class FormulaCategory {
  final String title;
  final List<FormulaOption> options;

  const FormulaCategory({required this.title, required this.options});

  factory FormulaCategory.fromJson(Map<String, dynamic> json) {
    final optionsList = json['options'] as List? ?? [];
    return FormulaCategory(
      title: json['title'] ?? 'Sin Título',
      options: optionsList.map((o) => FormulaOption.fromJson(o)).toList(),
    );
  }
}

class MealFormula {
  final String title;
  final String mealType;
  final IconData icon;
  final Color color;
  final List<FormulaCategory> categories;

  const MealFormula({
    required this.title,
    required this.mealType,
    required this.icon,
    required this.color,
    required this.categories,
  });

  factory MealFormula.fromJson(Map<String, dynamic> json) {
    final categoriesList = json['categories'] as List? ?? [];
    return MealFormula(
      title: json['title'] ?? 'Sin Título',
      mealType: json['mealType'] ?? '',
      icon: _iconFromString(json['icon'] ?? ''),
      color: _colorFromString(json['color'] ?? 'grey'),
      categories:
          categoriesList.map((c) => FormulaCategory.fromJson(c)).toList(),
    );
  }
}
