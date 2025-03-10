# Actualizar Ubuntu
sudo apt update 

sudo tee /etc/netplan/50-cloud-init.yaml > /dev/null <<EOT
# This file is generated from information provided by the datasource.  Changes
# to it will not persist across an instance reboot.  To disable cloud-init's
# network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
    ethernets:
        enp0s3:
            dhcp4: true
        enp0s8:
            addresses: [192.168.1.10/24]
            nameservers:
              addresses: [8.8.8.8, 1.1.1.1]
    version: 2
EOT
#comando para que se guarde
sudo netplan apply

# Instalar el servicio FTP
sudo apt install vsftpd

# Habilitar el firewall y abrir los puertos necesarios
sudo ufw enable
sudo ufw allow 20/tcp
sudo ufw allow 21/tcp
sudo ufw allow 40000:50000/tcp
sudo ufw reload

echo "Firewall configurado y puertos abiertos."

# Configuración de vsftpd
sudo tee /etc/vsftpd.conf > /dev/null <<EOT
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

# Reiniciar el servicio FTP
sudo systemctl restart vsftpd
sudo systemctl status vsftpd --no-pager

echo "Servicio FTP configurado y reiniciado."

# Crear carpetas principales
sudo mkdir -p /srv/ftp/publico
sudo mkdir -p /srv/ftp/reprobados
sudo mkdir -p /srv/ftp/recursadores

# Asignar permisos
sudo chown nobody:nogroup /srv/ftp/publico
sudo chmod 755 /srv/ftp/publico
sudo chown nobody:nogroup /srv/ftp/reprobados
sudo chmod 777 /srv/ftp/reprobados
sudo chown nobody:nogroup /srv/ftp/recursadores
sudo chmod 777 /srv/ftp/recursadores

echo "Carpetas FTP creadas."

# Función para crear usuario
crear_usuario() {
    read -p "Ingrese el nombre del usuario: " nombre
    echo "Seleccione el grupo:"
    echo "1. Reprobado"
    echo "2. Recursador"
    read -p "Seleccione una opción: " grupo_opcion
    
    if [[ "$grupo_opcion" == "1" ]]; then
        grupo="reprobados"
    elif [[ "$grupo_opcion" == "2" ]]; then
        grupo="recursadores"
    else
        echo "Opción no válida."
        return
    fi
    
    # Crear usuario y asignar contraseña
     sudo adduser "$nombre"
    
    # Crear carpeta específica del usuario
    sudo mkdir -p "/srv/ftp/$nombre"
    sudo chown "$nombre:ftp" "/srv/ftp/$nombre"
    sudo chmod 770 "/srv/ftp/$nombre"
    sudo chown $nombre:ftp /srv/ftp/publico
    sudo chmod 755 /srv/ftp/publico
    sudo chown $nombre:ftp /srv/ftp/$grupo
    sudo chmod 770 /srv/ftp/$grupo
    sudo mkdir -p "/srv/ftp/$nombre/$nombre"
    sudo chown $nombre:ftp /srv/ftp/$nombre/$nombre
    sudo chmod 770 /srv/ftp/$nombre/$nombre
    
    # Montar carpetas
    sudo mkdir -p "/srv/ftp/$nombre/publico"
    sudo mkdir -p "/srv/ftp/$nombre/$grupo"
    sudo mount --bind /srv/ftp/publico "/srv/ftp/$nombre/publico"
    sudo mount --bind "/srv/ftp/$grupo" "/srv/ftp/$nombre/$grupo"
    
    echo "Usuario $nombre creado con acceso a su carpeta, la pública y la de $grupo."
}

# Función para cambiar de grupo
cambiar_grupo() {
    read -p "Ingrese el nombre del usuario a cambiar de grupo: " nombre
    
    if ! id "$nombre" &>/dev/null; then
        echo "El usuario no existe."
        return
    fi
    
    grupo_actual=""
    if [[ -d "/srv/ftp/$nombre/reprobados" ]]; then
        grupo_actual="reprobados"
    elif [[ -d "/srv/ftp/$nombre/recursadores" ]]; then
        grupo_actual="recursadores"
    else
        echo "El usuario no tiene grupo asignado."
        return
    fi
    
    nuevo_grupo=""
    if [[ "$grupo_actual" == "reprobados" ]]; then
        nuevo_grupo="recursadores"
    else
        nuevo_grupo="reprobados"
    fi
    
    sudo mkdir -p "/srv/ftp/$nombre/$nuevo_grupo"
    sudo chown "$nombre:ftp" "/srv/ftp/$nombre/$nuevo_grupo"
    sudo usermod -G "$nuevo_grupo" "$nombre"
    
    # Montar carpetas nuevamente
    sudo umount "/srv/ftp/$nombre/$grupo_actual"
    sudo rm -r "/srv/ftp/$nombre/$grupo_actual"
    sudo mount --bind "/srv/ftp/$nuevo_grupo" "/srv/ftp/$nombre/$nuevo_grupo"
    
    echo "Usuario $nombre ahora pertenece a $nuevo_grupo."
}

# Menú principal
while true; do
    echo "\n1. Crear usuario"
    echo "2. Cambiar de grupo"
    echo "3. Salir"
    read -p "Seleccione una opción: " opcion
    
    case $opcion in
        1) crear_usuario ;;
        2) cambiar_grupo ;;
        3) echo "Saliendo..."; exit 0 ;;
        *) echo "Opción no válida." ;;
    esac
done
