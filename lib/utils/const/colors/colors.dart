import 'package:flutter/material.dart';

class AppColors {
  // Couleurs principales
  static const Color primary = Color(0xFF2196F3); // Bleu principal
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF64B5F6);

  // Couleurs secondaires
  static const Color secondary = Color(0xFFFFC107); // Jaune/Amber
  static const Color accent = Color(0xFF03A9F4);

  // Couleurs de fond
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;

  // Couleurs de texte
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFBDBDBD);

  // Couleurs d'état
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Couleurs pour les tags/badges
  static const Color tagCampus = Color(0xFFBBDEFB); // Bleu clair
  static const Color tagStudies = Color(0xFFE1BEE7); // Violet clair
  static const Color tagEmployment = Color(0xFFFFE0B2); // Orange clair
  static const Color tagCulture = Color(0xFFC8E6C9); // Vert clair

  // Couleurs pour les notifications
  static const Color notificationBadge = Color(0xFFE53935); // Rouge

  // Couleurs pour les catégories
  static const Color categorySelected = Color(
    0xFF212121,
  ); // Noir pour sélectionné
  static const Color categoryUnselected = Color(
    0xFFE0E0E0,
  ); // Gris clair pour non-sélectionné

  // Couleurs pour les champs de texte
  static const Color inputBorder = Color(0xFFBDBDBD);
  static const Color inputBorderFocused = Color(0xFF2196F3);

  // Dégradés
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );
}
