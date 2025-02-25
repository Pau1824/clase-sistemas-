# Importar las funciones desde los archivos
source ./validaciones/obtener_ip.sh
source ./validaciones/obtener_dominio.sh
source ./validaciones/configurar_ip.sh
source ./validaciones/configuracion_dns.sh

# Obtener la IP
ip_address=$(bash obtener_ip.sh)

# Obtener el dominio
domain=$(bash obtener_dominio.sh)

# Configurar IP estática
bash configurar_ip.sh "$ip_address"

# Configuración DNS
bash configuracion_dns.sh "$ip_address" "$domain"