$ErrorActionPreference = "Stop"

$TaskName = "Inicio Recordatorio Office365 - 360 dias"
$Directorio = Join-Path $env:LOCALAPPDATA "RecordatorioOffice365"
$InstaladorLocal = Join-Path $Directorio "instalar-recordatorio.ps1"

$UrlInstalador = "https://raw.githubusercontent.com/retrocenter-serv/office365-reminder/main/instalar.ps1"

$PowerShellExe = Join-Path `
    $env:SystemRoot `
    "System32\WindowsPowerShell\v1.0\powershell.exe"

$Usuario = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$FechaVencimiento = (Get-Date).AddDays(360)

New-Item `
    -Path $Directorio `
    -ItemType Directory `
    -Force | Out-Null

# Descargar ahora una copia local del instalador.
$Contenido = Invoke-RestMethod `
    -Uri $UrlInstalador `
    -UseBasicParsing

Set-Content `
    -Path $InstaladorLocal `
    -Value $Contenido `
    -Encoding UTF8 `
    -Force

# Eliminar una programación anterior, si existe.
Unregister-ScheduledTask `
    -TaskName $TaskName `
    -Confirm:$false `
    -ErrorAction SilentlyContinue

$Accion = New-ScheduledTaskAction `
    -Execute $PowerShellExe `
    -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$InstaladorLocal`""

$Disparador = New-ScheduledTaskTrigger `
    -Once `
    -At $FechaVencimiento

$Principal = New-ScheduledTaskPrincipal `
    -UserId $Usuario `
    -LogonType Interactive `
    -RunLevel Limited

$Configuracion = New-ScheduledTaskSettingsSet `
    -StartWhenAvailable `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries

Register-ScheduledTask `
    -TaskName $TaskName `
    -Action $Accion `
    -Trigger $Disparador `
    -Principal $Principal `
    -Settings $Configuracion `
    -Description "Inicia el recordatorio de renovación de Office 365 después de 360 días." `
    -Force | Out-Null

Write-Host ""
Write-Host "Programación creada correctamente." -ForegroundColor Green
Write-Host "Usuario: $Usuario"
Write-Host "El recordatorio comenzará el: $($FechaVencimiento.ToString('dd/MM/yyyy HH:mm'))"
Write-Host ""
