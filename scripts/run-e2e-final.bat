@echo off
setlocal
set ROOT=c:\Users\deguene\Documents\BINISHOP
echo === BINISHOP E2E FINAL RUN === > "%ROOT%\logs\e2e-final.log"
node --check "%ROOT%\scripts\e2e-run.mjs" > "%ROOT%\logs\e2e-final-check.log" 2>&1
if errorlevel 1 (
  echo SYNTAX_FAIL >> "%ROOT%\logs\e2e-final.log"
  type "%ROOT%\logs\e2e-final-check.log" >> "%ROOT%\logs\e2e-final.log"
  exit /b 1
)
echo SYNTAX_OK >> "%ROOT%\logs\e2e-final.log"
node "%ROOT%\scripts\e2e-run.mjs" >> "%ROOT%\logs\e2e-final.log" 2>&1
echo EXIT_CODE=%ERRORLEVEL% >> "%ROOT%\logs\e2e-final.log"
endlocal