@echo off
REM ============================================
REM BINISHOP — Création du bucket MinIO
REM ============================================
REM Méthode : conteneur temporaire minio/mc connecté au réseau Docker
REM ============================================
echo BINISHOP: Création du bucket MinIO binishop-media...

REM Créer le bucket (ignore l'erreur si déjà existant)
docker run --rm --network binishop-network ^
  -e "MC_HOST_local=http://binishop_admin:binishop_minio_secret_key_2026@minio:9000" ^
  minio/mc mb local/binishop-media --region eu-west-1 2>nul

if %ERRORLEVEL% NEQ 0 (
  echo BINISHOP: Bucket existe deja ou erreur creation >> c:\Users\deguene\Documents\BINISHOP\logs\bucket-create.log
)

REM Lister pour confirmer
docker run --rm --network binishop-network ^
  -e "MC_HOST_local=http://binishop_admin:binishop_minio_secret_key_2026@minio:9000" ^
  minio/mc ls local 2>nul > c:\Users\deguene\Documents\BINISHOP\logs\minio-bucket-list.txt

echo BINISHOP: Bucket créé et configuré.