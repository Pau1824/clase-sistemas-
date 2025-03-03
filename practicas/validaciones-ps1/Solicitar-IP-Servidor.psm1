Import-Module "C:\Users\Administrator\Desktop\practicas\validaciones-ps1\Validar-IP.psm1"

function Solicitar-IP-Servidor {
    while ($true) {
        $ip_address = Read-Host "Ingrese la dirección IP del servidor DNS"
        if (Validar-IP -ip_address $ip_address) {
            Write-Host "¡Dirección IP válida ingresada: $ip_address!"
            return $ip_address
        } else {
            Write-Host "La dirección IP ingresada no es válida. Por favor, inténtelo nuevamente."
        }
    }
}