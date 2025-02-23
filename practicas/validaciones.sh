# Función para validar una dirección IP
validar_ip() {
    local ip_address=$1
    local valid_format='^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
    [[ $ip_address =~ $valid_format ]]
}

# Función para validar un dominio
validar_dominio() {
    local domain=$1
    local valid_format='^([a-zA-Z0-9]+(-[a-zA-Z0-9]+)*\.)+[a-zA-Z]{2,}$'
    [[ $domain =~ $valid_format ]]
}
