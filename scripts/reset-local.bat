@echo off
REM ==========================================
REM BINISHOP — RESET LOCAL (Windows)
REM ==========================================
REM ATTENTION : Ce script est DESTRUCTIF.
REM Il supprime toutes les donnees locales
REM (PostgreSQL, Redis, MinIO) et remet
/// la boutique a zero.
REM ==========================================

echo =========================================
echo   BINISHOP — RESET ENVIRONNEMENT LOCAL
echo =========================================
echo.
echo   ATTENTION : Cette operation est DESTRUCTIVE !
echo.
echo   Elle va supprimer :
echo   - Toutes les donnees PostgreSQL
echo   - Toutes les donnees Redis
echo   - Toutes les images MinIO
echo   - Toutes les donnees Medusa
echo.
echo   La boutique reviendra a l'etat vide
echo   initial (0 produit, 0 client, 0 commande).
echo.
echo   Seul le compte administrateur initial
echo   sera conserve (regenere par le seed).
echo.

set /p CONFIRM="Tapez 'RESET' pour confirmer : "
if not "%CONFIRM%"=="RESET" (
    echo Annulation.
    pause
    exit /b 0
)

echo.
echo [1/4] Arret des conteneurs...
pushd ..\infrastructure
docker compose down
if %ERRORLEVEL% NEQ 0 (
    echo   ERREUR lors de l'arret des conteneurs.
) else (
    echo   Conteneurs arretes.
)
popd
echo.

echo [2/4] Suppression des volumes...
docker volume rm binishop_postgres_data 2>nul
docker volume rm binishop_redis_data 2>nul
docker volume rm binishop_minio_data 2>nul
echo   Volumes supprimes.
echo.

echo [3/4] Demarrage des services...
pushd ..\infrastructure
docker compose up -d --build
if %ERRORLEVEL% NEQ 0 (
    echo   ERREUR lors du demarrage.
    popd
    pause
    exit /b 1
)
popd
echo.

echo [4/4] Attente des services et migration...
echo   Attente de PostgreSQL...
:wait_postgres
docker exec binishop-postgres pg_isready -U binishop >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    timeout /t 3 /nobreak >nul
    goto wait_postgres
)
echo   PostgreSQL : OK

echo   Attente de Redis...
:wait_redis
docker exec binishop-redis redis-cli ping >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    timeout /t 2 /nobreak >nul
    goto wait_redis
)
echo   Redis : OK

echo   Attente de MinIO...
:wait_minio
docker exec binishop-minio curl -sf http://localhost:9000/minio/health/live >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    timeout /t 3 /nobreak >nul
    goto wait_minio
)
echo   MinIO : OK

echo   Attente de Medusa (migrations + seed)...
:wait_medusa
docker exec binishop-medusa curl -sf http://localhost:9000/health >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    timeout /t 5 /nobreak >nul
    goto wait_medusa
)
echo   Medusa : OK
echo.

echo =========================================
echo   BINISHOP — RESET TERMINE
echo =========================================
echo.
echo   La boutique est de nouveau vide.
echo   Connectez-vous en tant qu'administrateur
echo   pour recreer du contenu.
echo.
echo   Email    : admin@binishop.com
echo   Password : Admin123456!
echo.
echo =========================================

pause