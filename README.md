# Interpolador Bilineal con Ensamblador x86-64 y GUI en Python

Este proyecto realiza una interpolación bilineal sobre un cuadrante de una imagen en escala de grises. El proceso combina una interfaz gráfica desarrollada en Python con un backend en ensamblador NASM que ejecuta el cálculo de interpolación a bajo nivel.

## 🧩 Estructura del Proyecto

```
.
├── interp.asm              # Código en ensamblador NASM que realiza la interpolación
├── main.py                 # Punto de entrada principal de la aplicación
├── GUI.py                  # Interfaz gráfica (Tkinter)
├── Procesador.py       # Lógica de procesamiento de imágenes
├── Constantes.py            # Constantes usadas por la aplicación
├── entrada.jpg             # Imagen de entrada original
├── sin_interpolar.jpg      # Cuadrante original sin interpolar (97x97)
├── interpolado.jpg         # Resultado de la interpolación (385x385)
├── Makefile                # Automatización de compilación y limpieza
└── README.md               # Este archivo
```

## ⚙️ Requisitos

- Python 3.8+
- Paquetes:
  - `numpy`
  - `Pillow` (PIL)
- NASM (ensamblador x86-64)
- `ld` (linker de Linux)

Instalación de dependencias en Debian/Ubuntu:

```bash
sudo apt update
sudo apt install nasm python3 python3-pip
pip install numpy Pillow

```

## 🚀 Ejecución

Usa el `Makefile` para compilar y limpiar automáticamente:

```bash
make run

python3 main.py
```

Esto realizará lo siguiente:
1. Ejecuta la interfaz gráfica.
2. Permite seleccionar un cuadrante de la imagen.
3. Ejecuta el código en ensamblador para interpolar el bloque.
4. Muestra los resultados visualmente.

Para limpiar archivos temporales como `.img`, `.o`, y el binario ensamblado:

```bash
make clean
```

## 🧠 Funcionamiento

1. `main.py` inicializa la GUI.
2. `GUI.py` usa `Procesador` para:
   - Cargar `entrada.jpg`.
   - Extraer el cuadrante seleccionado.
   - Guardarlo como `supra.img`.
   - Ejecutar `interp.asm` para interpolar a 385x385 píxeles.
   - Generar `interpolado.jpg`.

3. `interp.asm` hace todo el procesamiento con interpolación bilineal directamente sobre los píxeles, controlando condiciones de borde y precisión.

## 🖼️ Resultado

- `sin_interpolar.jpg`: bloque original 97x97 sin procesar.
- `interpolado.jpg`: resultado expandido 385x385 con interpolación bilineal aplicada.

## 📄 Licencia

Este proyecto es para fines educativos, creado como parte del curso de Arquitectura de Computadores.

---

Desarrollado por **Olman Isaac Rodríguez Hernández**
