/* ==============================================================================
   linker.ld - Mapa de Memória do Kernel
   ============================================================================== */

/* Define a função de entrada principal que declarámos no boot.asm */
ENTRY(_start)

/* Define a organização das secções no ficheiro executável final */
SECTIONS
{
    /* Diz ao linker para começar a colocar os dados no endereço físico de 1MB */
    . = 1M;

    /* --------------------------------------------------------------------------
       Secção de Texto
       Esta é a parte mais crítica. A secção .multiboot TEM de vir primeiro!
       -------------------------------------------------------------------------- */
    .text BLOCK(4K) : ALIGN(4K)
    {
        KEEP(*(.multiboot)) /* Garante que o cabeçalho Multiboot fica no topo */ 
        *(.text*)        /* Logo a seguir vem o teu código executável (Assembly e C) */
    }

    /* --------------------------------------------------------------------------
       Secção Read-Only Data (Dados Apenas de Leitura)
       Aqui vão ficar as tuas strings constantes, como o nome do kernel 
       ou a mensagem de boas-vindas.
       -------------------------------------------------------------------------- */
    .rodata BLOCK(4K) : ALIGN(4K)
    {
        *(.rodata*)
    }

    /* --------------------------------------------------------------------------
       Secção de Dados (Dados Inicializados)
       Variáveis globais em C que já têm um valor atribuído na declaração.
       -------------------------------------------------------------------------- */
    .data BLOCK(4K) : ALIGN(4K)
    {
        *(.data*)
    }

    /* --------------------------------------------------------------------------
       Secção BSS (Dados Não Inicializados e Stack)
       Aqui é onde a stack que definiste no boot.asm vai viver na memória RAM.
       -------------------------------------------------------------------------- */
    .bss BLOCK(4K) : ALIGN(4K)
    {
        *(COMMON)
        *(.bss*)
    }

    _end = .;
    
    /* Nota: O alinhamento de 4K (4096 bytes) é o tamanho padrão de uma página 
       de memória na arquitetura x86. Isso vai facilitar muito a vida no futuro,
       quando decidires implementar paginação (Paging) e proteção de memória. */
}