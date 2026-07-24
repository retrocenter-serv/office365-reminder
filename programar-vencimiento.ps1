# Obtener información del equipo
$NombreEquipo = $env:COMPUTERNAME
$FechaActual = Get-Date

try {
    $SerieEquipo = (Get-CimInstance -ClassName Win32_BIOS -ErrorAction Stop).SerialNumber.Trim()
} catch {
    $SerieEquipo = "No disponible"
}

Write-Host ""
Write-Host "Configuración realizada correctamente." -ForegroundColor Green
Write-Host ""
Write-Host "Equipo: $NombreEquipo"
Write-Host "Serie del equipo: $SerieEquipo"
Write-Host "Usuario: $Usuario"
Write-Host "Fecha de configuración: $($FechaActual.ToString('dd/MM/yyyy HH:mm'))"
Write-Host "Vigencia del soporte registrada hasta: $($FechaVencimiento.ToString('dd/MM/yyyy HH:mm'))"
Write-Host ""
