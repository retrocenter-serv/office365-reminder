$TaskName = "Recordatorio Licencia Office365"
$Directorio = Join-Path $env:LOCALAPPDATA "RecordatorioOffice365"

Stop-ScheduledTask `
    -TaskName $TaskName `
    -ErrorAction SilentlyContinue

Unregister-ScheduledTask `
    -TaskName $TaskName `
    -Confirm:$false `
    -ErrorAction SilentlyContinue

Remove-Item `
    -Path $Directorio `
    -Recurse `
    -Force `
    -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "El recordatorio fue eliminado completamente." -ForegroundColor Green
Write-Host ""
