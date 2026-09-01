# Migration vers Medusa v2 — BINISHOP

> ✅ **STATUT : MIGRATION TERMINÉE** — Medusa v2.19.0 opérationnel

---

## 📌 Historique

| Phase | Version | Status |
|-------|---------|--------|
| 1 | Medusa v1.x | ❌ JAMAIS INSTALLÉE |
| 2 | Medusa v2.19.0 | ✅ MIGRÉE |

---

## 🏗️ Architecture

```
backend/  → Medusa v2 (defineConfig modules: [file, payment, homepage])
frontend/ → Flutter web + flutter_stripe
dnleye.com        → build/web (static hosting)
admin.dnleye.com  → Medusa + MinIO
```

---

## 🔑 Points de migration v1→v2

| Aspect | v1 | v2 |
|--------|----|----|
| Config | `medusa-config.js` | `defineConfig()` |
| Modules | `@medusajs/medusa` | `@medusajs/framework` |
| Providers | inline | `providers: []` |
| CLI | `medusa` | `@medusajs/cli@2` |
| Admin | `@medusajs/admin` | `@medusajs/admin@7`

---

## ⚙️ package.json (backend)

```json
{
  "scripts": {
    "dev": "medusa develop",
    "start": "medusa start",
    "build": "medusa build",
    "setup": "medusa db:migrate && medusa db:sync-links && medusa exec ./src/scripts/seed.ts && medusa user --email admin@binishop.com --password Admin123456!"
  },
  "dependencies": {
    "@medusajs/admin": "^7.1.18",
    "@medusajs/cli": "^2.19.0",
    "@medusajs/framework": "^2.19.0",
    "@medusajs/medusa": "^2.19.0",
    "@medusajs/payment-stripe": "^2.19.0"
  }
}
```

---

## 🔧 medusa-config.js (v2 — `defineConfig`)

```js
const { defineConfig } = require("@medusajs/framework/utils")

module.exports = defineConfig({
  projectConfig: {
    databaseUrl: process.env.DATABASE_URL,
    redisUrl: process.env.REDIS_URL,
    http: { storeCors, adminCors, jwtSecret, cookieSecret }
  },
  modules: [
    { resolve: "@medusajs/file", options: { providers: [...] } },
    { resolve: "@medusajs/payment", options: { providers: [payment-test, stripe?] } },
    { resolve: "./src/modules/homepage" }
  ]
})
```

---

## 📄 .env (backend — Medusa v2)

```env
DATABASE_URL=postgres://binishop:binishop_local_dev_2026@localhost:5432/binishop
REDIS_URL=redis://default:binishop_redis_dev_2026@localhost:6379
PORT=3005
MINIO_ENDPOINT=http://localhost:9000
STRIPE_API_KEY=""  # laisser vide → provider TEST
```

---

## 🔌 Stripe — Frontend + Backend dynamique

- **Backend** (`medusa-config.js:103`): `@medusajs/payment-stripe` chargé **uniquement si `STRIPE_API_KEY` présent**
- **Frontend** (`environment.dart:21`): `stripePublishableKey` = `FLUTTER_STRIPE_PUBLISHABLE_KEY`
- **Notifier** (`checkout_notifier.dart:14-17`):
  ```dart
  String _effectivePaymentProvider() =>
      Environment.stripePublishableKey.isNotEmpty
          ? 'pp_stripe_stripe'
          : 'pp_payment-test_payment-test';
  ```

---

## 🧪 Checklist migration

| Étape | Action |
|-------|--------|
| ✅ | `npm install` → `@medusajs/*@2.19.0` |
| ✅ | `medusa-config.js` → `defineConfig()` |
| ✅ | Modules custom migrés (`payment-test`, `homepage`) |
| ✅ | `@medusajs/admin@7` installé |
| ✅ | Scripts seed → `medusa exec` |
| ⏳ | Déploiement sur `admin.dnleye.com` |

---

## 🚀 Démarrage prod

```bash
cd backend && npm run setup && npm run start   # port 3005
cd ../frontend && flutter build web --release   # → build/web
# docker-compose.prod.yml → dnleye.com + admin.dnleye.com
```