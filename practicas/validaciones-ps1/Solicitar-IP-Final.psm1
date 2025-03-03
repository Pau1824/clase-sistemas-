Import-Module "C:\Users\Administrator\Desktop\practicas\validaciones-ps1\Validar-IP.psm1"

function Solicitar-IP-Final {
    param (
        [string]$ip_inicio
    )

    while ($true) {
        $ip_fin = Read-Host "Ingrese la IP de fin del rango DHCP"
        if (Validar-IP -ip_address $ip_fin) {
            $fin_octeto = [int]($ip_fin -split '\.')[3]
            $inicio_octeto = [int]($ip_inicio -split '\.')[3]

            if ($fin_octeto -gt $inicio_octeto) {
                Write-Host "IP de fin válida: $ip_fin"
                return $ip_fin
            } else {
                Write-Host "La IP final debe tener el último octeto mayor que la IP inicial."
            }
        } else {
            Write-Host "La IP ingresada no es válida. Inténtelo de nuevo."
        }
    }
}