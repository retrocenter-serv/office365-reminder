$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "Abriendo el portal oficial de Microsoft 365..." -ForegroundColor Cyan
Write-Host "Inicie sesión con una cuenta que tenga una licencia válida."
Write-Host ""

Start-Process "https://www.office.com"
