$ErrorActionPreference = "Stop"

# ============================================================
# CONFIGURACIÓN
# ============================================================

$TaskName = "Desinstalar McAfee Total Protection"
$FechaDesinstalacion = [datetime]::ParseExact(
    "25/07/2027 09:00",
    "dd/MM/yyyy HH:mm",
    [System.Globalization.CultureInfo]::InvariantCulture
)

$Directorio = Join-Path $env:ProgramData "McAfeeRemoval"
$ScriptLocal = Join-Path $Directorio "desinstalar-mcafee.ps1"
$LogPath = Join-Path $Directorio "desinstalacion.log"

$PowerShellExe = Join-Path `
    $env:SystemRoot `
    "System32\WindowsPowerShell\v1.0\powershell.exe"

# ============================================================
# VALIDAR ADMINISTRADOR
# ============================================================

$EsAdministrador = (
    New-Object Security.Principal.WindowsPrincipal(
        [Security.Principal.WindowsIdentity]::GetCurrent()
    )
).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)

if (-not $EsAdministrador) {
    throw "Abre PowerShell como administrador y vuelve a ejecutar el comando."
}

if ($FechaDesinstalacion -le (Get-Date)) {
    throw "La fecha de desinstalación debe ser posterior a la fecha actual."
}

# ============================================================
# INFORMACIÓN DEL EQUIPO
# ============================================================

$FechaActual = Get-Date
$NombreEquipo = $env:COMPUTERNAME
$Usuario = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

if ([string]::IsNullOrWhiteSpace($Usuario)) {
    $Usuario = "$env:USERDOMAIN\$env:USERNAME"
}

try {
    $SerieEquipo = (
        Get-CimInstance Win32_BIOS -ErrorAction Stop
    ).SerialNumber.Trim()

    if ([string]::IsNullOrWhiteSpace($SerieEquipo)) {
        $SerieEquipo = "No disponible"
    }
}
catch {
    $SerieEquipo = "No disponible"
}

# ============================================================
# CREAR SCRIPT LOCAL DE DESINSTALACIÓN
# ============================================================

New-Item `
    -Path $Directorio `
    -ItemType Directory `
    -Force | Out-Null

$ContenidoDesinstalador = @'
$ErrorActionPreference = "Continue"

$Directorio = Join-Path $env:ProgramData "McAfeeRemoval"
$LogPath = Join-Path $Directorio "desinstalacion.log"

New-Item `
    -Path $Directorio `
    -ItemType Directory `
    -Force | Out-Null

function Escribir-Log {
    param([string]$Mensaje)

    $Linea = "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') - $Mensaje"

    Add-Content `
        -Path $LogPath `
        -Value $Linea `
        -Encoding UTF8

    Write-Host $Linea
}

Escribir-Log "Inicio del proceso de desinstalación de McAfee."

# ============================================================
# BUSCAR WINGET
# ============================================================

$Winget = Get-Command winget.exe -ErrorAction SilentlyContinue
$Desinstalado = $false

if ($Winget) {
    Escribir-Log "Intentando desinstalación mediante WinGet."

    $NombresWinget = @(
        "McAfee Total Protection",
        "McAfee® Total Protection",
        "McAfee Total Protection - 10 Devices"
    )

    foreach ($Nombre in $NombresWinget) {
        Escribir-Log "Probando producto: $Nombre"

        & $Winget.Source uninstall `
            --name "$Nombre" `
            --exact `
            --silent `
            --disable-interactivity `
            --accept-source-agreements `
            --accept-package-agreements

        if ($LASTEXITCODE -eq 0) {
            Escribir-Log "WinGet finalizó correctamente para: $Nombre"
            $Desinstalado = $true
            break
        }
    }
}
else {
    Escribir-Log "WinGet no está disponible. Se utilizará el registro de Windows."
}

# ============================================================
# MÉTODO ALTERNATIVO: REGISTRO DE WINDOWS
# ============================================================

if (-not $Desinstalado) {

    $RutasRegistro = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    $Aplicaciones = foreach ($Ruta in $RutasRegistro) {
        Get-ItemProperty `
            -Path $Ruta `
            -ErrorAction SilentlyContinue
    }

    $ProductosMcAfee = $Aplicaciones |
        Where-Object {
            $_.DisplayName -and
            $_.DisplayName -match "(?i)McAfee.*Total Protection" -and
            $_.DisplayName -notmatch "(?i)WebAdvisor"
        } |
        Sort-Object DisplayName -Unique

    if (-not $ProductosMcAfee) {
        Escribir-Log "No se encontró McAfee Total Protection en el registro."
    }

    foreach ($Producto in $ProductosMcAfee) {

        Escribir-Log "Producto encontrado: $($Producto.DisplayName)"

        $Comando = $null

        if (-not [string]::IsNullOrWhiteSpace(
            $Producto.QuietUninstallString
        )) {
            $Comando = $Producto.QuietUninstallString
            Escribir-Log "Se utilizará el desinstalador silencioso registrado."
        }
        elseif (-not [string]::IsNullOrWhiteSpace(
            $Producto.UninstallString
        )) {
            $Comando = $Producto.UninstallString
            Escribir-Log "No existe comando silencioso. Se abrirá el desinstalador normal."
        }

        if ([string]::IsNullOrWhiteSpace($Comando)) {
            Escribir-Log "No se encontró comando de desinstalación."
            continue
        }

        try {
            # Producto basado en MSI
            if ($Comando -match "\{[0-9A-Fa-f-]{36}\}") {

                $CodigoProducto = $Matches[0]

                Escribir-Log "Ejecutando MSIEXEC para $CodigoProducto"

                $Proceso = Start-Process `
                    -FilePath "msiexec.exe" `
                    -ArgumentList "/x $CodigoProducto /qn /norestart" `
                    -Wait `
                    -PassThru

                Escribir-Log "Código de salida MSI: $($Proceso.ExitCode)"

                if ($Proceso.ExitCode -in @(0, 1605, 1614, 3010)) {
                    $Desinstalado = $true
                }
            }
            else {
                Escribir-Log "Ejecutando desinstalador proporcionado por McAfee."

                $Proceso = Start-Process `
                    -FilePath "cmd.exe" `
                    -ArgumentList "/d /s /c `"$Comando`"" `
                    -Wait `
                    -PassThru

                Escribir-Log "Código de salida: $($Proceso.ExitCode)"

                if ($Proceso.ExitCode -eq 0) {
                    $Desinstalado = $true
                }
            }
        }
        catch {
            Escribir-Log "Error durante la desinstalación: $($_.Exception.Message)"
        }
    }
}

# ============================================================
# VERIFICACIÓN FINAL
# ============================================================

Start-Sleep -Seconds 10

$McAfeeRestante = foreach ($Ruta in @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
)) {
    Get-ItemProperty `
        -Path $Ruta `
        -ErrorAction SilentlyContinue
} | Where-Object {
    $_.DisplayName -and
    $_.DisplayName -match "(?i)McAfee.*Total Protection"
}

if (-not $McAfeeRestante) {
    Escribir-Log "McAfee Total Protection ya no aparece instalado."

    Add-Type -AssemblyName System.Windows.Forms

    [void][System.Windows.Forms.MessageBox]::Show(
        "McAfee Total Protection fue desinstalado del equipo.`n`nSe recomienda reiniciar Windows.",
        "Desinstalación completada",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    )
}
else {
    Escribir-Log "McAfee todavía aparece instalado. Puede requerir confirmación manual o la herramienta oficial de eliminación."

    Add-Type -AssemblyName System.Windows.Forms

    [void][System.Windows.Forms.MessageBox]::Show(
        "No se pudo completar automáticamente la desinstalación de McAfee.`n`nAbra Configuración > Aplicaciones y termine la desinstalación manualmente.",
        "Desinstalación pendiente",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )

    Start-Process "ms-settings:appsfeatures"
}

Escribir-Log "Fin del proceso."
'@

Set-Content `
    -Path $ScriptLocal `
    -Value $ContenidoDesinstalador `
    -Encoding UTF8 `
    -Force

# ============================================================
# ELIMINAR PROGRAMACIÓN ANTERIOR
# ============================================================

Stop-ScheduledTask `
    -TaskName $TaskName `
    -ErrorAction SilentlyContinue

Unregister-ScheduledTask `
    -TaskName $TaskName `
    -Confirm:$false `
    -ErrorAction SilentlyContinue

# ============================================================
# CREAR TAREA PROGRAMADA
# ============================================================

$Accion = New-ScheduledTaskAction `
    -Execute $PowerShellExe `
    -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$ScriptLocal`""

$Disparador = New-ScheduledTaskTrigger `
    -Once `
    -At $FechaDesinstalacion

$Principal = New-ScheduledTaskPrincipal `
    -UserId $Usuario `
    -LogonType Interactive `
    -RunLevel Highest

$Configuracion = New-ScheduledTaskSettingsSet `
    -StartWhenAvailable `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -ExecutionTimeLimit (New-TimeSpan -Hours 2)

Register-ScheduledTask `
    -TaskName $TaskName `
    -Action $Accion `
    -Trigger $Disparador `
    -Principal $Principal `
    -Settings $Configuracion `
    -Description "Desinstala McAfee Total Protection el 25/07/2027." `
    -Force | Out-Null

# ============================================================
# RESULTADO
# ============================================================

Write-Host ""
Write-Host "Desinstalación programada correctamente." -ForegroundColor Green
Write-Host ""
Write-Host "Equipo: $NombreEquipo"
Write-Host "Serie del equipo: $SerieEquipo"
Write-Host "Usuario: $Usuario"
Write-Host "Fecha de configuración: $($FechaActual.ToString('dd/MM/yyyy HH:mm'))"
Write-Host "McAfee se desinstalará el: $($FechaDesinstalacion.ToString('dd/MM/yyyy HH:mm'))"
Write-Host "Registro futuro: $LogPath"
Write-Host ""
