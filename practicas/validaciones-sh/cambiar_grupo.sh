
cambiar_grupo() {
    read -p "Ingrese el nombre del usuario que quiere cambiar de grupo: " USERNAME

    # Verificar si el usuario existe
    if ! id "$USERNAME" &>/dev/null; then
        echo "El usuario '$USERNAME' no existe."
        return
    fi

    read -p "Desea cambiar a (1) Reprobado o (2) Recursador? (1/2): " NUEVO_GRUPO

    if [[ "$NUEVO_GRUPO" == "1" ]]; then
        NUEVO_GRUPO_NOMBRE="reprobados"
        VIEJO_GRUPO_NOMBRE="recursadores"
    elif [[ "$NUEVO_GRUPO" == "2" ]]; then
        NUEVO_GRUPO_NOMBRE="recursadores"
        VIEJO_GRUPO_NOMBRE="reprobados"
    else
        echo "Opción no válida. Volviendo al menú..."
        return
    fi

    # Desmontar el grupo anterior si existía
    sudo umount /srv/ftp/$USERNAME/$VIEJO_GRUPO_NOMBRE

    # Montar la nueva carpeta del grupo
    sudo mkdir -p /srv/ftp/$USERNAME/$NUEVO_GRUPO_NOMBRE
    sudo mount --bind /srv/ftp/$NUEVO_GRUPO_NOMBRE /srv/ftp/$USERNAME/$NUEVO_GRUPO_NOMBRE

    # Actualizar /etc/fstab para cambios persistentes
    sudo sed -i "/\/srv\/ftp\/$USERNAME\/$VIEJO_GRUPO_NOMBRE/d" /etc/fstab
    echo "/srv/ftp/$NUEVO_GRUPO_NOMBRE /srv/ftp/$USERNAME/$NUEVO_GRUPO_NOMBRE none bind 0 0" | sudo tee -a /etc/fstab

    echo "El usuario '$USERNAME' ha sido cambiado a '$NUEVO_GRUPO_NOMBRE'."
}
