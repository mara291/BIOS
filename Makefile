ASM = nasm
GCC = i386-elf-gcc
LD = i386-elf-ld

AFLAGS = -f bin
CFLAGS = -ffreestanding -m32 -g -c

all: kernel.bin

boot.bin: boot.asm
	$(ASM) boot.asm $(AFLAGS) -o obj/boot.bin

kernel_entry.o: kernel_entry.asm
	$(ASM) kernel_entry.asm -f elf -o obj/kernel_entry.o 

kernel.o:
	$(GCC) $(CFLAGS) kernel.c -o obj/kernel.o

kernel_full.bin: kernel_entry.o kernel.o
	$(LD) -o obj/kernel_full.bin -T linker.ld obj/kernel_entry.o obj/kernel.o --oformat binary
	
kernel.bin: kernel_full.bin boot.bin 
	cat obj/boot.bin obj/kernel_full.bin > obj/kernel.bin

run: all
	qemu-system-x86_64 -drive format=raw,file="obj/kernel.bin",index=0,if=floppy, -m 128M

qemu:
	qemu-system-x86_64 -drive format=raw,file="obj/kernel.bin",index=0,if=floppy, -m 128M

clean:
	rm obj/*