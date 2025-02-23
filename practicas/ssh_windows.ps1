#Intalo el servico ssh
Add-WindowsCapability -Online -Name OpenSSH~~~~0.0.1.0

#Inicio el servicio
Start-Service sshd

#Pongo el servicio para que se inicie automaticamente
Set-Service -Name sshd -StartupType 'Automatic'

#Hago una regla del firewall para que escuche desde el puerto 22 el servicio
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (ssh)' -Enabled True -Protocol TCP -Action Allow -LocalPort 22
