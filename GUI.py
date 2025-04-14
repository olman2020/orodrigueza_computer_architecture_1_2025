# constants.py
IMG_WIDTH = 390
IMG_HEIGHT = 390
QUADRANT_SIZE = 97
GRID_DIM = 4  # 4x4 cuadrantes

# ImageProcessor.py
from PIL import Image, ImageTk
import numpy as np
import subprocess
import constants

class Procesador:
    def __init__(self, path):
        self.original_image = Image.open(path).convert('L')
        self.scaled_image = self.original_image.resize((constants.IMG_WIDTH, constants.IMG_HEIGHT))
        self.pixel_matrix = np.array(self.scaled_image)

    def get_tk_image(self):
        return ImageTk.PhotoImage(self.scaled_image)

    def extract_quadrant(self, q_index):
        row = (q_index - 1) // constants.GRID_DIM
        col = (q_index - 1) % constants.GRID_DIM
        y = row * constants.QUADRANT_SIZE
        x = col * constants.QUADRANT_SIZE
        return self.pixel_matrix[y:y+constants.QUADRANT_SIZE, x:x+constants.QUADRANT_SIZE]

    def save_quadrant(self, data, filename):
        with open(filename, 'wb') as f:
            f.write(data.tobytes())

    def convert_to_image(self, binary_file, out_image, width, height):
        with open(binary_file, 'rb') as f:
            data = f.read()
        array = np.frombuffer(data, dtype=np.uint8)
        array = array.reshape((height, width))
        Image.fromarray(array, 'L').save(out_image)

    def interpolate(self, q_index):
        block = self.extract_quadrant(q_index)
        self.save_quadrant(block, 'supra.img')
        subprocess.run(['nasm', '-felf64', '-o', 'interp.o', 'interp.asm'], check=True)
        subprocess.run(['ld', '-o', 'interp_exec', 'interp.o'], check=True)
        subprocess.run(['./interp_exec'], check=True)
        self.convert_to_image('supra.img', 'sin_interpolar.jpg', 97, 97)
        self.convert_to_image('s_supra.img', 'interpolado.jpg', 385, 385)

import tkinter as tk
from tkinter import ttk
from Procesador import Procesador
from PIL import Image, ImageTk
import constants

class InterpolationApp:
    def __init__(self):
        self.window = tk.Tk()
        self.window.title("Interpolación Bilineal por Cuadrante")
        self.window.configure(bg='#2E3440')

        self.processor = Procesador("entrada.jpg")
        self.setup_ui()

    def setup_ui(self):
        style = ttk.Style()
        style.configure("TButton", font=('Segoe UI', 10), padding=6)
        style.configure("TLabel", font=('Segoe UI', 10), background='#2E3440', foreground='white')
        style.configure("TCombobox", font=('Segoe UI', 10))

        # Imagen original
        img = self.processor.get_tk_image()
        self.canvas_in = tk.Canvas(self.window, width=constants.IMG_WIDTH, height=constants.IMG_HEIGHT, bg='white', highlightthickness=1)
        self.canvas_in.create_image(0, 0, image=img, anchor='nw')
        self.canvas_in.image = img
        self.canvas_in.grid(row=0, column=0, padx=10, pady=10)

        # Imagen sin interpolar
        self.canvas_raw = tk.Canvas(self.window, width=97, height=97, bg='white', highlightthickness=1)
        self.canvas_raw.grid(row=0, column=1, padx=10, pady=10)

        # Imagen interpolada
        self.canvas_interp = tk.Canvas(self.window, width=385, height=385, bg='white', highlightthickness=1)
        self.canvas_interp.grid(row=0, column=2, padx=10, pady=10)

        # Controles
        control_frame = tk.Frame(self.window, bg='#2E3440')
        control_frame.grid(row=1, column=0, columnspan=3, pady=15)

        ttk.Label(control_frame, text="Seleccione un cuadrante [1-16]:").pack(side='left', padx=5)
        self.combo = ttk.Combobox(control_frame, values=[str(i) for i in range(1, 17)], width=5, state="readonly")
        self.combo.set("1")
        self.combo.pack(side='left', padx=5)

        ttk.Button(control_frame, text="Ejecutar", command=self.process).pack(side='left', padx=10)

    def process(self):
        try:
            idx = int(self.combo.get())
            self.processor.interpolate(idx)

            ni_img = ImageTk.PhotoImage(Image.open("sin_interpolar.jpg"))
            i_img = ImageTk.PhotoImage(Image.open("interpolado.jpg"))

            self.canvas_raw.create_image(0, 0, image=ni_img, anchor='nw')
            self.canvas_raw.image = ni_img

            self.canvas_interp.create_image(0, 0, image=i_img, anchor='nw')
            self.canvas_interp.image = i_img

        except Exception as e:
            print("Error procesando el cuadrante:", e)

    def run(self):
        self.window.mainloop()

if __name__ == "__main__":
    app = InterpolationApp()
    app.run()