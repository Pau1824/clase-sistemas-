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
        "Tomcat") 
            tomcat_ramas=( $(curl -s "$url" | grep -oP '(?<=href=")[0-9]+(?=/")' | sort -Vr) )
            versiones=()
            for rama in "${tomcat_ramas[@]}"; do
                sub_url="$url$rama/"
                sub_versiones=( $(curl -s "$sub_url" | grep -oP 'v[0-9]+\.[0-9]+\.[0-9]+(?=/")' | sort -Vr | uniq | head -n 3) )
                versiones+=("${sub_versiones[@]}")
            done
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
# Función para instalar Apache
instalar_apache() {
    elegir_version "Apache" "https://downloads.apache.org/httpd/"
    read -p "Ingrese el puerto en el que desea configurar Apache: " puerto
    sudo apt update && sudo apt install -y apache2
    sudo sed -i "s/Listen 80/Listen $puerto/g" /etc/apache2/ports.conf
    sudo systemctl restart apache2
    echo "Apache instalado y configurado en el puerto $puerto."
}

# Función para instalar Tomcat
instalar_tomcat() {
    elegir_version "Tomcat" "https://downloads.apache.org/tomcat/"
    read -p "Ingrese el puerto en el que desea configurar Tomcat: " puerto
    sudo apt update && sudo apt install -y tomcat9
    sudo sed -i "s/port=\"8080\"/port=\"$puerto\"/g" /etc/tomcat9/server.xml
    sudo systemctl restart tomcat9
    echo "Tomcat instalado y configurado en el puerto $puerto."
}

# Función para instalar Nginx
instalar_nginx() {
    elegir_version "Nginx" "http://nginx.org/en/download.html"
    read -p "Ingrese el puerto en el que desea configurar Nginx: " puerto
    sudo apt update && sudo apt install -y nginx
    sudo sed -i "s/listen 80;/listen $puerto;/g" /etc/nginx/sites-available/default
    sudo systemctl restart nginx
    echo "Nginx instalado y configurado en el puerto $puerto."
}

# Menú de selección de servicio
echo "¿Qué servicio desea instalar?"
echo "1.- Apache"
echo "2.- Tomcat"
echo "3.- Nginx"
echo "4.- Salir"
read -p "Seleccione una opción (1-4): " choice

case $choice in
    1) instalar_apache ;;
    2) instalar_tomcat ;;
    3) instalar_nginx ;;
    4) echo "Saliendo..."; exit 0 ;;
    *) echo "Opción inválida. Saliendo..."; exit 1 ;;
esac