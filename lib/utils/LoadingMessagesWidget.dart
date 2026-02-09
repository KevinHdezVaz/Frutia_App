import 'package:Frutia/l10n/app_localizations.dart';
import 'package:Frutia/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoadingMessagesWidget extends StatefulWidget {
  const LoadingMessagesWidget({Key? key}) : super(key: key);

  @override
  State<LoadingMessagesWidget> createState() => _LoadingMessagesWidgetState();
}

class _LoadingMessagesWidgetState extends State<LoadingMessagesWidget> {
  late final Stream<int> _ticker;

  @override
  void initState() {
    super.initState();
    // Creamos un "ticker" que emite un valor incremental cada 3 segundos
    _ticker = Stream.periodic(const Duration(seconds: 3), (i) => i)
        .asBroadcastStream();
  }

  List<String> _getMessages(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      l10n.analyzingResponses,
      l10n.creatingUniquePlan,
      l10n.frutiaAccompaniesYouLoading,
      l10n.almostPerfectPlan,
      l10n.frutiaKnowsNeeds,
      l10n.usersTrustUs,
      l10n.selectingBestRecipes,
      l10n.prepareForPositiveChange,
      l10n.calculatingMacros,
      l10n.adjustingPortions,
      l10n.filteringRecipes,
      l10n.investingInHealth,
      l10n.structuringMeals,
      l10n.consistencyIsKey,
      l10n.compilingShoppingList,
      l10n.eatingHealthyPossible,
      l10n.imagineEnergy,
      l10n.journeyBeginsNow,
      l10n.wellnessSeriously,
      l10n.smallStepGreatLeap,
      l10n.patienceSecretIngredient,
      l10n.optimizingBudget,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final messages = _getMessages(context);

    return StreamBuilder<int>(
      stream: _ticker,
      initialData: 0,
      builder: (context, snapshot) {
        final index = (snapshot.data ?? 0) % messages.length;

        // AnimatedSwitcher se encarga de la animación de cambio de texto
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
          transitionBuilder: (Widget child, Animation<double> animation) {
            // Animación de desvanecimiento (fade) y un ligero deslizamiento
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.3), // Empieza desde abajo
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Text(
            // La clave (key) es MUY IMPORTANTE. Le dice a AnimatedSwitcher
            // que el widget ha cambiado y debe animar la transición.
            messages[index],
            key: ValueKey<int>(index),
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: FrutiaColors.primaryText.withOpacity(0.8),
            ),
          ),
        );
      },
    );
  }
}
