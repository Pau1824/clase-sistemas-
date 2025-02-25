# Función para validar dominio
Validar-Dominio() {
    local domain=$1
    local valid_format="\.com$"

    [[ $domain =~ $valid_format ]]
}

# Solicitar el dominio
while true; do
    read -p "Ingrese el dominio: " domain
    if Validar-Dominio "$domain"; then
        break
    else
        echo "El dominio ingresado no es válido o no termina con '.com'. Intente nuevamente."
    fi
done

echo "$domain"