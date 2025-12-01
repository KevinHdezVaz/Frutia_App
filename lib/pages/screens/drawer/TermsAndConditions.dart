import 'package:Frutia/l10n/app_localizations.dart';
import 'package:Frutia/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.termsAndConditionsTitle,
          style: GoogleFonts.lato(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.termsTitle,
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 800.ms),
              const SizedBox(height: 16),
              Text(
                l10n.termsIntro,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: FrutiaColors.secondaryText,
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 800.ms),
              const SizedBox(height: 16),
              Text(
                l10n.termsSection1,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: FrutiaColors.secondaryText,
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 800.ms),
              const SizedBox(height: 16),
              Text(
                l10n.termsSection2,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: FrutiaColors.secondaryText,
                ),
              ).animate().fadeIn(delay: 800.ms, duration: 800.ms),
              const SizedBox(height: 16),
              Text(
                l10n.termsSection3,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: FrutiaColors.secondaryText,
                ),
              ).animate().fadeIn(delay: 1000.ms, duration: 800.ms),
              const SizedBox(height: 16),
              Text(
                l10n.termsSection4,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: FrutiaColors.secondaryText,
                ),
              ).animate().fadeIn(delay: 1200.ms, duration: 800.ms),
              const SizedBox(height: 16),
              Text(
                l10n.termsSection5,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: FrutiaColors.secondaryText,
                ),
              ).animate().fadeIn(delay: 1400.ms, duration: 800.ms),
              const SizedBox(height: 16),
              Text(
                l10n.termsSection6,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: FrutiaColors.secondaryText,
                ),
              ).animate().fadeIn(delay: 1600.ms, duration: 800.ms),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    l10n.goBack,
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ).animate().fadeIn(delay: 1800.ms, duration: 800.ms),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
