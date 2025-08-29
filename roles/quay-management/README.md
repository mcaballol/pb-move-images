# Quay Management Role

Este role de Ansible permite crear repositorios en Quay.io y asignar permisos de escritura a robot accounts.

## Funcionalidades

- Crear repositorios en Quay.io
- Crear robot accounts si no existen
- Asignar permisos de escritura a robot accounts
- Configuración flexible de visibilidad y tipo de repositorio

## Requisitos

- Token de API de Quay.io con permisos de administración
- Acceso a la API de Quay.io
- Ansible 2.9+

## Variables

### Variables Requeridas

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `quay_namespace` | Namespace/organización en Quay | `mi-empresa` |
| `quay_repository_name` | Nombre del repositorio | `mi-aplicacion` |

**Autenticación (una de estas opciones es requerida):**
| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `quay_token` | Token de API de Quay.io | `abc123...` |
| `quay_username` + `quay_password` | Credenciales de usuario | `usuario`, `contraseña` |

### Variables Opcionales

| Variable | Descripción | Valor por defecto |
|----------|-------------|-------------------|
| `quay_registry` | Registro de Quay | `quay.io` |
| `quay_api_url` | URL de la API de Quay | `https://{{ quay_registry }}` |
| `quay_repository_description` | Descripción del repositorio | `Repository created by Ansible` |
| `quay_repository_visibility` | Visibilidad del repositorio | `private` |
| `quay_repo_kind` | Tipo de repositorio | `image` |
| `quay_robot_account` | Nombre del robot account | No configurado |

## Uso

### Ejemplo básico

```yaml
- hosts: localhost
  gather_facts: false
  vars:
    quay_token: "{{ lookup('env', 'QUAY_TOKEN') }}"
    quay_namespace: "mi-empresa"
    quay_repository_name: "mi-aplicacion"
    quay_robot_account: "deploy-bot"
  
  roles:
    - quay-management
```

### Con variables de entorno

```bash
export QUAY_TOKEN="tu-token-aqui"
export QUAY_NAMESPACE="mi-empresa"
export QUAY_REPOSITORY_NAME="mi-aplicacion"
export QUAY_ROBOT_ACCOUNT="deploy-bot"

ansible-playbook playbook.yml
```

### Ejemplo completo en playbook

```yaml
---
- name: Manage Quay repositories
  hosts: localhost
  gather_facts: false
  
  vars:
    quay_token: "{{ lookup('env', 'QUAY_TOKEN') }}"
    quay_namespace: "{{ lookup('env', 'QUAY_NAMESPACE') }}"
    quay_repository_name: "{{ lookup('env', 'QUAY_REPOSITORY_NAME') }}"
    quay_robot_account: "{{ lookup('env', 'QUAY_ROBOT_ACCOUNT') }}"
    quay_repository_description: "Aplicación de ejemplo"
    quay_repository_visibility: "private"
  
  roles:
    - quay-management
```

## Permisos de Robot Account

El role crea automáticamente un robot account si no existe y le asigna permisos de escritura al repositorio. El formato del robot account es:

```
{namespace}+{robot_name}
```

Por ejemplo: `mi-empresa+deploy-bot`

## Estados de Respuesta

- **200/201**: Repositorio creado exitosamente
- **409**: Repositorio ya existe (no es un error)
- **Otros códigos**: Error en la creación

## Notas de Seguridad

- El token de Quay debe tener permisos de administración
- Los repositorios se crean como privados por defecto
- El robot account se crea solo si se especifica `quay_robot_account`

## Troubleshooting

### Error de autenticación
Verifica que el `quay_token` sea válido y tenga los permisos necesarios.

### Error de namespace
Asegúrate de que el namespace existe y tienes permisos para crear repositorios en él.

### Error de permisos
El token debe tener permisos de administración en la organización/namespace especificado.
