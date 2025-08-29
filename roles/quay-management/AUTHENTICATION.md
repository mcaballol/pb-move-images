# Autenticación en Quay Management Role

Este role soporta dos métodos de autenticación para interactuar con la API de Quay.io.

## Método 1: Token Directo (Recomendado para CI/CD)

Proporciona directamente un token de API de Quay.io:

```yaml
vars:
  quay_token: "tu-token-aqui"
  quay_namespace: "mi-empresa"
  quay_repository_name: "mi-aplicacion"
```

**Ventajas:**
- Más seguro para entornos de producción
- No requiere credenciales de usuario
- Ideal para CI/CD pipelines

**Cómo obtener el token:**
1. Ve a tu perfil en Quay.io
2. Selecciona "Generate Encrypted Password"
3. Copia el token generado

## Método 2: Usuario y Contraseña

Proporciona credenciales de usuario para obtener un token automáticamente:

```yaml
vars:
  quay_username: "tu-usuario"
  quay_password: "tu-contraseña"
  quay_namespace: "mi-empresa"
  quay_repository_name: "mi-aplicacion"
```

**Ventajas:**
- Más fácil de configurar
- El role obtiene el token automáticamente
- Útil para desarrollo y testing

**Consideraciones de seguridad:**
- Las contraseñas se envían a la API de Quay
- No se almacenan permanentemente
- Se recomienda usar tokens para producción

## Variables de Entorno

Puedes usar variables de entorno para configurar la autenticación:

```bash
# Opción 1: Token directo
export QUAY_TOKEN="tu-token-aqui"

# Opción 2: Usuario y contraseña
export QUAY_USERNAME="tu-usuario"
export QUAY_PASSWORD="tu-contraseña"

# Configuración del repositorio
export QUAY_NAMESPACE="mi-empresa"
export QUAY_REPOSITORY_NAME="mi-aplicacion"
export QUAY_ROBOT_ACCOUNT="deploy-bot"
```

## Flujo de Autenticación

1. **Verificación de credenciales**: El role verifica que se proporcione al menos un método de autenticación
2. **Obtención de token**: Si se usan usuario/contraseña, se hace una llamada a `/oauth/access_token`
3. **Validación**: Se verifica que la autenticación sea exitosa
4. **Ejecución**: Se procede con la creación del repositorio usando el token

## Instancias Privadas de Quay

Para instancias privadas de Quay, configura la variable `quay_registry`:

```yaml
vars:
  quay_registry: "quay.miempresa.com"
  quay_username: "usuario"
  quay_password: "contraseña"
```

## Troubleshooting de Autenticación

### Error: "Se requiere autenticación"
- Verifica que hayas proporcionado `quay_token` O (`quay_username` + `quay_password`)

### Error: "Error de autenticación"
- Verifica que las credenciales sean correctas
- Asegúrate de que el usuario tenga permisos en la organización
- Verifica que la instancia de Quay sea accesible

### Error: "Token expirado"
- Los tokens de usuario/contraseña pueden expirar
- Considera usar un token directo para operaciones de larga duración

## Seguridad

- **Nunca** commits credenciales en el código
- Usa variables de entorno o vaults de Ansible
- Para producción, prefiere tokens con permisos limitados
- Considera usar robot accounts específicos para cada repositorio
