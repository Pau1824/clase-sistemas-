#Tema 9.Administracion con PowerShell
#Subtema 9.1.-Administracion de servicios
Get-Service
Get-Service -Name Spooler
Get-Service -DisplayName Hora*
Get-Service | Where-Object {$_.Status -eq "Running"}
Get-Service | Where-Object {$_.StartType -eq "Automatic"} | Select-Object Name, StartType
Get-Service -DependentServices Spooler
Get-Service -RequiredServices Fax

#Subtema 9.1.1.- Stop-Service
Stop-Service -Name Spooler -Confirm -PassThru

#Subtema 9.1.2.- Start-Service
Start-Service -Name Spooler -Confirm -PassThru

#Subtema 9.1.3.- Suspend-Service
Suspend-Service -Name stisvc -Confirm -PassThru
Get-Service | Where-Object CanPauseAndContinue -eq True
Suspend-Service -Name Spooler

#Subtema 9.1.4.- Restart-Service
Restart-Service -Name WSearch -Confirm -PassThru

#Subtema 9.1.5.- Set-Service
Set-Service -Name dcsvc -DisplayName "Servidor de virtualizacion de credenciales de seguridad distribuidas"
Set-Service -Name BITS -StartupType Automatic -Confirm -PassThru | Select-Object Name, StartType
Set-Service -Name BITS -Description "Transfiere archivos en segundo plano mediante el uso de ancho de banda de red inactivo"
Get-CimInstance Win32_Service -Filter '"Name = "BITS"' | Format-List Name, Description
Set-Service -Name Spooler -Status Running -Confirm -PassThru
Set-Service -Name BITS -Status Stopped -Confirm -PassThru


#Subtema 9.2.-Administracion de procesos
#Subtema 9.2.1.- Get-Process
Get-Process
Get-Process -Name OpenVPNConnect
Get-Process -Name Search*
Get-Process -Id 2268
Get-Process WINWORD -FileVersionInfo
Get-Process WINWORD -IncludeUserName
Get-Process WINWORD -Module

#Subtema 9.2.2.- Stop-Porcess
Stop-Process -Name OpenVPNConnect -Confirm -PassThru
Stop-Process -Id 2268 -Confirm -PassThru
Get-Process -Name OpenVPNConnect | Stop-Process -Confirm -PassThru

#Subtema 9.2.3.- Start-Process
Start-Process -FilePath "C:\Windows\System32\notepad.exe" -PassThru
Start-Process -FilePath "cmd.exe" -ArgumentList "/c mkdir NuevaCarpeta" -WorkingDirectory "D:\Documents\FIC\06\ASO" -PassThru
Start-Process -FilePath "notepad.exe" -WindowStyle "Maximized" -PassTru
Start-Process -FilePath "D:\Documents\FIC\06\ASO\TT\TT.txt" -Verb Print -PassThru

#Subtema 9.2.4.- Wait-Process
Get-Process -Name notep*
Get-Process -Name Notepad
Wait-Process -Id 11568
Get-Process -Name notep*
Get-Process -Name notepad | Wait-Process


#Subtema 9.3.- Administracion de usuarios y grupos
#Subtema 9.3.1.- Get-LocalUser
Get-LocalUser
Get-LocalUser -Name chavi | Select-Object *
Get-LocalUser -SID S-1-5-21-4169144003-467534702-2126530610-1001 | Select-Object *

#Subtema 9.3.2.- Get-LocalGroup
Get-LocalGroup
Get-LocalGroup -Name Administrators | Select-Object *
Get-LocalGroup -SID S-1-5-32-544 | Select-Object *

#Subtema 9.3.3.- *-LocalUser 
New-LocalUser -Name "Usuario1" -Description "Usuario de prueba 1" -NoPassword
New-LocalUser -Name "Usuario2" -Description "Usuario de prueba 1" -Password (ConvertIo-SecureString -AsPlainText "12345" -Force)
Get-LocalUser -Name "Usuario1"
Remove-LocalUser -Name "Usuario1"
Get-LocalUser -Name "Usuario1"
Get-LocalUser -Name "Usuario2"
Get-LocalUser -Name "Usuario2" | Remove-LocalUser

#Subtema 9.3.4.- *-LocalGroup
New-LocalGroup -Name 'Group1' -Description 'Grupo de prueba 1'
Add-LocalGroupMember -Group Grupo1 -Member Usuario2 -Verbose
Get-LocalGroupMember Grupo1
Remove-LocalGroupMember -Group Grupo1 -Member Usuario1
Remove-LocalGroupMember -Group Grupo1 -Member Usuario2
Get-LocalGroupMember Grupo1
Get-LocalGroup -Name "Group1"
Remove-LocalGroup -Name "Grupo1"

#Anexo II: Habilitar la ejecucion de scirpt de powershell en windows
.\ejemplo.ps1