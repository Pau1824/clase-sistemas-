#Me aseguro que este actualizado ubuntu
apt-get update

#Instalo el servicio ssh
apt -y install openssh-server

#Hacemos que el servicio este disponible
systemctl enable ssh

#Reiniciamos el servicio
systemctl restart ssh

#Checamos que este corriendo el servicio
systemctl status ssh

#Este disponible el ssh en el firewall
ufw allow ssh

#Esta disponible el firewall
ufw enable