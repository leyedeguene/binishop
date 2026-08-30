/// BINISHOP — Shadow System
library core.theme.app_shadows;

import 'package:flutter/material.dart';

abstract final class AppShadows {
  static const BoxShadow none = BoxShadow(
    color: Colors.transparent,
  );

  static const BoxShadow sm = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 2,
    offset: Offset(0, 1),
  );

  static const BoxShadow md = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 4,
    offset: Offset(0, 2),
  );

  static const BoxShadow lg = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 8,
    offset: Offset(0, 4),
  );

  static const BoxShadow xl = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 16,
    offset: Offset(0, 8),
  );

  static const BoxShadow xxl = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 24,
    offset: Offset(0, 12),
  );

  // --- Card shadows ---
  static const BoxShadow card = BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 8,
    offset: Offset(0, 2),
  );

  static const BoxShadow cardHover = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 16,
    offset: Offset(0, 8),
  );

  // --- Elevated shadows ---
  static const BoxShadow elevated = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 12,
    offset: Offset(0, 4),
  );

  static const BoxShadow modal = BoxShadow(
    color: Color(0x33000000),
    blurRadius: 32,
    offset: Offset(0, 16),
  );

  // --- List of shadows for Material ---
  static const List<BoxShadow> elev0 = [none];
  static const List<BoxShadow> elev1 = [sm];
  static const List<BoxShadow> elev2 = [md];
  static const List<BoxShadow> elev3 = [lg];
  static const List<BoxShadow> elev4 = [xl];
  static const List<BoxShadow> elev5 = [xxl];
}