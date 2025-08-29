# OpenShift to Quay Image Migration Playbook

Este playbook de Ansible permite migrar imágenes de OpenShift a un registry de Quay usando skopeo.

## Prerrequisitos

- Ansible 2.9+
- OpenShift CLI (oc)
- Skopeo
- Acceso a un cluster de OpenShift
- Credenciales de Quay

## Instalación de dependencias

### En macOS:
```bash
# Instalar OpenShift CLI
brew install openshift-cli

# Instalar Skopeo
brew install skopeo
```

### En Ubuntu/Debian:
```bash
# Instalar OpenShift CLI
curl -LO https://github.com/openshift/oc/releases/download/v4.12.0/openshift-client-linux-4.12.0.tar.gz
tar -xzf openshift-client-linux-4.12.0.tar.gz
sudo mv oc /usr/local/bin/

# Instalar Skopeo
sudo apt-get update
sudo apt-get install skopeo
```

## Configuración

1. **Editar variables por defecto** (`group_vars/all.yml`):
   ```yaml
   openshift_cluster_url: "https://api.tu-cluster.com:6443"
   openshift_token: "tu-token-de-openshift"
   openshift_namespaces: ["default", "openshift", "tu-namespace"]
   
   quay_registry: "quay.io"
   quay_organization: "tu-organizacion"
   quay_username: "tu-usuario"
   quay_password: "tu-password"
   ```

2. **Crear archivo de variables personalizadas** (opcional):
   ```bash
   cp group_vars/all.yml group_vars/local.yml
   # Editar group_vars/local.yml con tus valores
   ```

## Uso

### Ejecutar en modo dry-run (recomendado primero):
```bash
ansible-playbook -i inventory.yml pb.yaml -e "dry_run=true"
```

### Ejecutar la migración completa:
```bash
ansible-playbook -i inventory.yml pb.yaml
```

### Ejecutar con variables personalizadas:
```bash
ansible-playbook -i inventory.yml pb.yaml \
  -e "openshift_cluster_url=https://api.tu-cluster.com:6443" \
  -e "openshift_token=tu-token" \
  -e "quay_organization=tu-org" \
  -e "dry_run=false"
```

### Ejecutar solo para namespaces específicos:
```bash
ansible-playbook -i inventory.yml pb.yaml \
  -e 'openshift_namespaces=["default", "openshift"]'
```

## Variables disponibles

| Variable | Descripción | Default |
|----------|-------------|---------|
| `openshift_cluster_url` | URL del cluster de OpenShift | `https://api.cluster.example.com:6443` |
| `openshift_token` | Token de autenticación de OpenShift | `your-openshift-token-here` |
| `openshift_namespaces` | Lista de namespaces a procesar | `["default", "openshift"]` |
| `quay_registry` | Registry de Quay | `quay.io` |
| `quay_organization` | Organización en Quay | `your-organization` |
| `quay_username` | Usuario de Quay | `your-username` |
| `quay_password` | Password de Quay | `your-password` |
| `image_prefix` | Prefijo para las imágenes en Quay | `""` |
| `dry_run` | Modo de prueba sin copiar | `false` |
| `parallel_jobs` | Número de trabajos paralelos | `5` |

## Estructura del playbook

```
pb-move-images/
├── pb.yaml                    # Playbook principal
├── inventory.yml              # Inventario
├── group_vars/
│   └── all.yml               # Variables por defecto
└── roles/
    ├── openshift-connection/  # Conexión a OpenShift
    ├── image-discovery/       # Descubrimiento de imágenes
    └── image-migration/       # Migración de imágenes
```

## Funcionalidades

- **Conexión automática** a cluster de OpenShift
- **Descubrimiento automático** de imagestreams en namespaces especificados
- **Migración con skopeo** respetando tags originales
- **Modo dry-run** para pruebas sin cambios
- **Manejo de errores** y reportes de éxito/fallo
- **Configuración flexible** mediante variables

## Troubleshooting

### Error: "oc command not found"
Instalar OpenShift CLI siguiendo las instrucciones de instalación.

### Error: "skopeo command not found"
Instalar Skopeo siguiendo las instrucciones de instalación.

### Error de autenticación en OpenShift
Verificar que el token sea válido y tenga permisos suficientes.

### Error de autenticación en Quay
Verificar credenciales de Quay y permisos de la organización.

### Imágenes no se copian
Verificar conectividad de red y permisos de acceso a ambos registries.

## Notas importantes

- El playbook ejecuta en `localhost` ya que necesita acceso a las herramientas CLI
- Se recomienda ejecutar primero en modo `dry_run=true`
- Las imágenes se copian con el mismo tag que en OpenShift
- El proceso puede tomar tiempo dependiendo del número y tamaño de las imágenes
- Asegúrate de tener suficiente espacio en disco para las operaciones de skopeo # pb-move-images
