-- ==========================================
-- BINISHOP — INITIALISATION POSTGRESQL
-- ==========================================
-- Ce fichier est exécuté au premier démarrage
-- du conteneur PostgreSQL.
--
-- Seules les données techniques nécessaires
-- au fonctionnement du système sont créées ici.
-- AUCUNE donnée commerciale (produits, clients,
-- commandes, etc.) n'est insérée.
--
-- Les données métier sont créées exclusivement
-- depuis l'interface d'administration.
-- ==========================================

-- Création des extensions nécessaires
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Les tables sont gérées par Medusa.js via ses migrations.
-- Aucune création manuelle de table n'est nécessaire ici.

-- Message de confirmation
DO $$
BEGIN
  RAISE NOTICE 'BINISHOP: Base de données initialisée avec succès.';
  RAISE NOTICE 'BINISHOP: Aucune donnée commerciale insérée.';
  RAISE NOTICE 'BINISHOP: La boutique est vide et prête pour l''administrateur.';
END $$;