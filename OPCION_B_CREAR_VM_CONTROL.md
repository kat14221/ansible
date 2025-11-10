╔═══════════════════════════════════════════════════════════════════════════════╗
║                                                                               ║
║               ⚙️  OPCIÓN B: CREAR VM CONTROL EN ESXI REMOTO ⚙️             ║
║                                                                               ║
║                    https://168.121.48.254:10101/ui/                          ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝

═══════════════════════════════════════════════════════════════════════════════════

ARQUITECTURA:

Tu Máquina (D:\ansible con código)
            │
            └──→ PUSH A GITHUB
                          │
                          └──→ VM Control (Debian 12 en ESXi remoto)
                                    │
                                    ├──→ PULL DEL REPO
                                    │
                                    └──→ Ejecuta bootstrap_complete.yml
                                            │
                                            ├──→ Crea debian-router (172.17.25.126)
                                            ├──→ Crea ubuntu-pc
                                            └──→ Crea windows-pc
                                                    │
                                                    └──→ Deploy Network Monitor

═══════════════════════════════════════════════════════════════════════════════════

FASE 1: ACCEDER A ESXI Y CREAR VM CONTROL
═════════════════════════════════════════════

PASO 1.1: Abre navegador y ve a vSphere
──────────────────────────────────────────

URL: https://168.121.48.254:10101/ui/#/host/vms

(Si te pide certificado, acepta la excepción)

PASO 1.2: Login a ESXi
──────────────────────

Usuario: root (o el que uses)
Contraseña: [la que tengas]

PASO 1.3: Crear nueva VM
────────────────────────

En la interfaz vSphere:
  1. Haz clic en [Create / Register VM]
  2. Selecciona [Create a new virtual machine]
  3. Completa:

     Nombre: debian-control
     Guest OS: Linux → Debian 12 x64
     Firmware: UEFI
     CPUs: 2
     RAM: 4 GB
     Disco: 20 GB (thin provisioned)
     Red: VM Network (o la red con acceso a 172.17.25.0/24)

  4. Haz clic [Finish]

PASO 1.4: Instalar Debian 12
─────────────────────────────

  1. Carga ISO de Debian 12
     (En vSphere: VM → Edit Settings → CD/DVD Drive → conecta ISO)
  
  2. Power On (enciende VM)
  
  3. Sigue instalador Debian:
     - Usuario: ansible
     - Contraseña: ansible (o tu contraseña preferida)
     - Hostname: debian-control
     - Particionar: LVM automático
     - Selecciona: SSH Server + Standard utilities
  
  4. Al terminar, reinicia

PASO 1.5: Obtener IP de la VM
──────────────────────────────

  En la VM (por consola ESXi):
  
  ip addr show
  
  Anota la IP (debería ser 172.17.25.x)
  
  Si no tiene IP, configura manualmente:
  
  sudo ip addr add 172.17.25.126/24 dev eth0
  sudo ip route add default via 172.17.25.1

═══════════════════════════════════════════════════════════════════════════════════

FASE 2: CONECTARSE A VM CONTROL Y CONFIGURARLA
════════════════════════════════════════════════

PASO 2.1: SSH a VM Control
────────────────────────────

Desde tu máquina (PowerShell):

  ssh ansible@172.17.25.126
  
  Contraseña: ansible

Deberías ver:

  ansible@debian-control:~$

PASO 2.2: Instalar Ansible y Git
──────────────────────────────────

En debian-control, ejecuta:

  sudo apt update
  sudo apt install -y ansible git python3-pip curl wget

Verifica:

  ansible --version
  git --version

PASO 2.3: Descargar repositorio
────────────────────────────────

  cd /home/ansible
  git clone https://github.com/kat14221/ansible.git
  cd ansible

Verifica que esté:

  ls -la
  
  Deberías ver: playbooks/, roles/, inventory/, etc.

═══════════════════════════════════════════════════════════════════════════════════

FASE 3: HACER PUSH DEL CÓDIGO NUEVO A GITHUB
══════════════════════════════════════════════

PASO 3.1: Desde tu máquina (D:\ansible), haz push
───────────────────────────────────────────────────

PowerShell en D:\ansible:

  git add -A
  git commit -m "feat: Network Monitor Dashboard + Extended Topology
  - Flask-based web dashboard
  - 3 detection methods for IPv6 devices
  - REST API with 8 endpoints
  - Bootstrap 5 responsive frontend
  - Ansible role for automated deployment
  - Extended topology (GNS3 + WiFi)
  - Complete documentation"
  
  git push origin main

Verifica en GitHub que se subieron los cambios.

═══════════════════════════════════════════════════════════════════════════════════

FASE 4: HACER PULL EN VM CONTROL
═════════════════════════════════

PASO 4.1: En debian-control, hacer pull
─────────────────────────────────────────

Aún en SSH en debian-control:

  cd /home/ansible/ansible
  git pull origin main

Deberías ver archivos nuevos:
  - roles/network-monitor/ (la herramienta)
  - docs/TOPOLOGIA_EXTENDIDA.md
  - scripts/deploy_and_run.sh
  - etc.

Verifica:

  ls -la roles/network-monitor/

═══════════════════════════════════════════════════════════════════════════════════

FASE 5: EJECUTAR BOOTSTRAP_COMPLETE.YML
════════════════════════════════════════

PASO 5.1: Instalar dependencias Ansible
──────────────────────────────────────────

En debian-control:

  pip3 install pyvmomi netaddr passlib

PASO 5.2: Verificar inventory y variables
────────────────────────────────────────────

  cat inventory/hosts.yml | head -50
  
  (Verifica que esxi-vmware-host esté configurado con la IP correcta: 172.17.25.1)

PASO 5.3: Configurar vault
────────────────────────────

  cp group_vars/all/vault.yml.template group_vars/all/vault.yml
  
  (Edita vault.yml con credenciales ESXi si es necesario)

PASO 5.4: Ejecutar bootstrap completo
───────────────────────────────────────

  ansible-playbook playbooks/bootstrap_complete.yml \
    -i inventory/hosts.yml \
    -u root \
    -k

(Te pedirá contraseña SSH de ESXi - usa la del root)

⏱️  Esto tardará ~5-10 minutos por cada VM que cree.

Verás:

  PLAY [Crear VM Debian Router] ***
  TASK [Crear VM Router Debian] ***
  ...
  PLAY [Crear VMs de Usuario] ***
  ...
  PLAY [Mostrar Resumen de Creación] ***
  ✅ VMs creadas exitosamente

═══════════════════════════════════════════════════════════════════════════════════

FASE 6: VERIFICAR NUEVAS VMS EN ESXI
═════════════════════════════════════

PASO 6.1: Vuelve a vSphere y verifica
────────────────────────────────────────

En https://168.121.48.254:10101/ui/#/host/vms

Deberías ver 3 VMs nuevas:
  • vm-debian-router (172.17.25.126)
  • vm-ubuntu-pc (172.17.25.10)
  • vm-windows-pc (172.17.25.11)

PASO 6.2: Espera a que terminen instalaciones
───────────────────────────────────────────────

Las VMs pueden estar instalando OS. Espera a que:
  1. Terminen la instalación
  2. Reinicien
  3. Estén en estado "Running"

═══════════════════════════════════════════════════════════════════════════════════

FASE 7: CONFIGURAR DEBIAN-ROUTER Y DESPLEGAR NETWORK MONITOR
══════════════════════════════════════════════════════════════

PASO 7.1: SSH a debian-router (la nueva VM creada)
────────────────────────────────────────────────────

Espera a que debian-router esté completamente instalada.

Desde tu máquina:

  ssh ansible@172.17.25.126
  
  (Nota: es la misma IP que debian-control... revisar IP de debian-router)

PASO 7.2: Instalar Ansible y Git en debian-router
────────────────────────────────────────────────────

  sudo apt update
  sudo apt install -y ansible git python3-pip curl

PASO 7.3: Clonar repositorio
──────────────────────────────

  cd /home/ansible
  git clone https://github.com/kat14221/ansible.git
  cd ansible

PASO 7.4: Desplegar Network Monitor
──────────────────────────────────────

  chmod +x scripts/deploy_and_run.sh
  bash scripts/deploy_and_run.sh

Espera ~2-3 minutos.

Verás:

  ╔═════════════════════════════════════════╗
  ║ 🎉 SISTEMA LEVANTADO 🎉               ║
  ╚═════════════════════════════════════════╝
  
  Network Monitor disponible en:
  http://172.17.25.126:5000

═══════════════════════════════════════════════════════════════════════════════════

FASE 8: ACCEDER AL NETWORK MONITOR
═══════════════════════════════════

PASO 8.1: Abre navegador
──────────────────────────

  http://172.17.25.126:5000

PASO 8.2: Usa el dashboard
────────────────────────────

  1. Haz clic [Escanear Red]
  2. Espera ~10 segundos
  3. Verás tabla con dispositivos detectados
  4. Prueba búsqueda, SSH, Ping, Exportar

═══════════════════════════════════════════════════════════════════════════════════

RESUMEN RÁPIDO (COPIAR Y PEGAR)
════════════════════════════════

EN TU MÁQUINA (D:\ansible PowerShell):
────────────────────────────────────────

git add -A
git commit -m "feat: Network Monitor + Extended Topology"
git push origin main

EN DEBIAN-CONTROL (SSH):
─────────────────────────

cd /home/ansible/ansible
git pull origin main
ansible-playbook playbooks/bootstrap_complete.yml -i inventory/hosts.yml -u root -k

[Espera 5-10 minutos a que se creen las VMs]

EN DEBIAN-ROUTER (SSH a nueva VM):
───────────────────────────────────

cd /home/ansible/ansible
chmod +x scripts/deploy_and_run.sh
bash scripts/deploy_and_run.sh

[Espera 2-3 minutos]

EN NAVEGADOR:
──────────────

http://172.17.25.126:5000

✅ ¡LISTO!

═══════════════════════════════════════════════════════════════════════════════════

TROUBLESHOOTING
═════════════════

❌ No puedo conectar a debian-control?
   → Verifica que la VM esté running en vSphere
   → Verifica que tenga IP: ip addr show
   → Verifica firewall: sudo ufw status

❌ Ansible no se instala?
   → sudo apt install -y python3 python3-pip
   → pip3 install ansible

❌ bootstrap_complete.yml falla?
   → Verifica credenciales ESXi en vault.yml
   → Verifica que pyvmomi esté instalado: pip3 install pyvmomi

❌ Network Monitor no responde?
   → Ver logs: tail -f /var/log/network-monitor/app.log
   → Reiniciar: sudo systemctl restart network-monitor

═══════════════════════════════════════════════════════════════════════════════════

ARQUITECTURA FINAL
═══════════════════

Tu Máquina (Windows con Git)
        │
        ├─→ GitHub (código subido)
        │
        └─→ ESXi Remoto (https://168.121.48.254:10101/)
                    │
                    ├─→ debian-control (VM Control: corre Ansible)
                    │         │
                    │         └─→ Ejecuta bootstrap_complete.yml
                    │
                    ├─→ debian-router (172.17.25.126): Network Monitor
                    │         │
                    │         └─→ http://172.17.25.126:5000 ← ACCESO AQUÍ
                    │
                    ├─→ ubuntu-pc (172.17.25.10): Cliente IPv6
                    │
                    └─→ windows-pc (172.17.25.11): Cliente Windows

═══════════════════════════════════════════════════════════════════════════════════

¡VAMOS! 🚀

PRÓXIMO PASO: Accede a https://168.121.48.254:10101/ui/#/host/vms y crea debian-control

═══════════════════════════════════════════════════════════════════════════════════
