# ==============================================================================
# Makefile - Automação de Compilação do Kernel
# ==============================================================================

# Compiladores e Flags
AS = nasm
# O ideal para OS Dev é usar um cross-compiler (i686-elf-gcc).
CC = i686-elf-gcc 
CFLAGS = -std=gnu99 -ffreestanding -O2 -Wall -Wextra
LDFLAGS = -T linker.ld -ffreestanding -O2 -nostdlib -lgcc

# Diretórios
BUILD_DIR = build
ISO_DIR = iso
SRC_DIR = src

# Arquivos Finais
BIN = $(BUILD_DIR)/meu_os.bin
ISO = meu_os.iso

# Alvos que não são arquivos físicos
.PHONY: all clean run iso

# O alvo padrão (quando você digita apenas 'make')
all: iso

# 1. Compilar o Assembly
$(BUILD_DIR)/boot.o: $(SRC_DIR)/boot/boot.asm
	mkdir -p $(BUILD_DIR)
	$(AS) -f elf32 $< -o $@

# 2. Compilar o C
$(BUILD_DIR)/kernel.o: $(SRC_DIR)/kernel/kernel.c
	mkdir -p $(BUILD_DIR)
	$(CC) -c $< -o $@ $(CFLAGS)

# 3. Linkar tudo no arquivo binário final
$(BIN): $(BUILD_DIR)/boot.o $(BUILD_DIR)/kernel.o
	$(CC) $(LDFLAGS) $^ -o $@

# 4. Gerar a ISO bootável
iso: $(BIN)
	mkdir -p $(ISO_DIR)/boot/grub
	cp $(BIN) $(ISO_DIR)/boot/
	cp grub.cfg $(ISO_DIR)/boot/grub/
	grub-mkrescue -o $(ISO) $(ISO_DIR)

# 5. Executar no emulador
run: iso
	qemu-system-i386 -cdrom $(ISO)

# 6. Limpar a sujeira (Unificado!)
clean:
	rm -rf $(BUILD_DIR) $(ISO_DIR) $(ISO)