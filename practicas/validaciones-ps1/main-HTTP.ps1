#HTTP   

Import-Module "C:\Users\Administrator\Desktop\validaciones-ps1\modulohttp.psm1"

# Verifica si el script se está ejecutando como Administrador
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Este script debe ejecutarse como Administrador." 
    exit
}

while ($true) {
    menu_http
    $op = Read-Host "Seleccione el servicio HTTP que queria instalar y configurar: "

    switch ($op) {
        "1" {
            $port = solicitar_puerto "Ingresa el puerto: "
            if ([string]::IsNullOrEmpty($port)){
                continue
            }
            conf_IIS -port "$port"
        }
        "2" {
            $version= obtener_apache
            $op2 = Read-Host "1 para instalar Apache o cualquier otro para regresar"
            if ($op2 -eq "1") {
                $port = solicitar_puerto "Ingresa el puerto:"
                if ([string]::IsNullOrEmpty($port)){
                    continue
                }
                conf_apache -port $port -version "$version"
            } else {
                Write-Host "Regresando" 
            }
        }
        "3" {
            $version = obtener_nginx

            do {
                menu_http2 "Nginx" $version.stable $version.mainline
                $op2 = Read-Host "Seleccione una opcion (1, 2 o 3):"
    
            if ($op2 -eq "1" -or $op2 -eq "2" -or $op2 -eq "3") {
                break
            } else {
                Write-Host "Opción no válida. Inténtalo de nuevo."
            }
            } while ($true)

            if ($op2 -eq "1") {
                $port = solicitar_puerto "Ingresa el puerto:"
                if (-not [string]::IsNullOrEmpty($port)) {
                conf_nginx -port $port -version $version.stable
            }
            } elseif ($op2 -eq "2") {
                $port = solicitar_puerto "Ingresa el puerto:"
                if (-not [string]::IsNullOrEmpty($port)) {
                conf_nginx -port $port -version $version.mainline
                }
            } elseif ($op2 -eq "3") {
                Write-Host "Regresando"
            }
        }
        "4" {
            exit
        }
        default {
            Write-Host "Opcion no valida." 
        }
    }


}