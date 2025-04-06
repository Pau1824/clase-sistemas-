function Configurarini($lines, $section, $key, $value){
    $sectionIndex = $lines.IndexOf("[$section]")
    if($sectionIndex -lt 0) {
        $lines += "[$section]", "$key=$value"
    } else {
        $i = $sectionIndex + 1
        $found = $false
        while ($i -lt $lines.Length -and $lines[$i] -notmatch "^\[.*\]"){
            if ($lines[$i] -match "^$key="){
                $lines[$i] = "$key=$value"
                $found = $true
                break
            }
            $i++
        }
        if(-not $found){
            $lines = @(
                $lines[0..$sectionIndex]
                "$key=$value"
                $lines[($sectionIndex + 1)..($lines.Length - 1)]
            )
        }
    }
    return $lines
}