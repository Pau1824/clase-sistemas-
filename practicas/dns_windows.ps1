function Validar-IP {
    param (
        [string]$ip_address
    )
    $valid_format = "^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
    
    if ($ip_address -match $valid_format) {
        return $true
    } else {
        return $false
    }
}

function Validar-Dominio {
    param (
        [string]$domain
    )
    $valid_format = ".com$"
    
    if ($domain -match $valid_format) {
        return $true
    } else {
        return $false
    }
}

# Solicitar la direccion IP del servidor DNS 
do {
    $ip_address = Read-Host "Ingrese la direccion IP del servidor DNS"
    if (Validar-IP $ip_address) {
        Write-Host "Dirección IP valida ingresada: $ip_address" -ForegroundColor Green
        break
    } else {
        Write-Host "La dirección IP ingresada no es valida. Por favor, intentelo nuevamente." -ForegroundColor Red
    }
} while ($true)

# Solicitar el dominio
do {
    $domain = Read-Host "Ingrese el dominio"
    if (Validar-Dominio $domain) {
        Write-Host "Dominio valido ingresado: $domain" -ForegroundColor Green
        break
    } else {
        Write-Host "El dominio ingresado no es valido o no termina con '.com'. Por favor, intentelo nuevamente." -ForegroundColor Red
    }
} while ($true)

# Separar la IP en octetos y construir la IP reversa
$octetos = $ip_address -split '\.'
$tres = "$($octetos[0]).$($octetos[1]).$($octetos[2])"
$reverse_ip = "$($octetos[2]).$($octetos[1]).$($octetos[0]).in-addr.arpa"
$last_octet = $octetos[3]
$last_octetp = "$($octetos[3]).in-addr.arpa"
$mascara = "255.255.255.0"

#comando para poner ip fija
netsh interface ipv4 set address name="Ethernet 2" static $ip_address $mascara
#comando para configurar el dns
netsh interface ipv4 set dns name="Ethernet 2" static 8.8.8.8

#comando para instalar servicio dns
Install-WindowsFeature -Name DNS -IncludeManagementTools

#Add-DnsServerForwarder -IPAddress 8.8.8.8,1.1.1.1

#Creo una zona DNS de reenvío
Add-DnsServerPrimaryZone -Name "$domain" -ZoneFile "$domain.dns" -DynamicUpdate None -PassThru 
#zona DNS inversa
Add-DnsServerPrimaryZone -NetworkID "$($tres).0/24" -ZoneFile "$reverse_ip.dns" -DynamicUpdate None -PassThru 
#Compruebo las zonas creadas 
Get-DnsServerZone 
#creamos un archivo de búsqueda
Add-DnsServerResourceRecordA -Name "www" -ZoneName "$domain" -IPv4Address "$ip_address" -TimeToLive 01:00:00 -CreatePtr -PassThru 
#Verificamos que se guardo
Get-DnsServerResourceRecord -ZoneName "$domain" | Format-Table -AutoSize -Wrap 
#Comando para que apunte al dns
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddress "$ip_address"
#Regla Firewall
New-NetFirewallRule -DisplayName "Permitir Ping Entrante" -Direction Inbound -Protocol ICMPv4 -Action Allow
Get-DnsServerResourceRecord -ZoneName "$domain"
#Creamos otro archivo de búsqueda 
Add-DnsServerResourceRecordA -Name "@" -ZoneName "$domain" -IPv4Address "$ip_address" -TimeToLive 01:00:00 -PassThru


nslookup $domain 
nslookup www.$domain 
nslookup $ip_address 



