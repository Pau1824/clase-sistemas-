function DescargarYDescomprimir {
    param(
        [string]$ftpServer,
        [string]$ftpUser,
        [string]$ftpPass,
        [string]$carpetaSeleccionada,  # Apache o Nginx
        [string]$selectedFile          # Archivo seleccionado (zip)
    )

    # Armamos la URL completa del FTP
    $URL_FTP = "ftp://$ftpServer/$carpetaSeleccionada/$selectedFile"
    Write-Host "Descargando desde: $URL_FTP" -ForegroundColor Cyan

    # Creamos el objeto WebClient con credenciales
    $ClienteWeb = New-Object System.Net.WebClient
    $ClienteWeb.Credentials = New-Object System.Net.NetworkCredential($ftpUser, $ftpPass)

    if ($carpetaSeleccionada -eq "Apache") {
        # Definimos la ruta de descarga y destino para Apache
        $zipPath = "$env:TEMP\apache-$selectedFile"
        $RutaDestino = "C:\Apache24"
        # Descargamos
        $ClienteWeb.DownloadFile($URL_FTP, $zipPath)
        Write-Host "Archivo Apache descargado en: $zipPath" -ForegroundColor Green
        # Descomprimimos
        Expand-Archive -Path $zipPath -DestinationPath $RutaDestino -Force
        Write-Host "Apache descomprimido en: $RutaDestino" -ForegroundColor Green
        $subfolder = Get-ChildItem -Path $RutaDestino | Where-Object { $_.PSIsContainer } | Select-Object -First 1
        if ($subfolder) {
            Write-Host "Moviendo contenido de $($subfolder.Name) a $RutaDestino" -ForegroundColor Yellow
            Move-Item -Path "$RutaDestino\$($subfolder.Name)\*" -Destination $RutaDestino -Force
            Remove-Item -Path "$RutaDestino\$($subfolder.Name)" -Recurse -Force
        }
    }
    elseif ($carpetaSeleccionada -eq "Nginx") {
        # Definimos la ruta de descarga y destino para Nginx
        $zipPath = "$env:TEMP\nginx-$selectedFile"
        $RutaDestino = "C:\Nginx"
        # Descargamos
        $ClienteWeb.DownloadFile($URL_FTP, $zipPath)
        Write-Host "Archivo Nginx descargado en: $zipPath" -ForegroundColor Green
        # Descomprimimos
        Expand-Archive -Path $zipPath -DestinationPath $RutaDestino -Force
        Write-Host "Nginx descomprimido en: $RutaDestino" -ForegroundColor Green
    }
    else {
        Write-Host "Opción no reconocida para la descarga y descompresión." -ForegroundColor Red
    }
}

function Configurar-Apache {
    param(
        [string]$RutaDestino,
        [int]$Port
    )

    try {
        Write-Host "Iniciando configuración de Apache..." -ForegroundColor Cyan

        # Configurar puerto en httpd.conf
        $configFile = Join-Path $RutaDestino "conf\httpd.conf"
        if (Test-Path $configFile) {
            (Get-Content $configFile) -replace "Listen 80", "Listen $Port" | Set-Content $configFile
            Write-Host "Puerto actualizado a $Port en httpd.conf" -ForegroundColor Green
        } else {
            Write-Host "No se encontró $configFile" -ForegroundColor Red
            return
        }

        # Instalar Apache como servicio
        $apacheExe = Get-ChildItem -Path $RutaDestino -Recurse -Filter httpd.exe -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($apacheExe) {
            Start-Process -FilePath $apacheExe.FullName -ArgumentList '-k', 'install', '-n', 'Apache24' -NoNewWindow -Wait
            Start-Service -Name "Apache24"
            Write-Host "Apache instalado y corriendo en el puerto $Port" -ForegroundColor Green
            New-NetFirewallRule -DisplayName "Abrir Puerto $Port Apache" -Direction Inbound -Protocol TCP -LocalPort $Port -Action Allow
        } else {
            Write-Host "No se encontró httpd.exe" -ForegroundColor Red
            return
        }

        # Preguntar por SSL
        do {
            $sslOptionApache = Read-Host "¿Desea agregar un certificado SSL? (s/n)"
            $sslOptionApache = $sslOptionApache.ToLower()
            if ($sslOptionApache -ne 's' -and $sslOptionApache -ne 'n') {
                Write-Host "Opción inválida. Solo se permite 's' o 'n'." -ForegroundColor Yellow
            }
        } while ($sslOptionApache -ne 's' -and $sslOptionApache -ne 'n')

        if ($sslOptionApache -eq 's') {
            Write-Host "Configurando SSL en Apache..." -ForegroundColor Cyan

            # Crear carpeta de certificados
            $certFolder = Join-Path $RutaDestino "Certificados"
            if (-not (Test-Path $certFolder)) {
                New-Item -Path $certFolder -ItemType Directory
                Write-Host "Carpeta 'Certificados' creada."
            }

            # Generar certificado y clave
            & openssl genrsa -out "$certFolder\apache.key" 2048
            & openssl req -new -x509 -key "$certFolder\apache.key" -out "$certFolder\apache.crt" -days 365 -subj "/CN=192.168.1.11"
            Write-Host "Certificado SSL generado."

            # Crear httpd-ssl.conf
            $sslContent = @"
#Listen 443
<VirtualHost *:$Port>
    ServerName localhost
    DocumentRoot "C:/Apache24/htdocs"

    SSLEngine on
    SSLCertificateFile "C:/Apache24/Certificados/apache.crt"
    SSLCertificateKeyFile "C:/Apache24/Certificados/apache.key"

    <Directory "C:/Apache24/htdocs">
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog "C:/Apache24/logs/error_log"
    CustomLog "C:/Apache24/logs/access_log" common
</VirtualHost>
"@

            Set-Content -Path "$RutaDestino\conf\extra\httpd-ssl.conf" -Value $sslContent
            Write-Host "Archivo httpd-ssl.conf generado." -ForegroundColor Green

            # Habilitar módulos SSL en httpd.conf
            (Get-Content $configFile) -replace '#LoadModule ssl_module modules/mod_ssl.so', 'LoadModule ssl_module modules/mod_ssl.so' | Set-Content $configFile
            (Get-Content $configFile) -replace '#LoadModule socache_shmcb_module modules/mod_socache_shmcb.so', 'LoadModule socache_shmcb_module modules/mod_socache_shmcb.so' | Set-Content $configFile
            (Get-Content $configFile) -replace '#Include conf/extra/httpd-ssl.conf', 'Include conf/extra/httpd-ssl.conf' | Set-Content $configFile

            # Agregar ServerName solo si no está
            if (-not (Select-String -Path $configFile -Pattern "ServerName localhost:$Port")) {
                Add-Content -Path $configFile -Value "ServerName localhost:$Port"
            }

             Add-Content -Path $configFile -Value "Include $RutaDestino\conf\extra\httpd-ssl.conf"
            # Reiniciar Apache
            Restart-Service -Name "Apache24" -Force
            Write-Host "Apache reiniciado con SSL en el puerto $Port" -ForegroundColor Green
        } else {
            Write-Host "No se realizará ninguna configuración SSL." -ForegroundColor Yellow
        }

    } catch {
        Write-Host "Error durante la instalación y configuración de Apache: $_" -ForegroundColor Red
    }
}

function Configurar-Nginx {
    param(
        [string]$RutaDestino,   # Ruta base: "C:\Nginx"
        [int]$Port,
        [string]$version,
        [string]$IP
    )

    try {
        Write-Host "Iniciando configuración de NGINX..." -ForegroundColor Cyan

        # Buscar carpeta real extraída (nginx-version)
        $nginxFolder = Get-ChildItem -Path $RutaDestino -Directory | Where-Object { $_.Name -like "nginx*" } | Select-Object -First 1
        if ($nginxFolder) {
            Write-Host "Se encontró la carpeta: $($nginxFolder.Name)" -ForegroundColor Green
        } else {
            Write-Host "No se encontró la carpeta extraída de NGINX en $RutaDestino" -ForegroundColor Red
            return
        }

        # Ruta completa al nginx.conf correcto
        $nginxConfPath = "$RutaDestino\$($nginxFolder.Name)\conf\nginx.conf"
        if (!(Test-Path $nginxConfPath)) {
            Write-Host "No se encontró el archivo nginx.conf en: $nginxConfPath" -ForegroundColor Red
            return
        }

        # Configurar puerto y logs
        (Get-Content $nginxConfPath) -replace "listen\s+80;", "listen $Port;" | Set-Content $nginxConfPath
        (Get-Content $nginxConfPath) -replace "#error_log\s+logs/error.log;", "error_log logs/error.log;" | Set-Content $nginxConfPath
        (Get-Content $nginxConfPath) -replace "#pid\s+logs/nginx.pid;", "pid logs/nginx.pid;" | Set-Content $nginxConfPath

        # Ejecutar NGINX desde la carpeta correcta
        $nginxExe = "$RutaDestino\$($nginxFolder.Name)\nginx.exe"
        if (Test-Path $nginxExe) {
            Start-Process -FilePath $nginxExe -WorkingDirectory "$RutaDestino\$($nginxFolder.Name)"
            Write-Host "NGINX iniciado correctamente." -ForegroundColor Green
        } else {
            Write-Host "No se encontró nginx.exe en $nginxExe" -ForegroundColor Red
            return
        }

        # Abrir el puerto en firewall
        New-NetFirewallRule -DisplayName "Nginx $Port" -Direction Inbound -Action Allow -Protocol TCP -LocalPort $Port

        # Preguntar si quiere SSL
        do {
            $sslOptionNginx = Read-Host "¿Desea agregar un certificado SSL? (s/n)"
            $sslOptionNginx = $sslOptionNginx.ToLower()
            if ($sslOptionNginx -ne 's' -and $sslOptionNginx -ne 'n') {
                Write-Host "Opción inválida. Solo se permite 's' o 'n'." -ForegroundColor Yellow
            }
        } while ($sslOptionNginx -ne 's' -and $sslOptionNginx -ne 'n')

        if ($sslOptionNginx -eq 's') {
            $sslPath = "$RutaDestino\$($nginxFolder.Name)\ssl"
            if (!(Test-Path $sslPath)) {
                New-Item -Path $sslPath -ItemType Directory
                Write-Host "Carpeta SSL creada en $sslPath"
            }

            # Generar certificado
            & openssl genrsa -out "$sslPath\nginx.key" 2048
            & openssl req -new -x509 -key "$sslPath\nginx.key" -out "$sslPath\nginx.crt" -days 365 -subj "/CN=$IP"
            Write-Host "Certificado SSL generado" -ForegroundColor Green

            # Sobreescribir nginx.conf con bloque SSL
            $sslBlock = @"
server {
    listen $Port ssl;
    server_name localhost;

    ssl_certificate      $sslPath\nginx.crt;
    ssl_certificate_key  $sslPath\nginx.key;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        root   html;
        index  index.html index.htm;
    }
}
"@
            Add-Content -Path $nginxConfPath -Value $sslBlock
            Write-Host "Bloque SSL agregado a nginx.conf" -ForegroundColor Green

            # Validar y recargar NGINX
            Push-Location "$RutaDestino\$($nginxFolder.Name)"
            .\nginx.exe -t
            .\nginx.exe -s reload
            Pop-Location
        }

        Write-Host "Configuración de NGINX finalizada." -ForegroundColor Cyan

    } catch {
        Write-Host "Error en la configuración de NGINX: $_" -ForegroundColor Red
    }
}


Export-ModuleMember -Function DescargarYDescomprimir, Configurar-Apache, Configurar-Nginx
