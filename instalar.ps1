$ErrorActionPreference = "Stop"

$TaskName = "Recordatorio Licencia Office365"
$Directorio = Join-Path $env:LOCALAPPDATA "RecordatorioOffice365"
$ScriptAviso = Join-Path $Directorio "RecordatorioOffice365.ps1"

$PowerShellExe = Join-Path $env:SystemRoot `
    "System32\WindowsPowerShell\v1.0\powershell.exe"

$Usuario = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

New-Item `
    -Path $Directorio `
    -ItemType Directory `
    -Force | Out-Null

$ContenidoAviso = @'
Add-Type -AssemblyName System.Windows.Forms

$Mensaje = @"
LICENCIA OFFICE 365

Su licencia de Microsoft Office requiere activación.

Por favor, ingrese a Office.com para activar nuevamente su licencia.

Este anuncio continuará apareciendo hasta que sea desactivado.
"@

while ($true) {

    [void][System.Windows.Forms.MessageBox]::Show(
        $Mensaje,
        "Activación de Licencia Office 365",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )

    # Volver a mostrar después de 30 minutos
    Start-Sleep -Seconds 1800
}
'@

Set-Content `
    -Path $ScriptAviso `
    -Value $ContenidoAviso `
    -Encoding UTF8 `
    -Force

Stop-ScheduledTask `
    -TaskName $TaskName `
    -ErrorAction SilentlyContinue

$Accion = New-ScheduledTaskAction `
    -Execute $PowerShellExe `
    -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$ScriptAviso`""

$Disparador = New-ScheduledTaskTrigger `
    -AtLogOn `
    -User $Usuario

$Principal = New-ScheduledTaskPrincipal `
    -UserId $Usuario `
    -LogonType Interactive `
    -RunLevel Limited

$Configuracion = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -ExecutionTimeLimit ([TimeSpan]::Zero) `
    -MultipleInstances IgnoreNew

Register-ScheduledTask `
    -TaskName $TaskName `
    -Action $Accion `
    -Trigger $Disparador `
    -Principal $Principal `
    -Settings $Configuracion `
    -Description "Recordatorio periódico de activación de Office 365." `
    -Force | Out-Null

Start-ScheduledTask -TaskName $TaskName

Write-Host ""
Write-Host "Recordatorio instalado correctamente." -ForegroundColor Green
Write-Host "El mensaje aparecerá cada 30 minutos."
Write-Host ""
