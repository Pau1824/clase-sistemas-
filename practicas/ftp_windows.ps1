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

# Crear el Sitio FTP en IIS
New-WebFtpSite -Name "FTPServidor" -Port 21 -PhysicalPath "C:\FTP"
Set-ItemProperty -Path "IIS:\Sites\FTPServidor" -Name bindings -Value @{protocol="ftp";bindingInformation="*:21:"}

# Configuración de autenticación
Set-ItemProperty "IIS:\Sites\FTPServidor" -Name ftpServer.security.authentication.basicAuthentication.enabled -Value $true
Set-ItemProperty "IIS:\Sites\FTPServidor" -Name ftpServer.security.authentication.anonymousAuthentication.enabled -Value $true

# Crear Grupos de Usuarios si no existen
if (!(Get-LocalGroup -Name "FTP_Reprobados" -ErrorAction SilentlyContinue)) {
    net localgroup "FTP_Reprobados" /add
}
if (!(Get-LocalGroup -Name "FTP_Recursadores" -ErrorAction SilentlyContinue)) {
    net localgroup "FTP_Recursadores" /add
}

# Configurar permisos en las carpetas con icacls
icacls "C:\FTP\publica" /grant "Everyone:R"
icacls "C:\FTP\reprobados" /grant "FTP_Reprobados:F"
icacls "C:\FTP\recursadores" /grant "FTP_Recursadores:F"

# Deshabilitar SSL en el FTP
Set-ItemProperty "IIS:\Sites\FTPServidor" -Name ftpServer.security.ssl.controlChannelPolicy -Value 0
Set-ItemProperty "IIS:\Sites\FTPServidor" -Name ftpServer.security.ssl.dataChannelPolicy -Value 0

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
        "1" { "FTP_Reprobados" }
        "2" { "FTP_Recursadores" }
        default {
            Write-Host "Opción inválida. Debe seleccionar 1 o 2." -ForegroundColor Red
            return
        }
    }

    $Password = Read-Host "Ingrese contraseña" -AsSecureString
    New-LocalUser -Name $NombreUsuario -Password $Password -Description "Usuario FTP"
    Add-LocalGroupMember -Group $Grupo -Member $NombreUsuario

    # Crear carpeta del usuario y vincular carpetas públicas y de grupo
    if (!(Test-Path "C:\FTP\$NombreUsuario")) { mkdir "C:\FTP\$NombreUsuario" }
    cmd.exe /c "mklink /d "C:\FTP\$NombreUsuario\publica" "C:\FTP\publica""
    cmd.exe /c "mklink /d "C:\FTP\$NombreUsuario\grupo" "C:\FTP\$Grupo""

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
        "FTP_Reprobados"
    } elseif ((Get-LocalGroupMember -Group "FTP_Recursadores" -Member $NombreUsuario -ErrorAction SilentlyContinue)) {
        "FTP_Recursadores"
    } else {
        Write-Host "El usuario no pertenece a ningún grupo." -ForegroundColor Red
        return
    }

    $NuevoGrupo = if ($GrupoActual -eq "FTP_Reprobados") { "FTP_Recursadores" } else { "FTP_Reprobados" }

    Remove-LocalGroupMember -Group $GrupoActual -Member $NombreUsuario
    Add-LocalGroupMember -Group $NuevoGrupo -Member $NombreUsuario

    Remove-Item "C:\FTP\$NombreUsuario\grupo" -Force
    cmd.exe /c "mklink /d "C:\FTP\$NombreUsuario\grupo" "C:\FTP\$NuevoGrupo""

    Write-Host "Usuario $NombreUsuario ahora pertenece a $NuevoGrupo." -ForegroundColor Green
}

# Configurar Firewall
New-NetFirewallRule -DisplayName "FTP (Puerto 21)" -Direction Inbound -Protocol TCP -LocalPort 21 -Action Allow
New-NetFirewallRule -DisplayName "FTP PASV (50000-51000)" -Direction Inbound -Protocol TCP -LocalPort 50000-51000 -Action Allow

# Reiniciar el servicio FTP para aplicar todos los cambios
Restart-Service FTPSVC

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

