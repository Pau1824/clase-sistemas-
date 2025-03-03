function Obtener-Dominio {
    do {
        $domain = Read-Host "Ingrese el dominio"
        
        # Validación de formato (debe contener al menos un punto y terminar en .com, .net, .org, etc.)
        $valid_format = "^[a-zA-Z0-9-]+\.[a-zA-Z]{2,}$"

        if ($domain -match $valid_format) {
            # Comprobar si el dominio ya existe en el servidor DNS
            $dnsZone = Get-DnsServerZone -Name $domain -ErrorAction SilentlyContinue
            if ($dnsZone) {
                Write-Host "El dominio ya está registrado en el servidor. Inténtelo con otro." -ForegroundColor Red
            } else {
                return $domain
            }
        } else {
            Write-Host "El dominio no es válido. Inténtelo de nuevo." -ForegroundColor Red
        }
    } while ($true)
}

Export-ModuleMember -Function Obtener-Dominio