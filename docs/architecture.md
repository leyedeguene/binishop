# Architecture BINISHOP

## Vue d'ensemble

BINISHOP est une plateforme e-commerce de mode fonctionnant en environnement local avec Docker Compose.

## Stack technique

| Composant | Technologie | Rôle |
|-----------|-------------|------|
| Frontend | Flutter (Client + Admin) | Interface utilisateur |
| Backend | Medusa.js | API e-commerce, logique métier |
| Base de données | PostgreSQL 16 | Persistance des données |
| Cache | Redis 7 | Cache, sessions, files d'attente |
| Stockage | MinIO S3 | Images, médias, fichiers |

## Architecture logicielle

```
┌─────────────────────────────────────┐
│          FLUTTER APP                │
│  ┌──────────┐  ┌──────────────────┐ │
│  │  CLIENT  │  │     ADMIN        │ │
│  └────┬─────┘  └────────┬─────────┘ │
│       │                  │           │
└───────┼──────────────────┼───────────┘
        │                  │
        ▼                  ▼
┌─────────────────────────────────────┐
│          MEDUSA.JS API              │
│  Routes Store / Routes Admin        │
└───────┬──────────────────┬──────────┘
        │                  │
        ▼                  ▼
┌──────────────┐    ┌──────────────┐
│  PostgreSQL  │    │    MinIO     │
│  Données     │    │    Images    │
└──────────────┘    └──────────────┘
        │
        ▼
┌──────────────┐
│    Redis     │
│  Cache/Jobs  │
└──────────────┘
```

## Principes fondamentaux

1. **Zéro donnée fictive** — Aucune donnée commerciale n'est pré-remplie
2. **Admin = source du contenu** — L'administrateur crée tout le catalogue
3. **Données réelles** — Toute donnée affichée provient du backend
4. **Sécurité backend** — Les permissions sont vérifiées côté Medusa

## Flux de données

### Création d'un produit
```
Admin → Medusa API → PostgreSQL + MinIO → Client voit le produit
```

### Commande client
```
Client → Panier → Checkout → Medusa → PostgreSQL (commande) → Stock mis à jour
```

Voir [development.md](development.md) pour les détails d'installation.