@echo off
REM ==========================================
REM BINISHOP — SETUP LOCAL (Windows)
REM ==========================================
REM Ce script configure l'environnement local
REM pour le développement de BINISHOP.
REM ==========================================

echo =========================================
echo   BINISHOP — Configuration locale
echo =========================================
echo.

REM Vérifier les prérequis
echo [1/6] Verification des prerequis...

where node >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERREUR: Node.js n'est pas installe.
    echo Veuillez installer Node.js >= 18
    pause
    exit /b 1
)
echo   Node.js : OK

where docker >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERREUR: Docker n'est pas installe.
    pause
    exit /b 1
)
echo   Docker : OK

where docker-compose >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    where docker >nul 2>&1
    docker compose version >nul 2>&1
    if %ERRORLEVEL% NEQ 0 (
        echo ERREUR: Docker Compose n'est pas disponible.
        pause
        exit /b 1
    )
)
echo   Docker Compose : OK

echo.

REM Vérifier le fichier .env
echo [2/6] Verification du fichier .env...
if not exist ..\.env (
    if exist ..\.env.example (
        copy ..\.env.example ..\.env
        echo   Fichier .env cree depuis .env.example.
        echo   ATTENTION: Modifiez les mots de passe si necessaire.
    ) else (
        echo   ERREUR: Fichier .env.example introuvable.
        pause
        exit /b 1
    )
) else (
    echo   Fichier .env : OK
)
echo.

REM Installer les dépendances backend
echo [3/6] Installation des dependances backend...
pushd ..\backend
if exist node_modules (
    echo   Dependances deja installees.
) else (
    call npm install --legacy-peer-deps
    if %ERRORLEVEL% NEQ 0 (
        echo   ERREUR lors de l'installation des dependances.
        popd
        pause
        exit /b 1
    )
)
popd
echo.

REM Démarrer les services Docker
echo [4/6] Demarrage des services Docker...
pushd ..\infrastructure
docker compose up -d --build
if %ERRORLEVEL% NEQ 0 (
    echo   ERREUR lors du demarrage des conteneurs.
    popd
    pause
    exit /b 1
)
popd
echo.

REM Attendre que les services soient prêts
echo [5/6] Attente des services...
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

echo   Attente de Medusa...
:wait_medusa
docker exec binishop-medusa curl -sf http://localhost:9000/health >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    timeout /t 5 /nobreak >nul
    goto wait_medusa
)
echo   Medusa : OK
echo.

REM Initialiser MinIO
echo [6/6] Configuration de MinIO...
docker exec binishop-minio bash /opt/init.sh 2>nul || (
    echo   Le bucket sera cree automatiquement par Medusa.
)
echo.

REM Afficher les informations
echo =========================================
echo   BINISHOP — Configuration terminee !
echo =========================================
echo.
echo   Services :
echo   - PostgreSQL : localhost:5432
echo   - Redis      : localhost:6379
echo   - MinIO      : localhost:9000 (API)
echo   - MinIO      : localhost:9001 (Console)
echo   - Medusa     : localhost:9000 (API)
echo.
echo   Admin Medusa : http://localhost:9000/app
echo   MinIO Admin  : http://localhost:9001
echo.
echo   Identifiants admin :
echo   - Email    : admin@binishop.com
echo   - Password : Admin123456!
echo.
echo   ATTENTION :
echo   - Ce script est pour le DEVELOPPEMENT LOCAL uniquement.
echo   - Aucune donnee commerciale n'a ete creee.
echo   - La boutique est vide.
echo   - Connectez-vous en tant qu'administrateur
echo     pour creer du contenu.
echo.
echo =========================================

pause