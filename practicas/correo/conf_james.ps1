
$domain = "mailandrea.com"
#$user = "andrea"
$pop3Port = 110
$smtpPort = 25
$domainFile = "C:\JamesServer\James\conf\domainlist.xml"
$pop3File = "C:\JamesServer\James\conf\pop3server.xml"
$smtpFile = "C:\JamesServer\James\conf\smtpserver.xml"
$imapFile = "C:\JamesServer\James\conf\imapserver.xml"
$phpIniFile = "C:\xampp\php\php.ini"

# Configurar la lista de dominios
(Get-Content $domainFile) -replace "<domainname>localhost</domainname>", "<domainname>$domain</domainname>" | Set-Content $domainFile
(Get-Content $pop3File) -replace "<bind>0.0.0.0:110</bind>", "<bind>10.0.0.14:110</bind>" | Set-Content $pop3File
(Get-Content $smtpFile) -replace "<bind>0.0.0.0:25</bind>", "<bind>10.0.0.14:25</bind>" | Set-Content $smtpFile
(Get-Content $smtpFile) -replace "<domain>yourdomain1</domain>", "<domain>$domain</domain>" | Set-Content $smtpFile
(Get-Content $imapFile) -replace "<bind>0.0.0.0:143</bind>", "<bind>10.0.0.14:143</bind>" | Set-Content $imapFile
(Get-Content $imapFile) -replace "<plainAuthDisallowed>true</plainAuthDisallowed>", "<plainAuthDisallowed>false</plainAuthDisallowed>" | Set-Content $imapFile
(Get-Content $phpIniFile) -replace "^;extension=php_imap.dll", "extension=php_imap.dll" | Set-Content $phpIniFile


# Habilitar el puerto en el firewall 
New-NetFirewallRule -DisplayName "POP3" -Direction Inbound -Protocol TCP -LocalPort $pop3Port -Action Allow
New-NetFirewallRule -DisplayName "SMTP" -Direction Inbound -Protocol TCP -LocalPort $smtpPort -Action Allow

james install
james start
james status


cd C:\JamesServer\James\bin
james-cli AddDomain "$domain"
#james-cli AddUser $user@$domain andrea123

cd C:\xampp\htdocs\squirrelmail\config
perl conf.pl

while ($true) {
    Write-Host "--- SERVIDOR DE CORREO ---" -ForegroundColor Cyan
    Write-Host "1. Crear usuario"
    Write-Host "2.Salir"
    
    $option = Read-Host "Seleccione una opcion"
    
    switch ($option) {
        "1" {
            $username = Read-Host "Ingrese nombre de usuario"
            if ([string]::IsNullOrEmpty($username)){
                continue
            }
            $password = Read-Host "Ingrese password:" -ForegroundColor Green
            
            cd C:\JamesServer\James\bin
            james-cli AddUser "$username@$domain" "$password"
        }
        "2" {
            exit
        }
        default {
            Write-Host "Opcion no valida." -ForegroundColor Red
        }
    }
}


