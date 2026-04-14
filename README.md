# Quintero Carrillo-post2-u4

## Descripción

Laboratorio 2 de la Unidad 4 — Lenguaje Ensamblador, correspondiente a la asignatura **Arquitectura de Computadores** de Ingeniería de Sistemas (UFPS, 2026).

El programa implementa y combina tres mecanismos fundamentales del lenguaje ensamblador NASM de 16 bits para DOS:

1. **Macros con parámetros y etiquetas locales** — definidas en `macros.asm` e incluidas con `%include`. Las etiquetas `%%` garantizan que cada expansión de macro genera nombres únicos, evitando colisiones cuando la misma macro se invoca varias veces.
2. **Bucle acumulador con `LOOP`** — el procedimiento `sumar_serie` calcula 1+2+3+…+N usando `CX` como contador decreciente y `AX` como acumulador, preservando `CX` en la pila.
3. **Condicionales `CMP` / `Jcc`** — el procedimiento `comparar_e_imprimir` evalúa dos valores con `CMP` y ramifica el flujo con `JE` (igual) y `JG` (mayor con signo), implementando una estructura if-else completa.

---

## Prerrequisitos

- **DOSBox 0.74** o superior instalado ([dosbox.com](https://www.dosbox.com))
- **NASM 2.14** o superior — `nasm.exe` disponible en el PATH de Windows o en la carpeta de trabajo
- **ALINK** — `alink.exe` en la misma carpeta de trabajo (o en el PATH)
- Post-Contenido 1 completado: entorno DOSBox, NASM y ALINK ya configurados
- Editor de texto plano con codificación **ASCII sin BOM**

---

## Estructura del repositorio

```
Quintero Carrilo-post2-u4/
├── macros.asm         ← biblioteca de macros utilitarias (8 macros documentadas)
├── programa2.asm      ← programa integrador principal
├── README.md          ← este archivo
└── capturas/
    ├── Inicialización del Entorno.png  
    ├── Ensamblado y enlanzado del programa.png   
    ├── Salida esperada.png
    └── macros.png     ← captura: salida completa en DOSBox
```

---

## Compilación y enlazado (terminal de Windows)

Los pasos de ensamblado y enlazado se ejecutan desde **CMD o PowerShell de Windows**, no desde DOSBox.

```cmd
:: Paso 1 — Ensamblar y generar archivo de listado (.lst)
:: El flag -l genera programa2.lst con el código máquina expandido
nasm -f obj programa2.asm -o programa2.obj -l programa2.lst

:: Paso 2 — Enlazar y generar el ejecutable DOS
alink programa2.obj -oEXE -o programa2.exe -entry main
```

> **Tip:** el archivo `programa2.lst` generado por el flag `-l` muestra cada expansión de macro con su código máquina hexadecimal. Ábrelo en un editor de texto para verificar el Checkpoint 1.

Si NASM reporta errores, indica el número de línea exacto:
```
programa2.asm:55: error: parser: instruction expected
```

---

## Ejecución en DOSBox

Copiar `programa2.exe` (y `macros.asm` si está separado) a la carpeta montada en DOSBox y ejecutar:

```
Z:\> mount C C:\ruta\a\tu\carpeta
Z:\> C:
C:\> programa2.exe
```

### Salida esperada en pantalla

```
=== Macros y Control de Flujo ===
[Linea A] Primera impresion
[Linea A] Primera impresion
[Linea A] Primera impresion
[Linea B] Segunda impresion
[Linea B] Segunda impresion
Suma 1+2+3 = 6
El valor mayor es: 9
Los valores son iguales.
Fin del programa.
```

---

## Descripción de los archivos

### `macros.asm` — biblioteca de macros

| Macro | Parámetros | Descripción |
|-------|-----------|-------------|
| `fin_dos` | ninguno | Termina el proceso DOS con código de salida 0 (`INT 21h` función `4Ch`) |
| `nueva_linea` | ninguno | Imprime CR+LF para bajar una línea |
| `print_str` | `%1` = etiqueta cadena | Imprime cadena terminada en `$` (función `09h`) |
| `print_char` | `%1` = valor ASCII | Imprime un carácter único (función `02h`) |
| `leer_char` | ninguno | Lee un carácter sin eco desde teclado (función `07h`), resultado en `AL` |
| `repetir_str` | `%1` = cadena, `%2` = N | Imprime la cadena N veces usando `LOOP` y etiquetas locales `%%` |
| `print_digito` | ninguno (opera en `AL`) | Imprime el dígito decimal (0-9) del nibble bajo de `AL`; preserva `AX` |

### `programa2.asm` — programa integrador

| Procedimiento / Bloque | Descripción |
|-----------------------|-------------|
| `sumar_serie` | Suma 1+2+…+N con `CX`=N; usa `LOOP`; preserva `CX` con `PUSH/POP` |
| `comparar_e_imprimir` | Compara `AX` vs `BX` con `CMP`; ramifica con `JE`/`JG`; preserva `AX`,`BX` |
| `main` — bloque 1 | Imprime encabezado con `print_str titulo` |
| `main` — bloque 2 | Demuestra `repetir_str` con 3 y 2 repeticiones |
| `main` — bloque 3 | Llama a `sumar_serie` con `CX=3`, imprime resultado `6` con `print_digito` |
| `main` — bloque 4 | Compara 9 vs 4 → imprime `"El valor mayor es: 9"` |
| `main` — bloque 5 | Compara 5 vs 5 → imprime `"Los valores son iguales."` |
| `main` — bloque 6 | Imprime mensaje final y termina con macro `fin_dos` |

---

## Conceptos clave demostrados

- **`%include`** inserta `macros.asm` textualmente antes del ensamblado, como si estuviera escrito directamente en el archivo principal.
- **`%%etiqueta`** dentro de una macro genera un nombre único por cada expansión (`%%ciclo` en la primera llamada a `repetir_str` se convierte en `..@1.ciclo`, en la segunda en `..@2.ciclo`, etc.), evitando errores de etiqueta duplicada.
- **`LOOP`** decrementa `CX` y salta si `CX != 0`; por eso `sumar_serie` preserva `CX` con `PUSH` antes de usarlo y lo restaura con `POP` al terminar.
- **`CMP ax, bx`** realiza `AX - BX` sólo para actualizar los flags (`ZF`, `SF`, `OF`), sin modificar los operandos. `JE` salta si `ZF=1`; `JG` salta si `SF=OF` y `ZF=0`.

