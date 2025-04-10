/*
 * Stage 1.5 Bootloader
 * Stage 1.5 is responsible for locating the kernel, loading it into memory and handoff control to it.
 * This part of the boot process is run in real mode, which is a 16-bit mode of the x86 architecture 
 */

#include "boot/i386/memory.h"
#include "boot/i386/boot.h"
#include "boot/i386/ext.h"

.file "strage1-5.S"
.section .text
.code16
.globl start, _start

start:
_start:

read_ext4_superblock:
    mov $MEMORY_IO_EXT_SUPERBLOCK_ADDRESS, %bx # Set buffer address to load the superblock
    mov $0x02, %ah                      # BIOS function: read sectors
    mov $BOOT_IO_EXT4_SUPERBLOCK_SECTOR_COUNT, %al # Number of sectors to read
    mov $0x00, %ch                      # Cylinder number
    mov $BOOT_IO_EXT4_SUPERBLOCK_START_SECTOR +1 , %cl # Sector number (1-based)
    mov $0x00, %dh                      # Head number
    mov MEMORY_BOOT_DRIVE_ADDRESS, %dl  # Boot drive number

    int $0x13                           # Call BIOS interrupt
    jc .error                           # If carry flag is set, there was an error
    
    cmp $BOOT_IO_EXT4_SUPERBLOCK_SECTOR_COUNT, %al # Check if the number of sectors read is 0
    jne .error                          # If so, jump to error

    pusha                               # Save all registers

    movw $EXT_MAGIC_OFFSET, %di         # Offset naar magic
    movw %es:(%bx,%di), %ax             # Lees 2 bytes vanaf ES:BX+0x38 in AX

    cmpw $EXT_MAGIC_NUMBER, %ax         # Vergelijk met ext magic
    jne .not_valid                      # Jump if not valid
    popa                                # Restore all registers

    mov $superblock_loaded_message, %si # Load the message to print
    call print_string                   # Call the print_string function


jmp .

.error:
    mov $disk_error_message, %si        # Load the message to print
    call print_string                   # Call the print_string function
    mov %ax, %bx                        # Move the error code to %al
    call print_hex_string               # Call the print_hex function
    jmp halt                            # Jump to halt if there was an error

.not_valid:
    mov $ext_magic_error_message, %si   # Load the message to print
    call print_string                   # Call the print_string function
    jmp halt                            # Jump to halt if not valid

print_string:
    pusha                               # Save all registers
    mov $0x0E, %ah                      # BIOS teletype function
.next_char:
    lodsb                               # Load the next byte from the string into %al
    or %al, %al                         # Check if the character is null (end of string)
    jz .done                            # If null, we're done
    int $0x10                           # Print the character
    jmp .next_char                      # Repeat for the next character
.done:
    popa                                # Restore all registers
    ret                                 # Return to the caller

print_hex_string:
    pusha                               # Save all registers
    mov $0x0E, %ah                      # BIOS teletype function

    # Print the "0x" prefix
    mov $'0', %al                       # Load '0' into %al
    int $0x10                           # Print '0'
    mov $'x', %al                       # Load 'x' into %al
    int $0x10                           # Print 'x'

    # Print the hexadecimal value
    mov %bx, %dx                        # Copy the value to %dx (preserve %bx)
    mov $0x04, %cx                      # Set loop counter for 4 hex digits (16 bits)

.next_digit:
    rol $0x04, %dx                      # Rotate left to bring the next nibble to the highest position
    mov %dl, %al                        # Copy the nibble to %al
    and $0x0F, %al                      # Mask out all but the lowest 4 bits
    cmp $0x0A, %al                      # Check if the nibble is >= 10
    jl .convert_to_char                 # If less than 10, it's a digit
    add $'A' - 10, %al                  # Convert to ASCII letter (A-F)
    jmp .print_char
.convert_to_char:
    add $'0', %al                       # Convert to ASCII digit (0-9)
.print_char:
    int $0x10                           # Print the character
    loop .next_digit                    # Repeat for the next nibble

    popa                                # Restore all registers
    ret                                 # Return to the caller

halt:
    hlt                                 # Halt the CPU
    jmp halt                            # Infinite loop to prevent further execution


disk_error_message: .asciz "Disk error: "
superblock_loaded_message: .asciz "Superblock loaded successfully.\r\n"
ext_magic_error_message: .asciz "Invalid EXT superblock magic number.\r\n"