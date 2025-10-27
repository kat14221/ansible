#!/bin/bash

# Colores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}🔄 Iniciando despliegue automatizado del router Debian${NC}"

# Directorio del proyecto
cd /home/pc02/proyectos/ansible-debian

# Actualizar repositorio
echo -e "${GREEN}📥 Actualizando repositorio...${NC}"
git pull

# Verificar conexión SSH inicial
echo -e "${GREEN}🔍 Verificando conexión SSH...${NC}"
if ! ssh -o ConnectTimeout=5 ansible@172.17.25.126 "echo test" > /dev/null 2>&1; then
    echo -e "${RED}❌ No se puede conectar al router Debian${NC}"
    exit 1
fi

# Ejecutar playbook con actualización de IP
echo -e "${GREEN}⚡ Ejecutando playbook...${NC}"
ansible-playbook playbooks/deploy_with_ip_update.yml -vv

# Verificar resultado
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Despliegue completado exitosamente${NC}"
else
    echo -e "${RED}❌ Error en el despliegue${NC}"
    exit 1
fi