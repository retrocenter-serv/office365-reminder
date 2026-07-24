$TaskName = "Recordatorio Licencia Office365"

Enable-ScheduledTask `
    -TaskName $TaskName `
    -ErrorAction Stop | Out-Null

Start-ScheduledTask `
    -TaskName $TaskName `
    -ErrorAction Stop

Write-Host ""
Write-Host "El recordatorio fue activado nuevamente." -ForegroundColor Green
Write-Host ""
