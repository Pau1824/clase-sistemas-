$mercuryURL = "https://download-us.pmail.com/m32-491.exe"
$mercryFolder = "C:\Mercury"
$installerPath = "$mercryFolder\MercuryInstall.exe"

$inipath = "$mercryFolder\mercury.ini"
$nssmUrls = "https://nssm.cc/release/nssm-2.24.zip"
$nssmFolder = "$mercryFolder\nssm"

#Creamos la carpeta de instalacion
New-Item -ItemType Directory -Path $mercryFolder -Force | Out-Null

#Descrgamos Mercury
Write-Host "Descargando mercury"
Invoke-WebRequest -Uri $mercuryURL -OutFile $installerPath

Write-Host "Ejecutamos instalador, requiere intervencion del usuario..."
Start-Process -FilePath $installerPath -Wait

if (-not (Test-Path $inipath)){
    Write-Error "No se encontró el archivo de configuracion, vuelva a ejecutar el script para reinstalar el srevicio"
    exit 1 
}

Write-Host "Configurando Servicio"

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

$content = Get-Content $inipath

$content = Configurarini $content "MercuryS" "TCP/IP_port" "25"
$content = Configurarini $content "MercuryP" "TCP/IP_port" "110"
$content = Configurarini $content "MercuryP" "POP3Enabled" "1"
$content = Configurarini $content "MercuryS" "SMTPEnabled" "1"

$content | Set-Content $inipath

#Start-Service Mercury32 al parecer para ejecutar como servicio esto requiere licencia 


Start-Process "C:\Mercury\mercury.exe" #Mejor ejecutar el .exe directamente y dejar la pestaña abierta

#Al parecer para crear usuario no hay comandos como tal, es hacerlo desde la propia app o editar archivos de configuracion dentro de C:\Mercury32\MAIL
#Supuestamente habua un pquerño programa que podias ejecutar para añadirlos pero no lo encontré, se llama pmuser.exe

<#Lo de aqui son verificaciones en caso de que algo no jale 
  Get-WmiObject -Class Win32_Service -Filter "Name='Mercury32'" | Select-Object Name, PathName, StartMode "State para chechar la ruta"



  Aplicación emergente: Mercury Service Startup Error : Mercury requires a valid license to run in service mode

  Se agotó el tiempo de espera (30000 ms) para la conexión con el servicio Mercury32.

  El servicio Mercury32 no pudo iniciarse debido al siguiente error: 
  El servicio no respondió a tiempo a la solicitud de inicio o de control.


#>