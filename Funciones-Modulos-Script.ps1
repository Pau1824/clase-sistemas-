#Tema 6. Funciones
Get-Verb
function Get-Fecha
{
Get-Date
}
Get-Fecha
Get-ChildItem -Path Function:\Get-*

function Get-Resta {
Param ([int]$num1, [int]$num2)
$resta=$num1-$num2
Write-Host "La resta de los parametros es $resta"
} 
Get-resta 10 5
Get-resta -num2 10 -num1 5
Get-resta -num2 10

function Get-Resta {
Param ([Parameter(Mandatory)][int]$num1, [int]$num2)
$resta=$num1-$num2
Write-Host "La resta de los parametros es $resta"
} 
Get-Resta -num2 10

function Get-Resta {
[CmdletBinding()]
Param ([int]$num1, [int]$num2)
$resta=$num1-$num2
Write-Host "La resta de los paramentros es $resta"
}
(Get-Command -Name Get-Resta).Parameters.Keys

function Get-Resta {
[CmdletBinding()]
Param ([int]$num1, [int]$num2)
$resta=$num1-$num2
Write-Verbose -Message "Operacion que va a realizar una resta de $num1 y $num2"
Write-Host "La resta de los paramentros es $resta"
}
Get-Resta 10 5 -Verbose


#Tema 7. Modulos
Get-Module
Get-Module -ListAvailable
Remove-Module BitsTransfer
Get-Module 
Get-Command -Module ISE
Get-Help ISE
Import-Module BitsTransfer


#Tema 8. Scripts
#Subtema 8.1.-Valores de salida
#Subtema 8.2.-Escritura de ayuda
#Subtema 8.3.-Gestion de errores
#Subtema 8.3.1.-Try/Catch
try
{
    Write-Output "Todo bien"
}
catch
{
    Write-Output "Algo lanzo una excepcion"
    Write-Output $_
}
try
{
    Start-Something -ErrorAction Stop
}
catch
{
    Write-Output "Algo genero una excepcion o uso Write-Error"
    Write-Output $_
}

#Subtema 8.3.2.-Try/Finally
$comando = [System.Data.SqlClient.SqlCommand]::New(queryString, connectinon)
try
{
    $comando.Connection.Open()
   $comando.ExecuteNonQuery()
}
finally 
{
    Write-Error "Ha habido un problema con la ejecucion de la query. Cerrando la conexion"
   $comando.Connection.Close()
}

#Subtema 8.3.3.-Variable Automatica $PSItem
try #No me funciona
{
    Start-Something -Path $path -ErrorAction Stop
}
catch [System.IO.DirectoryNotFoundException],[System.IO.FileNotFoundException]
{
    Write-Output "El directorio o fichero no ha sido encontrado: [$path]"
}
catch [System.IO.IOException]
{
    Write-Output "Error de IO con el archivo: [$path]"
}

throw "No se puede encontrar la ruta: [$path]"
throw [System.IO.FileNotFoundException] "No se puede encontrar la ruta: [$path]"
throw [System.IO.FileNotFoundException]::new()
throw [System.IO.FileNotFoundException]::new("No se puede encontrar la ruta: [$path]")
throw (New-Object -TypeName System.IO.FileNotFoundException )
throw (New-Object -TypeName System.IO.FileNotFoundException -ArgumentList "No se puede ejecutar la ruta: [$path]")

trap
{
    Write-Output $PSItem.ToString()
}
throw [System.Exception]::new('primero')
throw [System.Exception]::new('segundo')
throw [System.Exception]::new('tercero')

#Subtema 8.4.-Ejemplo practico de script
cd ..
CD C:\Program Files\WindowsPowerShell\Modules
ls
Get-Help Backup-Registry
-rutaBackup 'D:\tmp\Backups\Registro\'
ls .\tmp\Backups\Registro\
vim .\Backup-Registry.ps1
Import-Module BackupRegistry -Force
Backup-Registry -rutaBackup 'D:\tmp\Backups\Registro\'
ls 'D:\tmp\Backups\Registro\'
Get-Date
Get-ScheduledTask
Unregister-ScheduledTask 'Ejecutar Backup del registro del sistema'

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
cd C:\Program Files\WindowsPowerShell\Modules

@{
    ModuleVersion = '1.0.0'
    PowerShellVersion = '5.1'
    RootModule = 'Backup-Registry.ps1'
    Description = 'Modulo para realizar backups del registro del sistema de Windows'
    Author = 'Pau'
    FunctionsToExport = @('Backup-Registry') 
}