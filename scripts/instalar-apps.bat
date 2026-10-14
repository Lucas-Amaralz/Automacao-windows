@echo off
setlocal
rem ============================================================================
rem  instalar-apps.bat
rem  Roda, em ordem alfabetica, todos os scripts apps\instalar-*.bat.
rem  Para adicionar um programa novo, basta criar apps\instalar-<programa>.bat.
rem  Pode ser chamado pelo SetupComplete.cmd ou executado manualmente
rem  (clique direito > Executar como administrador).
rem ============================================================================

net session >nul 2>&1
if errorlevel 1 (
  echo Execute este script como administrador.
  exit /b 1
)

set "FALHAS=0"
for %%f in ("%~dp0apps\instalar-*.bat") do (
  echo.
  echo === %%~nf ===
  call "%%f"
  if errorlevel 1 (
    set /a FALHAS+=1
    echo [FALHOU] %%~nf
  ) else (
    echo [OK] %%~nf
  )
)

echo.
echo Programas com falha: %FALHAS%
exit /b %FALHAS%
