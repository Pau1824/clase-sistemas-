#Tema 1.Variables y tipos de datos
$variable1="Hola"
$variable2=" Que tal?"
$VARiable3=100
${VAR iable4}=200

New-Variable -Name variable5 -Value 300

$variable1+$variable2
$VARiable3+${VAR iable4}
$VARiable3-${VAR iable4}


#Subtema 1.1.-Variables automaticas
$variable1 + $variable2
$$
$^
$?
$Error
get-help about_automatic_variables #no funciona


#Subtema 1.2.-Variables de preferencia 
$ConfirmPreference
$DebugPreference
$ErrorActionPreference
$WarningPreference
get-help about_preference_variables #no funciona


#Tema 2.Tipos de datos
[int]$variable1=100
[int]$variable2="Hola"
$variable1.GetType()


#Tema 3.Ejecuciones Condicionales y bucles
#Subtema 3.1.- Ejecuciones condicionales
#Subtema 3.1.1.-Declarador if
$condicion = $true
if ( $condicion )
{
        Write-Output "La condicion era verdadera"
}
else
{
        Write-Output "La condicion era falsa"
}

#elseif
$numero = 2
if ( $numero -ge 3 )
{
        Write-Output "El numero [$numero] es mayor o igual que 3"
}
elseif ( $numero -lt 2 )
{
        Write-Output "El numero [$numero] es menor que 2"
}
else
{
        Write-Output "El numero [$numero] es igual a 2"
}

#Subtema 3.1.2.-Operador ternario
$PSVersionTable #actualizar esto

#Subtema 3.1.3.-Declaracion switch
switch (3)
{
        1 {"[$_] es uno."}
        2 {"[$_] es dos."}
        3 {"[$_] es tres."; Break}
        4 {"[$_] es cuatro."}
        3 {"[$_] es tres de nuevo."}
}

switch (1, 5)
{
        1 {"[$_] es uno."}
        2 {"[$_] es dos."}
        3 {"[$_] es tres."}
        4 {"[$_] es cuatro."}
        5 {"[$_] es cinco."}
}

switch ("seis")
{
        1 {"[$_] es uno."; Break}
        2 {"[$_] es dos."; Break}
        3 {"[$_] es tres."; Break}
        4 {"[$_] es cuatro."; Break}
        5 {"[$_] es cinco."; Break}
        "se*" {"[$_] coincide con se*."}
        Default {
                "No hay conicidencias con [$_]"
                }
}

switch -Wildcard ("seis")
{
        1 {"[$_] es uno."; Break}
        2 {"[$_] es dos."; Break}
        3 {"[$_] es tres."; Break}
        4 {"[$_] es cuatro."; Break}
        5 {"[$_] es cinco."; Break}
        "se*" {"[$_] coincide con [se*]."}
        Default {
                "No hay conicidencias con [$_]"
                }
}

$email = 'antonio.yanez@udc.es'
$email2 = 'antonio.yanez@usc.gal'
$url = 'https://www.dc.fi.udc.es/~afyanez/Docencia/2023'
switch -Regex ($url, $email, $email2)
{
        '^\w+\.\w+@(udc|usc|edu)\.es|gal$' { "[$_] es una direccion de correo electronico academica" }
        '^ftp\://.*$' { "[$_] es una direccion ftp" }
        '^(http[s]?)\://.*$' { "[$_] es una direccion web, que utiliza [$($matches[1])]" }
}


#Subtema 3.2.-Operadores logicos y comparativos
#Subtema 3.2.1.-Operadores comparativos
1 -eq "1.0"
"1.0" -eq 1

#Subtema 3.2.2.-Operadores logicos

#Subtema 3.3.-Bucles
#Subtema 3.3.1.-Bucle for
for (($i = 0), ($j = 0); $i -lt 5; $i++)
{
        "`$i:$i"
        "`$j:$j"
}

for ($($i = 0;$j = 0); $i -lt 5; $($i++;$j++))
{
        "`$i:$i"
        "`$j:$j"
}

#Subtema 3.3.2.-Bucle Foreach
$ssoo = "freebsd", "openbsd", "solaris", "fedora", "ubuntu", "netbsd"
foreach ($so in $ssoo)
{
        Write-Host $so
}

foreach ($archivo in Get-ChildItem) #No me devuelve nada
{
        if ($archivo.length -ge 10KB)
        {
                Write-Host $archivo -> [($archivo.length)]
        }
}

#Subtema 3.3.3.-Bucle While
$num = 0
while ($num -ne 3)
{
        $num++
        Write-Host $num
}

$num = 0
while ($num -ne 5)
{
        if ($num -eq 1) { $num = $num + 3 ; Continue }
        $num++
        Write-Host $num
}

#Subtema 3.3.4.-Bucle Do
$valor =  5
$multiplicacion = 1
do
{
        $multiplicacion = $multiplicacion * $valor
        $valor--
}
while ($valor -gt 0)
Write-Host $multiplicacion


$valor =  5
$multiplicacion = 1
do
{
        $multiplicacion = $multiplicacion * $valor
        $valor--
}
until ($valor -eq 0)
Write-Host $multiplicacion

#Subtema 3.3.5.-Declaraciones break y continue
$num = 10
for($i = 2; $i -lt 10; $i++)
{
        $num = $num+$i
        if ($i -eq 5) { break }
}
Write-Host $num
Write-Host $i

$cadena = "Hola, buenas tardes"
$cadena2 = "Hola, buenas noches"
switch -Wildcard ($cadena, $cadena2)
{
        "Hola, buenas*" {"[$_] coincide con [Hola, buenas*]"}
        "Hola, bue*" {"[$_] coincide con [Hola, bue*]"}
        "Hola,*" {"[$_] coincide con [Hola,*]"; Break}
        "Hola, buenas tardes" {"[$_] coincide con [Hola, buenas tardes]"}
}

$num = 10
for($i = 2; $i -lt 10; $i++)
{
        if ($i -eq 5) { Continue }
        $num = $num+$i
}
Write-Host $num
Write-Host $i

$cadena = "Hola, buenas tardes"
$cadena2 = "Hola, buenas noches"
switch -Wildcard ($cadena, $cadena2)
{
        "Hola, buenas*" {"[$_] coincide con [Hola, buenas*]"}
        "Hola, bue*" {"[$_] coincide con [Hola, bue*]"; Continue}
        "Hola,*" {"[$_] coincide con [Hola,*]"; }
        "Hola, buenas tardes" {"[$_] coincide con [Hola, buenas tardes]"}
}


#Tema 4.Cmdlets
Get-Command -Type Cmdlet | Sort-Object -Property Noun |  Format-Table -GroupBy Noun
Get-Command -Name Get-ChildItem -Args Cert: -Syntax
Get-Command -Name dir
Get-Command -Noun WSManInstance


#Tema 5.Objetos y Pipeline
#Subtema 5.1.- Objetos
#Subtema 5.1.1.-Get-Member
Get-Service -Name "LSM" | Get-Member
Get-Service -Name "LSM" | Get-Member -MemberType Property
Get-Item .\hola.txt | Get-Member -MemberType Method #Cambiar ruta

#Subtema 5.1.2.-Select-Object
Get-Item .\hola.txt | Select-Object Name, Length
Get-Service | Select-Object -Last 5
Get-Service | Select-Object -First 5

#Subtema 5.1.3.-Where-Object
Get-Service | Where-Object {$_.Status -eq "Running"}
(Get-Item .\hola.txt).IsReadOnly
(Get-Item .\hola.txt).IsReadOnly = 1
(Get-Item .\hola.txt).IsReadOnly

#Subtema 5.1.4.-Los metodos
Get-ChildItem *.txt
(Get-Item .\hola.txt).CopyTo("C:\Users\chavi\prueba.txt")
(Get-Item .\hola.txt).Delete() #No me funciono
Get-ChildItem *.txt
$miObjeto = New-Object PSObject
$miObjeto | Add-Member -MemberType NoteProperty -Name Nombre -Value "Miguel"
$miObjeto | Add-Member -MemberType NoteProperty -Name Edad -Value 23
$miObjeto | Add-Member -MemberType ScriptMethod -Name Saludar -Value { Write-Host "Hola mundo!" }

$miObjeto = New-Object -TypeName PSObject -Property @{
        Nombre = "Miguel"
        Edad = 23
}
$miObjeto | Add-Member -MemberType ScriptMethod -Name Saludar -Value { Write-Host "Hola mundo!"}
$miObjeto | Get-Member
$miObjeto = [PSCustomObject] @{
        Nombre = "Miguel"
        Edad = 23
}
$miObjeto | Add-Member -MemberType ScriptMethod -Name Saludar -Value { Write-Host "Hola mundo!"}
$miObjeto | Get-Member

#Subtema 5.1.5.-El pipeline
Get-Help -Full Get-Process
Get-Help -Full Stop-Process
Get-Process
Get-Process -Name Acrobat | Stop-Process #No funciona
Get-Process
Get-Help -Full Get-ChildItem
Get-Help -Full Get-Clipboard
Get-ChildItem *.txt | Get-Clipboard
System.String[]
Get-Help -Full Stop-Service
Get-Service
Get-Service Spooler | Stop-Service #Me da error
"Spooler" | Stop-Service #Me da error
$miObjeto = [PSCustomObject] @{
    Name = "Spooler"
}
$miObjeto | Stop-Service #No me funciono


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


#Tema 9.Administracion con PowerShell
#Subtema 9.1.-Administracion de servicios
Get-Service
Get-Service -Name Spooler
Get-Service -DisplayName Hora*
Get-Service | Where-Object {$_.Status -eq "Running"}
Get-Service | Where-Object {$_.StartType -eq "Automatic"} | Select-Object Name, StartType
Get-Service -DependentServices Spooler
Get-Service -RequiredServices Fax

#Subtema 9.1.1.- Stop-Service
Stop-Service -Name Spooler -Confirm -PassThru

#Subtema 9.1.2.- Start-Service
Start-Service -Name Spooler -Confirm -PassThru

#Subtema 9.1.3.- Suspend-Service
Suspend-Service -Name stisvc -Confirm -PassThru
Get-Service | Where-Object CanPauseAndContinue -eq True
Suspend-Service -Name Spooler

#Subtema 9.1.4.- Restart-Service
Restart-Service -Name WSearch -Confirm -PassThru

#Subtema 9.1.5.- Set-Service
Set-Service -Name dcsvc -DisplayName "Servidor de virtualizacion de credenciales de seguridad distribuidas"
Set-Service -Name BITS -StartupType Automatic -Confirm -PassThru | Select-Object Name, StartType
Set-Service -Name BITS -Description "Transfiere archivos en segundo plano mediante el uso de ancho de banda de red inactivo"
Get-CimInstance Win32_Service -Filter '"Name = "BITS"' | Format-List Name, Description
Set-Service -Name Spooler -Status Running -Confirm -PassThru
Set-Service -Name BITS -Status Stopped -Confirm -PassThru


#Subtema 9.2.-Administracion de procesos
#Subtema 9.2.1.- Get-Process
Get-Process
Get-Process -Name OpenVPNConnect
Get-Process -Name Search*
Get-Process -Id 2268
Get-Process WINWORD -FileVersionInfo
Get-Process WINWORD -IncludeUserName
Get-Process WINWORD -Module

#Subtema 9.2.2.- Stop-Porcess
Stop-Process -Name OpenVPNConnect -Confirm -PassThru
Stop-Process -Id 2268 -Confirm -PassThru
Get-Process -Name OpenVPNConnect | Stop-Process -Confirm -PassThru

#Subtema 9.2.3.- Start-Process
Start-Process -FilePath "C:\Windows\System32\notepad.exe" -PassThru
Start-Process -FilePath "cmd.exe" -ArgumentList "/c mkdir NuevaCarpeta" -WorkingDirectory "D:\Documents\FIC\06\ASO" -PassThru
Start-Process -FilePath "notepad.exe" -WindowStyle "Maximized" -PassTru
Start-Process -FilePath "D:\Documents\FIC\06\ASO\TT\TT.txt" -Verb Print -PassThru

#Subtema 9.2.4.- Wait-Process
Get-Process -Name notep*
Get-Process -Name Notepad
Wait-Process -Id 11568
Get-Process -Name notep*
Get-Process -Name notepad | Wait-Process


#Subtema 9.3.- Administracion de usuarios y grupos
#Subtema 9.3.1.- Get-LocalUser
Get-LocalUser
Get-LocalUser -Name chavi | Select-Object *
Get-LocalUser -SID S-1-5-21-4169144003-467534702-2126530610-1001 | Select-Object *

#Subtema 9.3.2.- Get-LocalGroup
Get-LocalGroup
Get-LocalGroup -Name Administrators | Select-Object *
Get-LocalGroup -SID S-1-5-32-544 | Select-Object *

#Subtema 9.3.3.- *-LocalUser 
New-LocalUser -Name "Usuario1" -Description "Usuario de prueba 1" -NoPassword
New-LocalUser -Name "Usuario2" -Description "Usuario de prueba 1" -Password (ConvertIo-SecureString -AsPlainText "12345" -Force)
Get-LocalUser -Name "Usuario1"
Remove-LocalUser -Name "Usuario1"
Get-LocalUser -Name "Usuario1"
Get-LocalUser -Name "Usuario2"
Get-LocalUser -Name "Usuario2" | Remove-LocalUser

#Subtema 9.3.4.- *-LocalGroup
New-LocalGroup -Name 'Group1' -Description 'Grupo de prueba 1'
Add-LocalGroupMember -Group Grupo1 -Member Usuario2 -Verbose
Get-LocalGroupMember Grupo1
Remove-LocalGroupMember -Group Grupo1 -Member Usuario1
Remove-LocalGroupMember -Group Grupo1 -Member Usuario2
Get-LocalGroupMember Grupo1
Get-LocalGroup -Name "Group1"
Remove-LocalGroup -Name "Grupo1"

#Anexo II: Habilitar la ejecucion de scirpt de powershell en windows
.\ejemplo.ps1