source validar_ip.sh

while true; do
    read -p "Ingrese la IP de fin del rango DHCP: " ip_fin
    if Validar-IP "$ip_fin"; then
        fin_octeto=$(echo "$ip_fin" | awk -F. '{print $4}')
        inicio_octeto=$(echo "$ip_inicio" | awk -F. '{print $4}')
        if (( fin_octeto > inicio_octeto )); then
            break
        else
            echo "La IP final debe tener el último octeto mayor que la IP inicial."
        fi
    else
        echo "La IP ingresada no es válida. Inténtelo de nuevo."
    fi
done

echo "$ip_fin"