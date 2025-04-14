# Makefile - Proyecto de interpolación bilineal en ASM

ASM = interp.asm
OBJ = interp.o
EXE = interp_exec
IMG = cuadro.img
OUT = salida.img

all: $(EXE)

$(EXE): $(OBJ)
	ld -o $(EXE) $(OBJ)

$(OBJ): $(ASM)
	nasm -f elf64 $(ASM) -o $(OBJ)

run: $(EXE)
	./$(EXE)

clean:
	rm -f *.o *.img *_exec

# Extra: generar imagen con Python GUI
gui:
	python3 GUI.py
