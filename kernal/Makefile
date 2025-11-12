AS = nasm
LD = ld

ASFLAGS = -f elf32
LDFLAGS = -m elf_i386 -T linker.ld
 

SRC_DIR = src
BUILD_DIR = build
ISO_DIR = isodir

OBJECTS = $(BUILD_DIR)/boot_header.o \
           $(BUILD_DIR)/kernel.o \
           $(BUILD_DIR)/gdt.o \
           $(BUILD_DIR)/idt.o \
           $(BUILD_DIR)/isr.o \
           $(BUILD_DIR)/irq.o \
           $(BUILD_DIR)/io.o \
           $(BUILD_DIR)/vga.o \
           $(BUILD_DIR)/keyboard.o \
           $(BUILD_DIR)/mem.o
 

KERNEL = $(BUILD_DIR)/kernel.bin
 

ISO = kernel.iso
 
PHONY: all clean run
 
all: $(ISO)
 

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)


$(BUILD_DIR)/%.o: $(SRC_DIR)/%.asm | $(BUILD_DIR)
	$(AS) $(ASFLAGS) $< -o $@


$(KERNEL): $(OBJECTS)
	$(LD) $(LDFLAGS) -o $@ $(OBJECTS)


$(ISO): $(KERNEL)
	mkdir -p $(ISO_DIR)/boot/grub
	cp $(KERNEL) $(ISO_DIR)/boot/kernel.bin
	cp grub.cfg $(ISO_DIR)/boot/grub/grub.cfg
	grub-mkrescue -o $(ISO) $(ISO_DIR)
 

clean:
	rm -rf $(BUILD_DIR) $(ISO_DIR) $(ISO)


run: $(ISO)
	qemu-system-i386 -cdrom $(ISO)


debug: $(ISO)
	qemu-system-i386 -cdrom $(ISO) -s -S
