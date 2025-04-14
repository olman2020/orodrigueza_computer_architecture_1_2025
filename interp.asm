; interp.asm - Interpolación bilineal corregida con control de bordes
BITS 64

section .bss
entrada resb 97*97
salida  resb 385*385
pix     resb 4
temp    resq 4

section .data
archivo_entrada db "supra.img", 0
archivo_salida  db "s_supra.img", 0

section .text
global _start

_start:
    ; Abrir imagen
    mov rax, 2
    lea rdi, [rel archivo_entrada]
    xor rsi, rsi
    xor rdx, rdx
    syscall
    mov r12, rax

    ; Leer a buffer
    mov rax, 0
    mov rdi, r12
    lea rsi, [rel entrada]
    mov rdx, 97*97
    syscall

    ; Cerrar
    mov rax, 3
    mov rdi, r12
    syscall

    ; Punteros base
    lea rsi, [rel entrada]
    lea rdi, [rel salida]

    xor r13, r13 ; fila
.filas:
    xor r14, r14 ; col
.columnas:
    ; A
    mov r8, r13
    imul r8, 97
    add r8, r14
    movzx eax, byte [rsi + r8]
    mov [pix], al

    ; B
    cmp r14, 96
    je .skip_B
    movzx ebx, byte [rsi + r8 + 1]
    mov [pix+1], bl
.skip_B:
    ; Inicializar C y D con cero para evitar residuos si no se asignan
    mov byte [pix+2], 0
    mov byte [pix+3], 0

    ; C y D
    cmp r13, 96
    je .discard_CD
    mov r9, r13
    inc r9
    imul r9, 97
    add r9, r14
    movzx ecx, byte [rsi + r9]
    mov [pix+2], cl
    cmp r14, 96
    je .discard_CD
    movzx edx, byte [rsi + r9 + 1]
    mov [pix+3], dl
.discard_CD:

    ; Coordenada base de salida
    mov r10, r13
    imul r10, 4
    imul r10, 385
    mov r11, r14
    imul r11, 4
    add r10, r11

    ; A
    mov al, [pix]
    mov [rdi + r10], al

    ; B
    cmp r14, 96
    je .skip_write_BD
    mov al, [pix+1]
    mov [rdi + r10 + 3], al

    ; D
    cmp r13, 96
    je .skip_write_BD
    cmp r14, 96
    je .skip_write_BD
    mov al, [pix+3]
    mov rax, r13
    add rax, 1
    imul rax, 4
    add rax, 3
    imul rax, 385
    mov rbx, r14
    imul rbx, 4
    add rbx, 3
    add rax, rbx
    mov [rdi + rax], al
.skip_write_BD:

    ; C
    cmp r13, 96
    je .skip_C
    mov al, [pix+2]
    mov rax, r13
    imul rax, 4
    add rax, 3
    imul rax, 385
    mov rbx, r14
    imul rbx, 4
    add rax, rbx
    mov [rdi + rax], al
.skip_C:

    ; Interpolaciones horizontales
    cmp r14, 96
    je .skip_interp_h
    mov al, [pix]
    mov bl, 2
    mov r8b, [pix+1]
    mov r9b, 1
    lea r15, [rdi + r10 + 1]
    call interpolar_peso

    mov al, [pix]
    mov bl, 1
    mov r8b, [pix+1]
    mov r9b, 2
    lea r15, [rdi + r10 + 2]
    call interpolar_peso
.skip_interp_h:

    ; Interpolaciones verticales
    cmp r13, 96
    je .skip_interp_v
    cmp r14, 96
    je .skip_interp_v

    ; --- c1 = (2/3)*A + (1/3)*C → [4i+1][4j]
    mov al, [pix]
    mov bl, 2
    mov r8b, [pix+2]
    mov r9b, 1
    mov rax, r13
    imul rax, 4
    add rax, 1                ; fila +1
    imul rax, 385
    mov rbx, r14
    imul rbx, 4
    ; columna = [4j]
    add rax, rbx
    lea r15, [rdi + rax]
    mov [temp], r15
    call interpolar_peso

    ; --- g1 = (1/3)*A + (2/3)*C → [4i+2][4j]
    mov al, [pix]
    mov bl, 1
    mov r8b, [pix+2]
    mov r9b, 2
    mov rax, r13
    imul rax, 4
    add rax, 2                ; fila +2
    imul rax, 385
    mov rbx, r14
    imul rbx, 4
    add rax, rbx
    lea r15, [rdi + rax]
    mov [temp+16], r15
    call interpolar_peso


    ; --- c2 y g2 solo si col < 96
    cmp r13, 96
    je .skip_diag
    cmp r14, 96
    je .skip_diag

    ; --- c2 = (2/3)*B + (1/3)*D → [4i+1][4j+3]
    mov al, [pix+1]
    mov bl, 2
    mov r8b, [pix+3]
    mov r9b, 1
    mov rax, r13
    imul rax, 4
    add rax, 1                ; fila +1
    imul rax, 385
    mov rbx, r14
    imul rbx, 4
    add rbx, 3                ; col +3
    add rax, rbx
    lea r15, [rdi + rax]
    mov [temp+8], r15
    call interpolar_peso
    
    ; --- g2 = (1/3)*B + (2/3)*D → [4i+2][4j+3]
    mov al, [pix+1]
    mov bl, 1
    mov r8b, [pix+3]
    mov r9b, 2
    mov rax, r13
    imul rax, 4
    add rax, 2                ; fila +2
    imul rax, 385
    mov rbx, r14
    imul rbx, 4
    add rbx, 3                ; col +3
    add rax, rbx
    lea r15, [rdi + rax]
    mov [temp+24], r15
    call interpolar_peso

    ; --- d = (2/3)*c1 + (1/3)*c2 → [4i+1][4j+1]
    mov r15, [temp]           ; c1
    mov al, [r15]
    mov bl, 2
    mov r12, [temp+8]         ; c2
    mov r8b, [r12]
    mov r9b, 1
    mov rax, r13
    imul rax, 4
    add rax, 1                ; fila +1
    imul rax, 385
    mov rbx, r14
    imul rbx, 4
    add rbx, 1                ; col +1
    add rax, rbx
    lea r15, [rdi + rax]
    call interpolar_peso

    ; --- e = (1/3)*c1 + (2/3)*c2 → [4i+1][4j+2]
    mov r15, [temp]           ; c1
    mov al, [r15]
    mov bl, 1
    mov r12, [temp+8]         ; c2
    mov r8b, [r12]
    mov r9b, 2
    mov rax, r13
    imul rax, 4
    add rax, 1                ; fila +1
    imul rax, 385
    mov rbx, r14
    imul rbx, 4
    add rbx, 2                ; col +2
    add rax, rbx
    lea r15, [rdi + rax]
    call interpolar_peso

    ; --- h = (2/3)*g1 + (1/3)*g2 → [4i+2][4j+1]
    mov r15, [temp+16]        ; g1
    mov al, [r15]
    mov bl, 2
    mov r12, [temp+24]        ; g2
    mov r8b, [r12]
    mov r9b, 1
    mov rax, r13
    imul rax, 4
    add rax, 2                ; fila +2
    imul rax, 385
    mov rbx, r14
    imul rbx, 4
    add rbx, 1                ; col +1
    add rax, rbx
    lea r15, [rdi + rax]
    call interpolar_peso

    ; --- i = (1/3)*g1 + (2/3)*g2 → [4i+2][4j+2]
    mov r15, [temp+16]        ; g1
    mov al, [r15]
    mov bl, 1
    mov r12, [temp+24]        ; g2
    mov r8b, [r12]
    mov r9b, 2
    mov rax, r13
    imul rax, 4
    add rax, 2                ; fila +2
    imul rax, 385
    mov rbx, r14
    imul rbx, 4
    add rbx, 2                ; col +2
    add rax, rbx
    lea r15, [rdi + rax]
    call interpolar_peso

.skip_diag:
   
.skip_interp_v:

    inc r14
    cmp r14, 97
    jl .columnas
    inc r13
    cmp r13, 97
    jl .filas

    ; Último píxel
    movzx eax, byte [rsi + 96*97 + 96]
    mov rcx, 384
    imul rcx, 385
    add rcx, 384
    mov [rdi + rcx], al

    ; Guardar salida
    mov rax, 2
    lea rdi, [rel archivo_salida]
    mov rsi, 577
    mov rdx, 0o666
    syscall
    mov r12, rax

    mov rax, 1
    mov rdi, r12
    lea rsi, [rel salida]
    mov rdx, 385*385
    syscall

    mov rax, 3
    mov rdi, r12
    syscall

    mov rax, 60
    xor rdi, rdi
    syscall

interpolar_peso:
    movzx ax, al
    movzx bx, bl
    imul ax, bx
    movzx cx, r8b
    movzx dx, r9b
    imul cx, dx
    add ax, cx
    add ax, 1
    mov bx, 3
    xor dx, dx
    div bx
    cmp ax, 255
    jbe .ok
    mov ax, 255
.ok:
    mov [r15], al
    ret
