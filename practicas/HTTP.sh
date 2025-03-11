#!/bin/bash

# Verifica si curl y jq están instalados
check_dependencies() {
    for pkg in curl jq; do
        if ! command -v $pkg &>/dev/null; then
            echo "Instalando $pkg..."
            sudo apt install -y $pkg
        fi
    done
}

# Función para verificar si el puerto está disponible
check_port() {
    while true; do
        read -p "Ingrese el puerto en el que desea instalar: " port
        if ! sudo netstat -tuln | grep -q ":$port "; then
            echo "El puerto $port está disponible."
            break
        else
            echo "El puerto $port está en uso. Intente con otro."
        fi
    done
}

# Función para obtener versiones de Apache desde su página oficial
get_apache_versions() {
    echo "Obteniendo versiones de Apache..."
    curl -s https://downloads.apache.org/httpd/ | grep -oP 'httpd-\K[0-9]+\.[0-9]+\.[0-9]+' | sort -V | uniq | tail -5
}

# Función para obtener versiones de Tomcat desde su página oficial
get_tomcat_versions() {
    echo "Obteniendo versiones de Tomcat..."
    curl -s https://downloads.apache.org/tomcat/ | grep -oP '(?<=href=")[0-9]+(?=/")' | sort -V | tail -5
}

# Función para obtener versiones de Nginx desde su página oficial
get_nginx_versions() {
    echo "Obteniendo versiones de Nginx..."
    curl -s http://nginx.org/en/download.html | grep -oP 'nginx-\K[0-9]+\.[0-9]+\.[0-9]+' | sort -V | tail -5
}

# Instalación de Apache
install_apache() {
    versions=$(get_apache_versions)
    echo "Seleccione la versión de Apache:"
    echo "$versions"
    read -p "Ingrese la versión de Apache: " apache_version

    check_port

    echo "Instalando Apache versión $apache_version en el puerto $port..."
    sudo apt update -y
    sudo apt install -y apache2
    sudo sed -i "s/Listen 80/Listen $port/" /etc/apache2/ports.conf
    sudo systemctl restart apache2
    echo "Apache $apache_version instalado en el puerto $port."
}

# Instalación de Tomcat
install_tomcat() {
    versions=$(get_tomcat_versions)
    echo "Seleccione la versión de Tomcat:"
    echo "$versions"
    read -p "Ingrese la versión de Tomcat: " tomcat_version

    check_port

    echo "Instalando Tomcat versión $tomcat_version en el puerto $port..."
    sudo apt update -y
    sudo apt install -y tomcat$tomcat_version
    sudo sed -i "s/Connector port=\"8080\"/Connector port=\"$port\"/" /etc/tomcat$tomcat_version/server.xml
    sudo systemctl restart tomcat$tomcat_version
    echo "Tomcat $tomcat_version instalado en el puerto $port."
}

# Instalación de Nginx
install_nginx() {
    versions=$(get_nginx_versions)
    echo "Seleccione la versión de Nginx:"
    echo "$versions"
    read -p "Ingrese la versión de Nginx: " nginx_version

    check_port

    echo "Instalando Nginx versión $nginx_version en el puerto $port..."
    sudo apt update -y
    sudo apt install -y nginx
    sudo sed -i "s/listen 80;/listen $port;/" /etc/nginx/sites-available/default
    sudo systemctl restart nginx
    echo "Nginx $nginx_version instalado en el puerto $port."
}

# Menú principal
main_menu() {
    echo "Seleccione el servicio a instalar:"
    echo "1) Apache"
    echo "2) Tomcat"
    echo "3) Nginx"
    read -p "Ingrese su opción: " choice

    case $choice in
        1) install_apache ;;
        2) install_tomcat ;;
        3) install_nginx ;;
        *) echo "Opción no válida"; exit 1 ;;
    esac
}

# Ejecutar el script
check_dependencies
main_menu
