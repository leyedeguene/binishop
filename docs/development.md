# Guide de développement BINISHOP

## Prérequis

- Node.js >= 18
- Docker Desktop
- Flutter SDK (dernière version stable)
- Git
# Guide de développement BINISHOP

## Prérequis

- Node.js >= 18
- Docker Desktop
- Flutter SDK (dernière version stable) — installé dans `c:\tools\flutter` sur cette machine
- Git

## Dépannage Windows — Stratégie de contrôle d'application (WDAC)

Sur cette machine, une stratégie WDAC/Device Guard bloque **parfois** le démarrage des
processus enfants lancés par le toolchain Dart (erreur
`ProcessStarter::StartForExec failed: Une stratégie de contrôle d'application a bloqué ce fichier`).

Constats pratiques :

| Commande | Comportement |
|----------|--------------|
| `dart.exe analyze` (appel direct) | ✅ Passe de façon fiable (pas de spawn enfant) |
| `flutter build web` / `flutter pub get` | ⚠️ Intermittent — échoue parfois, réussit parfois |

**Solutions :**

1. Réessayer simplement la commande (le blocage est intermittent) ;
2. Lancer la commande depuis un terminal utilisateur normal plutôt qu'un contexte planifié/détaché ;
3. Si nécessaire, ajouter une exclusion WDAC pour `c:\tools\flutter\bin\cache\dart-sdk\bin\dart.exe`
   (décision administrateur de la machine, hors périmètre du projet).

L'analyse statique (`dart analyze`) reste le filet de sécurité de compilation : elle ne nécessite
pas de spawn de processus enfant et valide l'intégralité du code Dart.


## Installation

### 1. Cloner le dépôt

```bash
git clone <repository-url>
cd binishop
```

### 2. Configurer l'environnement

```bash
cp .env.example .env
# Modifier les mots de passe si nécessaire (développement local uniquement)
```

### 3. Lancer l'infrastructure

```bash
cd infrastructure
docker compose up -d
```

### 4. Initialiser Medusa

```bash
cd ../backend
npm install
medusa migrations run
medusa seed --seed-file data/seed.js
medusa develop
```

### 5. Lancer Flutter

```bash
cd ../frontend
flutter pub get
flutter run -d chrome  # ou android / ios
```

## Services

| Service | URL | Identifiants |
|---------|-----|------|
| Medusa API | http://localhost:9000 | — |
| Admin Medusa | http://localhost:9000/app | admin@binishop.com / Admin123456! |
| MinIO API | http://localhost:9000 | binishop_admin / binishop_minio_secret_key_2026 |
| MinIO Console | http://localhost:9001 | binishop_admin / binishop_minio_secret_key_2026 |
| PostgreSQL | localhost:5432 | binishop / binishop_local_dev_2026 |
| Redis | localhost:6379 | binishop_redis_dev_2026 |

## Reset complet

```bash
# Supprime toutes les données et recommence
cd scripts
reset-local.bat  # Windows
# ou
bash reset-local.sh  # Git Bash / WSL
```

## Structure du projet

```
binishop/
├── frontend/       # Application Flutter (client + admin)
├── backend/        # Backend Medusa.js
├── infrastructure/ # Docker Compose, configs services
├── scripts/        # Scripts setup/reset
└── docs/           # Documentation
```

## Conventions de code

### Flutter
- Architecture Clean Architecture (presentation / domain / data)
- State management : Riverpod
- Routing : GoRouter
- HTTP : Dio
- Design System centralisé dans `core/theme/`
- Responsive : breakpoints définis dans `core/constants/breakpoints.dart`

### Medusa
- Modules pour les fonctionnalités custom
- Services pour la logique métier
- Subscribers pour les événements
- Routes API dans `src/api/`

## Règles importantes

1. **NE JAMAIS** ajouter de fausses données commerciales
2. **NE JAMAIS** stocker les images dans le dépôt Git
3. **NE JAMAIS** hardcoder les secrets
4. **TOUJOURS** paginer les requêtes catalogue
5. **TOUJOURS** valider les données côté backend