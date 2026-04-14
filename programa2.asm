; ============================================================
; programa2.asm — Laboratorio Post-Contenido 2, Unidad 4
; Arquitectura de Computadores — UFPS 2026
;
; Compilar (cmd Windows):
;   nasm -f obj programa2.asm -o programa2.obj -l programa2.lst
; Enlazar (DOSBox):
;   alink programa2.obj -oEXE programa2.exe
; Ejecutar (DOSBox):
;   programa2.exe
; ============================================================

%include "macros.asm"

; ============================================================
; Segmento de datos
; ============================================================
segment data public align=16 class=DATA use16

    titulo      db "=== Macros y Control de Flujo ===", 0Dh, 0Ah, 24h
    linea_a     db "[Linea A] Primera impresion", 0Dh, 0Ah, 24h
    linea_b     db "[Linea B] Segunda impresion", 0Dh, 0Ah, 24h
    msg_mayor   db "El valor mayor es: ", 24h
    msg_iguales db "Los valores son iguales.", 0Dh, 0Ah, 24h
    msg_fin     db "Fin del programa.", 0Dh, 0Ah, 24h

; ============================================================
; Segmento de codigo
; ============================================================
segment code public align=16 class=CODE use16

..start:                    ; entry point nativo de ALINK (sin runtime)

    mov  ax, data           ; carga direccion del segmento de datos
    mov  ds, ax             ; inicializa DS

    ; Paso 3: encabezado y repeticion con macro
    print_str titulo
    repetir_str linea_a, 3  ; imprime linea_a exactamente 3 veces

    ; Paso 4: suma 1+2+3 = 6 con LOOP
    mov  cx, 3
    call sumar_serie        ; resultado en AX = 6
    print_str msg_mayor
    print_digito            ; imprime "6"
    nueva_linea

    ; Paso 5: comparar 9 vs 4
    mov  ax, 9
    mov  bx, 4
    call comparar_e_imprimir

    ; Paso 5: comparar 5 vs 5
    mov  ax, 5
    mov  bx, 5
    call comparar_e_imprimir

    print_str msg_fin
    fin_dos


; ============================================================
; sumar_serie — suma 1+2+...+N usando LOOP
; Entrada:  CX = N
; Salida:   AX = suma
; Preserva: CX
; ============================================================
sumar_serie:
    push cx
    xor  ax, ax

suma_paso:
    add  ax, cx
    loop suma_paso

    pop  cx
    ret


; ============================================================
; comparar_e_imprimir — compara AX y BX, imprime el mayor
; Entrada:  AX = primer valor, BX = segundo valor
; Preserva: AX, BX
; ============================================================
comparar_e_imprimir:
    push ax
    push bx

    cmp  ax, bx

    je   comp_iguales
    jg   comp_ax_mayor

    ; BX > AX
    print_str msg_mayor
    mov  al, bl
    print_digito
    nueva_linea
    jmp  comp_fin

comp_ax_mayor:
    print_str msg_mayor
    print_digito
    nueva_linea
    jmp  comp_fin

comp_iguales:
    print_str msg_iguales

comp_fin:
    pop  bx
    pop  ax
    ret
