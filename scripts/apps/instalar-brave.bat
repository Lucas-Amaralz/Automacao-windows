@echo off
setlocal
rem ============================================================================
rem  instalar-brave.bat
rem  Instala o navegador Brave para todos os usuarios, sem perguntas,
rem  a partir do instalador offline guardado na pasta "instaladores".
rem
rem  Instalador esperado: BraveBrowserStandaloneSilentSetup.exe
rem  (baixe do GitHub oficial do Brave: github.com/brave/brave-browser/releases)
rem
rem  Codigos de saida: 0 = ok ou ja instalado | 2 = instalador nao encontrado
rem                    3 = instalacao nao confirmada
rem ============================================================================

set "ARQUIVO=BraveBrowserStandaloneSilentSetup.exe"
set "BRAVE_EXE=%ProgramFiles%\BraveSoftware\Brave-Browser\Application\brave.exe"

rem procura o instalador: depois da copia (Scripts\instaladores) ou no pendrive (raiz\instaladores)
set "INSTALADOR=%~dp0..\instaladores\%ARQUIVO%"
if not exist "%INSTALADOR%" set "INSTALADOR=%~dp0..\..\instaladores\%ARQUIVO%"

if exist "%BRAVE_EXE%" (
  echo Brave ja esta instalado.
  exit /b 0
)
if not exist "%INSTALADOR%" (
  echo Instalador nao encontrado: %ARQUIVO%
  exit /b 2
)

echo Instalando o Brave...
"%INSTALADOR%"

rem o instalador pode terminar antes do Brave ficar pronto: espera ate cerca de 2 minutos
rem (ping no lugar de timeout, que nao funciona quando roda sem janela, como SYSTEM)
for /l %%i in (1,1,24) do (
  if exist "%BRAVE_EXE%" goto :ok
  ping -n 6 127.0.0.1 >nul
)
echo O Brave nao foi encontrado em "%BRAVE_EXE%".
exit /b 3

:ok
echo Brave instalado com sucesso.
exit /b 0
