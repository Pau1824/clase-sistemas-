function Validar-IP {
    param (
        [string]$ip_address
    )
    $valid_format = "^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
    return $ip_address -match $valid_format
}