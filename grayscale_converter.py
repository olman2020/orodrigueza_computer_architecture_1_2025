from PIL import Image
import numpy as np
import os

def convert_to_grayscale_and_save(image_path, output_image_path, txt_output_path, bin_output_path):
    # Cargar imagen original
    image = Image.open(image_path)

    # Redimensionar a 390x390 si es más pequeña
    image = image.resize((390, 390))

    # Convertir a escala de grises
    grayscale_image = image.convert('L')
    grayscale_image.save(output_image_path)

    # Obtener valores de los píxeles
    pixels = np.array(grayscale_image)

    # Guardar como texto tipo CSV (para ensamblador si se usa .asciz)
    with open(txt_output_path, 'w') as file:
        for i, row in enumerate(pixels):
            row_values = ",".join(map(str, row))
            if i == len(pixels) - 1:
                file.write(f"{row_values},")
            else:
                file.write(f"{row_values},\n")

    # Guardar como binario crudo
    pixels.astype(np.uint8).tofile(bin_output_path)

    print(f"✅ Imagen convertida a 390x390 y guardada en: {output_image_path}")
    print(f"✅ Matriz como texto guardada en: {txt_output_path}")
    print(f"✅ Imagen cruda guardada en: {bin_output_path}")


# ===== RUTAS EN TU SISTEMA =====
base_path = "/home/olman2020/Escritorio/orodrigueza_computer_architecture_1_2025"
image_path = os.path.join(base_path, "imagen.jpg")
output_image_path = os.path.join(base_path, "imagen_gris.jpg")
txt_output_path = os.path.join(base_path, "grayscale_values.txt")
bin_output_path = os.path.join(base_path, "imagen.img")

# Ejecutar conversión
convert_to_grayscale_and_save(image_path, output_image_path, txt_output_path, bin_output_path)

