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
check_port() {
    while true; do
        read -p "Ingrese el puerto en el que desea instalar: " puerto
        if ! sudo netstat -tuln | grep -q ":$puerto "; then
            echo "El puerto $puerto está disponible."
            break
        else
            echo "El puerto $puerto está en uso. Intente con otro."
        fi
    done
}

# Función para instalar Apache
instalar_apache() {
    elegir_version "Apache" "https://downloads.apache.org/httpd/" || return
    check_port
    sudo apt update && sudo apt install -y apache2
    sudo sed -i "s/Listen 80/Listen $puerto/g" /etc/apache2/ports.conf
    sudo systemctl restart apache2
    echo "Apache instalado y configurado en el puerto $puerto."
}

# Función para instalar Lighttpd
instalar_lighttpd() {
    elegir_version "Lighttpd" "https://download.lighttpd.net/lighttpd/releases-1.4.x/" || return
    check_port
    sudo apt update && sudo apt install -y lighttpd
    sudo sed -i "s/server.port\s*=\s*80/server.port = $puerto/" /etc/lighttpd/lighttpd.conf
    sudo systemctl restart lighttpd
    echo "Lighttpd instalado y configurado en el puerto $puerto."
}

# Función para instalar Nginx
instalar_nginx() {
    elegir_version "Nginx" "http://nginx.org/en/download.html" || return
    check_port
    sudo apt update && sudo apt install -y nginx
    sudo sed -i "s/listen 80;/listen $puerto;/g" /etc/nginx/sites-available/default
    sudo systemctl restart nginx
    echo "Nginx instalado y configurado en el puerto $puerto."
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