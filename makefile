# x86_64-elf-as --32 -o boot.o src/boot/i386/boot.S
# x86_64-elf-ld -m elf_i386 -Ttext 0x7c00 --oformat binary -o boot.bin boot.o

AS = x86_64-elf-as
#AS = as
ASFLAGS = --32 -I ./include
LD = x86_64-elf-ld
#LD = ld
LDFLAGS = -m elf_i386
CC = x86_64-elf-gcc
#CC = gcc
CFLAGS = -m32 -ffreestanding -c -g -I ./include
CPP = x86_64-elf-cpp
#CPP = cpp
CPPFLAGS = -I ./src/include
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

stage1-5.o: src/boot/i386/stage1-5.S
	$(AS) $(ASFLAGS) -o build/$@ $<

stage1-5.bin: stage1-5.o
	$(LD) $(LDFLAGS) -Ttext 0x7e00 --oformat binary -o out/$@ build/$<

hd.img: boot.bin stage1-5.bin
	dd if=/dev/zero of=out/$@ bs=512 count=2880
	mkfs.ext2 -v out/$@
	dd if=out/$< of=out/$@ conv=notrunc
	dd if=out/$(word 2, $^) of=out/$@ conv=notrunc seek=1

run: hd.img
	qemu-system-i386 -drive format=raw,file=out/$<,if=ide --monitor stdio

debug: boot.bin
	qemu-system-i386 -drive format=raw,file=out/$<,if=ide -s -S

clean:
	rm -rdf build out
	mkdir build out
	