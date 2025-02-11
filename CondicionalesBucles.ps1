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
