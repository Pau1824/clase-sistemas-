#!/bin/bash

# Verificar si se ejecuta como root
if [[ $EUID -ne 0 ]]; then
   echo "Este script debe ejecutarse como root." 
   exit 1
fi

# Funcion para obtener versiones desde la web
obtener_versiones() {
    local servicio="$1"
    local url="$2"
    echo "Obteniendo versiones disponibles de $servicio..."
    
    # Descargar la pagina y extraer versiones
    local versiones=( $(curl -s "$url" | grep -oP '(\d+\.\d+\.\d+)' | sort -Vr | uniq) )

    if [ ${#versiones[@]} -eq 0 ]; then
        echo "No se encontraron versiones disponibles para $servicio."
        return 1
    fi

    echo "Seleccione la version de $servicio:"
    select version in "${versiones[@]}"; do
        if [[ -n "$version" ]]; then
            echo "Selecciono la version $version"
            echo "$version"
            return 0
        else
            echo "Opcion invalida. Intente de nuevo."
        fi
    done
}

# Funcion para solicitar el puerto de instalacion
solicitar_puerto() {
    local puerto
    while true; do
        read -p "Ingrese el puerto en el que desea configurar el servicio: " puerto
        if [[ "$puerto" =~ ^[0-9]+$ && $puerto -gt 0 && $puerto -lt 65536 ]]; then
            echo "$puerto"
            return 0
        else
            echo "Por favor, ingrese un numero de puerto valido (1-65535)."
        fi
    done
}

# Función para instalar Apache
instalar_apache() {
    local version
    version=$(obtener_versiones "Apache" "https://downloads.apache.org/httpd/") || version="2.4.58"

    local puerto
    puerto=$(solicitar_puerto)

    echo "Instalando Apache version $version..."
    sudo apt update && sudo apt install -y apache2
    sudo sed -i "s/Listen 80/Listen $puerto/g" /etc/apache2/ports.conf
    sudo systemctl restart apache2
    echo "Apache instalado y configurado en el puerto $puerto."
}

# Funcion para instalar Tomcat
instalar_tomcat() {
    local version
    version=$(obtener_versiones "Tomcat" "https://downloads.apache.org/tomcat/tomcat-9/") || version="9.0.73"

    local puerto
    puerto=$(solicitar_puerto)

    echo "Instalando Tomcat version $version..."
    sudo apt update && sudo apt install -y tomcat9
    sudo sed -i "s/port=\"8080\"/port=\"$puerto\"/g" /etc/tomcat9/server.xml
    sudo systemctl restart tomcat9
    echo "Tomcat instalado y configurado en el puerto $puerto."
}

# Funcion para instalar Nginx
instalar_nginx() {
    local version
    version=$(obtener_versiones "Nginx" "https://nginx.org/download/") || version="1.24.0"

    local puerto
    puerto=$(solicitar_puerto)

    echo "Instalando Nginx version $version..."
    sudo apt update && sudo apt install -y nginx
    sudo sed -i "s/listen 80;/listen $puerto;/g" /etc/nginx/sites-available/default
    sudo systemctl restart nginx
    echo "Nginx instalado y configurado en el puerto $puerto."
}

# Menu de seleccion de servicio
while true; do
    echo "Que servicio desea instalar?"
    echo "1.- Apache"
    echo "2.- Tomcat"
    echo "3.- Nginx"
    echo "4.- Salir"
    read -p "Seleccione una opcion (1-4): " choice

    case $choice in
        1) instalar_apache ;;
        2) instalar_tomcat ;;
        3) instalar_nginx ;;
        4) echo "Saliendo..."; exit 0 ;;
        *) echo "Opcion invalida. Intente de nuevo." ;;
    esac
done
