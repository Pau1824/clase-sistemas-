Import-Module "C:\Users\Administrator\Desktop\practicas\validaciones-ps1\Validar-IP.psm1"

function Solicitar-IP-Inicial {
    while ($true) {
        $ip_inicio = Read-Host "Ingrese la IP de inicio del rango DHCP"
        if (Validar-IP -ip_address $ip_inicio) {
            Write-Host "IP de inicio válida: $ip_inicio"
            return $ip_inicio
        } else {
            Write-Host "La IP ingresada no es válida. Inténtelo de nuevo."
        }
    }
}