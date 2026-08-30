#!/bin/bash
# ==========================================
# BINISHOP — INITIALISATION MINIO
# ==========================================
# Ce script crée le bucket nécessaire au
# stockage des images de la boutique.
#
# Il est exécuté manuellement après le
# démarrage de MinIO, ou via docker exec.
# ==========================================

set -e

# Configuration
MC_HOST="${MC_HOST:-minio}"
MC_PORT="${MC_PORT:-9000}"
MC_ALIAS="binishop"
BUCKET_NAME="${MINIO_BUCKET:-binishop-media}"
ACCESS_KEY="${MINIO_ACCESS_KEY:-binishop_admin}"
SECRET_KEY="${MINIO_SECRET_KEY:-binishop_minio_secret_key_2026}"

echo "BINISHOP: Configuration de MinIO..."
echo "BINISHOP: Alias: $MC_ALIAS"
echo "BINISHOP: Bucket: $BUCKET_NAME"

# Attendre que MinIO soit prêt
echo "BINISHOP: Attente de MinIO..."
until curl -sf "http://localhost:9000/minio/health/live" > /dev/null 2>&1; do
  echo "BINISHOP: MinIO pas encore prêt, nouvelle tentative dans 2s..."
  sleep 2
done
echo "BINISHOP: MinIO est prêt."

# Configurer mc (MinIO Client)
mc alias set "$MC_ALIAS" "http://localhost:9000" "$ACCESS_KEY" "$SECRET_KEY" --api S3v4

# Créer le bucket s'il n'existe pas
if mc ls "$MC_ALIAS/$BUCKET_NAME" > /dev/null 2>&1; then
  echo "BINISHOP: Le bucket '$BUCKET_NAME' existe déjà."
else
  mc mb "$MC_ALIAS/$BUCKET_NAME" --region "${MINIO_REGION:-eu-west-1}"
  echo "BINISHOP: Bucket '$BUCKET_NAME' créé."
fi

# Configurer la politique de bucket (privé, accessible via presigned URLs)
mc anonymous set private "$MC_ALIAS/$BUCKET_NAME"

# Activer la suppression des objets versionnés (future gestion)
mc version enable "$MC_ALIAS/$BUCKET_NAME" 2>/dev/null || true

echo "BINISHOP: MinIO configuré avec succès."
echo "BINISHOP: Bucket '$BUCKET_NAME' prêt."
echo "BINISHOP: Console accessible sur http://localhost:9001"