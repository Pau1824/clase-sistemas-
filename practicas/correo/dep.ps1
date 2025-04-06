# ==========================
# VARIABLES
# ==========================
$phpUrl = "https://windows.php.net/downloads/releases/archives/php-7.4.33-Win32-vc15-x64.zip"
$squirrelUrl = "https://sourceforge.net/projects/squirrelmail/files/stable/1.4.22/squirrelmail-webmail-1.4.22.zip"
$phpPath = "C:\PHP"
$inetpubPath = "C:\inetpub\wwwroot"
$squirrelPath = "$inetpubPath\squirrelmail"
$jamesPath = "C:\JamesServer"

# ==========================
# INSTALAR IIS Y DEPENDENCIAS
# ==========================
Write-Host "Instalando IIS y componentes necesarios..."
Install-WindowsFeature -Name Web-Server, Web-Common-Http, Web-Static-Content, Web-Default-Doc, Web-Dir-Browsing, Web-Http-Errors, Web-Http-Logging, Web-CGI -IncludeManagementTools

# ==========================
# DESCARGAR Y CONFIGURAR PHP
# ==========================
Write-Host "Descargando PHP..."
Invoke-WebRequest -Uri $phpUrl -OutFile "php.zip"
Expand-Archive -Path "php.zip" -DestinationPath $phpPath -Force
Remove-Item "php.zip"

# Agregar PHP al PATH
Write-Host "Configurando PHP..."
[System.Environment]::SetEnvironmentVariable("Path", "$env:Path;$phpPath", [System.EnvironmentVariableTarget]::Machine)

# Configurar PHP en IIS (FastCGI)
Write-Host "Configurando IIS para PHP..."
Install-WindowsFeature -Name Web-CGI
Import-Module WebAdministration
New-Item -Path "IIS:\Sites\Default Web Site\Handler Mappings" -Name "PHP_via_FastCGI" -Value "$phpPath\php-cgi.exe" -Type File -Force

# ==========================
# DESCARGAR Y CONFIGURAR SQUIRRELMAIL
# ==========================
Write-Host "Descargando SquirrelMail..."
Invoke-WebRequest -Uri $squirrelUrl -OutFile "squirrelmail.zip"
Expand-Archive -Path "squirrelmail.zip" -DestinationPath $inetpubPath -Force
Remove-Item "squirrelmail.zip"
Rename-Item -Path "$inetpubPath\squirrelmail-webmail*" -NewName "squirrelmail"

# Configurar permisos en IIS
Write-Host "Configurando permisos en IIS..."
icacls $squirrelPath /grant IIS_IUSRS:F /T

# ==========================
# CONFIGURAR SQUIRRELMAIL
# ==========================
$configFile = "$squirrelPath\config\config.php"

Write-Host "Configurando SquirrelMail para James Server..."
(Get-Content $configFile) -replace "\$domain = .*;", "`$domain = 'midominio.local';" | Set-Content $configFile
(Get-Content $configFile) -replace "\$imapServerAddress = .*;", "`$imapServerAddress = 'midominio.local';" | Set-Content $configFile
(Get-Content $configFile) -replace "\$imapPort = .*;", "`$imapPort = 143;" | Set-Content $configFile
(Get-Content $configFile) -replace "\$smtpServerAddress = .*;", "`$smtpServerAddress = 'midominio.local';" | Set-Content $configFile
(Get-Content $configFile) -replace "\$smtpPort = .*;", "`$smtpPort = 25;" | Set-Content $configFile
(Get-Content $configFile) -replace "\$auth_mech = .*;", "`$auth_mech = 'login';" | Set-Content $configFile

# ==========================
# CONFIGURAR APACHE JAMES
# ==========================
Write-Host "Configurando Apache James..."
$imapConfig = "$jamesPath\conf\imapserver.xml"

(Get-Content $imapConfig) -replace '<imapserver enabled="false"', '<imapserver enabled="true"' | Set-Content $imapConfig
(Get-Content $imapConfig) -replace '<port>9993</port>', '<port>143</port>' | Set-Content $imapConfig

# ==========================
# REINICIAR SERVICIOS
# ==========================
Write-Host "Reiniciando IIS..."
iisreset

Write-Host "Reiniciando Apache James..."
Stop-Process -Name "James" -Force -ErrorAction SilentlyContinue
Start-Process -FilePath "$jamesPath\bin\run.bat" -WindowStyle Hidden

Write-Host "Instalación completada. Accede a SquirrelMail en: http://localhost/squirrelmail"
