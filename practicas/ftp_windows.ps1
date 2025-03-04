netsh interface ipv4 set address name="Ethernet 2" static 192.168.1.11 255.255.255.0

# Instalación del Servidor FTP en Windows Server
Install-WindowsFeature -Name Web-Ftp-Server, Web-Server -IncludeManagementTools
Import-Module WebAdministration

# Creación de Carpetas
mkdir C:\FTP
mkdir C:\FTP\publica
mkdir C:\FTP\reprobados
mkdir C:\FTP\recursadores

# Verificar que las carpetas existen antes de continuar
if (!(Test-Path "C:\FTP\publica")) { mkdir "C:\FTP\publica" }
if (!(Test-Path "C:\FTP\reprobados")) { mkdir "C:\FTP\reprobados" }
if (!(Test-Path "C:\FTP\recursadores")) { mkdir "C:\FTP\recursadores" }

# Permitir la configuración de autorización en IIS
Set-WebConfigurationProperty -Filter "/system.ftpServer/security/authorization" -Name "overrideMode" -Value "Allow" -PSPath "MACHINE/WEBROOT/APPHOST"

# Crear el Sitio FTP en IIS y verificar el nombre correcto
New-WebFtpSite -Name "FTPServidor" -Port 21 -PhysicalPath "C:\FTP"
Set-ItemProperty "IIS:\Sites\FTPServidor" -Name ftpServer.security.authentication.basicAuthentication.enabled -Value $true
Set-ItemProperty "IIS:\Sites\FTPServidor" -Name ftpServer.security.authentication.anonymousAuthentication.enabled -Value $true

# Crear Grupos de Usuarios si no existen
if (!(Get-LocalGroup -Name "FTP_Reprobados" -ErrorAction SilentlyContinue)) {
    net localgroup "FTP_Reprobados" /add
}
if (!(Get-LocalGroup -Name "FTP_Recursadores" -ErrorAction SilentlyContinue)) {
    net localgroup "FTP_Recursadores" /add
}

# Configurar permisos en IIS con el nombre correcto del sitio
$ftpSiteName = "FTPServidor"  # Asegurar que coincida con `Get-WebSite`
Add-WebConfiguration "/system.ftpServer/security/authorization" -Value @{accessType="Allow";users="*";permissions=1} -PSPath "IIS:\Sites\$ftpSiteName"
Add-WebConfiguration "/system.ftpServer/security/authorization" -Value @{accessType="Allow";roles="reprobados";permissions=3} -PSPath "IIS:\Sites\$ftpSiteName"
Add-WebConfiguration "/system.ftpServer/security/authorization" -Value @{accessType="Allow";roles="recursadores";permissions=3} -PSPath "IIS:\Sites\$ftpSiteName"

# Función para Crear Usuarios FTP
function Crear-UsuarioFTP {
    param (
        [string]$NombreUsuario
    )

    if ($NombreUsuario -match "[^a-zA-Z0-9]") {
        Write-Host "El nombre de usuario solo puede contener letras y números." -ForegroundColor Red
        return
    }

    $Grupo = switch (Read-Host "Seleccione el grupo: 1 para Reprobados, 2 para Recursadores") {
        "1" { "Reprobados" }
        "2" { "Recursadores" }
        default {
            Write-Host "Opción inválida. Debe seleccionar 1 o 2." -ForegroundColor Red
            return
        }
    }

    $Password = Read-Host "Ingrese contraseña" -AsSecureString
    New-LocalUser -Name $NombreUsuario -Password $Password -Description "Usuario FTP"
    Add-LocalGroupMember -Group "FTP_$Grupo" -Member $NombreUsuario

    # Verificar que las carpetas existen antes de crear enlaces
    if (!(Test-Path "C:\FTP\$NombreUsuario")) { mkdir "C:\FTP\$NombreUsuario" }
    cmd.exe /c "mklink /d "C:\FTP\$NombreUsuario\publica" "C:\FTP\publica""
    cmd.exe /c "mklink /d "C:\FTP\$NombreUsuario\$Grupo" "C:\FTP\$Grupo""

    Write-Host "Usuario $NombreUsuario creado en el grupo $Grupo." -ForegroundColor Green
}

# Función para Cambiar de Grupo a un Usuario
function Cambiar-GrupoFTP {
    param (
        [string]$NombreUsuario
    )

    if (-not (Get-LocalUser -Name $NombreUsuario -ErrorAction SilentlyContinue)) {
        Write-Host "Usuario no encontrado." -ForegroundColor Red
        return
    }

    $GrupoActual = if ((Get-LocalGroupMember -Group "FTP_Reprobados" -Member $NombreUsuario -ErrorAction SilentlyContinue)) {
        "Reprobados"
    } elseif ((Get-LocalGroupMember -Group "FTP_Recursadores" -Member $NombreUsuario -ErrorAction SilentlyContinue)) {
        "Recursadores"
    } else {
        Write-Host "El usuario no pertenece a ningún grupo." -ForegroundColor Red
        return
    }

    $NuevoGrupo = if ($GrupoActual -eq "Reprobados") { "Recursadores" } else { "Reprobados" }

    Remove-LocalGroupMember -Group "FTP_$GrupoActual" -Member $NombreUsuario
    Add-LocalGroupMember -Group "FTP_$NuevoGrupo" -Member $NombreUsuario

    Remove-Item "C:\FTP\$NombreUsuario\$GrupoActual" -Force
    cmd.exe /c "mklink /d "C:\FTP\$NombreUsuario\$NuevoGrupo" "C:\FTP\$NuevoGrupo""

    Write-Host "Usuario $NombreUsuario ahora pertenece a $NuevoGrupo." -ForegroundColor Green
}

# Verificar si la configuración SSL existe antes de aplicarla
if (Get-WebConfigurationProperty -Filter "/system.ftpServer/security/sslPolicy" -PSPath "IIS:\") {
    Set-WebConfigurationProperty -Filter "/system.ftpServer/security/sslPolicy" -Name "server.ftpsServer.sslPolicy" -Value "None" -PSPath "IIS:\Sites\$ftpSiteName"
} else {
    Write-Host "Advertencia: No se encontró la configuración SSL en IIS, omitiendo cambio."
}

# Configurar Firewall
New-NetFirewallRule -DisplayName "FTP (Puerto 21)" -Direction Inbound -Protocol TCP -LocalPort 21 -Action Allow
New-NetFirewallRule -DisplayName "FTP PASV (50000-51000)" -Direction Inbound -Protocol TCP -LocalPort 50000-51000 -Action Allow

# Reiniciar el Servidor FTP
Restart-WebItem "IIS:\Sites\$ftpSiteName"

# Menú Interactivo
while ($true) {
    Write-Host "\n=== Menú de Administración FTP ===" -ForegroundColor Cyan
    Write-Host "1. Crear un nuevo usuario FTP"
    Write-Host "2. Cambiar de grupo a un usuario"
    Write-Host "3. Salir"
    
    $opcion = Read-Host "Seleccione una opción (1-3)"
    
    switch ($opcion) {
        "1" {
            $nombreUsuario = Read-Host "Ingrese el nombre del usuario"
            Crear-UsuarioFTP -NombreUsuario $nombreUsuario
        }
        "2" {
            $nombreUsuario = Read-Host "Ingrese el nombre del usuario"
            Cambiar-GrupoFTP -NombreUsuario $nombreUsuario
        }
        "3" {
            Write-Host "Saliendo..." -ForegroundColor Yellow
            break
        }
        default {
            Write-Host "Opción inválida. Intente de nuevo." -ForegroundColor Red
        }
    }
}
