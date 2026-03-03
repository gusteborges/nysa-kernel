#include <stdint.h>
#include <stddef.h>

/* O buffer de vídeo no modo texto VGA começa no endereço físico 0xB8000 */
uint16_t* terminal_buffer = (uint16_t*) 0xB8000;

const size_t VGA_WIDTH = 80;
const size_t VGA_HEIGHT = 25;

/* Variáveis de estado do terminal (Globais para este arquivo) */
volatile uint8_t terminal_color = 0x0F;
size_t terminal_row = 0;
size_t terminal_column = 0;

/* Função para colocar um caractere em uma posição (X, Y) da tela */
void terminal_putchar(char c, size_t x, size_t y) {
    const size_t index = y * VGA_WIDTH + x;
    /* Combina o caractere (8 bits) e a cor (8 bits) em um valor de 16 bits */
    terminal_buffer[index] = (uint16_t) c | (uint16_t) terminal_color << 8;
}

/* Função básica para imprimir uma string na tela */
void terminal_print(const char* str) {
    for (size_t i = 0; str[i] != '\0'; i++) {
        
        /* Se for quebra de linha, desce um Y e zera o X */
        if (str[i] == '\n') {
            terminal_column = 0;
            terminal_row++;
            continue;
        }

        /* Imprime na posição atual guardada no estado do sistema */
        terminal_putchar(str[i], terminal_column, terminal_row);
        terminal_column++;
        
        /* Se chegar no final da linha, faz a quebra automática */
        if (terminal_column >= VGA_WIDTH) {
            terminal_column = 0;
            terminal_row++;
        }
        
        /* Proteção simples: se a tela encher, volta pro topo 
           (Num futuro, você implementará o "scroll" da tela aqui) */
        if (terminal_row >= VGA_HEIGHT) {
            terminal_row = 0; 
        }
    }
}

/* Função para limpar a tela preenchendo-a com espaços vazios */
void terminal_clear() {
    for (size_t y = 0; y < VGA_HEIGHT; y++) {
        for (size_t x = 0; x < VGA_WIDTH; x++) {
            terminal_putchar(' ', x, y);
        }
    }
    /* Fundamental: Zera o estado do cursor para o topo esquerdo! */
    terminal_row = 0;
    terminal_column = 0;
}

/* O Entry Point do C! */
void kernel_main(uint32_t magic, uint32_t multiboot_info_addr) {
    
    terminal_clear();

    if (magic != 0x2BADB002) {
        terminal_color = 0x04; /* Vermelho */
        terminal_print("ERRO FATAL: Bootloader invalido!\n");
        return; 
    }

    terminal_color = 0x0A; /* Verde */
    terminal_print("Meu Kernel C/Assembly Iniciado!\n");
    terminal_print("-------------------------------\n");
    
    terminal_color = 0x0F; /* Branco */
    terminal_print("O sistema esta operante.\n");
    terminal_print("Aguardando novas instrucoes...");
}