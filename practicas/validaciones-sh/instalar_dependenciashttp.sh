#!/bin/bash
instalar_dependenciashttp(){ 
    # Actualizar lista de paquetes
    sudo apt update -y > /dev/null 2>&1
    
    # Lista de dependencias necesarias
    dependencias=("libapr1" "libapr1-dev" "libaprutil1" "libaprutil1-dev" "build-essential" "wget" "libpcre3" "libpcre3-dev" "libssl-dev" "zlib1g-dev")

    # Verificar e instalar cada dependencia si no está instalada
    for paquete in "${dependencias[@]}"; do
        if ! dpkg -l | grep -qw "$paquete"; then
            sudo apt-get install -y "$paquete" > /dev/null 2>&1
        fi
    done
}