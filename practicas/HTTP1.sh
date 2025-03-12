#!/bin/bash

# Función para obtener todas las versiones disponibles dinámicamente de la página oficial
elegir_version() {
    local servicio="$1"
    local url="$2"
    echo "Obteniendo versiones disponibles de $servicio..."
    
    case $servicio in
        "Apache") 
            versiones=( $(curl -s "$url" | grep -oP 'httpd-\K[0-9]+\.[0-9]+\.[0-9]+(?=\.tar\.gz)' | sort -Vr | uniq | head -n 1) )
            ;;
        "Lighttpd") 
            versiones=( $(curl -s "$url" | grep -oP 'lighttpd-\K[0-9]+\.[0-9]+\.[0-9]+(?=\.tar\.xz)' | sort -Vr | head -n 1) )
            ;;
        "Nginx") 
            versiones=( $(curl -s "$url" | grep -oP 'nginx-\K[0-9]+\.[0-9]+\.[0-9]+(?=\.tar\.gz)' | sort -Vr | uniq | head -n 2) )
            ;;
    esac

    if [ ${#versiones[@]} -eq 0 ]; then
        echo "No se encontraron versiones disponibles para $servicio."
        return 1
    fi

    echo "Seleccione la versión de $servicio:"
    select version in "${versiones[@]}"; do
        if [[ -n "$version" ]]; then
            echo "Seleccionó la versión $version"
            break
        else
            echo "Opción inválida. Intente de nuevo."
        fi
    done
}

# Verifica si el puerto está disponible
PUERTOS_RESERVADOS=(21 22 23 53 110 143 161 162 389 443 465 993 995 1433 1434 1521 3306 3389 1 7 9 11 13 15 17 19 137 138 139 2049 3128 6000)

check_port() {
    while true; do
        read -p "Ingrese el puerto en el que desea instalar: " puerto

        # Revisar si el puerto está en la lista de reservados
        if [[ " ${PUERTOS_RESERVADOS[@]} " =~ " $puerto " ]]; then
            echo "Error: El puerto $puerto está reservado y no se puede usar."
            continue
        fi

        # Revisar si el puerto está en uso
        if sudo netstat -tuln | grep -q ":$puerto "; then
            echo "El puerto $puerto ya está en uso. Intente con otro."
        else
            echo "El puerto $puerto está disponible."
            break
        fi
    done
}

# Función para instalar Apache con la versión específica
instalar_apache() {
    elegir_version "Apache" "https://downloads.apache.org/httpd/" || return
    check_port
    sudo apt update
    sudo apt install -y apache2="$version"

    # Configurar el puerto
    sudo sed -i "s/Listen 80/Listen $puerto/g" /etc/apache2/ports.conf
    sudo sed -i "s/<VirtualHost \*:80>/<VirtualHost \*:$puerto>/g" /etc/apache2/sites-available/000-default.conf

    sudo systemctl restart apache2
    echo "Apache versión $version instalado y configurado en el puerto $puerto."
}

# Función para instalar Lighttpd con la versión específica
instalar_lighttpd() {
    elegir_version "Lighttpd" "https://download.lighttpd.net/lighttpd/releases-1.4.x/" || return
    check_port

    # Generar el link de descarga
    url_descarga="https://download.lighttpd.net/lighttpd/releases-1.4.x/lighttpd-$version.tar.xz"

    echo "Descargando Lighttpd versión $version desde $url_descarga..."
    wget -O lighttpd.tar.xz "$url_descarga"

    if [[ ! -f lighttpd.tar.xz ]]; then
        echo "Error: No se pudo descargar Lighttpd."
        return
    fi

    echo "Descomprimiendo..."
    tar -xf lighttpd.tar.xz
    cd "lighttpd-$version" || return

    echo "Compilando e instalando..."
    ./configure
    make
    sudo make install

    echo "Configurando Lighttpd..."
    sudo mkdir -p /usr/local/etc/lighttpd
    sudo cp doc/config/lighttpd.conf /usr/local/etc/lighttpd/

    # Modificar el puerto
    sudo sed -i "s/server.port\s*=\s*80/server.port = $puerto/" /usr/local/etc/lighttpd/lighttpd.conf

    # Crear el servicio de systemd
    echo "Creando el servicio systemd..."
    sudo bash -c 'cat > /etc/systemd/system/lighttpd.service <<EOF
[Unit]
Description=Lighttpd Web Server
After=network.target

[Service]
ExecStart=/usr/local/sbin/lighttpd -D -f /usr/local/etc/lighttpd/lighttpd.conf
ExecReload=/bin/kill -HUP $MAINPID
KillMode=mixed
Restart=always

[Install]
WantedBy=multi-user.target
EOF'

    echo "Reiniciando systemd..."
    sudo systemctl daemon-reload
    sudo systemctl enable lighttpd
    sudo systemctl start lighttpd

    echo "Lighttpd versión $version instalado y configurado en el puerto $puerto."

}

# Función para instalar Nginx con la versión específica
instalar_nginx() {
    elegir_version "Nginx" "http://nginx.org/en/download.html" || return
    check_port
    sudo apt update
    sudo apt install -y nginx="$version"

    # Configurar el puerto en todas las líneas donde se usa
    sudo sed -i "s/listen 80;/listen $puerto;/g" /etc/nginx/sites-available/default
    sudo sed -i "s/listen \[::\]:80;/listen \[::\]:$puerto;/g" /etc/nginx/sites-available/default
    sudo sed -i "s/listen 443 ssl;/listen $puerto ssl;/g" /etc/nginx/sites-available/default
    sudo sed -i "s/listen \[::\]:443 ssl;/listen \[::\]:$puerto ssl;/g" /etc/nginx/sites-available/default

    sudo nginx -t && sudo systemctl restart nginx
    echo "Nginx versión $version instalado y configurado en el puerto $puerto."
}


# Menú de selección de servicio
echo "¿Qué servicio desea instalar?"
echo "1.- Apache"
echo "2.- Lighttpd"
echo "3.- Nginx"
echo "4.- Salir"
read -p "Seleccione una opción (1-4): " choice

case $choice in
    1) instalar_apache ;;
    2) instalar_lighttpd ;;
    3) instalar_nginx ;;
    4) echo "Saliendo..."; exit 0 ;;
    *) echo "Opción inválida. Saliendo..."; exit 1 ;;
esac