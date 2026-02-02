/// PlayRally - Pickleball Scoring App
/// 
/// Application configuration and constants

import 'package:flutter/material.dart';

// App Colors - Apple-inspired Lavender/Purple aesthetic
class AppColors {
  // Background colors
  static const Color background = Color(0xFFF5F3FF);       // Soft lavender white
  static const Color backgroundAlt = Color(0xFFEDE9FE);    // Light lavender
  
  // Primary accent colors
  static const Color primary = Color(0xFF8B5CF6);          // Vibrant purple
  static const Color primaryDark = Color(0xFF7C3AED);      // Deep purple
  static const Color primaryLight = Color(0xFFA78BFA);     // Light purple
  
  // Gradient colors
  static const Color gradientStart = Color(0xFF8B5CF6);    // Purple
  static const Color gradientEnd = Color(0xFF6D28D9);      // Deep violet
  
  // Secondary accent
  static const Color accent = Color(0xFFC4B5FD);           // Soft lavender
  static const Color accentLight = Color(0xFFDDD6FE);      // Very light lavender
  
  // Team colors - refined
  static const Color teamRed = Color(0xFFEF4444);          // Modern red
  static const Color teamBlue = Color(0xFF3B82F6);         // Modern blue
  
  // Neutral colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color cardBackground = Colors.white;
  
  // Text colors
  static const Color textPrimary = Color(0xFF1F2937);      // Dark gray
  static const Color textSecondary = Color(0xFF6B7280);    // Medium gray
  static const Color textLight = Color(0xFF9CA3AF);        // Light gray
  
  // Shadow color
  static const Color shadow = Color(0x1A8B5CF6);           // Purple tint shadow
}

// App Text Styles
class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );
  
  static const TextStyle subheading = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  
  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    letterSpacing: 0.3,
  );
}

// Game Configuration Defaults
class GameConfig {
  static const List<int> setOptions = [1, 3, 5];
  static const List<int> playToOptions = [11, 15];
  static const int winBy = 2;
  static const List<String> gameTypes = ['Singles', 'Doubles'];
}

// Route Names
class Routes {
  static const String splash = '/';
  static const String home = '/home';
  static const String gameFormat = '/game-format';
  static const String playerDetails = '/player-details';
  static const String scoring = '/scoring';
}
