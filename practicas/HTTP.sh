#!/bin/bash

# Verifica si el usuario es root
if [[ $EUID -ne 0 ]]; then
   echo "Este script debe ejecutarse como root." 
   exit 1
fi

# Función para obtener versiones de Apache
obtener_versiones_apache() {
    echo "Obteniendo versiones de Apache..."
    local url="https://httpd.apache.org/download.cgi"
    
    # Descargamos el contenido de la página y lo guardamos temporalmente para debug
    local contenido
    contenido=$(curl -s "$url")
    # Puedes descomentar la siguiente línea para guardar el HTML y revisarlo:
    echo "$contenido" > /tmp/apache_download.html

    # Usamos grep para extraer nombres de archivo que sigan el patrón y luego filtramos
    local versiones
    versiones=$(echo "$contenido" | grep -oP 'httpd-\d+\.\d+\.\d+\.tar\.bz2' | \
                sed -E 's/httpd-([0-9.]+)\.tar\.bz2/\1/' | sort -Vr | uniq)

    # Para debug: mostramos las versiones encontradas
    echo "DEBUG: Versiones encontradas:"
    echo "$versiones"

    # Imprimimos el resultado final (para capturarlo en un array con read)
    echo "$versiones"
}

# Función para obtener versiones de Tomcat
obtener_versiones_tomcat() {
    echo "Obteniendo versiones de Tomcat..."
    local contenido
    contenido=$(curl -s "https://archive.apache.org/dist/tomcat/")
    # Guardar para revisar si es necesario:
    echo "$contenido" > /tmp/tomcat_download.html

    local versiones
    versiones=$(echo "$contenido" | grep -oP 'tomcat-\d+/' | sed 's|/$||' | sort -Vr | uniq)
    echo "DEBUG: Versiones de Tomcat encontradas:"
    echo "$versiones"
    echo "$versiones"
}

# Función para obtener versiones de Nginx
obtener_versiones_nginx() {
    echo "Obteniendo versiones de Nginx..."
    local contenido
    contenido=$(curl -s "https://nginx.org/en/download.html")
    echo "$contenido" > /tmp/nginx_download.html

    local versiones
    versiones=$(echo "$contenido" | grep -oP 'nginx-\d+\.\d+\.\d+\.tar\.gz' | sort -Vr | uniq)
    echo "DEBUG: Versiones de Nginx encontradas:"
    echo "$versiones"
    echo "$versiones"
}

# Función para seleccionar una versión
seleccionar_version() {
    local servicio="$1"
    shift
    local versiones=("$@")
    if [ ${#versiones[@]} -eq 0 ]; then
        echo "No se encontraron versiones disponibles para $servicio."
        return 1
    fi

    echo "Seleccione la versión de $servicio:"
    select version in "${versiones[@]}"; do
        if [[ -n "$version" ]]; then
            echo "Seleccionó la versión $version"
            echo "$version"
            return 0
        else
            echo "Opción inválida. Intente de nuevo."
        fi
    done
}

# Función para solicitar un puerto
solicitar_puerto() {
    local puerto
    while true; do
        read -p "Ingrese el puerto en el que desea configurar el servicio: " puerto
        if [[ "$puerto" =~ ^[0-9]+$ && $puerto -gt 0 && $puerto -lt 65536 ]]; then
            echo "$puerto"
            return 0
        else
            echo "Por favor, ingrese un número de puerto válido (1-65535)."
        fi
    done
}

# Función para instalar Apache
instalar_apache() {
    # Capturamos la salida en un array
    read -ra versiones <<< "$(obtener_versiones_apache)"
    # Verificamos si se obtuvo algo
    if [ ${#versiones[@]} -eq 0 ]; then
        echo "No se pudo obtener ninguna versión de Apache. Revisa el patrón o el contenido HTML."
        return 1
    fi
    local version
    version=$(seleccionar_version "Apache" "${versiones[@]}") || return 1
    local puerto
    puerto=$(solicitar_puerto)

    echo "Descargando Apache versión $version..."
    wget "https://downloads.apache.org/httpd/httpd-$version.tar.bz2" -P /tmp/

    echo "Instalando Apache..."
    apt update && apt install -y apache2
    sed -i "s/Listen 80/Listen $puerto/g" /etc/apache2/ports.conf
    systemctl restart apache2
    echo "Apache instalado en el puerto $puerto."
}

# Función para instalar Tomcat
instalar_tomcat() {
    read -ra versiones <<< "$(obtener_versiones_tomcat)"
    if [ ${#versiones[@]} -eq 0 ]; then
        echo "No se pudo obtener ninguna versión de Tomcat."
        return 1
    fi
    local version
    version=$(seleccionar_version "Tomcat" "${versiones[@]}") || return 1
    local puerto
    puerto=$(solicitar_puerto)

    echo "Descargando Tomcat versión $version..."
    # Aquí se usa un ejemplo; en la práctica, deberías adaptar la URL según la versión elegida
    wget "https://archive.apache.org/dist/tomcat/$version/bin/apache-tomcat-9.0.73.tar.gz" -P /tmp/

    echo "Instalando Tomcat..."
    apt update && apt install -y tomcat9
    sed -i "s/port=\"8080\"/port=\"$puerto\"/g" /etc/tomcat9/server.xml
    systemctl restart tomcat9
    echo "Tomcat instalado en el puerto $puerto."
}

# Función para instalar Nginx
instalar_nginx() {
    read -ra versiones <<< "$(obtener_versiones_nginx)"
    if [ ${#versiones[@]} -eq 0 ]; then
        echo "No se pudo obtener ninguna versión de Nginx."
        return 1
    fi
    local version
    version=$(seleccionar_version "Nginx" "${versiones[@]}") || return 1
    local puerto
    puerto=$(solicitar_puerto)

    echo "Descargando Nginx versión $version..."
    wget "https://nginx.org/download/$version" -P /tmp/

    echo "Instalando Nginx..."
    apt update && apt install -y nginx
    sed -i "s/listen 80;/listen $puerto;/g" /etc/nginx/sites-available/default
    systemctl restart nginx
    echo "Nginx instalado en el puerto $puerto."
}

# Menú de selección de servicio
while true; do
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
        *) echo "Opción inválida. Intente de nuevo." ;;
    esac
done
