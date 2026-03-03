; ==============================================================================
; boot.asm - Ponto de entrada do Kernel
; ==============================================================================

; constantes para o cabeçalho Multiboot
MBALIGN     equ  1<<0                   ; Alinhar módulos carregados nos limites da página
MEMINFO     equ  1<<1                   ; Fornecer mapa de memória
FLAGS       equ  MBALIGN | MEMINFO      ; Flags do Multiboot
MAGIC       equ  0x1BADB002             ; 'Número Mágico' que o GRUB procura
CHECKSUM    equ -(MAGIC + FLAGS)        ; Prova de que somos um kernel Multiboot

; ------------------------------------------------------------------------------
; Seção Multiboot
; O GRUB vai procurar essa assinatura nos primeiros 8KB do arquivo binário final.
; ------------------------------------------------------------------------------
section .multiboot
align 4
    dd MAGIC
    dd FLAGS
    dd CHECKSUM

; ------------------------------------------------------------------------------
; Seção BSS (Block Started by Symbol)
; Usada para alocar memória não inicializada Stack.
; A linguagem C precisa de uma Stack configurada para chamar funções e criar variáveis locais.
; ------------------------------------------------------------------------------
section .bss
align 16
stack_bottom:
    resb 16384 ; Aloca 16 KB para a pilha (stack)
stack_top:

; ------------------------------------------------------------------------------
; Seção de Texto 
; Aqui é onde a execução realmente começa depois que o GRUB passa o controle.
; ------------------------------------------------------------------------------
section .text
global _start:function (_start.end - _start) ; Define o ponto de entrada principal
extern kernel_main                           ; Avisa que essa função existe em outro arquivo 

_start:
    ; 1. Configurar a Stack
    ; O registrador 'esp' aponta para o topo da nossa pilha recém-criada.
    mov esp, stack_top

    ; 2. (Opcional) Aqui você poderia configurar a GDT, paginação, etc., antes do C.

    ; 3. Chamar o nosso Kernel em C
    push ebx
    push eax
    call kernel_main

    ; 4. Loop Infinito
    ; Se por algum motivo o kernel_main retornar,
    ; nós travamos a CPU aqui para ela não executar lixo da memória.
    cli         ; Desabilita interrupções
.hang:
    hlt         ; Coloca a CPU em estado de espera (halt)
    jmp .hang   ; Pula de volta para .hang se for acordada

.end: