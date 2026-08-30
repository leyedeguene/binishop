/// BINISHOP — Design System Colors
/// Palette de couleurs premium pour une
/// boutique de mode moderne et élégante.
library core.theme.app_colors;

import 'package:flutter/material.dart';

abstract final class AppColors {
  // --- Primary ---
  static const Color primary = Color(0xFF1A1A2E);
  static const Color primaryLight = Color(0xFF2D2D4A);
  static const Color primaryDark = Color(0xFF0F0F1A);

  // --- Secondary / Accent ---
  static const Color secondary = Color(0xFFE94560);
  static const Color secondaryLight = Color(0xFFFF6B81);
  static const Color secondaryDark = Color(0xFFC23350);

  // --- Neutrals ---
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFFF5F5F5);

  // --- Text ---
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);

  // --- States ---
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF3B82F6);

  // --- Borders ---
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);
  static const Color borderFocus = Color(0xFF1A1A2E);

  // --- Badges ---
  static const Color badgeNew = Color(0xFF3B82F6);
  static const Color badgeSale = Color(0xFFDC2626);
  static const Color badgeBestseller = Color(0xFFF59E0B);
  static const Color badgeOutOfStock = Color(0xFF6B7280);

  // --- Specific ---
  static const Color ratingStar = Color(0xFFF59E0B);
  static const Color overlay = Color(0x80000000);
  static const Color shimmerBase = Color(0xFFE5E7EB);
  static const Color shimmerHighlight = Color(0xFFF3F4F6);

  // --- Dark mode (future) ---
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFE5E7EB);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);

  // --- Admin specific ---
  static const Color adminSidebar = Color(0xFF1A1A2E);
  static const Color adminSidebarText = Color(0xFFFFFFFF);
  static const Color adminSidebarActive = Color(0xFFE94560);
  static const Color adminTopbar = Color(0xFFFFFFFF);
}