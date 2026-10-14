@echo off
setlocal
rem ============================================================================
rem  INSTALAR.bat
rem  De dois cliques: ele pede permissao de administrador sozinho e instala,
rem  em ordem alfabetica, todos os programas da pasta "apps".
rem  Para adicionar um programa, crie apps\instalar-<programa>.bat e coloque
rem  o instalador offline na pasta "instaladores".
rem ============================================================================

rem sem permissao de administrador? abre de novo pedindo (janela "Deseja permitir...?")
net session >nul 2>&1
if errorlevel 1 (
  powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)

title Super automacao de instalacao de aplicativos
rem texto ciano (B) sobre fundo preto (0)
color 0B
cls
echo.
echo  ==============================================================
echo.
echo         SUPER AUTOMACAO DE INSTALACAO DE APLICATIVOS
echo.
echo         Instala os programas da empresa sem perguntas.
echo         Nao feche esta janela ate o final.
echo.
echo  ==============================================================
echo.
cd /d "%~dp0"
set "LOG=%~dp0instalacao.log"
echo [%date% %time%] Inicio >> "%LOG%"

set "FALHAS=0"
for %%f in ("%~dp0apps\instalar-*.bat") do (
  echo.
  echo === %%~nf ===
  call "%%f"
  if errorlevel 1 (
    set /a FALHAS+=1
    echo [FALHOU] %%~nf
    echo [%date% %time%] FALHOU: %%~nf >> "%LOG%"
  ) else (
    echo [OK] %%~nf
    echo [%date% %time%] OK: %%~nf >> "%LOG%"
  )
)

echo.
echo ============================================
if "%FALHAS%"=="0" (echo  Tudo instalado com sucesso.) else (echo  Programas com falha: %FALHAS%  - veja instalacao.log)
echo ============================================
echo [%date% %time%] Fim (falhas: %FALHAS%) >> "%LOG%"
echo.
rem tudo certo: fecha sozinho. Com falha: fica aberto para o tecnico ver qual programa falhou.
if "%FALHAS%"=="0" (
  echo Esta janela fecha sozinha em 5 segundos...
  timeout /t 5 /nobreak >nul
  exit
)
pause
exit /b %FALHAS%
