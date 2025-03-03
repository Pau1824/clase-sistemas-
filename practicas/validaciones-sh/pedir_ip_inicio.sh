source validar_ip.sh

while true; do
    read -p "Ingrese la IP de inicio del rango DHCP: " ip_inicio
    if Validar-IP "$ip_inicio"; then
        break
    else
        echo "La IP ingresada no es válida. Inténtelo de nuevo."
    fi
done

echo "$ip_inicio"