#!/bin/bash

# Ruta al directorio del proyecto
PROYECTO=~/Escritorio/orodrigueza_computer_architecture_1_2025

# Activar entorno virtual
source "$PROYECTO/venv/bin/activate"

# Ejecutar el script de conversión
python3 "$PROYECTO/grayscale_converter.py"

# Desactivar entorno virtual
deactivate

echo "✅ Proceso completo. Archivos generados:"
echo " - imagen_gris.jpg"
echo " - grayscale_values.txt"
echo " - imagen.img"
