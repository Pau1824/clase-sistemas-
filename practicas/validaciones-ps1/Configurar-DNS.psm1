function Configurar-DNS {
    param (
        [string]$ip_address,
        [string]$domain
    )

    # Separar la IP en octetos y construir la IP reversa
    $octetos = $ip_address -split '\.'
    $tres = "$($octetos[0]).$($octetos[1]).$($octetos[2])"
    $reverse_ip = "$($octetos[2]).$($octetos[1]).$($octetos[0]).in-addr.arpa"
    $mascara = "255.255.255.0"

    # Configurar IP fija
    netsh interface ipv4 set address name="Ethernet 2" static $ip_address $mascara

    # Configurar DNS
    netsh interface ipv4 set dns name="Ethernet 2" static 8.8.8.8

    # Instalar servicio DNS
    Install-WindowsFeature -Name DNS -IncludeManagementTools

    # Crear zona DNS de reenvío
    Add-DnsServerPrimaryZone -Name "$domain" -ZoneFile "$domain.dns" -DynamicUpdate None -PassThru 

    # Zona DNS inversa
    Add-DnsServerPrimaryZone -NetworkID "$($tres).0/24" -ZoneFile "$reverse_ip.dns" -DynamicUpdate None -PassThru 

    # Comprobar zonas creadas
    Get-DnsServerZone 

    # Crear archivo de búsqueda
    Add-DnsServerResourceRecordA -Name "www" -ZoneName "$domain" -IPv4Address "$ip_address" -TimeToLive 01:00:00 -CreatePtr -PassThru 

    # Verificar que se guardó
    Get-DnsServerResourceRecord -ZoneName "$domain" | Format-Table -AutoSize -Wrap 

    # Apuntar al DNS
    Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddress "$ip_address"

    # Crear regla de firewall para permitir ping
    New-NetFirewallRule -DisplayName "Permitir Ping Entrante" -Direction Inbound -Protocol ICMPv4 -Action Allow
    Get-DnsServerResourceRecord -ZoneName "$domain"

    # Crear otro archivo de búsqueda
    Add-DnsServerResourceRecordA -Name "@" -ZoneName "$domain" -IPv4Address "$ip_address" -TimeToLive 01:00:00 -PassThru

    # Pruebas con nslookup
    nslookup $domain 
    nslookup www.$domain 
    nslookup $ip_address 
}

Export-ModuleMember -Function Configurar-DNS