/// BINISHOP — Application Entry Point
/// Application Flutter e-commerce de mode.
/// Client + Administration dans une seule app.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    const ProviderScope(
      child: BINISHOPApp(),
    ),
  );
}

/// Provider déclenchant la restauration de session au démarrage.
final _sessionRestoreProvider = Provider((ref) {
  ref.watch(authNotifierProvider.notifier).restoreSession();
  return null;
});

class BINISHOPApp extends ConsumerWidget {
  const BINISHOPApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    // Restore session at boot (tokens persisted in SecureStorage)
    ref.watch(_sessionRestoreProvider);

    return MaterialApp.router(
      title: 'BINISHOP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.light,
      themeMode: ThemeMode.light,
      routerConfig: router,
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
      ],
    );
  }
}
