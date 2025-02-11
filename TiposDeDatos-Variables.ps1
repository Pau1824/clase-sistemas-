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
