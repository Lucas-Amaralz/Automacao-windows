# ============================================================================
#  otimizar-windows.ps1
#  Deixa o Windows 11 enxuto para uso corporativo em maquinas fracas.
#  O Autounattend.xml executa este script durante a instalacao (etapa "specialize"),
#  como SYSTEM e ANTES de existir qualquer usuario: os apps removidos nem chegam a
#  ser instalados para ninguem, e as configuracoes valem para todo usuario novo.
#  Log: C:\Windows\Temp\otimizacao.log
#
#  Mantidos de proposito (uteis no trabalho): Edge, Loja, OneDrive, Assistencia Rapida,
#  Calculadora, Bloco de Notas, Paint, Fotos, Ferramenta de Captura, Notas Autoadesivas,
#  To Do, Terminal e Media Player.
# ============================================================================
$ErrorActionPreference = 'Continue'
Start-Transcript -Path 'C:\Windows\Temp\otimizacao.log' -Append | Out-Null

# grava um valor no registro; se o Windows bloquear algum item, anota no log e segue para o proximo
function Set-Valor {
    param([string]$Caminho, [string]$Nome, $Valor, [string]$Tipo = 'DWord')
    try {
        if (-not (Test-Path $Caminho)) { New-Item -Path $Caminho -Force -ErrorAction Stop | Out-Null }
        New-ItemProperty -Path $Caminho -Name $Nome -Value $Valor -PropertyType $Tipo -Force -ErrorAction Stop | Out-Null
    }
    catch {
        Write-Output "AVISO: nao foi possivel definir $Nome ($($_.Exception.Message))"
    }
}

# ---------------------------------------------------------------------------
# 1) Apps que nao servem para trabalho (removidos da imagem, para todos os usuarios)
# ---------------------------------------------------------------------------
$remover = @(
    # jogos e Xbox
    'Microsoft.MicrosoftSolitaireCollection', 'Microsoft.GamingApp', 'Microsoft.XboxGamingOverlay',
    'Microsoft.XboxGameOverlay', 'Microsoft.XboxSpeechToTextOverlay', 'Microsoft.XboxIdentityProvider',
    'Microsoft.Xbox.TCUI', 'Microsoft.Edge.GameAssist',
    # apps de consumidor
    'Microsoft.BingNews', 'Microsoft.BingWeather', 'Microsoft.BingSearch', 'Microsoft.WindowsMaps',
    'Clipchamp.Clipchamp', 'Microsoft.YourPhone', 'MicrosoftWindows.CrossDevice',   # integracao com celular pessoal
    'Microsoft.People', 'Microsoft.Getstarted',
    'Microsoft.GetHelp', 'Microsoft.WindowsFeedbackHub', 'Microsoft.ZuneVideo', 'Microsoft.SkypeApp',
    'Microsoft.MixedReality.Portal', 'Microsoft.Microsoft3DViewer', 'Microsoft.Wallet',
    'Microsoft.Messaging', 'Microsoft.OneConnect', 'microsoft.windowscommunicationsapps',
    'MicrosoftTeams',                         # Teams pessoal (o Teams corporativo e instalado a parte)
    'Microsoft.Windows.DevHome', 'Microsoft.PowerAutomateDesktop',
    'Microsoft.MicrosoftOfficeHub',           # "Microsoft 365 (Office)": so um atalho para a loja
    'Microsoft.OutlookForWindows',            # "Novo Outlook": a empresa usa o Outlook do Microsoft 365
    'Microsoft.Copilot', 'Microsoft.549981C3F5F10',   # Copilot e Cortana
    'MicrosoftWindows.Client.WebExperience'           # Widgets (noticias na barra de tarefas)
)
Write-Output '== Removendo apps desnecessarios =='
Get-AppxProvisionedPackage -Online | Where-Object { $remover -contains $_.DisplayName } | ForEach-Object {
    Write-Output "Removendo: $($_.DisplayName)"
    Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue | Out-Null
}

# ---------------------------------------------------------------------------
# 2) Politicas da maquina (valem para todos os usuarios)
# ---------------------------------------------------------------------------
Write-Output '== Aplicando politicas =='
$pol = 'HKLM:\SOFTWARE\Policies\Microsoft'
# sem apps "sugeridos" instalando sozinhos, sem dicas e propaganda
Set-Valor "$pol\Windows\CloudContent" 'DisableWindowsConsumerFeatures' 1
Set-Valor "$pol\Windows\CloudContent" 'DisableConsumerAccountStateContent' 1
Set-Valor "$pol\Windows\CloudContent" 'DisableSoftLanding' 1
# sem Widgets
Set-Valor "$pol\Dsh" 'AllowNewsAndInterests' 0
# telemetria no minimo permitido no Windows Pro, sem pedidos de feedback e sem ID de anuncios
Set-Valor "$pol\Windows\DataCollection" 'AllowTelemetry' 1
Set-Valor "$pol\Windows\DataCollection" 'DoNotShowFeedbackNotifications' 1
Set-Valor "$pol\Windows\AdvertisingInfo" 'DisabledByGroupPolicy' 1
# sem gravacao de jogos em segundo plano
Set-Valor "$pol\Windows\GameDVR" 'AllowGameDVR' 0
# sem Recall (capturas de tela automaticas) e sem Copilot
Set-Valor "$pol\Windows\WindowsAI" 'DisableAIDataAnalysis' 1
Set-Valor "$pol\Windows\WindowsCopilot" 'TurnOffWindowsCopilot' 1
# atualizacoes compartilhadas so com a rede local, nunca com a internet
Set-Valor "$pol\Windows\DeliveryOptimization" 'DODownloadMode' 1
# sem icone de Chat/Teams pessoal na barra
Set-Valor "$pol\Windows\Windows Chat" 'ChatIcon' 3
# Edge: sem tela de boas-vindas e sem ficar rodando em segundo plano (pesa em maquina fraca)
Set-Valor "$pol\Edge" 'HideFirstRunExperience' 1
Set-Valor "$pol\Edge" 'StartupBoostEnabled' 0
Set-Valor "$pol\Edge" 'BackgroundModeEnabled' 0
Set-Valor "$pol\Edge" 'ShowRecommendationsEnabled' 0

# hibernacao desligada: libera no disco o mesmo tamanho da memoria RAM
Write-Output '== Desligando hibernacao =='
powercfg.exe /hibernate off

# ---------------------------------------------------------------------------
# 3) Perfil padrao: o que todo usuario novo recebe (barra limpa, sem efeitos pesados)
# ---------------------------------------------------------------------------
Write-Output '== Configurando o perfil padrao dos usuarios =='
reg.exe load 'HKU\PADRAO' 'C:\Users\Default\NTUSER.DAT' | Out-Null
$u = 'Registry::HKEY_USERS\PADRAO'
try {
    # sem apps e conteudos sugeridos
    $cdm = "$u\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    foreach ($n in 'ContentDeliveryAllowed', 'OemPreInstalledAppsEnabled', 'PreInstalledAppsEnabled',
                   'PreInstalledAppsEverEnabled', 'SilentInstalledAppsEnabled', 'SystemPaneSuggestionsEnabled',
                   'SoftLandingEnabled', 'SubscribedContent-338388Enabled', 'SubscribedContent-338389Enabled',
                   'SubscribedContent-353694Enabled', 'SubscribedContent-353696Enabled') {
        Set-Valor $cdm $n 0
    }
    # barra de tarefas e Explorador
    $adv = "$u\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    Set-Valor $adv 'ShowTaskViewButton' 0        # sem botao Visao de Tarefas
    # (Widgets: desligados pela politica AllowNewsAndInterests e pela remocao do app.
    #  O valor TaskbarDa e protegido pelo Windows 11 e nao pode ser alterado por script.)
    Set-Valor $adv 'TaskbarMn' 0                 # sem Chat
    Set-Valor $adv 'Start_IrisRecommendations' 0 # sem recomendacoes no Iniciar
    Set-Valor $adv 'TaskbarAnimations' 0         # sem animacoes na barra
    Set-Valor $adv 'HideFileExt' 0               # mostra extensoes (ajuda a perceber "fatura.pdf.exe")
    Set-Valor $adv 'LaunchTo' 1                  # Explorador abre em "Este Computador"
    Set-Valor "$u\Software\Microsoft\Windows\CurrentVersion\Search" 'SearchboxTaskbarMode' 1   # pesquisa so como icone
    Set-Valor "$u\Software\Policies\Microsoft\Windows\Explorer" 'DisableSearchBoxSuggestions' 1 # sem Bing na pesquisa
    Set-Valor "$u\Software\Policies\Microsoft\Windows\WindowsCopilot" 'TurnOffWindowsCopilot' 1
    # sem Destaque do Windows (papel de parede com "Saiba mais sobre esta imagem") e dicas
    Set-Valor "$u\Software\Policies\Microsoft\Windows\CloudContent" 'DisableWindowsSpotlightFeatures' 1
    Set-Valor "$u\Software\Policies\Microsoft\Windows\CloudContent" 'DisableSpotlightCollectionOnDesktop' 1
    Set-Valor "$u\Software\Policies\Microsoft\Windows\CloudContent" 'DisableTailoredExperiencesWithDiagnosticData' 1
    # privacidade
    Set-Valor "$u\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" 'Enabled' 0
    Set-Valor "$u\Software\Microsoft\Windows\CurrentVersion\Privacy" 'TailoredExperiencesWithDiagnosticDataEnabled' 0
    # desempenho: sem transparencia e sem animacoes, mantendo a suavizacao das fontes
    Set-Valor "$u\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" 'EnableTransparency' 0
    Set-Valor "$u\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" 'VisualFXSetting' 3
    Set-Valor "$u\Control Panel\Desktop" 'UserPreferencesMask' ([byte[]](0x90, 0x12, 0x03, 0x80, 0x10, 0x00, 0x00, 0x00)) 'Binary'
    Set-Valor "$u\Control Panel\Desktop\WindowMetrics" 'MinAnimate' '0' 'String'
}
finally {
    # libera o arquivo do perfil antes de descarregar
    Remove-Variable cdm, adv -ErrorAction SilentlyContinue
    [GC]::Collect(); [GC]::WaitForPendingFinalizers(); Start-Sleep -Seconds 2
    reg.exe unload 'HKU\PADRAO' | Out-Null
}

# ---------------------------------------------------------------------------
# 4) Barra de tarefas padrao para toda conta nova: so Explorador de Arquivos e Edge
#    (tira os atalhos fixados de fabrica, como o do "Novo Outlook", que baixa o app ao clicar)
# ---------------------------------------------------------------------------
Write-Output '== Definindo a barra de tarefas padrao =='
$layout = @'
<?xml version="1.0" encoding="utf-8"?>
<LayoutModificationTemplate xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification" xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout" xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout" xmlns:taskbar="http://schemas.microsoft.com/Start/2014/TaskbarLayout" Version="1">
  <CustomTaskbarLayoutCollection PinListPlacement="Replace">
    <defaultlayout:TaskbarLayout>
      <taskbar:TaskbarPinList>
        <taskbar:DesktopApp DesktopApplicationID="Microsoft.Windows.Explorer" />
        <taskbar:DesktopApp DesktopApplicationLinkPath="%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk" />
      </taskbar:TaskbarPinList>
    </defaultlayout:TaskbarLayout>
  </CustomTaskbarLayoutCollection>
</LayoutModificationTemplate>
'@
try {
    $shell = 'C:\Users\Default\AppData\Local\Microsoft\Windows\Shell'
    New-Item -Path $shell -ItemType Directory -Force | Out-Null
    Set-Content -Path "$shell\LayoutModification.xml" -Value $layout -Encoding UTF8 -ErrorAction Stop
}
catch { Write-Output "AVISO: nao foi possivel definir a barra de tarefas ($($_.Exception.Message))" }

# ---------------------------------------------------------------------------
# 5) Menu Iniciar padrao para toda conta nova: so apps de trabalho fixados.
#    Tira os "atalhos de propaganda" de fabrica (Xbox, Solitaire, WhatsApp, LinkedIn,
#    Outlook...): eles nem estao instalados, so baixam o app quando alguem clica.
# ---------------------------------------------------------------------------
Write-Output '== Definindo o menu Iniciar padrao =='
$iniciar = @'
{
  "pinnedList": [
    { "desktopAppLink": "%ALLUSERSPROFILE%\\Microsoft\\Windows\\Start Menu\\Programs\\Microsoft Edge.lnk" },
    { "desktopAppLink": "%APPDATA%\\Microsoft\\Windows\\Start Menu\\Programs\\File Explorer.lnk" },
    { "packagedAppId": "windows.immersivecontrolpanel_cw5n1h2txyewy!microsoft.windows.immersivecontrolpanel" },
    { "packagedAppId": "Microsoft.WindowsCalculator_8wekyb3d8bbwe!App" },
    { "packagedAppId": "Microsoft.WindowsNotepad_8wekyb3d8bbwe!App" },
    { "packagedAppId": "Microsoft.Paint_8wekyb3d8bbwe!App" },
    { "packagedAppId": "Microsoft.Windows.Photos_8wekyb3d8bbwe!App" },
    { "packagedAppId": "Microsoft.ScreenSketch_8wekyb3d8bbwe!App" },
    { "packagedAppId": "Microsoft.WindowsStore_8wekyb3d8bbwe!App" },
    { "packagedAppId": "MicrosoftCorporationII.QuickAssist_8wekyb3d8bbwe!App" },
    { "packagedAppId": "Microsoft.WindowsTerminal_8wekyb3d8bbwe!App" }
  ]
}
'@
try {
    Set-Content -Path "$shell\LayoutModification.json" -Value $iniciar -Encoding UTF8 -ErrorAction Stop
}
catch { Write-Output "AVISO: nao foi possivel definir o menu Iniciar ($($_.Exception.Message))" }

Write-Output '== Otimizacao concluida =='
Stop-Transcript | Out-Null
