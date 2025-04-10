/*
 * This is a simple bootloader for x86 architecture.
 * It is designed to load the next stage of the boot process from a specified sector on the disk.
 * This part of the boot process is run in real mode, which is a 16-bit mode of the x86 architecture.
 * Created by Michael van Heijningen on 2025/03/29.
 */

.file "boot.S"                          # This is the source file name
.text                                   # This is the text section where the code resides
.code16                                 # This is a 16-bit code segment
.globl start, _start                    # Entry point for the bootloader

.include "src/boot/i386/memory.S"
.include "src/boot/i386/constants.S"

start:
_start:
    cli                                 # Clear interrupts
    xor %bx, %bx                        # Clear AX register
    mov %bx, %es                        # Set extra segment to 0
    mov %bx, %ss                        # Set stack segment to 0
    mov %bx, %ds                        # Set data segment to 0
    mov %dl, MEMORY_BOOT_DRIVE_ADDRESS  # set boot drive number to memory location 0x0500
    mov $MEMORY_BOOT_SECTOR_OFFSET, %sp # Set up stack (grows downward from load address)
    sti                                 # Enable interrupts

.load_next_stage:
    mov $load_stage15_message, %si      # Load the message to print
    call print_string                   # Call the print_string function
    mov $MEMORY_BOOT_STAGE15_ADDRESS, %bx   # Set buffer address to load the kernel
    mov $0x02, %ah                      # BIOS function: read sectors
    mov next_stage_sector_size, %al     # Number of sectors to read
    mov $0x00, %ch                      # Cylinder number
    mov next_stage_sector_start, %cl    # Sector number
    mov $0x00, %dh                      # Head number
    mov MEMORY_BOOT_DRIVE_ADDRESS, %dl  # Boot drive number

    int $0x13                           # Call BIOS interrupt

    jc .error                           # If carry flag is set, there was an error
    
    cmp $0x01, %al                      # Check if the number of sectors read is 0
    jne .error                          # If so, jump to error

    jmp MEMORY_BOOT_STAGE15_ADDRESS     # Jump to the loaded kernel

.error:
    jmp halt                            # Jump to halt if there was an error

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

halt:
    hlt                                 # Halt the CPU
    jmp halt                            # Infinite loop to prevent further execution

load_stage15_message: .asciz "Starting MyOs bootloader...\r\n"

.fill 508-(.-_start), 1, 0              # Add zeroes to make it total 512 bytes

next_stage_sector_start: .byte 0x02
next_stage_sector_size: .byte 0x01

.word BOOT_BOOTLOADER_SIGNATURE              # Magic bytes that tell BIOS that this is bootable
