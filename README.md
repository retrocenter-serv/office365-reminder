# Office 365 Reminder

Repositorio público con scripts de PowerShell para registrar la vigencia del soporte técnico de Microsoft Office y programar avisos automáticos de renovación en equipos Windows.

El flujo está diseñado para utilizarse después de completar la instalación y activación autorizada de Microsoft Office.

> Este proyecto no activa Office, no modifica claves de producto y no instala servicios de activación. Su función es registrar un plazo de soporte y mostrar recordatorios al finalizar dicho periodo.

---

## Flujo de trabajo

El procedimiento general es el siguiente:

1. Instalar Microsoft Office en el equipo del cliente.
2. Completar la activación mediante un método autorizado.
3. Ejecutar el script de programación de vigencia.
4. Registrar automáticamente:
   - Nombre del equipo.
   - Número de serie.
   - Usuario de Windows.
   - Fecha actual.
   - Fecha de vencimiento del soporte.
5. Programar el inicio del recordatorio después de 360 días.
6. Mostrar avisos periódicos de renovación cuando se cumpla el plazo.
7. Desactivar, reactivar o eliminar el recordatorio cuando corresponda.

---

## Archivos del repositorio

| Archivo | Función |
|---|---|
| `programar-vencimiento.ps1` | Registra la vigencia del soporte y programa el recordatorio para dentro de 360 días. |
| `instalar.ps1` | Instala y ejecuta inmediatamente el recordatorio periódico. |
| `desactivar.ps1` | Detiene y deshabilita temporalmente el recordatorio. |
| `activar.ps1` | Vuelve a habilitar y ejecutar el recordatorio. |
| `eliminar.ps1` | Elimina la tarea programada y los archivos locales. |
| `abrir-office.ps1` | Abre el portal oficial de Microsoft 365. |

---

## Requisitos

- Windows 10 o Windows 11.
- Windows PowerShell 5.1 o superior.
- Conexión a Internet.
- Acceso al Programador de tareas de Windows.
- Permiso para ejecutar scripts de PowerShell.
- Ejecutar PowerShell como administrador cuando la configuración del equipo lo requiera.
- Autorización del propietario del equipo.

---

# Procedimiento principal

## 1. Instalar y activar Microsoft Office

Completa primero la instalación y activación autorizada de Microsoft Office en el equipo del cliente.

Para Microsoft 365, la activación normalmente se realiza iniciando sesión con una cuenta que tenga una licencia válida asignada.

Puedes abrir el portal oficial ejecutando:

```powershell
Start-Process "https://www.office.com"
```

También puedes utilizar el archivo del repositorio:

```powershell
irm "https://raw.githubusercontent.com/retrocenter-serv/office365-reminder/main/abrir-office.ps1" | iex
```

---

## 2. Programar la vigencia del soporte

Después de completar la instalación y activación autorizada, abre PowerShell y ejecuta:

```powershell
irm "https://raw.githubusercontent.com/retrocenter-serv/office365-reminder/main/programar-vencimiento.ps1" | iex
```

El script registrará la información del equipo y programará el inicio automático del recordatorio después de 360 días.

El resultado será similar al siguiente:

```text
Configuración realizada correctamente.

Equipo: GOYDEL-LIMA-14
Serie del equipo: ABC123456
Usuario: GOYDEL-LIMA-14\RENZO ROSARIO
Fecha de configuración: 24/07/2026 12:46
Vigencia del soporte registrada hasta: 19/07/2027 12:46
```

> La fecha mostrada corresponde a la vigencia registrada del soporte técnico. No representa una validación del estado real de la licencia de Microsoft Office.

---

## ¿Qué realiza `programar-vencimiento.ps1`?

El script:

1. Obtiene la fecha y hora actual.
2. Obtiene el nombre del equipo.
3. Consulta el número de serie mediante el BIOS.
4. Identifica al usuario actual de Windows.
5. Calcula una vigencia de 360 días.
6. Descarga una copia local de `instalar.ps1`.
7. Crea una tarea programada en Windows.
8. Configura la tarea para ejecutarse al finalizar el plazo.
9. Inicia automáticamente el sistema de recordatorios cuando se cumple la fecha.

---

## Importante sobre el usuario de Windows

El comando debe ejecutarse desde la sesión habitual del cliente.

La tarea programada se registra para el usuario que esté conectado en ese momento.

Por ejemplo:

```text
GOYDEL-LIMA-14\RENZO ROSARIO
```

Si el script se ejecuta utilizando otra cuenta administrativa, el recordatorio podría quedar asociado a dicha cuenta y no aparecer en la sesión normal del cliente.

---

# Funcionamiento del recordatorio

Cuando se cumplan los 360 días, se ejecutará automáticamente el archivo `instalar.ps1`.

El recordatorio mostrará un cuadro de diálogo con un mensaje similar a:

```text
LICENCIA OFFICE 365

Su licencia de Microsoft Office requiere activación.

Por favor, ingrese a Office.com para activar nuevamente su licencia.

Este anuncio continuará apareciendo hasta que sea desactivado.
```

Después de cerrar el mensaje, volverá a mostrarse cada 30 minutos.

La tarea también se ejecutará cuando el usuario vuelva a iniciar sesión en Windows.

---

# Ejecutar el recordatorio inmediatamente

Para instalar el recordatorio sin esperar los 360 días, ejecuta:

```powershell
irm "https://raw.githubusercontent.com/retrocenter-serv/office365-reminder/main/instalar.ps1" | iex
```

Este comando:

1. Crea una carpeta local para el sistema.
2. Guarda el script del aviso.
3. Crea la tarea programada.
4. Configura su ejecución al iniciar sesión.
5. Muestra el primer aviso inmediatamente.
6. Repite el aviso cada 30 minutos.

---

# Administración del recordatorio

## Desactivar temporalmente

Para detener el recordatorio sin eliminarlo:

```powershell
irm "https://raw.githubusercontent.com/retrocenter-serv/office365-reminder/main/desactivar.ps1" | iex
```

La tarea permanecerá instalada, pero quedará deshabilitada.

---

## Volver a activar

Para habilitar nuevamente el recordatorio:

```powershell
irm "https://raw.githubusercontent.com/retrocenter-serv/office365-reminder/main/activar.ps1" | iex
```

El aviso volverá a mostrarse y la tarea quedará activa para los siguientes inicios de sesión.

---

## Eliminar completamente

Para eliminar la tarea programada y los archivos locales:

```powershell
irm "https://raw.githubusercontent.com/retrocenter-serv/office365-reminder/main/eliminar.ps1" | iex
```

Este comando elimina:

- La tarea programada del recordatorio.
- El script almacenado localmente.
- La carpeta `RecordatorioOffice365`.
- Los archivos asociados al sistema de avisos.

---

# Verificar la programación

## Consultar la tarea de vencimiento

Ejecuta:

```powershell
Get-ScheduledTask -TaskName "Inicio Recordatorio Office365 - 360 dias"
```

Para visualizar su fecha de ejecución:

```powershell
Get-ScheduledTaskInfo -TaskName "Inicio Recordatorio Office365 - 360 dias"
```

---

## Consultar la tarea del recordatorio

Ejecuta:

```powershell
Get-ScheduledTask -TaskName "Recordatorio Licencia Office365"
```

---

## Abrir el Programador de tareas

Ejecuta:

```powershell
taskschd.msc
```

Busca las tareas:

```text
Inicio Recordatorio Office365 - 360 dias
Recordatorio Licencia Office365
```

---

# Cancelar la programación de 360 días

Para cancelar el inicio futuro del recordatorio antes de que se cumpla el plazo:

```powershell
Unregister-ScheduledTask `
    -TaskName "Inicio Recordatorio Office365 - 360 dias" `
    -Confirm:$false `
    -ErrorAction SilentlyContinue
```

Esto elimina únicamente la programación futura.

No modifica Microsoft Office ni cambia el estado de su licencia.

---

# Reprogramar la vigencia

Si deseas iniciar nuevamente el conteo de 360 días, vuelve a ejecutar:

```powershell
irm "https://raw.githubusercontent.com/retrocenter-serv/office365-reminder/main/programar-vencimiento.ps1" | iex
```

El script reemplazará la programación anterior y calculará una nueva fecha tomando como referencia el momento de la ejecución.

---

# Cambiar el plazo de vigencia

El archivo `programar-vencimiento.ps1` utiliza:

```powershell
$FechaVencimiento = (Get-Date).AddDays(360)
```

Para modificar el periodo, cambia el número de días.

Ejemplos:

| Periodo | Configuración |
|---|---|
| 180 días | `AddDays(180)` |
| 360 días | `AddDays(360)` |
| 365 días | `AddDays(365)` |
| 1 año calendario | `AddYears(1)` |

Ejemplo para un año exacto:

```powershell
$FechaVencimiento = (Get-Date).AddYears(1)
```

---

# Cambiar la frecuencia del aviso

El archivo `instalar.ps1` utiliza:

```powershell
Start-Sleep -Seconds 1800
```

`1800` segundos equivalen a 30 minutos.

| Frecuencia | Segundos |
|---|---:|
| 10 minutos | 600 |
| 15 minutos | 900 |
| 30 minutos | 1800 |
| 1 hora | 3600 |
| 2 horas | 7200 |

Después de modificar el archivo, vuelve a ejecutar `instalar.ps1` para actualizar la tarea.

---

# Revisar el código antes de ejecutarlo

Como el repositorio es público, puedes visualizar cualquier archivo antes de ejecutarlo.

Para revisar `programar-vencimiento.ps1`:

```powershell
irm "https://raw.githubusercontent.com/retrocenter-serv/office365-reminder/main/programar-vencimiento.ps1"
```

Para revisar `instalar.ps1`:

```powershell
irm "https://raw.githubusercontent.com/retrocenter-serv/office365-reminder/main/instalar.ps1"
```

Después de confirmar su contenido, puedes ejecutarlo agregando:

```powershell
| iex
```

Ejemplo:

```powershell
irm "https://raw.githubusercontent.com/retrocenter-serv/office365-reminder/main/programar-vencimiento.ps1" | iex
```

---

# Desinstalación manual

Si los archivos remotos no se encuentran disponibles, puedes eliminar manualmente las tareas y archivos locales:

```powershell
Stop-ScheduledTask `
    -TaskName "Recordatorio Licencia Office365" `
    -ErrorAction SilentlyContinue

Unregister-ScheduledTask `
    -TaskName "Recordatorio Licencia Office365" `
    -Confirm:$false `
    -ErrorAction SilentlyContinue

Unregister-ScheduledTask `
    -TaskName "Inicio Recordatorio Office365 - 360 dias" `
    -Confirm:$false `
    -ErrorAction SilentlyContinue

Remove-Item `
    "$env:LOCALAPPDATA\RecordatorioOffice365" `
    -Recurse `
    -Force `
    -ErrorAction SilentlyContinue
```

---

# Solución de problemas

## El comando no muestra ningún resultado

Comprueba que la URL del archivo exista:

```powershell
irm "https://raw.githubusercontent.com/retrocenter-serv/office365-reminder/main/programar-vencimiento.ps1"
```

---

## PowerShell bloquea la ejecución

Puedes habilitar la ejecución únicamente para la sesión actual:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
```

Después vuelve a ejecutar el comando.

---

## El recordatorio aparece en otra cuenta

Elimina las tareas desde la cuenta incorrecta y vuelve a ejecutar el script desde la sesión habitual del cliente.

---

## La tarea no se ejecutó exactamente en la fecha

La tarea está configurada para iniciarse cuando el equipo se encuentre disponible.

Si la computadora estaba apagada en el momento programado, Windows intentará ejecutarla cuando el usuario vuelva a iniciar sesión o cuando el equipo esté disponible.

---

## No se puede obtener el número de serie

En algunos equipos, el fabricante puede no registrar correctamente el número de serie en el BIOS.

En ese caso, el resultado puede mostrarse como:

```text
Serie del equipo: No disponible
```

---

# Seguridad

No almacenes dentro de este repositorio:

- Contraseñas.
- Tokens de acceso.
- Claves de producto.
- Credenciales corporativas.
- Información personal de clientes.
- Direcciones internas.
- Datos confidenciales.
- Comandos de terceros cuyo contenido no controles.

Debido a que el repositorio es público, cualquier persona puede revisar, copiar y ejecutar sus archivos.

---

# Alcance del proyecto

Este repositorio:

- No activa Microsoft Office.
- No elimina licencias.
- No instala servidores de activación.
- No comprueba el estado real de la licencia.
- No sustituye una suscripción válida.
- No bloquea las aplicaciones de Office.
- No modifica archivos internos de Microsoft Office.

El sistema únicamente:

- Registra un periodo de soporte.
- Programa una fecha de seguimiento.
- Muestra avisos de renovación.
- Permite administrar dichos avisos.

---

# Aviso de responsabilidad

Este proyecto está destinado al control administrativo de servicios de instalación, soporte técnico y renovación.

El técnico debe contar con autorización del propietario del equipo antes de instalar tareas programadas o recordatorios persistentes.

El propietario del equipo o la organización es responsable de disponer de las licencias necesarias para utilizar Microsoft Office y Microsoft 365.
