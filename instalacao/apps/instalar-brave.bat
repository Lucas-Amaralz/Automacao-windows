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
rem o instalador fica na pasta "instaladores", ao lado da pasta "apps"
set "INSTALADOR=%~dp0..\instaladores\%ARQUIVO%"

if exist "%BRAVE_EXE%" (
  echo Brave ja esta instalado.
  exit /b 0
)
if not exist "%INSTALADOR%" (
  echo Instalador nao encontrado: %ARQUIVO%
  exit /b 2
)

echo Instalando o Brave...
rem "start" sem /wait: o instalador do Brave pode deixar processos abertos (o atualizador)
rem e nunca "devolver" o controle. Por isso o script nao espera ele fechar: so confere
rem se o brave.exe apareceu, por ate cerca de 5 minutos.
start "" "%INSTALADOR%"

rem (ping no lugar de timeout, que falha quando nao ha janela interativa)
for /l %%i in (1,1,60) do (
  if exist "%BRAVE_EXE%" goto :ok
  ping -n 6 127.0.0.1 >nul
)
echo O Brave nao foi encontrado em "%BRAVE_EXE%".
exit /b 3

:ok
rem da alguns segundos para o instalador terminar de gravar os arquivos e atalhos
ping -n 11 127.0.0.1 >nul
echo Brave instalado com sucesso.
exit /b 0
