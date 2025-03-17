#!/bin/bash

source "./menu_http.sh"
source "./obtener_version.sh"
source "./solicitar_ver.sh"
source "./solicitar_puerto.sh"
source "./conf_http.sh"

if [[ $EUID -ne 0 ]]; then
    echo "Este script debe ejecutarse como root" 
    exit 1
fi

sudo apt install net-tools -y > /dev/null 2>&1

preguntar_ssl() {
    local respuesta
    while true; do
        read -p "¿Quieres activar SSL? (s/n): " respuesta
        respuesta=$(echo "$respuesta" | tr '[:upper:]' '[:lower:]')
        if [[ "$respuesta" == "s" || "$respuesta" == "n" ]]; then
            echo "$respuesta"
            return
        else
            echo "Entrada no válida. Debes ingresar 's' o 'n'." >&2
        fi
    done
}

while true; do
    menu_http
    read -p "Seleccione el servicio HTTP que queria instalar y configurar: " op
            
    if [ "$op" -eq 1 ]; then
        versions=$(obtener_version "Apache")
        stable=$(echo "$versions" | head -1)
        menu_http2 "Apache" "$stable" " "
        echo "Elija una version: "
        op2=$(solicitar_ver "Apache") 
        if [ "$op2" -eq 1 ]; then
            port=$(solicitar_puerto)
            if [[ -z "$port" ]]; then
                continue
            fi
            ssl=$(preguntar_ssl)
            conf_apache "$port" "$stable" "$ssl"
        elif [ "$op2" -eq 2 ]; then
            continue
        fi
    elif [ "$op" -eq 3 ]; then
        versions=$(obtener_version "Nginx")
        stable=$(echo "$versions" | tail -n 2 | head -1)
        mainline=$(echo "$versions" | tail -1)
        menu_http2 "Nginx" "$stable" "$mainline"
        echo "Elija una version: "
        op2=$(solicitar_ver "Nginx")
        if [ "$op2" -eq 1 ]; then  
            port=$(solicitar_puerto)
            if [[ -z "$port" ]]; then
                continue
            fi
            ssl=$(preguntar_ssl)
            conf_nginx "$port" "$stable" "$ssl"
        elif [ "$op2" -eq 2 ]; then
            port=$(solicitar_puerto)
            if [[ -z "$port" ]]; then
                continue
            fi
            ssl=$(preguntar_ssl)
            conf_nginx "$port" "$mainline" "$ssl"
        elif [ "$op2" -eq 3 ]; then
            continue
        fi
    elif [ "$op" -eq 2 ]; then
        versions=$(obtener_version "OpenLiteSpeed")
        stable=$(echo "$versions" | tail -n 2 | head -1)
        mainline=$(echo "$versions" | tail -1)
        menu_http2 "OpenLiteSpeed" "$stable" "$mainline"
        echo "Elija una version: "
        op2=$(solicitar_ver "OpenLiteSpeed")
        if [ "$op2" -eq 1 ]; then
            port=$(solicitar_puerto)
            if [[ -z "$port" ]]; then
                continue
            fi
            ssl=$(preguntar_ssl)
            conf_litespeed "$port" "$stable" "$ssl"
        elif [ "$op2" -eq 2 ]; then 
            port=$(solicitar_puerto)
            if [[ -z "$port" ]]; then
                continue
            fi
            ssl=$(preguntar_ssl)
            conf_litespeed "$port" "$mainline" "$ssl"
        elif [ "$op2" -eq 3 ]; then
            continue
        fi
    elif [ "$op" -eq 4 ]; then
        echo "Saliendo..."
        exit 0
    else
        echo "Opción no válida"
    fi
done