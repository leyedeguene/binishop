@echo off
cd /d c:\Users\deguene\Documents\BINISHOP\backend
echo Installation des dependances backend...
call npm install --legacy-peer-deps
if %ERRORLEVEL% EQU 0 (
    echo Installation reussie !
) else (
    echo Erreur lors de l'installation.
)
pause