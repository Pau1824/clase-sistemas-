# Importar las funciones desde los archivos
source ./configuracion_ftp.sh
source ./crear_usuario.sh
source ./cambiar_grupo.sh

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
        1) read USERNAME GRUPO_NOMBRE <<< "$(bash crear_usuario.sh)"
            bash configuracion_ftp.sh "$USERNAME" "$GRUPO_NOMBRE"
            ;;
        2) cambiar_grupo ;;
        3) echo "Saliendo..."; exit 0 ;;
        *) echo "Opción no válida, intente de nuevo." ;;
    esac
done