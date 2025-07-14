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

// En tu archivo de modelos (ej. lib/models/plan_model.dart)
class MealPlanData {
  final NutritionPlan nutritionPlan;
  final List<InspirationRecipe> recipes;
  final List<MealFormula> formulas;

  const MealPlanData({
    required this.nutritionPlan,
    required this.recipes,
    required this.formulas,
  });

  factory MealPlanData.fromJson(Map<String, dynamic> json) {
    List<InspirationRecipe> parsedRecipes = [];
    List<MealFormula> parsedFormulas = [];

    // Manejar recipes como lista o como mapa
    if (json['recipes'] is List) {
      // Caso 1: recipes es una lista de recetas (formato del JSON actual)
      parsedRecipes = (json['recipes'] as List<dynamic>)
          .map((r) => InspirationRecipe.fromJson(r as Map<String, dynamic>))
          .toList();
    } else if (json['recipes'] is Map) {
      // Caso 2: recipes es un mapa con inspirationRecipes y formulas (formato antiguo o futuro)
      final recipesData = json['recipes'] as Map<String, dynamic>;
      parsedRecipes =
          (recipesData['inspirationRecipes'] as List<dynamic>? ?? [])
              .map((r) => InspirationRecipe.fromJson(r as Map<String, dynamic>))
              .toList();
      parsedFormulas = (recipesData['formulas'] as List<dynamic>? ?? [])
          .map((f) => MealFormula.fromJson(f as Map<String, dynamic>))
          .toList();
    }

    return MealPlanData(
      nutritionPlan: NutritionPlan.fromJson(json['nutritionPlan'] ?? {}),
      recipes: parsedRecipes,
      formulas: parsedFormulas,
    );
  }
}

// ==========================================================
// 2. MODELOS PARA 'nutritionPlan'
// ==========================================================

// --- Añade esta nueva clase ---
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

class NutritionPlan {
  final TargetMacros targetMacros;
  final Map<String, List<MealCategory>> meals;
  final List<String> generalRecommendations;
  final List<String> rememberRecommendations;

  const NutritionPlan({
    required this.targetMacros,
    required this.meals,
    required this.generalRecommendations,
    required this.rememberRecommendations,
  });

  factory NutritionPlan.fromJson(Map<String, dynamic> json) {
    final mealsData = json['meals'] as Map<String, dynamic>? ?? {};
    final Map<String, List<MealCategory>> parsedMeals = {};
    mealsData.forEach((key, value) {
      final categoriesList = value as List? ?? [];
      parsedMeals[key] =
          categoriesList.map((c) => MealCategory.fromJson(c)).toList();
    });

    final recommendations =
        json['recommendations'] as Map<String, dynamic>? ?? {};
    final general = recommendations['general'] as List? ?? [];
    final remember = recommendations['remember'] as List? ?? [];

    return NutritionPlan(
      targetMacros: TargetMacros.fromJson(json['targetMacros'] ?? {}),
      meals: parsedMeals,
      generalRecommendations: List<String>.from(general),
      rememberRecommendations: List<String>.from(remember),
    );
  }
}

class TargetMacros {
  final int calories;
  final int protein;
  final int carbs;
  final int fats;

  const TargetMacros({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  factory TargetMacros.fromJson(Map<String, dynamic> json) {
    return TargetMacros(
      calories: json['calories'] ?? 0,
      protein: json['protein'] ?? 0,
      carbs: json['carbs'] ?? 0,
      fats: json['fats'] ?? 0,
    );
  }
}

class MealCategory {
  final String title;
  final List<MealOption> options;

  const MealCategory({required this.title, required this.options});

  factory MealCategory.fromJson(Map<String, dynamic> json) {
    var optionsList = json['options'] as List? ?? [];
    List<MealOption> options =
        optionsList.map((i) => MealOption.fromJson(i)).toList();
    return MealCategory(
      title: json['title'] ?? 'Sin título',
      options: options,
    );
  }
}

// --- Reemplaza tu clase MealOption por esta ---
class MealOption {
  final String name;
  final String imageUrl;
  final int calories;
  final int protein;
  final int carbs;
  final int fats;
  final List<PriceInfo> prices; // <-- CAMBIO CLAVE: Se añade esta línea

  const MealOption({
    required this.name,
    required this.imageUrl,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.prices, // <-- CAMBIO CLAVE: Se añade al constructor
  });

  factory MealOption.fromJson(Map<String, dynamic> json) {
    // Se añade la lógica para parsear la lista de precios
    var pricesList = json['prices'] as List? ?? [];

    return MealOption(
      name: json['name'] ?? 'Sin nombre',
      imageUrl: json['imageUrl'] ?? '',
      calories: json['calories'] ?? 0,
      protein: json['protein'] ?? 0,
      carbs: json['carbs'] ?? 0,
      fats: json['fats'] ?? 0,
      prices: pricesList
          .map((p) => PriceInfo.fromJson(p))
          .toList(), // <-- CAMBIO CLAVE
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'prices': prices.map((p) => p.toJson()).toList(), // <-- CAMBIO CLAVE
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
  final String? id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String mealType;
  final int? prepTimeMinutes;
  final int calories;
  final List<String> planComponents;
  final List<RecipeIngredient> additionalIngredients;
  final List<String> steps;

  const InspirationRecipe({
    this.id,
    required this.title,
    this.description,
    this.imageUrl,
    required this.mealType,
    this.prepTimeMinutes,
    required this.calories,
    required this.planComponents,
    required this.additionalIngredients,
    required this.steps,
  });

  factory InspirationRecipe.fromJson(Map<String, dynamic> json) {
    final additional = json['additionalIngredients'] as List<dynamic>? ?? [];
    // Maneja el caso donde el JSON usa 'name' en lugar de 'title' (backend actual)
    final title = json['name'] ?? json['title'] ?? 'Sin Título';
    // Convierte instructions en steps si steps no está presente
    final steps = (json['steps'] as List<dynamic>?)?.cast<String>() ??
        (json['instructions'] != null ? [json['instructions'] as String] : []);
    return InspirationRecipe(
      id: json['id']?.toString() ?? 'recipe_${title.hashCode}',
      title: title,
      description: json['description'] ?? 'Receta nutritiva para tu plan.',
      imageUrl: json['imageUrl'] ?? 'https://via.placeholder.com/150',
      mealType: json['mealType'] ?? 'General',
      prepTimeMinutes: json['prepTimeMinutes'] ?? 30,
      calories: json['calories'] ?? 0,
      planComponents:
          (json['planComponents'] as List<dynamic>?)?.cast<String>() ?? [],
      additionalIngredients: additional
          .map((i) => RecipeIngredient.fromJson(i as Map<String, dynamic>))
          .toList(),
      steps: steps,
    );
  }
}

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
