# API BINISHOP — État réel validé

## Environnement local opérationnel

| Service | URL | Statut |
|---------|-----|--------|
| Medusa API | http://localhost:3005 | ✅ Ready |
| Admin Medusa (REST) | http://localhost:3005/admin/* | ✅ |
| MinIO API | http://localhost:9000 | ✅ |
| MinIO Console | http://localhost:9001 | ✅ |
| PostgreSQL | localhost:5432 | ✅ |
| Redis | localhost:6379 | ✅ |

**Note ports** : 9000/9001 sont occupés par MinIO → Medusa tourne sur 3005.

## Identifiants locaux

| Élément | Valeur |
|---------|--------|
| Compte admin | admin@binishop.com / Admin123456! |
| Publishable key | pk_47dd9ad1e92866bc524bed6104f492b037252dbb3037a7ede0734da34990ca3c |
| Bucket MinIO | binishop-media (privé) |
| Région seedée | Europe (EUR) — FR, BE, DE, ES, IT, PT, NL, LU |

## Authentification admin (validée)

```bash
# Login -> JWT token
curl -X POST http://localhost:3005/auth/user/emailpass \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@binishop.com","password":"Admin123456!"}'
# -> {"token":"eyJ..."}

# Toute requête admin : Authorization: Bearer <token>
```

## Store API (validée)

Toutes les requêtes store exigent le header :
```
x-publishable-api-key: pk_47dd9ad1e92866bc524bed6104f492b037252dbb3037a7ede0734da34990ca3c
```

### Endpoints testés et fonctionnels

| Méthode | Endpoint | Résultat |
|---------|----------|----------|
| GET | /store/products | ✅ `{"products":[],"count":0}` (boutique vide) |
| GET | /store/product-categories | ✅ `{"product_categories":[],"count":0}` |
| GET | /store/regions | ✅ Région Europe/EUR + 8 pays |
| POST | /store/carts | ✅ Panier créé (currency eur, region liée) |
| GET | /health | ✅ Custom BINISHOP: status ok + database connected |

### Endpoints à utiliser côté client Flutter

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | /store/products?q=&category_id=&limit=&offset= | Catalogue paginé |
| GET | /store/products/:id | Fiche produit + variantes |
| POST | /store/carts | Créer panier |
| GET | /store/carts/:id | Charger panier |
| POST | /store/carts/:id/line-items | Ajouter article {variant_id, quantity} |
| POST | /store/carts/:id/line-items/:line_id | MAJ quantité |
| DELETE | /store/carts/:id/line-items/:line_id | Retirer article |
| POST | /store/carts/:id/addresses | Adresses livraison/facturation |
| POST | /store/carts/:id/shipping-methods | Choisir transporteur {option_id} |
| GET | /store/shipping-options?cart_id= | Options livraison disponibles |
| POST | /store/payment-collections | Créer collection paiement |
| POST | /store/payment-collections/:id/payment-sessions | Session {provider_id} |
| POST | /store/payment-collections/:id/authorize | Autoriser paiement |
| POST | /store/carts/:id/complete | Finaliser commande |
| POST | /auth/customer/emailpass | Login client |
| POST | /store/customers | Inscription client |

### Provider paiement — Stripe vs TEST (dynamique)

Le **backend** (`medusa-config.js`) charge `@medusajs/payment-stripe@2.19.0` **uniquement si** `STRIPE_API_KEY` est défini. Sinon → provider TEST.

Le **frontend** (`checkout_notifier.dart`) détecte la clé publique Stripe :
- `FLUTTER_STRIPE_PUBLISHABLE_KEY` renseigné → provider `pp_stripe_stripe`
- Vide → provider `pp_payment-test_payment-test` (local)

```env
# backend/.env  (clé secrète — NE JAMAIS pousser)
STRIPE_API_KEY=sk_test_...

# frontend/.env (clé publique — safe côté client)
FLUTTER_STRIPE_PUBLISHABLE_KEY=pk_test_...
```

**Carte test Stripe** : `4242 4242 4242 4242`, date future n'importe laquelle, CVC 3 chiffres.

### Provider paiement TEST (custom)

Module : `src/modules/payment-test` — provider id `payment-test`.
- Aucune transaction réelle, autorisation automatique.
- Le provider_id complet est formaté `pp_payment-test_payment-test`.

## Uploads fichiers (MinIO)

Via module file-s3 configuré sur MinIO :
- Bucket privé `binishop-media`
- Presigned URLs générées par le backend
- Formats : JPEG, PNG, WEBP, AVIF (max 10 MB)

## Endpoints custom prévus (Phase suivante)

À implémenter sous `/store/custom/*` et `/admin/custom/*` :
- wishlist (add/remove/list)
- bestsellers (agrégation Order réelle)
- homepage blocks (CRUD)
- analytics dashboard (revenue, top products, low stock)

Ces modules nécessiteront un module custom avec migrations propres.


## Endpoints Medusa officiels

BINISHOP utilise les endpoints standards de Medusa.js pour les opérations e-commerce courantes.

### Store API

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | /store/products | Liste des produits publiés |
| GET | /store/products/:id | Détail d'un produit |
| GET | /store/categories | Liste des catégories |
| GET | /store/collections | Liste des collections |
| POST | /store/carts | Créer un panier |
| POST | /store/carts/:id/line-items | Ajouter un article |
| POST | /store/carts/:id/complete-checkout | Finaliser la commande |
| POST | /store/auth | Authentification client |
| POST | /store/customers | Créer un compte client |

### Admin API

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | /admin/products | Liste des produits |
| POST | /admin/products | Créer un produit |
| PUT | /admin/products/:id | Modifier un produit |
| DELETE | /admin/products/:id | Supprimer un produit |
| GET | /admin/categories | Liste des catégories |
| POST | /admin/categories | Créer une catégorie |
| PUT | /admin/categories/:id | Modifier une catégorie |
| DELETE | /admin/categories/:id | Supprimer une catégorie |
| GET | /admin/orders | Liste des commandes |
| GET | /admin/orders/:id | Détail d'une commande |
| GET | /admin/customers | Liste des clients |

## Endpoints personnalisés BINISHOP

### Wishlist

| Méthode | Endpoint | Authentification | Description |
|---------|----------|:---:|-------------|
| GET | /store/wishlist | Client | Liste des favoris |
| POST | /store/wishlist | Client | Ajouter un favori |
| DELETE | /store/wishlist/:id | Client | Supprimer un favori |

### Médias

| Méthode | Endpoint | Authentification | Description |
|---------|----------|:---:|-------------|
| POST | /admin/uploads/request | Admin | Demander une URL d'upload signée |
| POST | /admin/uploads/confirm | Admin | Confirmer l'upload |
| DELETE | /admin/uploads/:id | Admin | Supprimer un fichier |

### Analytics

| Méthode | Endpoint | Authentification | Description |
|---------|----------|:---:|-------------|
| GET | /admin/analytics/overview | Admin | Statistiques dashboard |
| GET | /admin/analytics/revenue | Admin | Chiffre d'affaires (query: ?period=7d) |
| GET | /admin/analytics/top-products | Admin | Produits les plus vendus |
| GET | /admin/analytics/low-stock | Admin | Alertes stock |

### Homepage

| Méthode | Endpoint | Authentification | Description |
|---------|----------|:---:|-------------|
| GET | /admin/homepage-blocks | Admin | Liste des blocs |
| POST | /admin/homepage-blocks | Admin | Créer un bloc |
| PUT | /admin/homepage-blocks/:id | Admin | Modifier un bloc |
| DELETE | /admin/homepage-blocks/:id | Admin | Supprimer un bloc |
| PATCH | /admin/homepage-blocks/reorder | Admin | Réordonner les blocs |

### Bestsellers

| Méthode | Endpoint | Authentification | Description |
|---------|----------|:---:|-------------|
| GET | /store/bestsellers | Public | Top ventes (query: ?period=30d) |
| GET | /admin/bestsellers | Admin | Configuration bestsellers |

## Flux d'upload d'image

1. `POST /admin/uploads/request` → reçoit `{ uploadUrl, fileKey }`
2. `PUT {uploadUrl}` (direct vers MinIO) → MinIO stocke le fichier
3. `POST /admin/uploads/confirm` → Medusa associe l'image au produit
4. L'image est accessible via presigned URL retournée par Medusa