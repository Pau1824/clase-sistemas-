
    USERNAME=$1
    GRUPO_NOMBRE=$2

    sudo su
    #Intalacion del servicio
    apt-get update
    apt-get install vsftpd

    #Abrir puertos en el firewall
    ufw enable
    ufw allow 21/tcp
    ufw allow 20/tcp
    ufw allow 40000:50000/tcp
    ufw reload

    echo "Configurando directorios..."
    sudo mkdir -p /srv/ftp/publico
    sudo mkdir -p /srv/ftp/reprobados
    sudo mkdir -p /srv/ftp/recursadores
    sudo mkdir -p /srv/ftp/$USERNAME

    # Asignar permisos
    sudo chown nobody:nogroup /srv/ftp/publico
    sudo chmod 755 /srv/ftp/publico
    sudo chown nobody:nogroup /srv/ftp/reprobados
    sudo chmod 777 /srv/ftp/reprobados
    sudo chown nobody:nogroup /srv/ftp/recursadores
    sudo chmod 777 /srv/ftp/recursadores
    sudo chown $USERNAME:ftp /srv/ftp/$USERNAME
    sudo chmod 770 /srv/ftp/$USERNAME
    sudo chown $USERNAME:ftp /srv/ftp/publico
    sudo chmod 755 /srv/ftp/publico
    sudo chown $USERNAME:ftp /srv/ftp/$GRUPO_NOMBRE
    sudo chmod 770 /srv/ftp/$GRUPO_NOMBRE
    sudo chown $USERNAME:ftp /srv/ftp/$USERNAME/$USERNAME
    sudo chmod 770 /srv/ftp/$USERNAME/$USERNAME

    # Montar carpetas
    sudo mkdir -p /srv/ftp/$USERNAME/publico
    sudo mkdir -p /srv/ftp/$USERNAME/$GRUPO_NOMBRE
    sudo mount --bind /srv/ftp/publico /srv/ftp/$USERNAME/publico
    sudo mount --bind /srv/ftp/$GRUPO_NOMBRE /srv/ftp/$USERNAME/$GRUPO_NOMBRE

    # Agregar montajes a /etc/fstab
    #echo "/srv/ftp/publico /srv/ftp/$USERNAME/publico none bind 0 0" | sudo tee -a /etc/fstab
    #echo "/srv/ftp/$GRUPO_NOMBRE /srv/ftp/$USERNAME/$GRUPO_NOMBRE none bind 0 0" | sudo tee -a /etc/fstab

    # Configurar vsftpd
    #if ! grep -q "local_root=/srv/ftp/\$USER" /etc/vsftpd.conf; then
     #   echo "user_sub_token=\$USER" | sudo tee -a /etc/vsftpd.conf
     #  echo "local_root=/srv/ftp/\$USER" | sudo tee -a /etc/vsftpd.conf
    #fi


    # Configuración de named.conf.options
    sudo tee /etc/vsftp.conf > /dev/null <<EOT
listen=YES
listen_ipv6=NO
anonymous_enable=YES
local_enable=YES
write_enable=YES
anon_upload_enable=NO
anon_mkdir_write_enable=NO
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
chroot_local_user=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
rsa_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
ssl_enable=NO
anon_root=/srv/ftp/publico
anon_other_write_enable=NO
pasv_enable=YES
pasv_min_port=40000
pasv_max_port=50000
pasv_address=192.168.1.10
allow_writeable_chroot=YES
user_sub_token=$USER
local_root=/srv/ftp/$USER
EOT

    systemctl restart vsftpd
    systemctl status vsftpd

