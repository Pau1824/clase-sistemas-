# Importar las funciones desde los archivos
source ./configuracion_ftp.sh
source ./crear_usuario.sh
source ./cambiar_grupo.sh

# Configurar la IP fija antes de iniciar el menú
ip_address="192.168.1.10"
bash configurar_ip.sh "$ip_address"

# Menú interactivo
while true; do
    echo "================================="
    echo "   Gestión de Usuarios FTP"
    echo "================================="
    echo "1. Crear usuario"
    echo "2. Cambiar de grupo"
    echo "3. Salir"
    read -p "Seleccione una opción: " OPCION

    case $OPCION in
        1) bash crear_usuario.sh ;;
        2) bash cambiar_grupo.sh ;;
        3) echo "Saliendo..."; exit 0 ;;
        *) echo "Opción no válida, intente de nuevo." ;;
    esac
done