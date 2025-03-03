Import-Module "C:\Users\Administrator\Desktop\practicas\validaciones-ps1\Validar-IP.psm1"
Import-Module "C:\Users\Administrator\Desktop\practicas\validaciones-ps1\Solicitar-IP-Servidor.psm1"
Import-Module "C:\Users\Administrator\Desktop\practicas\validaciones-ps1\Solicitar-IP-Inicial.psm1"
Import-Module "C:\Users\Administrator\Desktop\practicas\validaciones-ps1\Solicitar-IP-Final.psm1"
Import-Module "C:\Users\Administrator\Desktop\practicas\validaciones-ps1\Configurar-IP.psm1"
Import-Module "C:\Users\Administrator\Desktop\practicas\validaciones-ps1\Configurar-DHCP.psm1"

# Obtener datos del usuario
$ip_address = Solicitar-IP-Servidor
$ip_inicio = Solicitar-IP-Inicial
$ip_fin = Solicitar-IP-Final -ip_inicio $ip_inicio

# Configurar IP estática
Configurar-IP -ip_address $ip_address

# Configurar DHCP
Configurar-DHCP -ip_address $ip_address -ip_inicio $ip_inicio -ip_fin $ip_fin

Write-Host "Configuración completada con éxito." -ForegroundColor Green