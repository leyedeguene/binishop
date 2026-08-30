/// BINISHOP — Formatting Utilities
library core.utils.formatters;

import 'package:intl/intl.dart';

abstract final class Formatters {
  /// Formate un montant en devise (ex: "45,00 €")
  static String currency(num? value, {String currencyCode = 'EUR'}) {
    final v = value ?? 0;
    final symbol = _symbol(currencyCode);
    final formatted = NumberFormat('#,##0.00', 'fr_FR').format(v);
    return '$formatted $symbol';
  }

  /// Formatage compact d'un montant (échelles grandes)
  static String compactNumber(num? value) {
    final v = value ?? 0;
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toString();
  }

  /// Formate une date ISO vers "12 mars 2026"
  static String date(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('d MMM yyyy', 'fr_FR').format(dt);
    } catch (_) {
      return iso;
    }
  }

  /// Formate une date ISO avec heure
  static String dateTime(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('d MMM yyyy • HH:mm', 'fr_FR').format(dt);
    } catch (_) {
      return iso;
    }
  }

  static String _symbol(String code) {
    switch (code.toUpperCase()) {
      case 'EUR':
        return '€';
      case 'USD':
        return '\$';
      case 'GBP':
        return '£';
      case 'XOF':
        return 'FCFA';
      default:
        return code.toUpperCase();
    }
  }
}