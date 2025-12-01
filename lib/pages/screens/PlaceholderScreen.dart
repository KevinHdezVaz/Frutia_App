import 'package:Frutia/l10n/app_localizations.dart';
import 'package:Frutia/pages/Pantalla1.dart';
import 'package:Frutia/pages/Pantalla2.dart';
import 'package:Frutia/pages/screens/CompraDetailScreen.dart';
import 'package:Frutia/pages/screens/ModificationsScreen.dart';
import 'package:Frutia/pages/screens/datosPersonales/OnboardingScreen.dart';
import 'package:Frutia/pages/screens/RecipeDetailScreen.dart';
import 'package:Frutia/pages/screens/miplan/MyPlanPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:Frutia/utils/colors.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlaceholderScreen extends StatefulWidget {
  const PlaceholderScreen({Key? key}) : super(key: key);

  @override
  State<PlaceholderScreen> createState() => _PlaceholderScreenState();
}

class _PlaceholderScreenState extends State<PlaceholderScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const _HomeContent(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [FrutiaColors.accent, FrutiaColors.accent2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Frutia',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(
        child: _screens[_currentIndex],
      ),
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
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              elevation: 0,
              iconSize: 22,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              items: [
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.person, size: 22),
                  ),
                  label: l10n.profile,
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.message, size: 22),
                  ),
                  label: "Frutia",
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.food_bank, size: 22),
                  ),
                  label: l10n.myPlan,
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.auto_graph_outlined, size: 22),
                  ),
                  label: l10n.progress,
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.book, size: 22),
                  ),
                  label: l10n.aboutUs,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent({super.key});

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  final GlobalKey _miPlanKey = GlobalKey(debugLabel: 'miPlanShowcase');
  final GlobalKey _recetasKey = GlobalKey(debugLabel: 'recetasShowcase');
  final GlobalKey _comprasKey = GlobalKey(debugLabel: 'comprasShowcase');
  final GlobalKey _modificacionesKey =
      GlobalKey(debugLabel: 'modificacionesShowcase');

  late List<Map<String, dynamic>> categories;
  late List<GlobalKey> categoryKeys;

  @override
  void initState() {
    super.initState();

    categories = [
      {
        'name': 'myPlan',
        'icon': Icons.home,
        'image': 'assets/images/plan_alimenticion.jpg'
      },
      {
        'name': 'recipes',
        'icon': Icons.restaurant_menu,
        'image': 'assets/images/receta.png'
      },
      {
        'name': 'shopping',
        'icon': Icons.shopping_cart,
        'image': 'assets/images/compras.jpg'
      },
      {
        'name': 'modifications',
        'icon': Icons.edit,
        'image': 'assets/images/modificacione.png'
      },
    ];

    categoryKeys = [
      _miPlanKey,
      _recetasKey,
      _comprasKey,
      _modificacionesKey,
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showCategoryShowcase();
    });
  }

  Future<void> _showCategoryShowcase() async {
    final prefs = await SharedPreferences.getInstance();
    final bool showcaseShown = prefs.getBool('categoryShowcaseShown') ?? false;

    if (!showcaseShown && mounted) {
      await Future.delayed(const Duration(milliseconds: 500));

      if (ShowCaseWidget.of(context).mounted) {
        ShowCaseWidget.of(context).startShowCase(categoryKeys);
        await prefs.setBool('categoryShowcaseShown', true);
        debugPrint('PlaceholderScreen: Category showcase started!');
      } else {
        debugPrint(
            'PlaceholderScreen: ShowCaseWidget is not mounted in context.');
      }
    } else {
      debugPrint(
          'PlaceholderScreen: Category showcase conditions not met or already shown.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(categories.length, (index) {
                    return _InteractiveCard(
                      category: categories[index],
                      index: index,
                      cardKey: categoryKeys[index],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InteractiveCard extends StatefulWidget {
  final Map<String, dynamic> category;
  final int index;
  final GlobalKey cardKey;

  const _InteractiveCard({
    required this.category,
    required this.index,
    required this.cardKey,
  });

  @override
  _InteractiveCardState createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<_InteractiveCard>
    with SingleTickerProviderStateMixin {
  bool _isTapped = false;
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getCategoryName(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case 'myPlan':
        return l10n.myPlan;
      case 'recipes':
        return l10n.recipes;
      case 'shopping':
        return l10n.shopping;
      case 'modifications':
        return l10n.modifications;
      default:
        return key;
    }
  }

  String _getShowcaseDescription(BuildContext context, String categoryKey) {
    final l10n = AppLocalizations.of(context)!;
    switch (categoryKey) {
      case 'myPlan':
        return l10n.myPlanDescription;
      case 'recipes':
        return l10n.recipesDescription;
      case 'shopping':
        return l10n.shoppingDescription;
      case 'modifications':
        return l10n.modificationsDescription;
      default:
        return l10n.importantSection;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryName = _getCategoryName(context, widget.category['name']);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Showcase(
        key: widget.cardKey,
        title: categoryName,
        description: _getShowcaseDescription(context, widget.category['name']),
        tooltipBackgroundColor: FrutiaColors.accent,
        targetShapeBorder: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12))),
        titleTextStyle: GoogleFonts.poppins(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        descTextStyle: GoogleFonts.lato(color: Colors.white, fontSize: 14),
        disableMovingAnimation: true,
        disableScaleAnimation: true,
        child: GestureDetector(
          onTapDown: (_) {
            setState(() {
              _isTapped = true;
            });
            _controller.forward();
          },
          onTapUp: (_) {
            setState(() {
              _isTapped = false;
            });
            _controller.reverse();
          },
          onTapCancel: () {
            setState(() {
              _isTapped = false;
            });
            _controller.reverse();
          },
          onPanStart: (_) {
            setState(() {
              _isHovered = true;
            });
            _controller.forward();
          },
          onPanEnd: (_) {
            setState(() {
              _isHovered = false;
            });
            _controller.reverse();
          },
          onTap: () async {
            switch (widget.category['name']) {
              case 'myPlan':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfessionalMiPlanDiarioScreen()),
                );
                break;
              case 'recipes':
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PremiumRecetasScreen(),
                    ));
                break;
              case 'shopping':
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ComprasScreen()),
                );
                break;
              case 'modifications':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ModificationsScreen()),
                );
                break;
            }
          },
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Card(
                  elevation: _isHovered || _isTapped ? 8 : 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: _isTapped ? Colors.grey[200] : Colors.white,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: AssetImage(widget.category['image']),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(_isHovered ? 0.2 : 0.3),
                          BlendMode.darken,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.category['icon'],
                            size: 40,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            categoryName,
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 2.0,
                                  color: Colors.black.withOpacity(0.5),
                                  offset: Offset(1.0, 1.0),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      )
          .animate()
          .fadeIn(duration: 800.ms, delay: (200 + widget.index * 200).ms)
          .slideY(
            begin: 0.3,
            end: 0.0,
            duration: 800.ms,
            curve: Curves.easeOut,
          ),
    );
  }
}
