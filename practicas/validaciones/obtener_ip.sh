# Función para validar IP
Validar-IP() {
    local ip_address=$1
    local valid_format="^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"

    [[ $ip_address =~ $valid_format ]]
}

# Solicitar la dirección IP del servidor DNS
while true; do
    read -p "Ingrese la dirección IP del servidor DNS: " ip_address
    if Validar-IP "$ip_address"; then
        break
    else
        echo "La dirección IP ingresada no es válida. Intente nuevamente."
    fi
done

echo "$ip_address"