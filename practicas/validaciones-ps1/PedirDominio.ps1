do {
    $ip_address = Read-Host "Ingrese la dirección IP del servidor DNS"
    powershell -File .\ValidarIP.ps1 -ip_address $ip_address
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Dirección IP válida ingresada: $ip_address" -ForegroundColor Green
        return $ip_address
    } else {
        Write-Host "La dirección IP ingresada no es válida. Inténtelo nuevamente." -ForegroundColor Red
    }
} while ($true)