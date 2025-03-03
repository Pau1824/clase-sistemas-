# Obtener la IP del servidor
ip_address=$(bash pedir_ip_servidor.sh)

# Obtener la IP inicial del rango
ip_inicio=$(bash pedir_ip_inicio.sh)

# Obtener la última IP del rango
ip_fin=$(bash pedir_ip_fin.sh)

# Configurar IP estática
bash configurar_ip.sh "$ip_address"

# Configurar DHCP
bash configurar_dhcp.sh "$ip_address" "$ip_inicio" "$ip_fin"