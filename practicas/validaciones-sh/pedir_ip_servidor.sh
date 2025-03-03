source validar_ip.sh

while true; do
    read -p "Ingrese la dirección IP del servidor DNS: " ip_address
    if Validar-IP "$ip_address"; then
        break
    else
        echo "La dirección IP ingresada no es válida. Inténtelo nuevamente."
    fi
done

echo "$ip_address"