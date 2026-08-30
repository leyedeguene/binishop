@echo off
REM ============================================
REM BINISHOP — Démarrage safe Medusa
REM ============================================
REM Arrêt propre de tout processus Medusa/Node
taskkill /f /im medusa.exe 2>nul
taskkill /f /fi "WINDOWTITLE eq medusa*" 2>nul
echo === STOP NODE === > c:\Users\deguene\Documents\BINISHOP\logs\stop-node.log
for /f "tokens=2" %%i in ('tasklist /fi "imagename eq node.exe" /fo csv ^| findstr /i medusa') do (
  taskkill /f /pid %%i 2>> c:\Users\deguene\Documents\BINISHOP\logs\stop-node.log
)
timeout /t 2 /nobreak >nul 2>nul

REM Relance Medusa avec config corrigée
cd /d c:\Users\deguene\Documents\BINISHOP\backend
echo START_MEDUSA %DATE% %TIME% > c:\Users\deguene\Documents\BINISHOP\logs\medusa-server.log
echo PATH=%PATH% > c:\Users\deguene\Documents\BINISHOP\logs\medusa-path.log
start /b "" cmd /c "set PORT=3005 && npx medusa develop --port 3005 --host 0.0.0.0 >> c:\Users\deguene\Documents\BINISHOP\logs\medusa-server.log 2>&1"
echo BINISHOP_MEDUSA_STARTED