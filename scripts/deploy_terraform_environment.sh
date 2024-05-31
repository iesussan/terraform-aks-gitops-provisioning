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
