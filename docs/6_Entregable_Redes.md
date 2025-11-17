# 🌐 Guía para el Entregable: Redes de Datos

**Objetivo:** Presentar un informe técnico de **Nivel 4 (Sobresaliente)** que documente el diseño, implementación, seguridad y validación de una red IPv6 de nivel empresarial, destacando el uso de la automatización para garantizar la consistencia y la auditabilidad.

---

## 📝 Estructura del Informe

### Sección 1: Diseño de Topología y Plan de Direccionamiento (Nivel 4)

**Tu Argumento:** "He diseñado una topología de red híbrida (física y virtual) que segmenta el entorno de laboratorio (`Red Fernandez`) del backbone de la red principal (`Red Laboratorio`). El plan de direccionamiento IPv6 es jerárquico y está documentado, utilizando DHCPv6 para una gestión centralizada y reservas estáticas para servicios críticos, eliminando la impredictibilidad de SLAAC."

**Evidencias a Incluir:**
1.  **Documentación de Diseño (Archivos clave):**
    *   **Archivo:** `docs/3_Topologia_Red.md` y `docs/NIVEL4_TOPOLOGIA.md`. Incluye los diagramas ASCII y las tablas de dispositivos directamente en tu informe. Estos documentos son la prueba principal de tu diseño.

2.  **Código Fuente (Implementación del Plan):**
    *   **Archivo:** `roles/debian-ipv6-gateway/templates/dhcpd6.conf.j2`. Muestra la implementación práctica de tu plan de direccionamiento: el rango dinámico (`::10` a `::99`) y las reservas de IP para `ubuntu-pc` y `windows-pc`.
    *   **Archivo:** `roles/debian-ipv6-gateway/templates/radvd.conf.j2`. Muestra cómo deshabilitaste `AdvAutonomous`, una decisión de diseño clave para forzar el uso de DHCPv6 y tener control total sobre las IPs.

---

### Sección 2: Implementación de Enrutamiento y Servicios de Red (Nivel 4)

**Tu Argumento:** "He configurado un router Linux (`debian-router`) como el núcleo de la red, proveyendo servicios esenciales de Capa 3 como enrutamiento estático, anuncios de router (RA), DHCPv6 y, crucialmente, **NAT (Masquerade)** para proveer acceso a internet a toda la red interna. Toda la configuración es declarativa y automatizada con Ansible, garantizando una implementación consistente."

**Evidencias a Incluir:**
1.  **Código Fuente (Configuración del Router):**
    *   **Archivo:** `roles/debian-ipv6-router/tasks/main.yml`. Muestra la tarea que habilita el forwarding IPv6 (`net.ipv6.conf.all.forwarding=1`), convirtiendo a la máquina en un router.
    *   **Archivo:** `docs/NIVEL4_TOPOLOGIA.md`. Incluye la sección de configuración del router físico Cisco IOS, mostrando la ruta estática `ipv6 route 2025:db8:101::/64 via 2025:db8:101::1`.

2.  **Pruebas Funcionales (Capturas de pantalla):**
    *   **Evidencia 2.1: Tabla de Enrutamiento del Gateway.**
        *   **Comando:** En `debian-router`, ejecuta `ip -6 route`.
        *   **Descripción de la Captura:** Captura la salida y resalta la ruta por defecto y la ruta estática hacia la `Red Laboratorio` (`2025:db8:100::/64`).

    *   **Evidencia 2.2: Tabla de Enrutamiento del Cliente.**
        *   **Comando:** En `ubuntu-pc`, ejecuta `ip -6 route`.
        *   **Descripción de la Captura:** Captura la salida y resalta la línea `default via 2025:db8:101::1`, demostrando que ha aprendido su gateway a través de RA.

    *   **Evidencia 2.3: Prueba de Conectividad Inter-Red.**
        *   **Comando:** Desde `ubuntu-pc`, ejecuta `ping6 -c 4 2025:db8:100::2`.
        *   **Descripción de la Captura:** Muestra un `ping` exitoso desde la red virtual `101` a la red física `100`, probando que el enrutamiento funciona de extremo a extremo.

---

### Sección 3: Gestión de Conectividad, Seguridad y Servicios de Aplicación (Nivel 4)

**Tu Argumento:** "He implementado una política de seguridad de red mediante un firewall `nftables` que no solo permite la conectividad P2P controlada, sino que también implementa **NAT para el acceso a internet**. Además, he desplegado servicios de aplicación (servidor web, portal de descubrimiento) que operan nativamente sobre IPv6, y he utilizado herramientas de análisis de tráfico como `tcpdump` y `nmap` para validar y monitorear la red."

**Evidencias a Incluir:**
1.  **Código Fuente (Políticas y Servicios):**
    *   **Archivo:** `roles/debian-ipv6-router/templates/nftables.conf.j2`. Explica la regla `forward` que permite el tráfico entre `2025:db8:100::/64` y `2025:db8:101::/64`, justificando por qué es necesaria para los juegos P2P.
    *   **Archivo:** `roles/network-monitor/files/app.py`. Explica que este es el backend de una herramienta de monitoreo personalizada que utiliza `nmap` para escanear la red.

2.  **Pruebas Funcionales (Capturas de pantalla):**
    *   **Evidencia 3.1: Verificación de Reglas de Firewall.**
        *   **Comando:** En `debian-router`, ejecuta `sudo nft list ruleset`.
        *   **Descripción de la Captura:** Captura la salida y resalta la regla en la cadena `forward` que contiene `ip6 saddr 2025:db8:100::/64 ip6 daddr 2025:db8:101::/64 accept`.

    *   **Evidencia 3.2: Demostración de Juego P2P Inter-Red.**
        *   **Acción:** Inicia una partida en una máquina y únete desde otra en una red diferente.
        *   **Descripción de la Captura:** Una captura de pantalla que muestre a ambos jugadores en la misma partida. Si es posible, muestra las consolas de ambas máquinas con sus respectivas IPs visibles.

    *   **Evidencia 3.3 (Opcional pero potente): Análisis de Tráfico con Wireshark.**
        *   **Acción:** Ejecuta `tcpdump` en `debian-router` mientras haces un `ping` desde `ubuntu-pc` a la red `100`. Copia el archivo `.pcap` a tu máquina y ábrelo con Wireshark.
        *   **Descripción de la Captura:** Captura la ventana de Wireshark mostrando los paquetes `ICMPv6 Echo Request` y `Echo Reply` fluyendo entre las dos subredes.

---

### Sección 4: Automatización y Validación de la Red (Nivel 4)

**Tu Argumento:** "Toda la infraestructura de red se gestiona como **Infraestructura como Código (IaC)**. He utilizado Ansible no solo para el despliegue inicial, sino también para la **validación continua y la auditoría**. He creado un playbook específico que, en modo `check`, puede detectar cualquier cambio no autorizado en la configuración de la red (como una regla de firewall modificada), garantizando la integridad y la capacidad de recuperación automática del sistema."

**Evidencias a Incluir:**
1.  **Código Fuente (Orquestación y Auditoría):**
    *   **Archivo:** `playbooks/configure_academic_lab.yml`. Tu playbook principal que orquesta todo el despliegue.
    *   **Archivo:** `scripts/run_audit.sh`. Tu herramienta de auditoría personalizada.

2.  **Demostración Práctica (Video corto o serie de capturas):**
    *   **Paso 1: Romper la red.** Conéctate a `debian-router` y edita `/etc/nftables.conf`. Comenta la regla que permite el tráfico P2P.
    *   **Paso 2: Auditar.** En tu máquina de control, ejecuta `./scripts/run_audit.sh`.
    *   **Evidencia 4.1: Detección de Falla de Configuración de Red.** **Captura la salida de la auditoría**. Resalta la sección `diff` donde Ansible te muestra exactamente qué línea del firewall fue modificada.
    *   **Paso 3: Corregir.** Ejecuta `ansible-playbook playbooks/configure_academic_lab.yml`.
    *   **Evidencia 4.2: Recuperación Automática de la Red.** Captura la salida del playbook donde la tarea "Configure nftables" se muestra como `changed`, probando que la configuración de red fue restaurada automáticamente.

---

### Conclusión

Resume cómo tu proyecto demuestra un dominio sobresaliente de los conceptos de redes, desde el diseño de bajo nivel (direccionamiento, enrutamiento) hasta la gestión de alto nivel (servicios, seguridad) y la operación moderna (automatización, IaC). Enfatiza que tu solución no es solo funcional, sino también robusta, segura y mantenible gracias al uso de Ansible.