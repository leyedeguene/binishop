@echo off
cd /d c:\Users\deguene\Documents\BINISHOP\backend
set PORT=3005
set HOST=0.0.0.0
REM Lancement persistant du serveur Medusa développeur (port 3005)
npx medusa develop --port 3005 --host 0.0.0.0 > c:\Users\deguene\Documents\BINISHOP\logs\medusa-server.log 2>&1
