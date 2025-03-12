#!/bin/bash

# Función para obtener todas las versiones disponibles dinámicamente de la página oficial
elegir_version() {
    local servicio="$1"
    local url="$2"
    echo "Obteniendo versiones disponibles de $servicio..."

    case $servicio in
        "Apache") 
            versiones=( $(curl -s "$url" | grep -oP 'httpd-\K[0-9]+\.[0-9]+\.[0-9]+(?=\.tar\.gz)' | sort -Vr | uniq) )
            ;;
        "Lighttpd") 
            versiones=( $(curl -s "$url" | grep -oP 'lighttpd-\K[0-9]+\.[0-9]+\.[0-9]+(?=\.tar\.xz)' | sort -Vr) )
            ;;
        "Nginx") 
            versiones=( $(curl -s "$url" | grep -oP 'nginx-\K[0-9]+\.[0-9]+\.[0-9]+(?=\.tar\.gz)' | sort -Vr) )
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

# Lista de puertos reservados que el usuario NO puede usar
PUERTOS_RESERVADOS=(21 22 23 53 110 143 161 162 389 443 465 993 995 1433 1434 1521 3306 3389 1 7 9 11 13 15 17 19 137 138 139 2049 3128 6000)

# Verifica si el puerto está disponible
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

instalar_apache() {
    local version
    version=$(elegir_version "Apache" "https://downloads.apache.org/httpd/") || return
    version=$(echo "$version" | tr -d '\r\n')  # Limpia la versión seleccionada
    
    # Verificar que la versión es válida (solo números y puntos)
    if ! [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "Error: La versión seleccionada no es válida."
        exit 1
    fi
    
    check_port

    local url="https://downloads.apache.org/httpd/httpd-${version}.tar.gz"
    echo "Descargando Apache versión $version desde $url..."
    
    wget "$url" -O apache.tar.gz

    if [ ! -s apache.tar.gz ]; then
        echo "Error: La descarga de Apache falló o el archivo está vacío."
        exit 1
    fi

    echo "Extrayendo Apache..."
    tar -xzf apache.tar.gz || { echo "Error al extraer Apache"; exit 1; }

    cd "httpd-${version}" || { echo "Error: No se pudo acceder al directorio de Apache."; exit 1; }

    echo "Instalando dependencias necesarias..."
    sudo apt update
    sudo apt install -y build-essential libpcre3 libpcre3-dev libssl-dev

    echo "Compilando Apache..."
    ./configure --prefix=/usr/local/apache$version --enable-so
    make -j$(nproc)
    sudo make install

    echo "Modificando configuración del puerto..."
    sudo sed -i "s/Listen 80/Listen $puerto/g" /usr/local/apache$version/conf/httpd.conf

    echo "Iniciando Apache..."
    sudo /usr/local/apache$version/bin/apachectl start

    echo "Configurando firewall para permitir tráfico en el puerto $puerto..."
    if command -v ufw &> /dev/null; then
        sudo ufw allow "$puerto"/tcp
    else
        echo "UFW no está instalado, asegúrese de permitir el puerto manualmente."
    fi

    echo "Apache versión $version instalado, configurado en el puerto $puerto y ejecutándose."
}

# Función para instalar Lighttpd
instalar_lighttpd() {
    local version
    version=$(elegir_version "Lighttpd" "https://download.lighttpd.net/lighttpd/releases-1.4.x/") || return
    check_port
    local url="https://download.lighttpd.net/lighttpd/releases-1.4.x/lighttpd-${version}.tar.xz"

    echo "Descargando Lighttpd versión $version desde $url..."
    wget "$url" -O lighttpd.tar.xz

    echo "Extrayendo Lighttpd..."
    tar -xf lighttpd.tar.xz
    cd "lighttpd-${version}" || exit

    echo "Compilando Lighttpd..."
    ./configure --prefix=/usr/local/lighttpd$version
    make
    sudo make install

    echo "Lighttpd versión $version instalado en /usr/local/lighttpd$version"
}

# Función para instalar Nginx
instalar_nginx() {
    local version
    version=$(elegir_version "Nginx" "http://nginx.org/en/download.html") || return
    check_port
    local url="http://nginx.org/download/nginx-${version}.tar.gz"

    echo "Descargando Nginx versión $version desde $url..."
    wget "$url" -O nginx.tar.gz

    echo "Extrayendo Nginx..."
    tar -xzf nginx.tar.gz
    cd "nginx-${version}" || exit

    echo "Compilando Nginx..."
    ./configure --prefix=/usr/local/nginx$version
    make
    sudo make install

    echo "Nginx versión $version instalado en /usr/local/nginx$version"
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
