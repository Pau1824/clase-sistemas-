netsh interface ipv4 set address name="Ethernet 2" static 192.168.1.11 255.255.255.0

# Instalación del Servidor FTP en Windows Server
Install-WindowsFeature -Name Web-Ftp-Server, Web-Server -IncludeManagementTools
Import-Module WebAdministration

# Creación de Carpetas
mkdir C:\FTP
mkdir C:\FTP\publica
mkdir C:\FTP\reprobados
mkdir C:\FTP\recursadores
mkdir C:\FTP\LocalUser
mkdir C:\FTP\LocalUser\Public

# Verificar que las carpetas existen antes de continuar
if (!(Test-Path "C:\FTP\publica")) { mkdir "C:\FTP\publica" }
if (!(Test-Path "C:\FTP\reprobados")) { mkdir "C:\FTP\reprobados" }
if (!(Test-Path "C:\FTP\recursadores")) { mkdir "C:\FTP\recursadores" }
if (!(Test-Path "C:\FTP\LocalUser")) { mkdir "C:\FTP\LocalUser" }
if (!(Test-Path "C:\FTP\LocalUser\Public")) { mkdir "C:\FTP\LocalUser\Public" }

# Crear el Sitio FTP en IIS
New-WebFtpSite -Name "FTPServidor" -Port 21 -PhysicalPath "C:\FTP"

# Configuración de autenticación
Set-ItemProperty "IIS:\Sites\FTPServidor" -Name ftpServer.security.authentication.basicAuthentication.enabled -Value 1
Set-ItemProperty "IIS:\Sites\FTPServidor" -Name ftpServer.security.authentication.anonymousAuthentication.enabled -Value 1

Set-ItemProperty "IIS:\Sites\FTPServidor" -Name ftpServer.userIsolation.mode -Value "IsolateRootDirectoryOnly"

cmd /c "mklink /d "C:\FTP\LocalUser\Public\publica" "C:\FTP\publica""

# Crear Grupos de Usuarios si no existen
if (!(Get-LocalGroup -Name "FTP_Reprobados" -ErrorAction SilentlyContinue)) {
    net localgroup "FTP_Reprobados" /add
}
if (!(Get-LocalGroup -Name "FTP_Recursadores" -ErrorAction SilentlyContinue)) {
    net localgroup "FTP_Recursadores" /add
}
if (!(Get-LocalGroup -Name "FTP_Publico" -ErrorAction SilentlyContinue)) {
    net localgroup "FTP_Publico" /add
}

Add-WebConfiguration "/system.ftpServer/security/authorization" -Value @{accessType="Allow";users="*";permissions=3} -PSPath IIS:\ -Location "FTPServidor"

# Eliminar configuraciones previas en las carpetas
Remove-WebConfigurationProperty -PSPath IIS:\ -Location "FTPServidor/publica" -Filter "system.ftpServer/security/authorization" -Name "."
Remove-WebConfigurationProperty -PSPath IIS:\ -Location "FTPServidor/reprobados" -Filter "system.ftpServer/security/authorization" -Name "."
Remove-WebConfigurationProperty -PSPath IIS:\ -Location "FTPServidor/recursadores" -Filter "system.ftpServer/security/authorization" -Name "."

# Asignar permisos específicos a cada grupo con `Add-WebConfiguration`
Add-WebConfiguration "/system.ftpServer/security/authorization" -Value @{accessType="Allow";users="*";permissions=1} -PSPath IIS:\ -Location "FTPServidor/publica"
Add-WebConfiguration "/system.ftpServer/security/authorization" -Value @{accessType="Allow";roles="FTP_Reprobados";permissions=3} -PSPath IIS:\ -Location "FTPServidor/reprobados"
Add-WebConfiguration "/system.ftpServer/security/authorization" -Value @{accessType="Allow";roles="FTP_Recursadores";permissions=3} -PSPath IIS:\ -Location "FTPServidor/recursadores"
Add-WebConfiguration "/system.ftpServer/security/authorization" -Value @{accessType="Allow";roles="FTP_Publico";permissions=3} -PSPath IIS:\ -Location "FTPServidor/publica"


# Deshabilitar SSL en el FTP
Set-ItemProperty "IIS:\Sites\FTPServidor" -Name ftpServer.security.ssl.controlChannelPolicy -Value 0
Set-ItemProperty "IIS:\Sites\FTPServidor" -Name ftpServer.security.ssl.dataChannelPolicy -Value 0

Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False


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
    New-LocalUser -Name $NombreUsuario -Password $Password
    Add-LocalGroupMember -Group $Grupo -Member $NombreUsuario
    Add-LocalGroupMember -Group "FTP_Publico" -Member $NombreUsuario

    # Crear carpeta del usuario y vincular carpetas públicas y de grupo
    if (!(Test-Path "C:\FTP\$NombreUsuario")) { mkdir "C:\FTP\$NombreUsuario" }
    if (!(Test-Path "C:\FTP\LocalUser\$NombreUsuario")) { mkdir "C:\FTP\LocalUser\$NombreUsuario" }

    # Vincular carpetas públicas y de grupo
    cmd /c "mklink /d "C:\FTP\LocalUser\$NombreUsuario\publica" "C:\FTP\publica""
    cmd /c "mklink /d "C:\FTP\LocalUser$NombreUsuario\$Grupo" "C:\FTP\$Grupo""
    cmd /c "mklink /d "C:\FTP\LocalUser\$NombreUsuario\$NombreUsuario" "C:\FTP\$NombreUsuario""

    Remove-WebConfigurationProperty -PSPath IIS:\ -Location "FTPServidor/$NombreUsuario" -Filter "system.ftpServer/security/authorization" -Name "."

    # Asignar permisos al usuario en IIS en su propia carpeta
    Add-WebConfiguration "/system.ftpServer/security/authorization" -Value @{accessType="Allow";users="$NombreUsuario";permissions=3} -PSPath IIS:\ -Location "FTPServidor/$NombreUsuario"

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

    # Actualizar permisos en IIS
    Remove-WebConfigurationProperty -PSPath IIS:\ -Location "FTP/$NombreUsuario" -Filter "system.ftpServer/security/authorization" -Name "."
    Add-WebConfiguration "/system.ftpServer/security/authorization" -Value @{accessType="Allow";users="$NombreUsuario";permissions=3} -PSPath IIS:\ -Location "FTP/$NombreUsuario"

    Write-Host "Usuario $NombreUsuario ahora pertenece a $NuevoGrupo." -ForegroundColor Green
}

# Configurar Firewall
New-NetFirewallRule -DisplayName "FTP (Puerto 21)" -Direction Inbound -Protocol TCP -LocalPort 21 -Action Allow
New-NetFirewallRule -DisplayName "FTP PASV (50000-51000)" -Direction Inbound -Protocol TCP -LocalPort 50000-51000 -Action Allow

# Reiniciar el servicio FTP para aplicar todos los cambios
#Restart-Service W3SVC
#Restart-Service FTPSVC

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

