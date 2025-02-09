function Backup-Registry {
    Param(
        [Parameter(Mandatory = $true)]
        [string]$rutaBackup
        )

    if (!(Test-Path -Path $rutaBackup)) {
    New-Item -ItemType Directory -Path $rutaBackup | Out-Null
    }

    $nombreArchivo = "Back-Registry_" + (Get-Date -Format "yyyy-MM-dd_mm-ss") + ".reg"
    $rutaArchivo = Join-Path -Path $rutaBackup -ChildPath $nombreArchivo

    try {
        Write-Host "Realizando backup del registro del sistema en $rutaArchivo..."
        reg export HKLM $rutaArchivo
        Write-Host "El backup del registro del sistema se ha realizado con exito."
    }
    catch {
        Write-Host "Se ha producido un error al realizar el backup del registro del sistema: $_"
    }
}

$logDirectory = "C:\Ing. Software\6 Semestre\Administracion de sistemas"
$logFile = Join-Path $logDirectory "backup-registry_log.txt"
$logEntry = "$(Get-Date) - $env:USERNAME - Backup - $backupPath"
if (!(Test-Path $logDirectory)) {
    New-Item -ItemType Directory -Path $logDirectory | Out-Null
}
Add-Content -Path $logFile -Value $logEntry

$backupCount = 10
$backups = Get-ChildItem $backupDirectory -Filter *.reg | Sort-Object LastWriteTime -Descending
if ($backups.Count -gt $backupCount) {
    $backupsToDelete = $backups[$backupCount..($backups.Count - 1)]
    $backupsToDelete | Remove-Item -Force
}



$env:PSModulePath
cd ..
CD C:\Program Files\WindowsPowerShell\Modules
ls


$Time = New-ScheduledTaskTrigger -At 02:00 -Daily
$PS = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-Command `"Import-Module BackupRegistry -Force;
Backup-Registry - rutaBackup 'D:\tmp\Backups\Registry'`""
Register-ScheduledTask -TaskName "Ejecutar Backup del registro del sistema" -Trigger $Time -Action $PS