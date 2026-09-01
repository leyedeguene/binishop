# Configuration GitLab CI/CD pour BINISHOP

> **Frontend** (Flutter web) accessible via `https://dnleye.com`  
> **Admin** (Medusa + MinIO) accessible via `https://admin.dnleye.com`  
> Tout doit être déployé via un fichier `.gitlab-ci.yml` unique.

---

## 1. Architecture cible

```
dnleye.com          → Flutter web build (static hosting)
admin.dnleye.com    → Medusa API (port 3005) + MinIO UI (port 9001)
                     → PostgreSQL + Redis (backend)
```

- **Frontend** : Build Flutter en mode release, push du dossier `build/web` vers un bucket S3/MinIO ou tout autre hébergeur static.
- **Backend admin** : Container Docker avec Medusa + dépendances, exposé derrière un reverse proxy (nginx).
- **Secrets GitLab** : `STRIPE_API_KEY`, `FLUTTER_STRIPE_PUBLISHABLE_KEY`, etc.

---

## 2. Variables d'environnement GitLab CI

Aller dans **GitLab → Project → Settings → CI/CD → Variables** et ajouter :

| Nom                          | Valeur Exemple                          | Type     | Protégé |
|------------------------------|------------------------------------------|----------|--------|
| `STRIPE_API_KEY`             | `sk_test_...`                            | Secret   | ✅     |
| `FLUTTER_STRIPE_PUBLISHABLE_KEY` | `pk_test_...`                        | Public   | ❌     |
| `MEDUSA_PUBLISHABLE_KEY`     | `pk_47dd9ad1e92866bc524bed6104f492b037252dbb3037a7ede0734da34990ca3c` | Secret | ✅ |
| `DATABASE_URL`               | `postgresql://postgres:postgres@db:5432/postgres` | Secret | ✅ |
| `REDIS_URL`                  | `redis://redis:6379`                     | Secret   | ✅     |
| `DOCKER_REGISTRY`            | `registry.gitlab.com`                    | Public   | ❌     |
| `DOCKER_IMAGE_BACKEND`       | `$CI_REGISTRY_IMAGE/backend`             | Public   | ❌     |
| `DOCKER_IMAGE_FRONTEND`      | `$CI_REGISTRY_IMAGE/frontend`            | Public   | ❌     |
| `DOMAIN_CLIENT`              | `dnleye.com`                             | Public   | ❌     |
| `DOMAIN_ADMIN`               | `admin.dnleye.com`                       | Public   | ❌     |

---

## 3. Structure des fichiers attendus

```
.
├── .gitlab-ci.yml
├── frontend/
│   ├── pubspec.yaml
│   ├── .env.example
│   └── build/web/  ← artifact build ci-dessus
├── backend/
│   ├── Dockerfile
│   ├── medusa-config.js
│   ├── .env.example
│   └── package.json
└── docker-compose.yml  ← utilisé en local ou prod
```

---

## 4. Exemple minimal `.gitlab-ci.yml`

> ⚠️ Ce fichier n’est pas inclus ici — il doit être créé à la racine du dépôt.  
> Ce README guide les variables et la logique à intégrer.

### Étapes principales :

#### `build_frontend`:
- Runner : `flutter:3.22.0`
- Script :
  ```bash
  cd frontend
  cp .env.example .env
  sed -i "s/PLACEHOLDER/$FLUTTER_STRIPE_PUBLISHABLE_KEY/g" .env
  flutter pub get
  flutter build web --release
  ```
- Artifacts : `frontend/build/web`

#### `deploy_frontend`:
- Runner : `alpine:latest`
- Script : déploiement static (ex: FTP, S3, ou push vers bucket)

#### `build_backend`:
- Runner : Docker
- Build image : `backend/Dockerfile`
- Tags : `docker`
- Variables :
  ```yaml
  context: ./backend
  args:
    - STRIPE_API_KEY
    - MEDUSA_PUBLISHABLE_KEY
    - DATABASE_URL
    - REDIS_URL
  ```

#### `deploy_backend`:
- SSH ou Docker sur serveur
- Reverse proxy : nginx
- Ports exposés :
  - `3005` → Medusa (interne)
  - `9001` → MinIO Console (interne)
- Domaine : `admin.dnleye.com`

---

## 5. Notes importantes

- 🔐 **Ne jamais exposer `STRIPE_API_KEY` côté client**.
- 🌐 Le frontend lit `FLUTTER_STRIPE_PUBLISHABLE_KEY` via `.env` au moment du build.
- 🛡️ Le `.env` réel doit être **exclu du repo** via `.gitignore`.
- 📄 Utiliser `.env.example` comme template dans CI.
- 🔄 Pour un déploiement continu sans interruption : utiliser Blue/Green ou rolling update avec Docker Swarm/Kubernetes.

---

## 6. Checklist pré-déploiement

- [ ] `.env.example` présent dans `frontend/` et `backend/`
- [ ] `pubspec.yaml` contient `flutter_stripe: ^x.x.x`
- [ ] `medusa-config.js` lit `STRIPE_API_KEY`
- [ ] `environment.dart` expose `stripePublishableKey`
- [ ] `checkout_notifier.dart` utilise `_effectivePaymentProvider()`
- [ ] Git repository initialisé et poussé sur GitLab
- [ ] Variables CI/CD renseignées dans GitLab

---

## 📌 Besoin d'aide ?

Modifier ce README ou poser une question dans les *issues* GitLab du projet.
