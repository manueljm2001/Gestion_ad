# ==============================================================================
# Script de Automatización de Directorio Activo
# ==============================================================================

# Importar el módulo de Active Directory
Import-Module ActiveDirectory

do {
    # Mostrar el Menú Principal
    Clear-Host
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "     MENÚ DE GESTIÓN DE DIRECTORIO ACTIVO " -ForegroundColor Yellow
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "1. Mostrar información del dominio"
    Write-Host "2. Crear una nueva Unidad Organizativa (OU)"
    Write-Host "3. Crear un nuevo Grupo"
    Write-Host "4. Crear un nuevo Usuario"
    Write-Host "5. Salir"
    Write-Host "==========================================" -ForegroundColor Cyan
    
    $opcion = Read-Host "Selecciona una opción (1-5)"

    switch ($opcion) {
        "1" {
            Clear-Host
            Write-Host "--- INFORMACIÓN DEL DOMINIO ---" -ForegroundColor Green
            
            # Obtener datos del equipo local y del dominio
            $equipo = $env:COMPUTERNAME
            $infoDominio = Get-ADDomain
            
            # Contar elementos del directorio activo
            $numOUs = (Get-ADOrganizationalUnit -Filter *).Count
            $numGrupos = (Get-ADGroup -Filter *).Count
            $numUsuarios = (Get-ADUser -Filter *).Count

            Write-Host "Nombre del equipo local : $equipo"
            Write-Host "Nombre del dominio      : $($infoDominio.DNSRoot)"
            Write-Host "Número de OUs           : $numOUs"
            Write-Host "Número de Grupos        : $numGrupos"
            Write-Host "Número de Usuarios      : $numUsuarios"
            
            Read-Host "`nPulsa Enter para volver al menú..."
        }
        "2" {
            Clear-Host
            Write-Host "--- CREAR NUEVA UNIDAD ORGANIZATIVA (OU) ---" -ForegroundColor Green
            
            $nombreOU = Read-Host "Introduce el nombre de la nueva OU"
            $rutaDN = Read-Host "Introduce el DN del contenedor padre (ej: DC=manuel,DC=aws)"

            try {
                New-ADOrganizationalUnit -Name $nombreOU -Path $rutaDN -ProtectedFromAccidentalDeletion $false
                Write-Host "`n[ÉXITO] La OU '$nombreOU' se ha creado correctamente." -ForegroundColor Green
            }
            catch {
                Write-Host "`n[ERROR] No se pudo crear la OU: $_" -ForegroundColor Red
            }
            
            Read-Host "`nPulsa Enter para volver al menú..."
        }
        "3" {
            Clear-Host
            Write-Host "--- CREAR NUEVO GRUPO ---" -ForegroundColor Green
            
            $nombreGrupo = Read-Host "Introduce el nombre del grupo"
            $rutaOU = Read-Host "Introduce el DN de la OU donde se ubicará (ej: OU=MiOU,DC=manuel,DC=aws)"
            $ambito = Read-Host "Introduce el ámbito (DomainLocal, Global, Universal) [Global por defecto]"
            if ([string]::IsNullOrEmpty($ambito)) { $ambito = "Global" }
            
            $categoria = Read-Host "Introduce la categoría (Security, Distribution) [Security por defecto]"
            if ([string]::IsNullOrEmpty($categoria)) { $categoria = "Security" }

            try {
                New-ADGroup -Name $nombreGrupo -Path $rutaOU -GroupScope $ambito -GroupCategory $categoria
                Write-Host "`n[ÉXITO] El grupo '$nombreGrupo' se ha creado correctamente." -ForegroundColor Green
            }
            catch {
                Write-Host "`n[ERROR] No se pudo crear el grupo: $_" -ForegroundColor Red
            }

            Read-Host "`nPulsa Enter para volver al menú..."
        }
        "4" {
            Clear-Host
            Write-Host "--- CREAR NUEVO USUARIO ---" -ForegroundColor Green
            
            $nombre = Read-Host "Nombre de pila"
            $apellidos = Read-Host "Apellidos"
            $sAMAccountName = Read-Host "Nombre de inicio de sesión (sAMAccountName)"
            $rutaOU = Read-Host "Introduce el DN de la OU destino (ej: OU=MiOU,DC=manuel,DC=aws)"
            $nombreGrupoDestino = Read-Host "Nombre del grupo al que se desea añadir"
            $passwordTexto = Read-Host "Contraseña inicial" -AsSecureString

            try {
                # Crear el usuario con la contraseña y obligar cambio en el primer inicio
                New-ADUser -Name "$nombre $apellidos" `
                           -GivenName $nombre `
                           -Surname $apellidos `
                           -SamAccountName $sAMAccountName `
                           -UserPrincipalName "$sAMAccountName@manuel.aws" `
                           -Path $rutaOU `
                           -AccountPassword $passwordTexto `
                           -Enabled $true `
                           -ChangePasswordAtLogon $true

                # Añadir al usuario al grupo especificado
                Add-ADGroupMember -Identity $nombreGrupoDestino -Members $sAMAccountName

                Write-Host "`n[ÉXITO] Usuario '$sAMAccountName' creado y añadido al grupo '$nombreGrupoDestino' correctamente." -ForegroundColor Green
            }
            catch {
                Write-Host "`n[ERROR] No se pudo completar la creación del usuario: $_" -ForegroundColor Red
            }

            Read-Host "`nPulsa Enter para volver al menú..."
        }
        "5" {
            Write-Host "`nSaliendo del aplicativo de gestión... ¡Hasta pronto!" -ForegroundColor Cyan
        }
        default {
            Write-Host "`n[AVISO] Opción no válida. Selecciona un número del 1 al 5." -ForegroundColor Yellow
            Start-Sleep -Seconds 2
        }
    }
} while ($opcion -ne "5")