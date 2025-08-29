#!/bin/bash

# Script para crear repositorios en Quay usando el role quay-management
# Uso: ./create-repo.sh <namespace> <repository-name> [robot-account]

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para mostrar ayuda
show_help() {
    echo "Uso: $0 <namespace> <repository-name> [robot-account]"
    echo ""
    echo "Argumentos:"
    echo "  namespace       Namespace/organización en Quay"
    echo "  repository-name Nombre del repositorio a crear"
    echo "  robot-account   Nombre del robot account (opcional)"
    echo ""
    echo "Variables de entorno requeridas:"
    echo "  QUAY_TOKEN      Token de API de Quay.io"
    echo ""
    echo "Ejemplo:"
    echo "  export QUAY_TOKEN='tu-token-aqui'"
    echo "  $0 mi-empresa mi-aplicacion deploy-bot"
}

# Verificar argumentos
if [ $# -lt 2 ]; then
    echo -e "${RED}Error: Faltan argumentos requeridos${NC}"
    show_help
    exit 1
fi

NAMESPACE=$1
REPO_NAME=$2
ROBOT_ACCOUNT=${3:-""}

# Verificar variables de entorno
if [ -z "$QUAY_TOKEN" ] && [ -z "$QUAY_USERNAME" ]; then
    echo -e "${RED}Error: Se requiere autenticación${NC}"
    echo "Por favor, proporciona una de estas opciones:"
    echo ""
    echo "Opción 1 - Token directo:"
    echo "export QUAY_TOKEN='tu-token-aqui'"
    echo ""
    echo "Opción 2 - Usuario y contraseña:"
    echo "export QUAY_USERNAME='tu-usuario'"
    echo "export QUAY_PASSWORD='tu-contraseña'"
    exit 1
fi

if [ -n "$QUAY_USERNAME" ] && [ -z "$QUAY_PASSWORD" ]; then
    echo -e "${RED}Error: QUAY_USERNAME está definido pero QUAY_PASSWORD no${NC}"
    exit 1
fi

echo -e "${GREEN}Creando repositorio en Quay...${NC}"
echo "Namespace: $NAMESPACE"
echo "Repositorio: $REPO_NAME"
if [ -n "$ROBOT_ACCOUNT" ]; then
    echo "Robot Account: $ROBOT_ACCOUNT"
fi
echo ""

# Crear archivo de variables temporal
cat > /tmp/quay-vars.yml << EOF
---
EOF

if [ -n "$QUAY_TOKEN" ]; then
    echo "quay_token: \"$QUAY_TOKEN\"" >> /tmp/quay-vars.yml
else
    echo "quay_username: \"$QUAY_USERNAME\"" >> /tmp/quay-vars.yml
    echo "quay_password: \"$QUAY_PASSWORD\"" >> /tmp/quay-vars.yml
fi

cat >> /tmp/quay-vars.yml << EOF
quay_namespace: "$NAMESPACE"
quay_repository_name: "$REPO_NAME"
quay_robot_account: "$ROBOT_ACCOUNT"
quay_repository_description: "Repositorio creado automáticamente"
quay_repository_visibility: "private"
EOF

# Ejecutar el playbook
echo -e "${YELLOW}Ejecutando Ansible playbook...${NC}"
ansible-playbook -i localhost, -c local example-playbook.yml -e @/tmp/quay-vars.yml

# Limpiar archivo temporal
rm -f /tmp/quay-vars.yml

echo ""
echo -e "${GREEN}¡Repositorio creado exitosamente!${NC}"
echo "URL: https://quay.io/repository/$NAMESPACE/$REPO_NAME"

if [ -n "$ROBOT_ACCOUNT" ]; then
    echo "Robot Account: $NAMESPACE+$ROBOT_ACCOUNT"
    echo ""
    echo "Para usar en Docker:"
    echo "docker login quay.io -u $NAMESPACE+$ROBOT_ACCOUNT -p <TOKEN>"
fi
