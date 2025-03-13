menu_http(){
    echo "--- SERVICIOS HTTP ---"
    echo "1. Apache"
    echo "2. Nginx"
    echo "3. OpenLiteSpeed"
    echo "4. Salir"
}

menu_http2(){
    local service="$1"
    local stable="$2"
    local mainline="$3"
    echo "--- $service ---"
    
    if [ "$service" = "Apache" ]; then
        echo "1. Versión Estable - $stable"
        echo "2. Versión de Desarrollo no Disponible - 2 para Regresar"
    elif [ "$service" = "Nginx" ] || [ "$service" = "OpenLiteSpeed" ]; then
        echo "1. Versión Estable - $stable"
        echo "2. Versión Mainline (En desarrollo) - $mainline"
        echo "3. Regresar"
    else 
        echo "Opción no válida"
        exit 1
    fi
}