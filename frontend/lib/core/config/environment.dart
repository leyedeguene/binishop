/// BINISHOP — Environment Configuration
library core.config.environment;

import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class Environment {
  static String get apiBaseUrl => _get('API_BASE_URL', 'http://localhost:3005');
  static String get apiStoreUrl => _get('API_STORE_URL', 'http://localhost:3005/store');
  static String get apiAdminUrl => _get('API_ADMIN_URL', 'http://localhost:3005/admin');
  static String get publishableApiKey =>
      _get('PUBLISHABLE_API_KEY', '');
  static String get minioPublicUrl => _get('MINIO_PUBLIC_URL', 'http://localhost:9000');
  static String get appName => _get('APP_NAME', 'BINISHOP');
  static String get appEnv => _get('APP_ENV', 'development');
  static String get defaultCurrency => _get('DEFAULT_CURRENCY', 'EUR');
  static String get defaultLocale => _get('DEFAULT_LOCALE', 'fr');
  static String get defaultRegion => _get('DEFAULT_REGION', 'eu');

  static bool get isDevelopment => appEnv == 'development';
  static bool get isProduction => appEnv == 'production';

  static String _get(String key, String defaultValue) {
    return dotenv.env[key] ?? defaultValue;
  }
}