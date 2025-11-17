# 🎓 Guía para el Entregable: Sistemas Operativos

**Objetivo:** Estructurar un informe técnico de **Nivel 4 (Sobresaliente)** que demuestre la administración avanzada de Sistemas Operativos (Linux y Windows) utilizando Ansible para la automatización y gestión de la configuración.

---

## 📝 Estructura del Informe

### Sección 1: Gestión de Procesos y Servicios (Nivel 4)

**Tu Argumento:** "Más allá de la gestión manual con `systemctl`, he implementado un sistema de **gestión de servicios como código** usando Ansible. Esto garantiza que los servicios críticos (`radvd`, `isc-dhcp-server`, `nftables`) no solo se inicien, sino que su estado deseado (activo y habilitado) se aplique y verifique automáticamente, reduciendo errores humanos y asegurando la disponibilidad."

**Evidencias a Incluir:**
1.  **Código Fuente (Automatización):**
    *   **Archivo:** `roles/debian-ipv6-router/tasks/main.yml`
    *   **Qué mostrar:** Las tareas que usan el módulo `systemd` para `state: started` y `enabled: yes`.
    *   **Archivo:** `roles/network-discovery-portal/tasks/main.yml`
    *   **Qué mostrar:** La creación de una unidad de servicio systemd (`netdiscover.service`) desde cero para una aplicación personalizada, demostrando un control total del ciclo de vida de un proceso.

2.  **Pruebas Funcionales (Capturas de pantalla):**
    *   **Evidencia 1.1: Verificación de Servicio de Red Crítico.**
        *   **Comando:** `sudo systemctl status isc-dhcp-server6`
        *   **Descripción de la Captura:** Toma una captura de la terminal mostrando la salida completa del comando. Resalta la línea `Active: active (running)` en color verde para indicar el éxito.
        *   **Qué significa la salida (Tu explicación para el profesor):**
            > "Con este comando, estoy verificando el estado del servicio DHCPv6 a través de `systemd`, el gestor de servicios de Linux. Como pueden ver en la línea `Active: active (running)`, el servicio está funcionando correctamente y listo para asignar direcciones IPv6 a los clientes. La sección `Loaded` nos confirma que el servicio está configurado para iniciarse automáticamente cuando el servidor arranca (`enabled`), lo cual es crucial para la disponibilidad de la red. Las últimas líneas de log nos muestran que se ha iniciado sin errores y está escuchando peticiones en la interfaz de red correcta (`ens34`)."

    *   **Evidencia 1.2: Verificación de Servicio Personalizado.**
        *   **Comando:** `sudo systemctl status netdiscover.service`
        *   **Descripción de la Captura:** Captura la salida que muestra el estado `active (running)` del portal de descubrimiento y las últimas líneas de log que indican que se ha iniciado correctamente.
        *   **Qué significa la salida (Tu explicación para el profesor):**
            > "Para demostrar un control total sobre los servicios del sistema, aquí verifico el estado de `netdiscover.service`, una unidad de `systemd` que yo mismo definí para ejecutar mi aplicación Python/Flask. La salida `active (running)` confirma que mi aplicación personalizada se está ejecutando como un servicio en segundo plano, de manera robusta y gestionada por el sistema operativo, igual que un servicio profesional. Esto asegura que el portal de monitoreo esté siempre disponible."

    *   **Evidencia 1.3: Visualización de Proceso en Ejecución.**
        *   **Comando:** `htop`
        *   **Descripción de la Captura:** Abre `htop`, presiona la tecla `F4` para filtrar, escribe `dhcpd` y presiona Enter. Captura la pantalla con el proceso `isc-dhcp-server` resaltado. Esto demuestra que el servicio está consumiendo recursos del sistema.
        *   **Qué significa la salida (Tu explicación para el profesor):**
            > "Finalmente, para conectar el concepto de 'servicio' con el de 'proceso', utilizo `htop`. Mientras `systemctl` nos da el estado administrativo, `htop` nos muestra los procesos reales que están consumiendo recursos. Al filtrar por `dhcpd`, podemos ver el proceso `isc-dhcp-server` en la lista. Observamos su PID (Process ID), el usuario bajo el cual se ejecuta (`root`), y su consumo de CPU y memoria. Esto confirma que el servicio no solo está 'activo', sino que su proceso correspondiente está vivo y operando en el sistema."

---

### Sección 2: Administración de Usuarios y Políticas de Seguridad (Nivel 4)

**Tu Argumento:** "He diseñado e implementado un **modelo de control de acceso basado en roles (RBAC)** que se aplica de forma consistente en un entorno heterogéneo (Linux y Windows). Utilizando Ansible, he automatizado la creación de perfiles (`alumno`, `profesor`, `admin`) con políticas de privilegios mínimos, garantizando que cada usuario tenga únicamente los permisos necesarios para su función."

**Evidencias a Incluir:**
1.  **Código Fuente (Definición de Políticas):**
    *   **Archivo:** `roles/academic-users/tasks/main.yml`. Destaca la sección que configura `/etc/sudoers.d/profesores`, ya que es la implementación directa de una política de seguridad con privilegios limitados.
    *   **Archivo:** `roles/windows-academic-users/tasks/main.yml`. Demuestra la capacidad de extender el mismo modelo de roles a un sistema operativo diferente, asignando usuarios a grupos locales de Windows (`Users`, `Administrators`).

2.  **Pruebas Funcionales (Capturas de pantalla):**
    *   **Evidencia 2.1: Denegación de Privilegios para Rol `alumno`.**
        *   **Comandos:** `ssh alumno1@2025:db8:101::10`, seguido de `sudo apt update`.
        *   **Descripción de la Captura:** Muestra la terminal con el intento de login exitoso y el posterior error `...is not in the sudoers file. This incident will be reported.`.

    *   **Evidencia 2.2: Aplicación de Privilegios Limitados para Rol `profesor`.**
        *   **Comandos:** `ssh profesor1@2025:db8:101::1`, seguido de `sudo systemctl status radvd` y luego `sudo apt install htop`.
        *   **Descripción de la Captura:** Una sola captura que muestre: 1) El login exitoso. 2) La salida correcta del comando `systemctl`. 3) El error de denegación de `sudo` para el comando `apt`.

    *   **Evidencia 2.3: Escalada de Privilegios para Rol `admin`.**
        *   **Comandos:** `ssh admin@2025:db8:101::1`, seguido de `sudo su -` y `whoami`.
        *   **Descripción de la Captura:** Muestra cómo el usuario `admin` se convierte en `root` sin necesidad de introducir una contraseña, y el comando `whoami` confirma que la sesión es de `root`.

---

### Sección 3: Gestión de la Seguridad del Sistema (Firewall y Secretos) (Nivel 4)

**Tu Argumento:** "Para proteger el sistema operativo de amenazas, he implementado una estrategia de seguridad en capas. Primero, he configurado un firewall a nivel de host (`nftables`) con una política de 'denegar por defecto', permitiendo únicamente el tráfico a los servicios explícitamente autorizados. Segundo, para la gestión de secretos, he utilizado **Ansible Vault** para cifrar todas las credenciales sensibles (como contraseñas de vCenter), evitando su exposición en texto plano y siguiendo las mejores prácticas de seguridad (DevSecOps)."

**Evidencias a Incluir:**
1.  **Código Fuente (Políticas de Seguridad):**
    *   **Archivo:** `roles/debian-ipv6-router/templates/nftables.conf.j2`. Destaca la línea `policy drop` en la cadena `input`, que es la base de una postura de seguridad fuerte. Muestra también las reglas `accept` específicas para los servicios necesarios (SSH, HTTP, etc.).
    *   **Archivo:** `playbooks/vault_rekey.yml` y `scripts/manage_vault.sh`. Menciona que has creado herramientas para gestionar el ciclo de vida del vault, como cambiar la contraseña (`rekey`) y validar su contenido.

2.  **Pruebas Funcionales (Capturas de pantalla):**
    *   **Evidencia 3.1: Verificación de Reglas de Firewall Activas.**
        *   **Comando:** En `debian-router`, ejecuta `sudo nft list ruleset`.
        *   **Descripción de la Captura:** Captura la salida y resalta la política `policy drop` en la cadena `input` y la regla `masquerade` en la tabla `nat`, que protege la red interna.

    *   **Evidencia 3.2: Prueba de Bloqueo de Puerto no Autorizado.**
        *   **Comando:** Desde `ubuntu-pc`, intenta conectar a un puerto no permitido en el router, por ejemplo: `telnet 2025:db8:101::1 9090`.
        *   **Descripción de la Captura:** Muestra cómo la conexión se queda en `Trying...` y finalmente falla con un `Connection timed out`. Esto prueba que el firewall está bloqueando activamente el tráfico no deseado.

    *   **Evidencia 3.3: Demostración de Gestión de Secretos con Ansible Vault.**
        *   **Paso 1 (Mostrar cifrado):** Ejecuta `cat group_vars/all/vault.yml`.
        *   **Descripción de la Captura 1:** Captura la salida que muestra el texto cifrado, comenzando con `$ANSIBLE_VAULT;...`. Explica que esto es lo que se almacena de forma segura en el repositorio.
        *   **Paso 2 (Mostrar descifrado):** Ejecuta `ansible-vault view group_vars/all/vault.yml`.
        *   **Descripción de la Captura 2:** Tras introducir la contraseña, captura la salida que muestra las variables en texto plano (ej. `vcenter_password: qwe123$`). Esto demuestra que los secretos son gestionables pero nunca se exponen.

---

### Sección 4: Automatización de Tareas y Gestión de Configuración (Nivel 4)

**Tu Argumento:** "He trascendido la automatización básica (como `cron`) para adoptar un enfoque de **Infraestructura como Código (IaC)** con Ansible. Toda la configuración del sistema está definida en código versionado. Además, he desarrollado un **playbook de auditoría** que utiliza los modos `check` y `diff` de Ansible para detectar y reportar instantáneamente cualquier desviación de la configuración, garantizando la integridad y la autocuración del sistema."

**Evidencias a Incluir:**
1.  **Código Fuente (Herramienta de Auditoría):**
    *   **Archivos:** `playbooks/audit_and_report.yml` y `scripts/run_audit.sh`. Explica que estos archivos componen una herramienta para verificar la integridad de la configuración.

2.  **Demostración Práctica (Video corto o serie de capturas):**
    *   **Paso 1: Romper algo.** Conéctate a `debian-router` y edita `/etc/nftables.conf`. Comenta una regla, por ejemplo, la que permite el tráfico P2P.
    *   **Paso 2: Auditar.** En tu máquina de control, ejecuta `chmod +x scripts/run_audit.sh` y luego `./scripts/run_audit.sh`.
    *   **Evidencia 4.1: Detección de Desviación de Configuración.** **Captura la salida de la auditoría**. Resalta la sección `diff` donde Ansible muestra en rojo (`-`) la línea que debería estar y en verde (`+`) la línea comentada que encontraste. Este es el "momento eureka".
    *   **Paso 3: Corregir.** Ejecuta `ansible-playbook playbooks/configure_academic_lab.yml`.
    *   **Evidencia 4.2: Autocuración del Sistema.** Captura la salida del playbook donde la tarea "Configure nftables" se muestra como `changed`. Esto prueba que Ansible ha corregido el problema.

---

### Sección 5: Administración del Almacenamiento y Sistemas de Archivos

**Tu Argumento:** "He estructurado el sistema de archivos para separar los datos de las aplicaciones (`/opt/network-portal`) de los datos de usuario, y he implementado directorios compartidos (`/srv/alumnos`, `/srv/profesores`) con permisos de acceso basados en grupos, aplicando el principio de menor privilegio."

**Evidencias a Incluir:**
1.  **Código Fuente (Definición de Estructura):**
    *   **Archivo:** `roles/network-discovery-portal/tasks/main.yml`. Muestra la creación del directorio de la aplicación con `owner: www-data`.
    *   **Archivo:** `roles/academic-users/tasks/main.yml`. Muestra la creación de los directorios `/srv` con los permisos de grupo correctos.

2.  **Pruebas Funcionales (Capturas de pantalla):**
    *   **Evidencia 5.1: Verificación de Permisos de Directorios.**
        *   **Comando:** `ls -ld /srv/alumnos /srv/profesores`
        *   **Descripción de la Captura:** Muestra la salida del comando, resaltando los permisos (`drwxrwxr-x` vs `drwxrwx---`) y los grupos propietarios (`alumnos` vs `profesores`).

    *   **Evidencia 5.2: Prueba de Acceso Denegado entre Roles.**
        *   **Comandos:** `ssh alumno1@2025:db8:101::10`, seguido de `touch /srv/profesores/test.txt`.
        *   **Descripción de la Captura:** Muestra el error `Permission denied` al intentar crear un archivo en el directorio del otro rol.

---

### Sección 6: Conectividad e Integración de SO (Implementación de Centro de Datos)

**Tu Argumento:** "He diseñado y desplegado un **centro de datos virtual heterogéneo**, donde sistemas operativos Linux (Debian, Ubuntu) y Windows coexisten y colaboran en una red IPv6 unificada. La configuración de red es proporcionada de manera centralizada por un router virtual, demostrando una solución de infraestructura integrada y optimizada."

**Evidencias a Incluir:**
1.  **Código Fuente (Orquestación):**
    *   **Archivo:** `inventory/hosts.yml`. Muestra cómo `debian-router`, `ubuntu-pc` y `windows-pc` son gestionados desde un único inventario.
    *   **Archivo:** `roles/debian-ipv6-gateway/templates/dhcpd6.conf.j2`. Muestra las reservas de IP para los clientes Linux y Windows.

2.  **Pruebas Funcionales (Capturas de pantalla):**
    *   **Evidencia 6.1: Conectividad entre Sistemas Operativos Heterogéneos.**
        *   **Comando:** Desde `ubuntu-pc`, ejecuta `ping6 -c 4 2025:db8:101::11`.
        *   **Descripción de la Captura:** Muestra un `ping` exitoso desde un cliente Linux a un cliente Windows a través de la red IPv6.

    *   **Evidencia 6.2: Detección de SO en el Portal de Descubrimiento.**
        *   **Acción:** Abre `http://[2025:db8:101::1]:5000` en tu navegador y haz clic en "Escanear".
        *   **Descripción de la Captura:** Captura la tabla de resultados del portal, donde se vea claramente una fila para `ubuntu-pc` con "Linux" en la columna de SO, y otra para `windows-pc` con "Windows".

---

### Conclusión

Resume cómo tu proyecto no solo cumple, sino que **supera los requisitos del Nivel 4** al utilizar herramientas de automatización profesionales (Ansible) para construir un sistema robusto, seguro y auditable, demostrando una comprensión profunda de los principios de administración de sistemas operativos modernos.