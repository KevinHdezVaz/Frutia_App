import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:Frutia/utils/colors.dart';

class MyPlanPage extends StatefulWidget {
  @override
  _MyPlanPageState createState() => _MyPlanPageState();
}

class _MyPlanPageState extends State<MyPlanPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<String> favoriteMeals = [];
  List<String> favoriteTips = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 4, vsync: this); // Añadida pestaña para Recomendaciones
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _toggleFavorite(String itemName, bool isMeal) {
    setState(() {
      final list = isMeal ? favoriteMeals : favoriteTips;
      final message = isMeal ? 'comida' : 'recomendación';
      if (list.contains(itemName)) {
        list.remove(itemName);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$itemName eliminad${isMeal ? 'a' : 'o'} de favoritos',
              style: GoogleFonts.lato(color: Colors.white),
            ),
            backgroundColor: FrutiaColors.accent,
          ),
        );
      } else {
        list.add(itemName);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$itemName añadid${isMeal ? 'a' : 'o'} a favoritos',
              style: GoogleFonts.lato(color: Colors.white),
            ),
            backgroundColor: FrutiaColors.accent,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Plan',
            style: GoogleFonts.lato(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        backgroundColor: Colors
            .transparent, // Fondo transparente para que se vea el gradiente
        elevation: 0, // Sin sombra
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              FrutiaColors.secondaryBackground, // Off-White
              FrutiaColors.accent, // Strawberry Red
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TabBar(
                controller: _tabController,
                labelColor: FrutiaColors.accent,
                unselectedLabelColor: FrutiaColors.disabledText,
                indicatorColor: FrutiaColors.accent,
                labelStyle: GoogleFonts.lato(fontWeight: FontWeight.bold),
                tabs: [
                  Tab(text: 'Desayuno'),
                  Tab(text: 'Almuerzo'),
                  Tab(text: 'Cena'),
                  Tab(text: 'Recomendaciones'), // Nueva pestaña
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    ListViewSection(
                      sectionType: 'Desayuno',
                      items: breakfastMeals,
                      notes: [],
                      favoriteItems: favoriteMeals,
                      onToggleFavorite: (itemName) =>
                          _toggleFavorite(itemName, true),
                      isMeal: true,
                    ),
                    ListViewSection(
                      sectionType: 'Almuerzo',
                      items: lunchDinnerMeals,
                      notes: [
                        'Ensalada LIBRE (NO beterraga, NO zanahoria, ½ palta SOLO con atún o pollo)',
                        'Escoge una proteína y un carbohidrato y apóyate con una receta',
                      ],
                      favoriteItems: favoriteMeals,
                      onToggleFavorite: (itemName) =>
                          _toggleFavorite(itemName, true),
                      isMeal: true,
                    ),
                    ListViewSection(
                      sectionType: 'Cena',
                      items: lunchDinnerMeals,
                      notes: [
                        'Ensalada LIBRE (NO beterraga, NO zanahoria, ½ palta SOLO con atún o pollo)',
                        'Escoge una proteína y un carbohidrato y apóyate con una receta',
                      ],
                      favoriteItems: favoriteMeals,
                      onToggleFavorite: (itemName) =>
                          _toggleFavorite(itemName, true),
                      isMeal: true,
                    ),
                    ListViewSection(
                      sectionType: 'Recomendaciones',
                      items: recommendations,
                      notes: [
                        'Sigue estos consejos para mejorar tu plan nutricional'
                      ],
                      favoriteItems: favoriteTips,
                      onToggleFavorite: (itemName) =>
                          _toggleFavorite(itemName, false),
                      isMeal: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ModificationsScreen()),
          );
        },
        child: Icon(Icons.edit, color: Colors.white),
        backgroundColor: FrutiaColors.accent,
        tooltip: 'Modificar Preferencias',
        heroTag: 'modify',
      ).animate().scale(duration: 800.ms, curve: Curves.easeOut),
      bottomNavigationBar: Container(
        color: FrutiaColors.secondaryBackground,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              selectedItemColor: FrutiaColors.accent,
              unselectedItemColor: FrutiaColors.disabledText,
              backgroundColor: FrutiaColors.secondaryBackground,
              currentIndex: 2, // Seleccionado "Mi Plan"
              onTap: (index) {
                if (index == 0) {
                  Navigator.pushNamed(context, '/profile');
                } else if (index == 1) {
                  Navigator.pushNamed(context, '/chat');
                } else if (index == 3) {
                  Navigator.pushNamed(context, '/progress');
                } else if (index == 4) {
                  Navigator.pushNamed(context, '/about');
                }
              },
              elevation: 0,
              iconSize: 22,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              items: [
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.person,
                      color: 2 == 0
                          ? FrutiaColors.accent
                          : FrutiaColors.disabledText,
                      size: 22,
                    ),
                  ),
                  label: "Perfil",
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.message,
                      color: 2 == 1
                          ? FrutiaColors.accent
                          : FrutiaColors.disabledText,
                      size: 22,
                    ),
                  ),
                  label: "Frutia",
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.food_bank,
                      color: 2 == 2
                          ? FrutiaColors.accent
                          : FrutiaColors.disabledText,
                      size: 22,
                    ),
                  ),
                  label: "Mi Plan",
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.auto_graph_outlined,
                      color: 2 == 3
                          ? FrutiaColors.accent
                          : FrutiaColors.disabledText,
                      size: 22,
                    ),
                  ),
                  label: "Progreso",
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.book,
                      color: 2 == 4
                          ? FrutiaColors.accent
                          : FrutiaColors.disabledText,
                      size: 22,
                    ),
                  ),
                  label: "Nosotros",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Lista de comidas para Desayuno
  final List<Map<String, dynamic>> breakfastMeals = [
    {
      'name': '2 huevos + 1 tostada',
      'calories': '200 kcal',
      'image': 'assets/eggs_toast.jpg',
      'recipeRoute': '/recipe/eggs_toast',
    },
    {
      'name': '1 scoop de proteína + 1 plátano',
      'calories': '250 kcal',
      'image': 'assets/protein_banana.jpg',
      'recipeRoute': '/recipe/protein_banana',
    },
    {
      'name': 'Pancakes proteicos',
      'calories': '300 kcal',
      'image': 'assets/protein_pancakes.jpg',
      'recipeRoute': '/recipe/protein_pancakes',
    },
    {
      'name': '85g de pollo + 1 tostada',
      'calories': '220 kcal',
      'image': 'assets/chicken_toast.jpg',
      'recipeRoute': '/recipe/chicken_toast',
    },
    {
      'name': '1 lata de atún en agua + galletas de agua',
      'calories': '180 kcal',
      'image': 'assets/tuna_crackers.jpg',
      'recipeRoute': '/recipe/tuna_crackers',
    },
  ];

  // Lista de comidas para Almuerzo y Cena
  final List<Map<String, dynamic>> lunchDinnerMeals = [
    {
      'name': 'Pollo (170g) + Camote (300g) + Ensalada',
      'calories': '500 kcal',
      'image': 'assets/chicken_sweetpotato.jpg',
      'recipeRoute': '/recipe/chicken_sweetpotato',
    },
    {
      'name': 'Carne (200g) + Quinoa (200g) + Ensalada',
      'calories': '550 kcal',
      'image': 'assets/beef_quinoa.jpg',
      'recipeRoute': '/recipe/beef_quinoa',
    },
    {
      'name': 'Pescado (200g) + Lentejas (300g) + Ensalada',
      'calories': '520 kcal',
      'image': 'assets/fish_lentils.jpg',
      'recipeRoute': '/recipe/fish_lentils',
    },
    {
      'name': '1.5 latas de atún + ½ palta + Ensalada',
      'calories': '400 kcal',
      'image': 'assets/tuna_avocado.jpg',
      'recipeRoute': '/recipe/tuna_avocado',
    },
  ];

  // Lista de recomendaciones (página 10)
  final List<Map<String, dynamic>> recommendations = [
    {
      'name': 'Bebe 2 litros de agua al día',
      'details': 'Mantenerte hidratado es clave para tu salud y energía.',
      'image': 'assets/water.jpg',
      'detailsRoute': '/details/water',
    },
    {
      'name': 'Incluye fibra en cada comida',
      'details': 'La fibra ayuda a la digestión y te mantiene saciado.',
      'image': 'assets/fiber.jpg',
      'detailsRoute': '/details/fiber',
    },
    {
      'name': 'Evita beterraga y zanahoria',
      'details': 'Sigue tus preferencias personales para un plan cómodo.',
      'image': 'assets/no_beet.jpg',
      'detailsRoute': '/details/no_beet',
    },
    {
      'name': 'Prueba snacks proteicos',
      'details': 'Los snacks ricos en proteína te ayudan a mantener músculo.',
      'image': 'assets/protein_snack.jpg',
      'detailsRoute': '/details/protein_snack',
    },
  ];
}

class ListViewSection extends StatelessWidget {
  final String sectionType;
  final List<Map<String, dynamic>> items;
  final List<String> notes;
  final List<String> favoriteItems;
  final Function(String) onToggleFavorite;
  final bool isMeal;

  ListViewSection({
    required this.sectionType,
    required this.items,
    required this.notes,
    required this.favoriteItems,
    required this.onToggleFavorite,
    required this.isMeal,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sectionType,
            style: GoogleFonts.lato(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: FrutiaColors.primaryText,
            ),
          ).animate().fadeIn(duration: 800.ms).slideX(
                begin: -0.2,
                end: 0.0,
                duration: 800.ms,
                curve: Curves.easeOut,
              ),
          SizedBox(height: 16),
          if (notes.isNotEmpty)
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              color: FrutiaColors.primaryBackground,
              child: ExpansionTile(
                title: Text(
                  'Notas Importantes',
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    color: FrutiaColors.primaryText,
                  ),
                ),
                leading: Icon(Icons.info_outline, color: FrutiaColors.accent),
                children: notes
                    .map((note) => Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            note,
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              color: FrutiaColors.secondaryText,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ).animate().fadeIn(duration: 800.ms).slideY(
                  begin: 0.3,
                  end: 0.0,
                  duration: 800.ms,
                  curve: Curves.easeOut,
                ),
          SizedBox(height: 16),
          ...items.asMap().entries.map((entry) {
            final item = entry.value;
            return Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              color: FrutiaColors.primaryBackground,
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context,
                      isMeal ? item['recipeRoute'] : item['detailsRoute']);
                },
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          item['image'],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 80,
                            height: 80,
                            color: FrutiaColors.secondaryBackground,
                            child: Icon(Icons.image_not_supported,
                                color: FrutiaColors.disabledText),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style: GoogleFonts.lato(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: FrutiaColors.primaryText,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              isMeal ? item['calories'] : item['details'],
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                color: FrutiaColors.secondaryText,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          favoriteItems.contains(item['name'])
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: favoriteItems.contains(item['name'])
                              ? FrutiaColors.accent
                              : FrutiaColors.disabledText,
                        ),
                        onPressed: () => onToggleFavorite(item['name']),
                      ),
                    ],
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 800.ms, delay: (200 + entry.key * 200).ms)
                .slideY(
                  begin: 0.3,
                  end: 0.0,
                  duration: 800.ms,
                  curve: Curves.easeOut,
                );
          }).toList(),
        ],
      ),
    );
  }
}

class ModificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              FrutiaColors.secondaryBackground,
              FrutiaColors.accent,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Modificar Preferencias',
                  style: GoogleFonts.lato(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: FrutiaColors.primaryText,
                  ),
                ).animate().fadeIn(duration: 800.ms).slideX(
                      begin: -0.2,
                      end: 0.0,
                      duration: 800.ms,
                      curve: Curves.easeOut,
                    ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Ingredientes a evitar',
                    labelStyle:
                        GoogleFonts.lato(color: FrutiaColors.secondaryText),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: FrutiaColors.accent),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: FrutiaColors.disabledText),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: FrutiaColors.accent, width: 2),
                    ),
                    hintText: 'Ej: Beterraga, zanahoria',
                    hintStyle:
                        GoogleFonts.lato(color: FrutiaColors.disabledText),
                  ),
                  style: GoogleFonts.lato(color: FrutiaColors.primaryText),
                ).animate().fadeIn(duration: 800.ms).slideY(
                      begin: 0.3,
                      end: 0.0,
                      duration: 800.ms,
                      curve: Curves.easeOut,
                    ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Preferencias guardadas',
                          style: GoogleFonts.lato(color: Colors.white),
                        ),
                        backgroundColor: FrutiaColors.accent,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Guardar Cambios',
                    style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  ),
                ).animate().fadeIn(duration: 800.ms).slideY(
                      begin: 0.3,
                      end: 0.0,
                      duration: 800.ms,
                      curve: Curves.easeOut,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
