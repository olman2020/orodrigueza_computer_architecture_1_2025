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
