# x86_64-elf-as --32 -o boot.o src/boot/i386/boot.S
# x86_64-elf-ld -m elf_i386 -Ttext 0x7c00 --oformat binary -o boot.bin boot.o

AS = x86_64-elf-as
ASFLAGS = --32
LD = x86_64-elf-ld
LDFLAGS = -m elf_i386
CC = x86_64-elf-gcc
CFLAGS = -m32 -ffreestanding -c -g -Iinclude

qemu = qemu-system-i386

# $@ = target
# $< = first dependency
# $^ = all dependencies
# $* = target without extension
# $? = newer than target
# $(@D) = target directory
# $(@F) = target file name
# $(@R) = target file name without extension
# $(@X) = target file name with extension

all: run

boot.o: src/boot/i386/boot.S
	$(AS) $(ASFLAGS) -o build/$@ $<

boot.bin: boot.o
	$(LD) $(LDFLAGS) -Ttext 0x7c00 --oformat binary -o out/$@ build/$<

run: boot.bin
	qemu-system-i386 -drive format=raw,file=out/$<

clean:
	rm -rd build out
	mkdir build out
	