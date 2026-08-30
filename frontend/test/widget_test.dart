// BINISHOP — Smoke test du design system.
//
// Vérifie que [AppTheme.light] construit un thème Material 3 cohérent
// sans dépendance réseau ni dotenv (exécutable en CI comme en local).
//
// NB : les parcours e-commerce complets (auth → catalogue → panier →
// checkout) sont couverts par les tests d'intégration de la Phase 8,
// exécutés contre l'instance Medusa locale réelle.

import 'package:binishop/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AppTheme.light produit un thème Material 3 valide', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      // AppTheme.light n'est pas une constante : pas de const ici.
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: SizedBox.shrink()),
      ),
    );
    await tester.pump();

    final BuildContext context = tester.element(find.byType(Scaffold));

    expect(Theme.of(context).useMaterial3, isTrue);
    expect(Theme.of(context).brightness, Brightness.light);
    // Palette propriétaire BINISHOP (bleu nuit profond) et non le bleu
    // Material par défaut : garantit que le thème est bien appliqué.
    expect(
      Theme.of(context).colorScheme.primary,
      isNot(const Color(0xFF2196F3)),
    );
    expect(
      Theme.of(context).colorScheme.secondary,
      isNot(const Color(0xFF03DAC6)),
    );
  });
}
