#!/bin/bash

# Script para ejecutar la migración de imágenes de OpenShift a Quay
# Uso: ./run-migration.sh [dry-run|migrate] [namespace1,namespace2,...]

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para mostrar ayuda
show_help() {
    echo "Uso: $0 [dry-run|migrate] [namespace1,namespace2,...]"
    echo ""
    echo "Comandos:"
    echo "  dry-run    Ejecutar en modo de prueba sin copiar imágenes"
    echo "  migrate    Ejecutar la migración completa"
    echo ""
    echo "Ejemplos:"
    echo "  $0 dry-run"
    echo "  $0 migrate"
    echo "  $0 dry-run default,openshift"
    echo "  $0 migrate kube-system,default"
    echo ""
    echo "Variables de entorno disponibles:"
    echo "  OPENSHIFT_CLUSTER_URL  - URL del cluster de OpenShift"
    echo "  OPENSHIFT_TOKEN        - Token de autenticación"
    echo "  QUAY_ORGANIZATION      - Organización en Quay"
    echo "  QUAY_USERNAME          - Usuario de Quay"
    echo "  QUAY_PASSWORD          - Password de Quay"
}

# Verificar argumentos
if [ $# -eq 0 ]; then
    show_help
    exit 1
fi

MODE=$1
NAMESPACES=${2:-""}

# Validar modo
if [ "$MODE" != "dry-run" ] && [ "$MODE" != "migrate" ]; then
    echo -e "${RED}Error: Modo inválido. Use 'dry-run' o 'migrate'${NC}"
    show_help
    exit 1
fi

# Configurar variables
DRY_RUN="false"
if [ "$MODE" = "dry-run" ]; then
    DRY_RUN="true"
    echo -e "${YELLOW}Ejecutando en modo DRY-RUN (sin cambios reales)${NC}"
else
    echo -e "${GREEN}Ejecutando migración completa${NC}"
fi

# Construir comando ansible-playbook
CMD="ansible-playbook -i inventory.yml pb.yaml -e \"dry_run=$DRY_RUN\""

# Agregar namespaces si se especificaron
if [ -n "$NAMESPACES" ]; then
    CMD="$CMD -e \"openshift_namespaces=[$NAMESPACES]\""
    echo -e "${YELLOW}Procesando namespaces: $NAMESPACES${NC}"
fi

# Agregar variables de entorno si están disponibles
if [ -n "$OPENSHIFT_CLUSTER_URL" ]; then
    CMD="$CMD -e \"openshift_cluster_url=$OPENSHIFT_CLUSTER_URL\""
fi

if [ -n "$OPENSHIFT_TOKEN" ]; then
    CMD="$CMD -e \"openshift_token=$OPENSHIFT_TOKEN\""
fi

if [ -n "$QUAY_ORGANIZATION" ]; then
    CMD="$CMD -e \"quay_organization=$QUAY_ORGANIZATION\""
fi

if [ -n "$QUAY_USERNAME" ]; then
    CMD="$CMD -e \"quay_username=$QUAY_USERNAME\""
fi

if [ -n "$QUAY_PASSWORD" ]; then
    CMD="$CMD -e \"quay_password=$QUAY_PASSWORD\""
fi

echo -e "${GREEN}Comando a ejecutar:${NC}"
echo "$CMD"
echo ""

# Confirmar ejecución en modo migrate
if [ "$MODE" = "migrate" ]; then
    read -p "¿Estás seguro de que quieres ejecutar la migración completa? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Migración cancelada${NC}"
        exit 0
    fi
fi

# Ejecutar comando
echo -e "${GREEN}Ejecutando playbook...${NC}"
eval $CMD

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Playbook ejecutado exitosamente${NC}"
else
    echo -e "${RED}Error ejecutando el playbook${NC}"
    exit 1
fi 