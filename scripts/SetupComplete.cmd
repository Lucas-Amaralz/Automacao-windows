@echo off
rem ============================================================================
rem  SetupComplete.cmd
rem  O Windows executa este arquivo sozinho, como SYSTEM, no fim da instalacao
rem  (antes da tela de criacao de conta). Nao precisa de usuario nem de senha.
rem  Log: C:\Windows\Temp\provisionamento.log
rem ============================================================================
set "LOG=C:\Windows\Temp\provisionamento.log"

echo [%date% %time%] Inicio do provisionamento >> "%LOG%"
call "%~dp0instalar-apps.bat" >> "%LOG%" 2>&1
echo [%date% %time%] Fim do provisionamento (codigo %errorlevel%) >> "%LOG%"

rem apaga os instaladores copiados do pendrive, para nao ocupar espaco no disco
if exist "%~dp0instaladores" rd /s /q "%~dp0instaladores"
exit /b 0
