function Configurar-DHCP {
    param (
        [string]$ip_address,
        [string]$ip_inicio,
        [string]$ip_fin
    )

    $ip_parts = $ip_address -split '\.'
    $subneteo = "$($ip_parts[0]).$($ip_parts[1]).$($ip_parts[2]).0"
    $puerta = "$($ip_parts[0]).$($ip_parts[1]).$($ip_parts[2]).1"
    $mascara = "255.255.255.0"

    Write-Host "Subnet: $subneteo"
    Write-Host "Puerta de enlace: $puerta"

    Install-WindowsFeature DHCP -IncludeManagementTools
    Add-DhcpServerv4Scope -Name "RedLocal" -StartRange $ip_inicio -EndRange $ip_fin -SubnetMask $mascara
    Add-DhcpServerv4ExclusionRange -ScopeId $subneteo -StartRange $ip_address -EndRange $ip_address
    Restart-Service -Name DHCPServer
    New-NetFirewallRule -DisplayName "Permitir ping entrante" -Direction Inbound -Protocol ICMPv4 -Action Allow
}

Export-ModuleMember -Function Configurar-DHCP