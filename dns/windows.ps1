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
        Write-Host "¡Dirección IP válida ingresada: $ip_address!" -ForegroundColor Green
        break
    } else {
        Write-Host "La dirección IP ingresada no es válida. Por favor, inténtelo nuevamente." -ForegroundColor Red
    }
} while ($true)

# Solicitar el dominio
do {
    $domain = Read-Host "Ingrese el dominio"
    if (Validar-Dominio $domain) {
        Write-Host "¡Dominio válido ingresado: $domain!" -ForegroundColor Green
        break
    } else {
        Write-Host "El dominio ingresado no es válido o no termina con '.com'. Por favor, inténtelo nuevamente." -ForegroundColor Red
    }
} while ($true)

# Separar la IP en octetos y construir la IP reversa
$octetos = $ip_address -split '\.'
$tres = "$($octetos[0]).$($octetos[1]).$($octetos[2])"
$reverse_ip = "$($octetos[2]).$($octetos[1]).$($octetos[0])"
$last_octet = $octetos[3]
$mascara = "255.255.255.0"
$gateway = ""

#comando para poner ip fija
netsh interface ipv4 set address name="Ethernet 2" static $ip_address $mascara $gateway
#comando para configurar el dns
netsh interface ipv4 set dns name="Ethernet2" static 8.8.8.8

#comando para instalar servicio dns
Install-WindowsFeature -Name DNS -IncludeManagementTools

Add-DnsServerPrimaryZone -Name "$domain" -ZoneFile "$domain.dns" -DynamicUpdate None -PassThru 
Add-DnsServerPrimaryZone -NetworkID $ip_address -ZoneFile "$reverse_ip.in-addr.arpa.dns" -DynamicUpdate None -PassThru 
Get-DnsServerZone 
Add-DnsServerResourceRecordA -Name "www" -ZoneName "$domain" -IPv4Address "$ip_address" -TimeToLive 01:00:00 -CreatePtr -PassThru 
Get-DnsServerResourceRecord -ZoneName "$domain" | Format-Table -AutoSize -Wrap
Get-DnsServerResourceRecord -ZoneName "$domain" | Format-Table -AutoSize -Wrap
Get-DnsServerZone 
Add-DnsServerPrimaryZone -Network "$($tres).0/24" -ZoneFile "$reverse_ip.in-addr.arpa.dns" -DynamicUpdate None -PassThru
Get-DnsServerZone 
Get-DnsServerResourceRecord -ZoneName "$reverse_ip.in-addr.arpa"
Add-DnsServerResourceRecordPtr -Name "$last_octet" -ZoneName "$reverse_ip.in-addr.arpa" -PtrDomainName "$domain" -TimeToLive 01:00:00 -PassThru
Get-DnsServerResourceRecord -ZoneName  "$last_octet.in-addr.arpa"
Restart-Service DNS
nslookup $domain localhost
nslookup www.$domain localhost
nslookup $ip_address localhost