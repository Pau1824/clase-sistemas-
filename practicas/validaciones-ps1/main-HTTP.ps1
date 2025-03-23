#HTTP   

Import-Module "C:\Users\Administrator\Desktop\validaciones-ps1\modulohttp.psm1"
Import-Module "C:\Users\Administrator\Desktop\validaciones-ps1\moduloFTP-HTTP.psm1"

# Verifica si el script se está ejecutando como Administrador
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Este script debe ejecutarse como Administrador." 
    exit
}

Write-Host "Seleccione el método de instalación:"
Write-Host "1. HTTP (Servicios)"
Write-Host "2. FTP (Listar Carpetas)"
$opcion = Read-Host "Ingrese su opción"

if ($opcion -eq "1") {
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
} elseif ($opcion -eq "2") {
    $ftpFolders = Get-FTPList | Where-Object { $_.Trim() -ne "" }
    if ($ftpFolders.Count -eq 0) {
        Write-Host "No se encontraron carpetas en el FTP." -ForegroundColor Red
        exit
    }

    Write-Host "`n= CARPETAS DISPONIBLES EN EL FTP =" -ForegroundColor Cyan
    for ($i = 0; $i -lt $ftpFolders.Count; $i++) {
        Write-Host "$($i+1). $($ftpFolders[$i].Trim())"
    }

    $seleccion = Read-Host "Seleccione la carpeta a instalar (1-$($ftpFolders.Count)) o 0 para salir"
    if ($seleccion -eq "0") {
        Write-Host "Saliendo..."
        exit
    } elseif ($seleccion -match "^\d+$" -and [int]$seleccion -le $ftpFolders.Count) {
        $carpetaSeleccionada = $ftpFolders[$seleccion - 1].Trim()
        Write-Host "Selecciono la carpeta: $carpetaSeleccionada"

        $ftpServer = "192.168.1.2"
        $ftpUser = "windows"
        $ftpPass = "1234"

        # Mostrar carpeta seleccionada
        $selectedService = $ftpFolders[[int]$seleccion - 1].Trim()
        Write-Host "Selecciono la carpeta: $selectedService" -ForegroundColor Yellow

        # Verificamos que $selectedService no esté vacío
        if ([string]::IsNullOrWhiteSpace($selectedService)) {
            Write-Host "Error: La carpeta seleccionada es vacia o invalida." -ForegroundColor Red
            return
        }

        # Construimos y mostramos la ruta que se va a usar
        $rutaFTP = "$selectedService/"
        Write-Host "Ruta que se usara en la conexión FTP: $rutaFTP" -ForegroundColor Cyan

        # Llamamos a la función con la ruta correcta
        $files = listar_http -ftpServer $ftpServer -ftpUser $ftpUser -ftpPass $ftpPass -directory $rutaFTP

        # Filtramos y validamos resultados
        $files = $files | Where-Object { ($_ -match '\S') -and ($_ -ne $null) } | ForEach-Object { $_.Trim() }

        if ($files.Count -eq 0) {
            Write-Host "No se encontraron archivos en el directorio." -ForegroundColor Red
            return
        }

        if ($files -isnot [System.Array]) {
            $files = @($files)
        }

        # Mostramos las versiones encontradas
        $index = 1
        foreach ($file in $files) {
            # Detecta NGINX
            if ($file -match 'nginx-([0-9]+\.[0-9]+\.[0-9]+)\.zip') {
                $version = $matches[1]
                if ($index -eq 1) {
                    Write-Host "$index. Version estable: $version"
                } elseif ($index -eq 2) {
                    Write-Host "$index. Version de desarrollo: $version"
                } else {
                    Write-Host "$index. $version"
                }
            }
            # Detecta Apache
            elseif ($file -match 'httpd-([0-9]+\.[0-9]+\.[0-9]+)') {
                $version = $matches[1]
                Write-Host "$index. Version LTS: $version"
            }
            else {
                Write-Host "$index. $file"
            }
            $index++
        }

        do {
            $op2 = Read-Host "Elija la version que desea instalar (1-$($files.Count)), o escriba 0 para salir"
            if ($op2 -eq "0") { 
                Write-Host "Saliendo..." -ForegroundColor Yellow
                return
            }
            if ($op2 -match "^\d+$" -and [int]$op2 -le $files.Count) {
                break
            } else {
                Write-Host "Opción no valida. Intente de nuevo" -ForegroundColor Red
            }
        } while ($true)

        # Guardamos la versión seleccionada
        $selectedFile = $files[[int]$op2 - 1]
        Write-Host "Selecciono la version: $selectedFile" -ForegroundColor Green
    }
} else {
    Write-Host "Opcion no valida" -ForegroundColor Red
}

