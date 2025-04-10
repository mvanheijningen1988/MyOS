/*
 * This is a simple bootloader for x86 architecture.
 * It switches to protected mode and loads a kernel into memory.
 * Created by Michael van Heijningen on 2025/03/29.
 */

#include "boot/i386/data.h"
#include "boot/i386/memory.h"
#include "boot/i386/boot.h"

.file "boot.S"                          # This is the source file name
.text                                   # This is the text section where the code resides
.code16                                 # This is a 16-bit code segment
.globl start, _start                    # Entry point for the bootloader

start:
_start:
    cli                                 # Clear interrupts
    xor %bx, %bx                        # Clear AX register
    mov %bx, %es                        # Set extra segment to 0
    mov %bx, %ss                        # Set stack segment to 0
    mov %bx, %ds                        # Set data segment to 0x0500 
    mov %dl, MEMORY_BOOT_DRIVE_ADDRESS  # set boot drive number to memory location 0x0500
    mov $BOOT_SECTOR_START, %sp         # Set up stack (grows downward from load address)
    sti                                 # Enable interrupts

.load_next_stage:
    mov $CONVENTIONAL_MEM2_START, %bx   # Set buffer address to load the kernel
    mov next_stage_sector_size, %ah     # BIOS function: read sectors
    mov $0x01, %al                      # Number of sectors to read
    mov $0x00, %ch                      # Cylinder number
    mov next_stage_sector_start, %cl    # Sector number
    mov $0x00, %dh                      # Head number
    mov MEMORY_BOOT_DRIVE_ADDRESS, %dl  # Boot drive number

    int $0x13                           # Call BIOS interrupt

    jc .error                           # If carry flag is set, there was an error
    
    cmp $0x01, %al                      # Check if the number of sectors read is 0
    jne .error                          # If so, jump to error

    jmp CONVENTIONAL_MEM2_START         # Jump to the loaded kernel
.error:
    jmp halt                            # Jump to halt if there was an error

halt:
    hlt                                 # Halt the CPU
    jmp halt                            # Infinite loop to prevent further execution

.fill 508-(.-_start), 1, 0              # Add zeroes to make it total 512 bytes

next_stage_sector_start: .byte 0x02
next_stage_sector_size: .byte 0x01

.word BOOTLOADER_SIGNATURE              # Magic bytes that tell BIOS that this is bootable