# Recordatorio de licencia Office 365

Repositorio público con scripts de PowerShell para instalar y administrar un recordatorio periódico de activación de Microsoft Office 365.

El sistema muestra un cuadro de diálogo indicando que la licencia requiere activación y solicita al usuario ingresar al portal oficial de Microsoft.

> Este proyecto no activa Microsoft Office ni modifica licencias. Solamente instala un recordatorio visual en Windows.

---

## Funcionalidades

- Muestra un aviso de activación de Office 365.
- El aviso aparece al iniciar sesión en Windows.
- Después de cerrar el mensaje, vuelve a aparecer cada 30 minutos.
- Se ejecuta mediante una tarea programada de Windows.
- Puede desactivarse temporalmente.
- Puede volver a activarse.
- Puede eliminarse completamente.
- Permite abrir el portal oficial de Microsoft 365.

---

## Archivos disponibles

| Archivo | Función |
|---|---|
| `instalar.ps1` | Instala y ejecuta el recordatorio. |
| `desactivar.ps1` | Detiene y deshabilita temporalmente el recordatorio. |
| `activar.ps1` | Habilita y ejecuta nuevamente el recordatorio. |
| `eliminar.ps1` | Elimina la tarea programada y los archivos instalados. |
| `abrir-office.ps1` | Abre el portal oficial de Microsoft 365. |

---

## Requisitos

- Windows 10 o Windows 11.
- Windows PowerShell 5.1 o superior.
- Acceso al Programador de tareas de Windows.
- Conexión a Internet para descargar los scripts.
- Ejecutar PowerShell como administrador cuando la configuración del equipo lo requiera.

---

## Instalación

Abre PowerShell y ejecuta:

```powershell
irm "https://raw.githubusercontent.com/retrocenter-serv/office365-reminder/main/instalar.ps1" | iex
```

El script realizará lo siguiente:

1. Creará una carpeta en el perfil del usuario.
2. Guardará localmente el script del recordatorio.
3. Creará una tarea programada.
4. Configurará la tarea para ejecutarse al iniciar sesión.
5. Mostrará el primer aviso inmediatamente.
6. Repetirá el aviso cada 30 minutos después de cerrarlo.

---

## Desactivar temporalmente

Para detener el recordatorio sin eliminarlo:

```powershell
irm "https://raw.githubusercontent.com/retrocenter-serv/office365-reminder/main/desactivar.ps1" | iex
```

La tarea permanecerá instalada, pero no se ejecutará.

---

## Volver a activar

Para habilitar nuevamente el recordatorio:

```powershell
irm "https://raw.githubusercontent.com/retrocenter-serv/office365-reminder/main/activar.ps1" | iex
```

El aviso volverá a ejecutarse inmediatamente y también en los siguientes inicios de sesión.

---

## Eliminar completamente

Para eliminar la tarea programada y todos los archivos locales:

```powershell
irm "https://raw.githubusercontent.com/retrocenter-serv/office365-reminder/main/eliminar.ps1" | iex
```

Esta acción elimina:

- La tarea programada.
- El script almacenado localmente.
- La carpeta del recordatorio.

---

## Abrir el portal oficial de Microsoft 365

Para abrir el portal de Microsoft:

```powershell
irm "https://raw.githubusercontent.com/retrocenter-serv/office365-reminder/main/abrir-office.ps1" | iex
```

También puede ingresar directamente a:

```text
https://www.office.com
```

El usuario deberá iniciar sesión con una cuenta que tenga asignada una licencia válida de Microsoft 365.

---

## Cambiar la frecuencia

El instalador utiliza actualmente:

```powershell
Start-Sleep -Seconds 1800
```

Los `1800` segundos equivalen a 30 minutos.

Ejemplos:

| Frecuencia | Segundos |
|---|---:|
| 10 minutos | 600 |
| 15 minutos | 900 |
| 30 minutos | 1800 |
| 1 hora | 3600 |
| 2 horas | 7200 |

Para cambiar la frecuencia, modifica el archivo `instalar.ps1` antes de ejecutarlo nuevamente.

---

## Verificar la tarea programada

Puedes comprobar la tarea desde PowerShell:

```powershell
Get-ScheduledTask -TaskName "Recordatorio Licencia Office365"
```

También puedes abrir el Programador de tareas de Windows:

```powershell
taskschd.msc
```

Busca la tarea:

```text
Recordatorio Licencia Office365
```

---

## Seguridad

Antes de ejecutar un script remoto, puedes revisar su contenido sin ejecutarlo:

```powershell
irm "https://raw.githubusercontent.com/retrocenter-serv/office365-reminder/main/instalar.ps1"
```

Después de verificarlo, puedes ejecutarlo:

```powershell
irm "https://raw.githubusercontent.com/retrocenter-serv/office365-reminder/main/instalar.ps1" | iex
```

No almacenes en este repositorio:

- Contraseñas.
- Tokens de GitHub.
- Claves de producto.
- Credenciales corporativas.
- Información personal.
- Datos confidenciales de clientes.

Debido a que el repositorio es público, cualquier persona puede ver y descargar su contenido.

---

## Activación de Microsoft 365

Estos scripts no activan Office, no modifican archivos de licencia y no instalan servicios de activación.

La activación debe realizarse mediante los medios oficiales de Microsoft:

1. Abrir Word, Excel o cualquier aplicación de Office.
2. Seleccionar **Archivo**.
3. Ingresar a **Cuenta**.
4. Seleccionar **Iniciar sesión**.
5. Utilizar una cuenta que tenga asignada una licencia válida.

También puede realizarse desde:

```text
https://www.office.com
```

---

## Desinstalación manual

En caso de que el script remoto no esté disponible, puedes eliminar manualmente la tarea con PowerShell:

```powershell
Stop-ScheduledTask `
    -TaskName "Recordatorio Licencia Office365" `
    -ErrorAction SilentlyContinue

Unregister-ScheduledTask `
    -TaskName "Recordatorio Licencia Office365" `
    -Confirm:$false `
    -ErrorAction SilentlyContinue

Remove-Item `
    "$env:LOCALAPPDATA\RecordatorioOffice365" `
    -Recurse `
    -Force `
    -ErrorAction SilentlyContinue
```

---

## Aviso

Este repositorio está destinado únicamente a recordatorios administrativos y de soporte técnico.

El propietario del equipo o la organización es responsable de contar con las licencias correspondientes para utilizar Microsoft Office y Microsoft 365.
