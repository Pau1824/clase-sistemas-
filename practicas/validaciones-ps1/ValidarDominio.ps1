param (
    [string]$domain
)

$valid_format = ".com$"

if ($domain -match $valid_format) {
    exit 0  # Dominio válido
} else {
    exit 1  # Dominio inválido
}