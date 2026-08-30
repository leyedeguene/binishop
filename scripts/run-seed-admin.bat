@echo off
REM ==========================================
REM BINISHOP - Demarrage serveur Medusa dev
REM Port 3005 : 9000/9001 sont utilises par MinIO
REM IMPORTANT : le log est ECRIT HORS du dossier
REM backend/ sinon le watcher Medusa se relance
REM en boucle sur son propre fichier de log.
REM ==========================================
cd /d c:\Users\deguene\Documents\BINISHOP\backend
if not exist ..\logs mkdir ..\logs
echo START_MEDUSA_DEV %DATE% %TIME% > ..\logs\medusa-server.log
call npx medusa develop --port 3005 >> ..\logs\medusa-server.log 2>&1