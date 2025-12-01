import 'package:Frutia/l10n/app_localizations.dart';
import 'package:Frutia/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
// import 'package:url_launcher/url_launcher.dart'; // Uncomment if using URL launching

class HelpAndSupportScreen extends StatelessWidget {
  const HelpAndSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.helpAndSupportTitle,
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
                l10n.helpTitle,
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 800.ms),
              const SizedBox(height: 16),
              Text(
                l10n.helpIntro,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: FrutiaColors.secondaryText,
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 800.ms),
              const SizedBox(height: 16),
              Text(
                l10n.helpSection1,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: FrutiaColors.secondaryText,
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 800.ms),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  // Replace with your actual FAQs page navigation
                  // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => FAQsScreen()));
                  // Or use: launchUrl(Uri.parse('https://www.frutia.com/faqs'));
                },
                child: Text(
                  l10n.viewFAQs,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ).animate().fadeIn(delay: 800.ms, duration: 800.ms),
              const SizedBox(height: 16),
              Text(
                l10n.helpSection2,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: FrutiaColors.secondaryText,
                ),
              ).animate().fadeIn(delay: 1000.ms, duration: 800.ms),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  // Replace with email action
                  // Example: launchUrl(Uri.parse('mailto:soporte@frutia.com'));
                },
                child: Text(
                  l10n.contactEmail,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ).animate().fadeIn(delay: 1200.ms, duration: 800.ms),
              const SizedBox(height: 16),
              Text(
                l10n.helpSection3,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: FrutiaColors.secondaryText,
                ),
              ).animate().fadeIn(delay: 1400.ms, duration: 800.ms),
              const SizedBox(height: 8),
              const SizedBox(height: 16),
              Text(
                l10n.helpSection4,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: FrutiaColors.secondaryText,
                ),
              ).animate().fadeIn(delay: 1800.ms, duration: 800.ms),
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
                ).animate().fadeIn(delay: 2000.ms, duration: 800.ms),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
