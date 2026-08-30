/// BINISHOP — Spacing System
library core.theme.app_spacing;

import 'package:flutter/material.dart';

abstract final class AppSpacing {
  // --- Base unit ---
  static const double unit = 4;

  // --- Standard spacing values ---
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;
  static const double massive = 48;
  static const double giant = 64;
  static const double colossal = 80;

  // --- Edge insets (for padding) ---
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );

  static const EdgeInsets screenPaddingMobile = EdgeInsets.all(lg);

  static const EdgeInsets screenPaddingTablet = EdgeInsets.symmetric(
    horizontal: xxl,
    vertical: lg,
  );

  static const EdgeInsets screenPaddingDesktop = EdgeInsets.symmetric(
    horizontal: 48,
    vertical: xxl,
  );

  // --- Card insets ---
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
  static const EdgeInsets cardPaddingCompact = EdgeInsets.all(md);

  // --- Section insets ---
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(vertical: xxl);
  static const EdgeInsets sectionPaddingSmall = EdgeInsets.symmetric(vertical: lg);

  // --- List insets ---
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );

  // --- Button insets ---
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: xxl,
    vertical: md,
  );

  static const EdgeInsets buttonPaddingSmall = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: sm,
  );

  // --- Gap widgets ---
  static const SizedBox gapXs = SizedBox(height: xs);
  static const SizedBox gapSm = SizedBox(height: sm);
  static const SizedBox gapMd = SizedBox(height: md);
  static const SizedBox gapLg = SizedBox(height: lg);
  static const SizedBox gapXl = SizedBox(height: xl);
  static const SizedBox gapXxl = SizedBox(height: xxl);
  static const SizedBox gapXxxl = SizedBox(height: xxxl);

  static const SizedBox gapWXs = SizedBox(width: xs);
  static const SizedBox gapWSm = SizedBox(width: sm);
  static const SizedBox gapWMd = SizedBox(width: md);
  static const SizedBox gapWLg = SizedBox(width: lg);
  static const SizedBox gapWXl = SizedBox(width: xl);
}