class FoodTranslations {
  // ⭐ MAPEO COMPLETO: DB_KEY (inglés) → Traducciones
  static const Map<String, Map<String, String>> _foodNames = {
    // ═══════════════════════════════════════
    // PROTEÍNAS
    // ═══════════════════════════════════════
    'whole_egg': {'en': 'Whole Egg', 'es': 'Huevo entero'},
    'whole_eggs': {'en': 'Whole Eggs', 'es': 'Huevos enteros'}, // ⭐ NUEVO
    'scrambled_eggs': {'en': 'Scrambled Eggs', 'es': 'Huevos revueltos'},
    'egg_whites_whole': {
      'en': 'Egg Whites + Whole Egg',
      'es': 'Claras + Huevo Entero'
    },
    'egg_whites': {'en': 'Egg Whites', 'es': 'Claras de huevo'},
    'pasteurized_egg_whites': {
      'en': 'Pasteurized Egg Whites',
      'es': 'Claras pasteurizadas'
    },

    'canned_tuna': {'en': 'Canned Tuna', 'es': 'Atún en lata'},
    'fresh_tuna': {'en': 'Fresh Tuna', 'es': 'Atún fresco'},

    'chicken_breast': {'en': 'Chicken Breast', 'es': 'Pechuga de pollo'},
    'chicken_thigh': {'en': 'Chicken Thigh', 'es': 'Pollo muslo'},
    'chicken_thigh_skin': {
      'en': 'Chicken Thigh With Skin',
      'es': 'Pollo muslo con piel'
    },

    'ground_beef': {'en': 'Ground Beef', 'es': 'Carne molida'},
    'ground_beef_8020': {'en': 'Ground Beef 80/20', 'es': 'Carne molida 80/20'},
    'lean_beef': {'en': 'Lean Beef', 'es': 'Carne de res magra'},
    'ribeye': {'en': 'Ribeye', 'es': 'Ribeye'},

    'fresh_salmon': {'en': 'Fresh Salmon', 'es': 'Salmón fresco'},
    'salmon': {'en': 'Salmon', 'es': 'Salmón'},
    'white_fish': {'en': 'White Fish', 'es': 'Pescado blanco'},

    'turkey_breast': {'en': 'Turkey Breast', 'es': 'Pechuga de pavo'},
    'duck_breast': {'en': 'Duck Breast', 'es': 'Pechuga de pato'},

    'greek_yogurt': {'en': 'Greek Yogurt', 'es': 'Yogurt griego'},
    'natural_yogurt': {'en': 'Natural Yogurt', 'es': 'Yogurt natural'},
    'high_protein_greek_yogurt': {
      'en': 'High Protein Greek Yogurt',
      'es': 'Yogurt griego alto en proteína'
    },

    'fresh_cheese': {'en': 'Fresh Cheese', 'es': 'Queso fresco'},
    'cottage_cheese': {'en': 'Cottage Cheese', 'es': 'Queso cottage'},
    'oaxaca_cheese': {'en': 'Oaxaca Cheese', 'es': 'Queso Oaxaca'},
    'panela_cheese': {'en': 'Panela Cheese', 'es': 'Queso panela'},
    'aged_cheese': {'en': 'Aged Cheese', 'es': 'Queso añejo'},

    'whey_protein': {'en': 'Whey Protein', 'es': 'Proteína whey'},
    'casein': {'en': 'Casein', 'es': 'Caseína'},
    'protein_powder': {'en': 'Protein Powder', 'es': 'Proteína en polvo'},
    'plant_protein_powder': {
      'en': 'Plant Protein Powder',
      'es': 'Proteína vegetal en polvo'
    },

    // Proteínas Vegetarianas/Veganas
    'cooked_lentils': {'en': 'Cooked Lentils', 'es': 'Lentejas cocidas'},
    'lentils': {'en': 'Lentils', 'es': 'Lentejas'},
    'cooked_black_beans': {
      'en': 'Cooked Black Beans',
      'es': 'Frijoles negros cocidos'
    },
    'black_beans': {'en': 'Black Beans', 'es': 'Frijoles negros'},
    'cooked_chickpeas': {'en': 'Cooked Chickpeas', 'es': 'Garbanzos cocidos'},
    'chickpeas': {'en': 'Chickpeas', 'es': 'Garbanzos'},
    'beans': {'en': 'Beans', 'es': 'Frijoles'},

    'firm_tofu': {'en': 'Firm Tofu', 'es': 'Tofu firme'},
    'tofu': {'en': 'Tofu', 'es': 'Tofu'},
    'tempeh': {'en': 'Tempeh', 'es': 'Tempeh'},
    'seitan': {'en': 'Seitan', 'es': 'Seitán'},

    'grilled_panela_cheese': {
      'en': 'Grilled Panela Cheese',
      'es': 'Queso panela a la plancha'
    },
    'ricotta_herbs': {'en': 'Ricotta With Herbs', 'es': 'Ricotta con hierbas'},
    'ricotta': {'en': 'Ricotta', 'es': 'Ricotta'},
    'lentil_burger': {'en': 'Lentil Burger', 'es': 'Hamburguesa de lentejas'},

    'Artisan Whole Wheat Bread': {
      'en': 'Artisan Whole Wheat Bread',
      'es': 'Pan integral artesanal'
    },
    'Beans': {'en': 'Beans', 'es': 'Frijoles'},
    'Basic Noodles/Pasta': {
      'en': 'Basic Noodles/Pasta',
      'es': 'Fideos básicos'
    },
    'Broccoli': {'en': 'Broccoli', 'es': 'Brócoli'},
    'Cauliflower': {'en': 'Cauliflower', 'es': 'Coliflor'},
    'Corn Tortillas': {'en': 'Corn Tortillas', 'es': 'Tortillas de maíz'},
    'Cream Of Rice': {'en': 'Cream Of Rice', 'es': 'Crema de arroz'},
    'Lettuce': {'en': 'Lettuce', 'es': 'Lechuga'},
    'Organic Oats': {'en': 'Organic Oats', 'es': 'Avena orgánica'},
    'Potato': {'en': 'Potato', 'es': 'Papa'},
    'Quinoa': {'en': 'Quinoa', 'es': 'Quinua'},
    'Rice Crackers': {'en': 'Rice Crackers', 'es': 'Galletas de arroz'},
    'Spinach': {'en': 'Spinach', 'es': 'Espinacas'},
    'Sweet Potato': {'en': 'Sweet Potato', 'es': 'Camote'},
    'Traditional Oats': {'en': 'Traditional Oats', 'es': 'Avena tradicional'},
    'White Rice': {'en': 'White Rice', 'es': 'Arroz blanco'},
    'Zucchini': {'en': 'Zucchini', 'es': 'Calabacín'},

    // ═══════════════════════════════════════
    // CARBOHIDRATOS
    // ═══════════════════════════════════════
    'white_rice': {'en': 'White Rice', 'es': 'Arroz blanco'},
    'potato': {'en': 'Potato', 'es': 'Papa'},
    'sweet_potato': {'en': 'Sweet Potato', 'es': 'Camote'},
    'pasta': {'en': 'Pasta', 'es': 'Fideo'},
    'quinoa': {'en': 'Quinoa', 'es': 'Quinua'},
    'cooked_quinoa': {'en': 'Cooked Quinoa', 'es': 'Quinua cocida'},
    'oatmeal': {'en': 'Oatmeal', 'es': 'Avena'},
    'traditional_oatmeal': {
      'en': 'Traditional Oatmeal',
      'es': 'Avena tradicional'
    },
    'organic_oatmeal': {'en': 'Organic Oatmeal', 'es': 'Avena orgánica'},
    'whole_wheat_bread': {'en': 'Whole Wheat Bread', 'es': 'Pan integral'},
    'artisan_whole_wheat_bread': {
      'en': 'Artisan Whole Wheat Bread',
      'es': 'Pan integral artesanal'
    },
    'corn_tortilla': {'en': 'Corn Tortilla', 'es': 'Tortilla de maíz'},
    'rice_crackers': {'en': 'Rice Crackers', 'es': 'Galletas de arroz'},
    'cream_of_rice': {'en': 'Cream Of Rice', 'es': 'Crema de arroz'},
    'corn_cereal': {'en': 'Corn Cereal', 'es': 'Cereal de maíz'},

    // Carbohidratos Keto
    'broccoli': {'en': 'Broccoli', 'es': 'Brócoli'},
    'steamed_broccoli': {
      'en': 'Steamed Broccoli',
      'es': 'Brócoli al vapor'
    }, // ⭐ NUEVO
    'cauliflower': {'en': 'Cauliflower', 'es': 'Coliflor'},
    'spinach': {'en': 'Spinach', 'es': 'Espinaca'},
    'sauteed_spinach': {
      'en': 'Sautéed Spinach',
      'es': 'Espinacas salteadas'
    }, // ⭐ NUEVO
    'lettuce': {'en': 'Lettuce', 'es': 'Lechuga'},

    // ═══════════════════════════════════════
    // GRASAS
    // ═══════════════════════════════════════
    'vegetable_oil': {'en': 'Vegetable Oil', 'es': 'Aceite vegetal'}, // ⭐ NUEVO
    'extra_virgin_olive_oil': {
      'en': 'Extra Virgin Olive Oil',
      'es': 'Aceite de oliva extra virgen'
    },
    'olive_oil': {'en': 'Olive Oil', 'es': 'Aceite de oliva'},
    'mct_oil': {'en': 'MCT Oil', 'es': 'Aceite MCT'},

    'peanuts': {'en': 'Peanuts', 'es': 'Maní'},
    'peanut_butter': {'en': 'Peanut Butter', 'es': 'Mantequilla de maní'},
    'homemade_peanut_butter': {
      'en': 'Homemade Peanut Butter',
      'es': 'Mantequilla de maní casera'
    },

    'avocado': {'en': 'Avocado', 'es': 'Aguacate'},
    'small_avocado': {'en': 'Small Avocado', 'es': 'Aguacate pequeño'},
    'hass_avocado': {'en': 'Hass Avocado', 'es': 'Aguacate hass'},

    'almonds': {'en': 'Almonds', 'es': 'Almendras'},
    'walnuts': {'en': 'Walnuts', 'es': 'Nueces'},
    'organic_chia_seeds': {
      'en': 'Organic Chia Seeds',
      'es': 'Semillas de chía orgánicas'
    },

    'honey': {'en': 'Honey', 'es': 'Miel'},
    'dark_chocolate_70': {
      'en': '70% Dark Chocolate',
      'es': 'Chocolate negro 70%'
    },

    'lard': {'en': 'Lard', 'es': 'Manteca de cerdo'},
    'butter': {'en': 'Butter', 'es': 'Mantequilla'},
    'ghee_butter': {'en': 'Ghee Butter', 'es': 'Mantequilla ghee'},

    // ═══════════════════════════════════════
    // FRUTAS
    // ═══════════════════════════════════════
    'banana': {'en': 'Banana', 'es': 'Plátano'},
    'apple': {'en': 'Apple', 'es': 'Manzana'},
    'orange': {'en': 'Orange', 'es': 'Naranja'},
    'berries': {'en': 'Mixed Berries', 'es': 'Berries mix'},
    'organic_berries': {
      'en': 'Organic Mixed Berries',
      'es': 'Berries mix orgánico'
    }, // ⭐ NUEVO
    'strawberries': {'en': 'Strawberries', 'es': 'Fresas'},
    'blueberries': {'en': 'Blueberries', 'es': 'Arándanos'},
    'blackberries': {'en': 'Blackberries', 'es': 'Moras'},
    'mango': {'en': 'Mango', 'es': 'Mango'},
    'papaya': {'en': 'Papaya', 'es': 'Papaya'},
    'watermelon': {'en': 'Watermelon', 'es': 'Sandía'},
    'pear': {'en': 'Pear', 'es': 'Pera'},
    'grapes': {'en': 'Grapes', 'es': 'Uvas'},

    // ═══════════════════════════════════════
    // VEGETALES
    // ═══════════════════════════════════════
    'mixed_salad': {'en': 'Mixed Salad', 'es': 'Ensalada mixta'},
    'steamed_vegetables': {
      'en': 'Steamed Vegetables',
      'es': 'Vegetales al vapor'
    },
    'mediterranean_salad': {
      'en': 'Mediterranean Salad',
      'es': 'Ensalada mediterránea'
    },
    'sauteed_vegetables': {
      'en': 'Sautéed Vegetables',
      'es': 'Vegetales salteados'
    },
  };

  /// ⭐ Convierte nombres mostrados en UI → keys de BD
  static List<String> listToDbValues(List<String> displayNames, String locale) {
    return displayNames.map((displayName) {
      final entry = _foodNames.entries.firstWhere(
        (e) => e.value[locale]?.toLowerCase() == displayName.toLowerCase(),
        orElse: () => MapEntry('', {}),
      );
      return entry.key.isNotEmpty ? entry.key : displayName;
    }).toList();
  }

  /// ⭐ Convierte keys de BD → nombres para mostrar en UI
  static List<String> listToDisplayNames(List<String> dbKeys, String locale) {
    return dbKeys.map((dbKey) {
      // 1. ¿Es una key directa?
      if (_foodNames.containsKey(dbKey)) {
        return _foodNames[dbKey]?[locale] ?? dbKey;
      }

      // 2. ¿Es un valor en español o inglés (buscamos por valor)?
      // Esto es útil si los datos se guardaron en un idioma y se cargan en otro.
      try {
        final entry = _foodNames.entries.firstWhere(
          (e) =>
              e.value['es']?.toLowerCase() == dbKey.toLowerCase() ||
              e.value['en']?.toLowerCase() == dbKey.toLowerCase(),
        );
        return entry.value[locale] ?? dbKey;
      } catch (_) {
        return dbKey;
      }
    }).toList();
  }

  static String getName(String dbKey, String locale) {
    return _foodNames[dbKey]?[locale] ?? dbKey;
  }

  static bool hasKey(String dbKey) {
    return _foodNames.containsKey(dbKey);
  }

  static List<String> getAllKeys() {
    return _foodNames.keys.toList();
  }
}
