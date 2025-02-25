# Obtener IP válida
$ip_address = powershell -File .\PedirIP.ps1

# Obtener dominio válido
$domain = powershell -File .\PedirDominio.ps1

# Separar la IP en octetos y construir la IP reversa
$octetos = $ip_address -split '\.'
$tres = "$($octetos[0]).$($octetos[1]).$($octetos[2])"
$reverse_ip = "$($octetos[2]).$($octetos[1]).$($octetos[0]).in-addr.arpa"
$last_octet = $octetos[3]
$last_octetp = "$($octetos[3]).in-addr.arpa"
$mascara = "255.255.255.0"

# Configurar IP estática
netsh interface ipv4 set address name="Ethernet 2" static $ip_address $mascara

# Configurar DNS
netsh interface ipv4 set dns name="Ethernet 2" static 8.8.8.8

# Instalar servicio DNS
Install-WindowsFeature -Name DNS -IncludeManagementTools

# Crear zona DNS de reenvío
Add-DnsServerPrimaryZone -Name "$domain" -ZoneFile "$domain.dns" -DynamicUpdate None -PassThru 

# Crear zona DNS inversa
Add-DnsServerPrimaryZone -NetworkID "$($tres).0/24" -ZoneFile "$reverse_ip.dns" -DynamicUpdate None -PassThru 

# Verificar zonas creadas
Get-DnsServerZone 

# Crear archivo de búsqueda
Add-DnsServerResourceRecordA -Name "www" -ZoneName "$domain" -IPv4Address "$ip_address" -TimeToLive 01:00:00 -CreatePtr -PassThru 

# Verificar registros creados
Get-DnsServerResourceRecord -ZoneName "$domain" | Format-Table -AutoSize -Wrap 

# Configurar cliente DNS
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddress "$ip_address"

# Agregar regla de firewall para permitir ICMP (ping)
New-NetFirewallRule -DisplayName "Permitir Ping Entrante" -Direction Inbound -Protocol ICMPv4 -Action Allow

# Crear otro archivo de búsqueda
Add-DnsServerResourceRecordA -Name "@" -ZoneName "$domain" -IPv4Address "$ip_address" -TimeToLive 01:00:00 -PassThru

# Probar configuración con nslookup
nslookup $domain 
nslookup www.$domain 
nslookup $ip_address 