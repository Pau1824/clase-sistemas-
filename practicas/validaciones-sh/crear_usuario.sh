
crear_usuario() {
    read -p "Ingrese el nombre del usuario: " USERNAME
    read -s -p "Ingrese la contraseña: " PASSWORD
    echo
    read -p "El usuario es (1) Reprobado o (2) Recursador? (1/2): " GRUPO

    # Determinar el grupo
    if [[ "$GRUPO" == "1" ]]; then
        GRUPO_NOMBRE="reprobados"
    elif [[ "$GRUPO" == "2" ]]; then
        GRUPO_NOMBRE="recursadores"
    else
        echo "Opción no válida. Volviendo al menú..."
        return
    fi

    # Crear usuario si no existe
    if id "$USERNAME" &>/dev/null; then
        echo "El usuario '$USERNAME' ya existe."
        return
    fi

    echo "Creando usuario '$USERNAME'..."
    sudo adduser --home /srv/ftp/$USERNAME --shell /usr/sbin/nologin --disabled-password $USERNAME
    echo "$USERNAME:$PASSWORD" | sudo chpasswd

    # Configuración general
    source configuracion_ftp.sh "$USERNAME" "$GRUPO_NOMBRE"

    echo "Usuario '$USERNAME' creado correctamente como '$GRUPO_NOMBRE'."
}
