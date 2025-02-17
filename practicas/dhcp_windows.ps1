function Validar-IP {
    param (
        [string]$ip_address
    )
    $valid_format = "^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
    return $ip_address -match $valid_format
}

# Solicitar la dirección IP del servidor DNS
while ($true) {
    $ip_address = Read-Host "Ingrese la dirección IP del servidor DNS"
    if (Validar-IP -ip_address $ip_address) {
        Write-Host "¡Dirección IP válida ingresada: $ip_address!"
        break
    } else {
        Write-Host "La dirección IP ingresada no es válida. Por favor, inténtelo nuevamente."
    }
}

# Solicitar la IP de inicio del rango
while ($true) {
    $ip_inicio = Read-Host "Ingrese la IP de inicio del rango DHCP"
    if (Validar-IP -ip_address $ip_inicio) {
        Write-Host "IP de inicio válida: $ip_inicio"
        break
    } else {
        Write-Host "La IP ingresada no es válida. Inténtelo de nuevo."
    }
}

# Solicitar la IP de fin del rango DHCP
while ($true) {
    $ip_fin = Read-Host "Ingrese la IP de fin del rango DHCP"
    if (Validar-IP -ip_address $ip_fin) {
        $fin_octeto = [int]($ip_fin -split '\.')[3]
        $inicio_octeto = [int]($ip_inicio -split '\.')[3]

        if ($fin_octeto -gt $inicio_octeto) {
            Write-Host "IP de fin válida: $ip_fin"
            break
        } else {
            Write-Host "La IP final debe tener el último octeto mayor que la IP inicial."
        }
    } else {
        Write-Host "La IP ingresada no es válida. Inténtelo de nuevo."
    }
}

Write-Host "Configuración completa:"
Write-Host "Servidor DHCP: $ip_address"
Write-Host "Rango de IPs: $ip_inicio - $ip_fin"

$ip_parts = $ip_address -split '\.'
$subneteo = "$($ip_parts[0]).$($ip_parts[1]).$($ip_parts[2]).0"
$puerta = "$($ip_parts[0]).$($ip_parts[1]).$($ip_parts[2]).1"
$mascara = "255.255.255.0"

Write-Host "Subnet: $subneteo"
Write-Host "Puerta de enlace: $puerta"

netsh interface ipv4 set address name="Ethernet 2" static $ip_address $mascara
Install-WindowsFeature DHCP -IncludeManagementTools
Add-DhcpServerv4Scope -Name "RedLocal" -StartRange $ip_inicio -EndRange $ip_fin -SubnetMask $mascara
Add-DhcpServerv4ExclusionRange -ScopeId $subneteo -StartRange $ip_address -EndRange $ip_address
Restart-Service -Name DHCPServer
New-NetFIrewallRule -DisplayName "Permitir ping entrante" -Direction Inbound -Protocol ICMPv4 -Action Allow