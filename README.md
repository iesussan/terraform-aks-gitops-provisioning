

### `README.md`

 Este proyecto despliega la infraestructura necesaria para crear un clúster de Azure Kubernetes Service (AKS) utilizando Terraform y configurando el addon de GitOps (Flux). La integración se realiza con un repositorio público de GitHub que contiene las configuraciones base requeridas, incluyendo un controlador de Ingress NGINX desplegado mediante el controlador de Helm provisto por el operador de Flux como parte del addon de GitOps. Además, se crea un namespace base donde se desplegará el Ingress controller según los manifiestos de Helm. Esta es una plantilla compatible con Azure Developer CLI (azd).

El objetivo de este repositorio es acelerar el despliegue de aplicaciones basadas en las mejores prácticas para gestionar las configuraciones de las aplicaciones y la infraestructura utilizando Git como fuente de la verdad.

## Estructura del Proyecto

```bash
.
├── README.md
├── azure.yaml
├── infra
│   ├── core
│   │   ├── azure-container-registry
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   └── variables.tf
│   │   ├── azure-kubernetes-service
│   │   │   ├── configuration
│   │   │   │   ├── ama-metrics-prometheus-config-configmap.yaml
│   │   │   │   ├── ama-metrics-settings-configmap.yaml
│   │   │   │   └── kube-prometheus-stack-custom-values.yaml
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   ├── providers.tf
│   │   │   └── variables.tf
│   │   ├── azure-log-analytics-workspace
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   └── variables.tf
│   │   ├── azure-resource-group
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   └── variables.tf
│   │   └── azure-virtual-networks
│   │       ├── main.tf
│   │       ├── outputs.tf
│   │       ├── providers.tf
│   │       └── variables.tf
│   ├── environments
│   │   └── dev.tfvars.json
│   ├── main.tf
│   ├── output.tf
│   ├── provider.tf
│   └── variables.tf
└── scripts
    └── deploy_terraform_environment.sh
```

## Configuración y Despliegue

### Prerrequisitos

1. **Azure CLI**: Instala [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).
2. **Terraform**: Instala [Terraform](https://www.terraform.io/downloads.html).
3. **Azure Developer CLI (azd)**: Instala [Azure Developer CLI](https://learn.microsoft.com/es-es/azure/developer/azure-developer-cli).

### Autenticación

Antes de ejecutar el despliegue, asegúrate de autenticarte en Azure y exportar las siguientes variables de entorno:

```bash
azd auth login --tenant-id "TENANT_ID"
export AZURE_SUBSCRIPTION_ID="AZURE_SUBSCRIPTION"
export AZURE_LOCATION="REGION" -> Esta region debe coincidir con la variable resource_group_location definida en el archivo infra/environments/dev.tfvars.json
```

### Desplegar el Entorno

Para desplegar el entorno, ejecuta el siguiente script proporcionándole el nombre del entorno (por ejemplo, `dev`, `stg`, `prd`).

Nota: Actualmente este proyecto solo cuenta con varibales para el ambiente dev.

```bash
./scripts/deploy_terraform_environment.sh dev
```

El script `deploy_terraform_environment.sh` realiza las siguientes acciones:

1. Verifica que el archivo de variables para el entorno especificado exista (`infra/environments/$ENV.tfvars.json`).
2. Copia el archivo de variables al lugar esperado por `azd` (`infra/main.tfvars.json`).
3. Ejecuta `azd up` para desplegar la infraestructura en Azure.
4. Limpia el archivo `main.tfvars.json` después de la ejecución si `azd up` fue exitoso.

### Agregar Nuevos Entornos

Para agregar un nuevo entorno, sigue estos pasos:

1. Crea un archivo de variables para el nuevo entorno, por ejemplo `stg.tfvars.json` para staging o `prd.tfvars.json` para producción.
2. Copia el contenido de `dev.tfvars.json` y ajusta los valores según las necesidades del nuevo entorno.
3. Ejecuta el script `deploy_terraform_environment.sh` con el nuevo nombre del entorno:

```bash
./scripts/deploy_terraform_environment.sh stg
```

### Estructura del Script de Despliegue

```bash
#!/bin/bash

# Asume que el primer argumento es el nombre del entorno (dev, stg, prd)
ENV=$1

# Verifica que el archivo de variables exista
if [ ! -f "infra/environments/$ENV.tfvars.json" ]; then
    echo "El archivo de variables para el entorno '$ENV' no existe."
    exit 1
fi

# Copia el archivo de variables al lugar esperado por azd
cp "infra/environments/$ENV.tfvars.json" "infra/main.tfvars.json"

# Ejecuta azd up y guarda el estado de salida
azd up
status=$?

# Limpia el archivo main.tfvars.json después de la ejecución solo si azd up fue exitoso
if [ $status -eq 0 ]; then
    rm -f "infra/main.tfvars.json"
else
    echo "azd up failed, retaining main.tfvars.json for debugging."
fi

# Sal del script con el estado de salida de azd up
exit $status
```

### Consideraciones Adicionales

- Asegúrate de tener los permisos necesarios en Azure para crear y gestionar recursos.
- Revisa los archivos `tfvars` en el directorio `infra/environments` para personalizar las configuraciones de cada entorno.
- Utiliza `azd down` para destruir la infraestructura cuando ya no sea necesaria.

## Contribuir

Si deseas contribuir a este proyecto, por favor sigue estos pasos:

1. Haz un fork del proyecto.
2. Crea una rama (`git checkout -b feature/tu-feature`).
3. Haz commit de tus cambios (`git commit -am 'Agrega tu feature'`).
4. Haz push a la rama (`git push origin feature/tu-feature`).
5. Abre un Pull Request.

## Licencia

Este proyecto está licenciado bajo los términos de la licencia MIT.
