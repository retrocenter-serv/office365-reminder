$TaskName = "Recordatorio Licencia Office365"

Stop-ScheduledTask `
    -TaskName $TaskName `
    -ErrorAction SilentlyContinue

Disable-ScheduledTask `
    -TaskName $TaskName `
    -ErrorAction Stop | Out-Null

Write-Host ""
Write-Host "El recordatorio fue desactivado." -ForegroundColor Yellow
Write-Host ""
