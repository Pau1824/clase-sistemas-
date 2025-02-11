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
