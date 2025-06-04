import 'package:flutter/material.dart';

class FrutiaColors {
  // Core Background Colors
  static const Color primaryBackground =
      Color(0xFFFFFFFF); // White for main background
  static const Color secondaryBackground =
      Color(0xFFF5F5F5); // Off-White for secondary backgrounds

  // Text Colors
  static const Color primaryText =
      Color(0xFF2D2D2D); // Dark Gray for primary text
  static const Color secondaryText =
      Color.fromARGB(255, 7, 7, 7); // Light Gray for secondary text
  static const Color disabledText =
      Color.fromRGBO(221, 131, 131, 1); // Medium Gray for disabled text

  // Accent and Highlight Colors
  static const Color accent = Color(
      0xFFFF4D4D); // Strawberry Red for primary accent (buttons, highlights)
  static const Color secondaryAccent =
      Color(0xFFFF8A80); // Light Coral for secondary accent
  static const Color warning =
      Color(0xFFFFA726); // Orange for warnings or alerts
  static const Color success =
      Color(0xFF4CAF50); // Green for success states (formerly nutrition)
  static const Color error = Color(0xFFD32F2F); // Deep Red for error states

  // Themed Colors for Specific Features
  static const Color nutrition =
      Color(0xFF4CAF50); // Green for nutrition-related elements
  static const Color progress =
      Color(0xFF42A5F5); // Blue for progress indicators or trackers
  static const Color plan =
      Color(0xFFAB47BC); // Purple for plan-related elements
  static const Color chatBubble =
      Color(0xFFE1F5FE); // Light Blue for chat bubbles

  // Shadow and Overlay Colors
  static const Color shadow =
      Color(0x1A000000); // Black with 10% opacity for shadows
  static const Color overlay =
      Color(0x80000000); // Black with 50% opacity for overlays
}
