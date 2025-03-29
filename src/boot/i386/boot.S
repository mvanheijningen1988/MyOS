.code16                     # This is a 16-bit code segment
.global _start              # Entry point for the bootloader

_start:         
    mov $0x0E, %ah          # BIOS teletype function
    mov $'x', %al           # character to print
    int $0x10               # BIOS interrupt to print character in AL
    jmp .                   # infinite loop to keep the program running

.fill 510-(.-_start), 1, 0  # add zeroes to make it 510 bytes long 
.word 0xaa55                # magic bytes that tell BIOS that this is bootable
