# Importar los módulos
Import-Module "C:\Users\Administrator\Desktop\practicas\validaciones-ps1\Obtener-IP.psm1"
Import-Module "C:\Users\Administrator\Desktop\practicas\validaciones-ps1\Obtener-Dominio.psm1"
Import-Module "C:\Users\Administrator\Desktop\practicas\validaciones-ps1\Configurar-IP.psm1"
Import-Module "C:\Users\Administrator\Desktop\practicas\validaciones-ps1\Configurar-DNS.psm1"

# Obtener IP y dominio
$ip_address = Obtener-IP
$domain = Obtener-Dominio

# Configurar la IP estática
Configurar-IP $ip_address

# Configurar DNS
Configurar-DNS $ip_address $domain

Write-Host "Configuración completada con éxito." -ForegroundColor Green